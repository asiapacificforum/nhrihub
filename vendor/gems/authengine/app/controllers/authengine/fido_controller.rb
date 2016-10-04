class Authengine::FidoController < ApplicationController
  skip_before_action :check_permissions, :only => [:challenge_request]

  def challenge_request
    respond_to do |format|
      # user on the login page requests by ajax a challenge that they will
      # sign to prove posession of the private key, corresponding with the
      # public key associated with the account. User is selected
      # using the username and password supplied
      format.json do
        key_handle, challenge = generate_challenge
        if @failed_challenge_message.present?
          render :plain => @failed_challenge_message, :status => 406
        else
          render :json => U2F::SignRequest.new(key_handle, challenge, APPLICATION_ID), :status => 200
        end
      end
    end
  end

private

  # TODO should be a class method on User model
  def generate_challenge
    if login = params[:login] # the normal login procedure
      User.find_and_generate_challenge(login)
    elsif password_reset_code = params[:password_reset_code] # password reset procedure
      user = User.find_by_password_reset_code(password_reset_code)
      user.generate_challenge
      user
    end
  rescue User::AuthenticationError => message
    @failed_challenge_message = message
  end

end
