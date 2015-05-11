class SessionsController < ApplicationController
  def new
    render :new
  end

  def create
    # find if any user has that email
    user = User.find_by(email: params[:email])
    
    # if that user exists and it has a password that was sent
    if user && user.authenticate(params[:password])
      
      # save the user_id in the session hash
      session[:user_id] = user.id

      # and redirect to that user's home page
      redirect_to users_path
    else
      # the email/password is wrong!
      @message = "This email and password combination does not exist."
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end