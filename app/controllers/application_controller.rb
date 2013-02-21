class ApplicationController < ActionController::Base
  protect_from_forgery

  after_filter :close_connection
  helper_method :current_user

  def current_user
  	@current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
    @current_user
  end

  def harvest_api
    @harvest_api ||= Api::HarvestClient.new(current_user)
  end

  def pivotal_api
    @pivotal_api ||= Api::PivotalClient.new(current_user)
  end

  def close_connection
  	ActiveRecord::Base.connection.close unless ActiveRecord::Base.connection.blank?
  end
end
