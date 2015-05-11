class WelcomeController < ApplicationController
  def index
    redirect_to users_path if logged_in?
  end
end