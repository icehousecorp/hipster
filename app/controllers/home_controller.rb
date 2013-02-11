class HomeController < ApplicationController
  def index
  	redirect_to user_path(session[:user_id]) if session[:user_id]
  end

  def logout
  	session.delete(:user_id)
  	redirect_to root_url
  end

  def harvest
    auth_hash = env['omniauth.auth'].to_hash
	# render text: env['omniauth.auth'].to_hash.inspect
    if session[:user_id]
      user = User.find(session[:user_id])
      user.harvest_token = auth_hash['credentials']['token']
      user.save
      redirect_to user, notice: 'success updating harvest credentials'
    end
  end

  def google_oauth2
  	auth_hash = request.env['omniauth.auth'].to_hash
  	identity = Identity.where(provider: 'google_oauth2', uid: auth_hash['uid']).first
  	if identity && identity.user_id
	  	redirect_to user_path(identity.user_id)
  	else
  		user = User.from_googleauth(auth_hash)
  		identity = Identity.create(provider: 'google_oauth2', uid: auth_hash['uid'], user_id: user.id)
  		puts 'creating new user'
  		puts identity.user_id
  		puts user.errors.inspect
	  	redirect_to edit_user_path(identity.user_id)
  	end
  	session[:user_id] = identity.user_id

	# render text: request.env['omniauth.auth'].to_hash.inspect
  end
end
