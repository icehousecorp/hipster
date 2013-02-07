class HomeController < ApplicationController
  def index
  end

  def callback
	raise env['omniauth.auth'].inspect
  end
end
