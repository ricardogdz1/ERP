module Api
  module V1
    class AuthController < Api::BaseController
      skip_before_action :authenticate_user!, only: [:login]
      
      # POST /api/v1/auth/login
      def login
        user = User.find_by(name: params[:username])
        
        if user && user.authenticate(params[:password])
          token = encode_token({ user_id: user.id })
          
          render json: {
            user: {
              id: user.id,
              name: user.name,
              email: user.email,
              role: user.role
            },
            token: token,
            message: "Login realizado com sucesso"
          }, status: :ok
        else
          render json: { 
            error: "Usuário ou senha inválidos" 
          }, status: :unauthorized
        end
      end
      
      # POST /api/v1/auth/logout
      def logout
        # Token é stateless, então apenas retornamos sucesso
        render json: { 
          message: "Logout realizado com sucesso" 
        }, status: :ok
      end
      
      # GET /api/v1/auth/me
      def me
        render json: {
          user: {
            id: current_user.id,
            name: current_user.name,
            email: current_user.email,
            role: current_user.role
          }
        }, status: :ok
      end
      
      private
      
      def encode_token(payload)
        payload[:exp] = 24.hours.from_now.to_i
        JWT.encode(payload, Rails.application.secret_key_base)
      end
    end
  end
end