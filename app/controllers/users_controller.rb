class UsersController < ApplicationController

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(session[:user_id]|| params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(session[:user_id]|| params[:id])
  end

  def validate_pivotal_token
    return true unless @user.pivotal_token_changed?
    @current_user = @user
    pivotal_api.all_projects
    rescue => e 
      puts current_user.inspect
      puts e.inspect
      nil
  end

  def confirm_harvest
    redirect_to harvest_api.authorize_url(root_url)
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(session[:user_id]|| params[:id])
    @user.assign_attributes(params[:user])
    need_harvest_login = @user.harvest_subdomain_changed? || @user.harvest_identifier_changed? || @user.harvest_secret_changed?
    if validate_pivotal_token() && @user.save
      puts "user is valid"
      puts need_harvest_login
      if need_harvest_login
        redirect_to harvest_api.authorize_url(root_url)
      else
        redirect_to @user, notice: 'User was successfully updated.'
      end
    else
      @error = 'Wrong pivotal token.' if @user.pivotal_token_changed?
      render action: "edit"
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(session[:user_id]|| params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
end
