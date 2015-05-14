class SessionsController < ApplicationController
  def new
    render :new
  end

  def create
    # make the create token request to the identity provider, returns an
    # OAuth2::AccessToken instance
    access_token = github_oauth_client.get_token params[:code], {
      redirect_uri: redirect_uri
    }

    # make a second request, with the token, for the authenticated
    # user's basic information (credentials)
    credentials = access_token.get('https://api.github.com/user', {
      headers: {
        'Authorization' => "token #{access_token.token}",
        'User-Agent'    => 'request'
      }
    }).parsed

    # see if the user exists yet (if not, create them) and
    # then log them in
    user = log_in_user_with({
      access_token: access_token.token,
      oauth_uid:    credentials['id'],
      name:         credentials['name'],
      email:        credentials['email']
    })

    # and then redirect to that user's home page
    redirect_to user_path(user)
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end

  helper_method :code_uri

  private
  
  # make the redirect work for any port and server, instead of hard-coding it!
  def redirect_uri
    @redirect_uri ||= root_url[0..-2] + oauth_callback_path
  end

  def github_oauth_client
    @github_oauth_client ||= OAuth2::Client.new(
      ENV["GITHUB_OAUTH_ID"], 
      ENV["GITHUB_OAUTH_SECRET"], 
      site:          'https://github.com',
      authorize_url: '/login/oauth/authorize',
      token_url:     '/login/oauth/access_token'
    ).auth_code
  end

  def code_uri
    @code_uri ||= github_oauth_client.authorize_url(
      :redirect_uri => redirect_uri,
      :scope => ''
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
    session[:access_token] = credentials[:token]
    session[:user_id]      = user.id

    # return the user model
    user
  end
end