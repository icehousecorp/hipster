class HomeController < ApplicationController
  def index
    if current_user
      if params[:code]
        # raise params.inspect
        token = harvest_api.token(params[:code], root_url)
        current_user.harvest_token = token.token
        current_user.harvest_refresh_token = token.refresh_token
        current_user.save
        flash[:notice] = 'harvest setting verified'
      end
      redirect_to projects_path
    end
  end

  def logout
  	session.delete(:user_id)
  	redirect_to root_url
  end

  def google_oauth2
  	auth_hash = request.env['omniauth.auth'].to_hash
  	identity = Identity.where(provider: 'google_oauth2', uid: auth_hash['uid']).first
  	if identity && identity.user_id
      user = identity.user
      # user.update_attributes(email: auth_hash['info']['email'])
      redirect_to projects_path
	  	# redirect_to user_path(identity.user_id)
  	else
  		user = User.from_googleauth(auth_hash)
  		identity = Identity.create(provider: 'google_oauth2', uid: auth_hash['uid'], user_id: user.id)
  		puts 'creating new user'
  		puts identity.user_id
  		puts user.errors.inspect
	  	redirect_to edit_user_path(identity.user_id)
  	end
  	session[:user_id] = identity.user_id
  end
end
