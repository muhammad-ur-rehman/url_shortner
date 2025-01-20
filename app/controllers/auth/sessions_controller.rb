class Auth::SessionsController < ApplicationController
  skip_before_action :authenticate_user

  def signup
    user = User.new(user_params)

    if user.save
      token = Jwt::Encode.encode(user_id: user.id)
      render json: { jwt: token }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def create
    user = User.find_by_email(params[:email])

    if user&.valid_password?(params[:password])
      token = Jwt::Encode.encode(user_id: user.id)
      render json: { jwt: token }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
