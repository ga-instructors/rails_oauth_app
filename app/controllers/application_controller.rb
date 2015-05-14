class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def current_user_client
    @current_user_client ||= Github.new(oauth_token: session[:access_token])
  end

  def current_user_api_data
    @current_user_api_data ||= current_user_client.get_request("user").to_hash
  end

  def logged_in?
    current_user.present?
  end

  helper_method :current_user, :current_user_client, 
                :current_user_api_data, :logged_in?
end
