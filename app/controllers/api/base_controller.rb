module Api
  class BaseController < ApplicationController
    # Pular verificação CSRF para API
    skip_before_action :verify_authenticity_token
    before_action :authenticate_user!
    
    # Responder apenas JSON
    before_action :set_default_format
    
    # Tratamento de erros
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
    rescue_from JWT::DecodeError, with: :unauthorized
    
    private
    
    def set_default_format
      request.format = :json
    end
    
    def authenticate_user!
      token = request.headers['Authorization']&.split(' ')&.last
      
      if token
        begin
          decoded_token = decode_token(token)
          @current_user = User.find(decoded_token['user_id'])
        rescue JWT::DecodeError => e
          unauthorized
        rescue ActiveRecord::RecordNotFound
          unauthorized
        end
      else
        unauthorized
      end
    end

    def current_user
      @current_user
    end
    
    def decode_token(token)
      JWT.decode(token, Rails.application.secret_key_base, true, algorithm: 'HS256').first
    end
    
    def not_found(exception)
      render json: { error: exception.message }, status: :not_found
    end
    
    def unprocessable_entity(exception)
      render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
    end
    
    def unauthorized
      render json: { error: 'Não autorizado. Token inválido ou expirado.' }, status: :unauthorized
    end
    
    def pagination_dict(collection)
      {
        current_page: collection.current_page,
        next_page: collection.next_page,
        prev_page: collection.prev_page,
        total_pages: collection.total_pages,
        total_count: collection.total_count
      }
    end
  end
end  
