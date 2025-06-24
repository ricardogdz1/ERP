module Api
  module V1
    class ProductsController < Api::BaseController
      before_action :set_product, only: [:show, :update, :destroy]
      
      # GET /api/v1/products
      def index
        @products = Product.includes(:inventories)
                          .page(params[:page])
                          .per(params[:per_page] || 20)
        
        # Filtros opcionais
        @products = @products.where(is_active: true) if params[:active_only] == 'true'
        @products = @products.where(is_service: false) if params[:products_only] == 'true'
        @products = @products.where('name ILIKE ?', "%#{params[:search]}%") if params[:search].present?
        @products = @products.where(category: params[:category]) if params[:category].present?
        
        render json: {
          products: @products,
          meta: pagination_dict(@products)
        }
      end
      
      # GET /api/v1/products/1
      def show
        render json: @product
      end
      
      # POST /api/v1/products
      def create
        @product = Product.new(product_params)
        
        if @product.save
          render json: @product, status: :created
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # PATCH/PUT /api/v1/products/1
      def update
        if @product.update(product_params)
          render json: @product
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/products/1
      def destroy
        @product.destroy
        head :no_content
      end
      
      private
      
      def set_product
        @product = Product.find(params[:id])
      end
      
      def product_params
        params.require(:product).permit(
          :name, :description, :sku, :barcode, :category,
          :unit_of_measure, :cost_price, :sale_price,
          :minimum_stock, :current_stock, :maximum_stock,
          :net_weight, :gross_weight, :dimensions, :brand,
          :supplier_code, :location, :expiration_date,
          :is_active, :is_service, :requires_stock_control
        )
      end
    end
  end
end