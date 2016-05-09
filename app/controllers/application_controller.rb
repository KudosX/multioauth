class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  private

  def authenticate_user!
    # user has to be authenticated
    redirect_to new_session_path unless user_signed_in?
  end

  def require_no_authentication
    # user has to be NOT authenticated
    redirect_to root_path if current_user
  end

  def sign_in(user)
    session[:user_id] = user.id
    @current_user = user
  end

  def user_signed_in?
    !current_user.nil?
  end

  def current_user
    # We either return a previously set @current_user variable or
    # assign value now
    session[:user_id] ? @current_user ||= User.find_by(id: session[:user_id]) : nil
  end

  def sign_out
    session.delete(:user_id)
    @current_user = nil
  end

  # These methods should be available in the views as well
  helper_method :current_user, :user_signed_in?
end



