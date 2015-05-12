class SessionsController < ApplicationController
  def new
    render :new
  end

  def create
    # make the create token request to the identity provider
    token = request_token
    # make a second request, with the token, for the authenticated
    # user's basic information (credentials)
    credentials = get_credentials_with token
    # see if the user exists yet, and if not create them
    # then log them in
    user = log_in_user_by credentials
    # and then redirect to that user's home page
    redirect_to user_path(user)
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end

  helper_method :code_uri

  private

  GITHUB_CODE_URI  = 'https://github.com/login/oauth/authorize'
  GITHUB_TOKEN_URI = 'https://github.com/login/oauth/access_token'
  API_PROFILE_URI  = 'https://api.github.com/user'
  
  # ENV["GITHUB_OAUTH_ID"]
  # ENV["GITHUB_OAUTH_SECRET"]
  
  # make the redirect work for any port and server, instead of hard-coding it!
  def redirect_uri
    root_url[0..-2] + oauth_callback_path
  end

  def code_uri
    query_params = "?" + URI.encode_www_form({
      response_type: 'code',
      client_id:     ENV["GITHUB_OAUTH_ID"],
      redirect_uri:  redirect_uri,
      scope:         '' # the default works for GitHub
    })
    GITHUB_CODE_URI + query_params
  end

  def request_token
    response = HTTParty.post GITHUB_TOKEN_URI, {
      body: {
        :code          => params[:code],
        :client_id     => ENV["GITHUB_OAUTH_ID"],
        :client_secret => ENV["GITHUB_OAUTH_SECRET"],
        :redirect_uri  => redirect_uri,
        :grant_type    => "authorization_code"
      },
      headers: {
        'Accept' => 'application/json'
      },
      format: :json # parse the response as JSON
    }
    response['access_token']
  end

  def get_credentials_with(token)
    response = HTTParty.get API_PROFILE_URI, {
      headers: {
        'Authorization' => "token #{token}",
        'User-Agent'    => 'request'
      },
      format: :json # parse the response as JSON
    }

    return {
      access_token: token,
      oauth_uid:    response['id'],
      name:         response['name'],
      email:        response['email']
    }
  end

  def log_in_user_by(credentials)
    # find if any user has that oauth_uid
    user = User.find_or_initialize_by(oauth_uid: credentials[:oauth_uid])
    
    # if none does, add them to the database
    if user.new_record?
      user.name  = credentials[:name]
      user.email = credentials[:email]
      user.save
    end

    # save the user_id and access token in the session hash
    session[:access_token] = credentials[:token]
    session[:user_id]      = user.id

    # return the user model
    user
  end
end