class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, except: [:destroy]
  before_action :require_no_authentication, only: [:new, :create]

  def new
    @providers = SocialAccount::AVAILABLE_PROVIDERS
  end

  def create
    @user = User.find_by(email: params[:email])
    # authenticate is a method provided by bcrypt gem; it returns either true or false
    if @user && @user.authenticate(params[:password])
      sign_in @user
      flash[:success] = "Welcome"
      redirect_to root_path
    else
      # This flash message should be visible only once, when we render the page, not after the reloading
      # of the page
      flash.now[:exceptions] = "Login and/or password is incorrect."
      render 'new'
    end
  end

  def destroy
    sign_out
    flash[:success] = "See you!"
    redirect_to new_session_path
  end
end
