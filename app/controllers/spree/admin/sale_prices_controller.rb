module Spree
  module Admin
    class SalePricesController < BaseController
      before_action :load_product
      before_action :validate_price_ids, only: %i[new create]

      respond_to :html
      respond_to :js, only: :destroy

      def index
        @sale_prices = Spree::SalePrice.for_product(@product).ordered
      end

      def create
        selected_prices.each do |p|
          p.put_on_sale(sale_price_params[:value], sale_price_params)
        end
        @product.touch

        redirect_to admin_product_sale_prices_path(@product)
      end

      def destroy
        @sale_price = Spree::SalePrice.find(params[:id])
        @sale_price.discard
        render_js_for_destroy
      end

      private

      def load_product
        @product = Spree::Product.find_by(slug: params[:product_id])
        redirect_to request.referer unless @product.present?
      end

      def validate_price_ids
        return if params[:price_ids].present?

        flash[:error] = I18n.t('spree.put_on_sale_requires_prices')
        redirect_to admin_product_sale_prices_path(@product)
      end

      def selected_prices
        Spree::Price.find(params[:price_ids].split)
      end

      def sale_price_params
        params.require(:sale_price).permit(:value, :start_at, :end_at)
      end
    end
  end
end
