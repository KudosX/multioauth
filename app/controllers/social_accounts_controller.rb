class SocialAccountsController < ApplicationController
  skip_before_action :authenticate_user!, except: [:destroy]
  # We have to check the owner. If the requested account does not belong to the
  # currently logged in user, do nothing.
  before_action :check_owner!, only: [:destroy]

  def create
    begin
      # go ahead and try to create a new social account or find an existing one
      # note that current_user may return nil
      @social_account = SocialAccount.from_omniauth(request.env['omniauth.auth'], current_user)
        # We rescue from the error that is raised when we do not have enough information about the user
    rescue RecordNotFound
      # Store the authentication hash in the session - we will require it a bit later
      session[:auth_hash] = request.env['omniauth.auth'].except('extra', 'credentials')
      flash[:success] = "Please provide some more data..."
      # Redirect to another page with a form to provide additional data
      redirect_to additional_info_social_accounts_path and return
    end
    # Otherwise we take the associated user and sign him in (unless he is already signed in)
    sign_in(@social_account.user) unless current_user
    redirect_to edit_user_path(@social_account.user)
  end

  def additional_info
    # If authentication hash is not set, we just redirect to the root page
    # We require this hash to proceed
    redirect_to root_path unless session[:auth_hash]
    # This hash will be used to build a form
    @auth_hash = session[:auth_hash]
  end

  def finalize
    # Fetch the provided e-mail and find or set a new user
    @user = User.find_or_initialize_by(email: params[:email])
    # If the user was not found in the database, it will be marked as a new record (meaning that it is not yet saved)
    if !@user.new_record?
      # If the user WAS found, we have to check that the correct password was entered
      # This is done to prevent malicious users from logging in via accounts they do not own
      redirect_to root_path and return unless @user.authenticate(params[:password])
    else
      # If the user was not found, we have to set a password for him
      @user.password = params[:password]
      @user.password_confirmation = params[:password]
      # If @user.save returned false, it means that some incorrect data were provided
      render 'additional_info' and return unless @user.save
    end
    # Now just try to create social_account again - this time it should be successful, because we do
    # have a user account now
    @social_account = SocialAccount.from_omniauth(session.delete(:auth_hash), @user)
    # Lastly, sign him in
    sign_in @social_account.user
    redirect_to edit_user_path(@social_account.user)
  end

  def destroy
    @social_account.destroy
    redirect_to edit_user_path(@social_account.user)
  end

  private

  def check_owner!
    @social_account = SocialAccount.find_by(id: params[:id])
    redirect_to root_path unless @social_account && current_user.social_accounts.include?(@social_account)
  end
end