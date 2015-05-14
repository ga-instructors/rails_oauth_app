class SessionsController < ApplicationController
  def new
    render :new
  end

  def create
    # use the Github instance representing the application to get an access
    # token for the user represented by their auth code
    access_token = application_client.get_token(params[:code]).token
    
    # store the access token in the current session
    session[:access_token] = access_token

    # use the Github instance representing the authenticated user to grab their
    # profile information
    user = log_in_user_with({
      oauth_uid:    current_user_api_data['id'],
      name:         current_user_api_data['name'],
      email:        current_user_api_data['email']
    })

    # and then redirect to that user's home page
    redirect_to user_path(user)
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end

  helper_method :application_client

  private
  
  # make the redirect work for any port and server, instead of hard-coding it!
  def redirect_uri
    @redirect_uri ||= root_url[0..-2] + oauth_callback_path
  end

  def application_client
    @application_client ||= Github.new(
      client_id:     ENV["GITHUB_OAUTH_ID"],
      client_secret: ENV["GITHUB_OAUTH_SECRET"]
    )
  end

  def log_in_user_with(credentials)
    # find if any user has that oauth_uid
    user = User.find_or_initialize_by(oauth_uid: credentials[:oauth_uid])
    
    # if none does, add them to the database
    if user.new_record?
      user.name  = credentials[:name]
      user.email = credentials[:email]
      user.save
    end

    # save the user_id and access token in the session hash
    session[:user_id] = user.id

    # return the user model
    user
  end
end