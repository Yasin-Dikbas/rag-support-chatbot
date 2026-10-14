module Api
  class RegistrationsController < ApplicationController
    skip_before_action :authenticate_request!, only: :create

    # POST /api/signup
    def create
      user = User.new(user_params)

      if user.save
        token = JsonWebToken.encode(user_id: user.id)
        render json: { token: token, user: user_json(user) }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.permit(:email, :password)
    end

    def user_json(user)
      { id: user.id, email: user.email }
    end
  end
end
