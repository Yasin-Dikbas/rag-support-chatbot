module Api
  class SessionsController < ApplicationController
    skip_before_action :authenticate_request!, only: :create

    # POST /api/login
    def create
      user = User.find_by(email: params[:email].to_s.strip.downcase)

      if user&.authenticate(params[:password])
        token = JsonWebToken.encode(user_id: user.id)
        render json: { token: token, user: { id: user.id, email: user.email } }
      else
        render json: { error: "Invalid email or password" }, status: :unauthorized
      end
    end

    # GET /api/me
    def show
      render json: { id: current_user.id, email: current_user.email }
    end
  end
end
