class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]
  before_action :require_no_authentication, only: [:new, :create]
  # Users cannot modify profiles they do not own
  before_action :check_owner!, only: [:edit, :update]

  def edit
    @providers = SocialAccount::AVAILABLE_PROVIDERS
  end

  def update
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "Welcome!"
      sign_in @user
      redirect_to root_path
    else
      render :new
    end
  end

  private

  def user_params
    # :password and :password_confirmation are virtual attributes - they are not being
    # stored to the database. Instead we store a hash of the password
    # Read more here
    # http://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def check_owner!
    @user = User.find_by(id: params[:id])
    redirect_to root_path unless @user && current_user == @user
  end
end
