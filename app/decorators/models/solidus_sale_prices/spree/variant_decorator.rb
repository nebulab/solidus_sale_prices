# frozen_string_literal: true

module SolidusSalePrices
  module Spree
    module VariantDecorator
      extend ActiveSupport::Concern

      included do
        has_many :sale_prices, through: :prices

        delegate :on_sale?,
                 :sale_price, :sale_price=,
                 :original_price, :original_price=,
                 :discount_percent, :discount_percent=,
                 to: :default_price
      end

      def put_on_sale(value, params = {})
        currencies = params.fetch(:currencies, [])
        if params[:currency].present?
          currencies << params[:currency] unless currencies.include? params[:currency]
        end
        run_on_prices(currencies) { |p| p.put_on_sale value, params }
      end

      alias :create_sale :put_on_sale

      # TODO make update_sale method

      def active_sale_in(currency)
        price_in(currency).active_sale
      end

      alias :current_sale_in :active_sale_in

      def next_active_sale_in(currency)
        price_in(currency).next_active_sale
      end

      alias :next_current_sale_in :next_active_sale_in

      def sale_price_in(currency)
        ::Spree::Price.new variant_id: self.id, currency: currency, amount: price_in(currency).sale_price
      end

      def discount_percent_in(currency)
        price_in(currency).discount_percent
      end

      def on_sale_in?(currency)
        price_in(currency).on_sale?
      end

      def original_price_in(currency)
        ::Spree::Price.new variant_id: self.id, currency: currency, amount: price_in(currency).original_price
      end

      def enable_sale(currencies = nil)
        run_on_prices(currencies) { |p| p.enable_sale }
      end

      def disable_sale(currencies = nil)
        run_on_prices(currencies) { |p| p.disable_sale }
      end

      def start_sale(end_time = nil, currencies = nil)
        run_on_prices(currencies) { |p| p.start_sale end_time }
      end

      def stop_sale(currencies = nil)
        run_on_prices(currencies) { |p| p.stop_sale }
      end

      private

      # runs on all prices or on the ones with the currencies you've specified
      def run_on_prices(currencies = nil, &block)
        if currencies.present? && currencies.any?
          prices_with_currencies = prices.select { |p| currencies.include?(p.currency) }
          prices_with_currencies.each { |p| block.call p }
        else
          prices.each { |p| block.call p }
        end
      end
    end
  end
end

::Spree::Variant.include SolidusSalePrices::Spree::VariantDecorator
