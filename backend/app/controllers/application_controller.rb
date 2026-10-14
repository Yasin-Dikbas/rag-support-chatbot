class ApplicationController < ActionController::API
  before_action :authenticate_request!

  rescue_from ActionController::ParameterMissing do |e|
    render json: { error: e.message }, status: :bad_request
  end

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "Not found" }, status: :not_found
  end

  attr_reader :current_user

  private

  def authenticate_request!
    header = request.headers["Authorization"]
    token = header&.split(" ")&.last
    decoded = token && JsonWebToken.decode(token)

    @current_user = decoded && User.find_by(id: decoded[:user_id])

    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
  end
end
