module SolidusSalePrices
  module Spree
    module PriceDecorator
      def self.prepended(base)
        base.has_many :sale_prices, dependent: :destroy
        base.has_many :active_sale_prices, -> { merge(::Spree::SalePrice.active) }, class_name: '::Spree::SalePrice'
        base.after_save :update_calculated_sale_prices
        base.after_discard do
          sale_prices.discard_all
        end
      end

      def update_calculated_sale_prices
        reload
        sale_prices.each(&:update_calculated_price!)
      end

      def put_on_sale(value, params = {})
        new_sale(value, params).save
      end

      def new_sale(value, params = {})
        sale_price_params = {
          value: value,
          start_at: params.fetch(:start_at, Time.now),
          end_at: params.fetch(:end_at, nil),
          enabled: params.fetch(:enabled, true),
          calculator: params.fetch(:calculator_type, ::Spree::Calculator::FixedAmountSalePriceCalculator.new)
        }
        return sale_prices.new(sale_price_params)
      end

      # TODO make update_sale method

      def active_sale
        first_sale(active_sale_prices) if on_sale?
      end
      alias :current_sale :active_sale

      def next_active_sale
        first_sale(sale_prices) if sale_prices.present?
      end
      alias :next_current_sale :next_active_sale

      def sale_price
        active_sale.calculated_price if on_sale?
      end

      def sale_price=(value)
        if on_sale?
          active_sale.update_attribute(:value, value)
        else
          put_on_sale(value)
        end
      end

      def discount_percent
        return 0.0 unless original_price > 0
        return 0.0 unless on_sale?
        (1 - (sale_price / original_price)) * 100
      end

      def on_sale?
        return false unless (first_active_sale_calculated_price = first_sale(active_sale_prices)&.calculated_price)

        first_active_sale_calculated_price < original_price
      end

      def original_price
        self[:amount]
      end

      def original_price=(value)
        self[:amount] = ::Spree::LocalizedNumber.parse(value)
      end

      def price
        on_sale? ? sale_price : original_price
      end

      def price=(price)
        if on_sale?
          sale_price = price
        else
          self[:amount] = ::Spree::LocalizedNumber.parse(price)
        end
      end

      def amount
        price
      end

      def enable_sale
        next_active_sale.enable if next_active_sale.present?
      end

      def disable_sale
        active_sale.disable if active_sale.present?
      end

      def start_sale(end_time = nil)
        next_active_sale.start(end_time) if next_active_sale.present?
      end

      def stop_sale
        active_sale.stop if active_sale.present?
      end

      private
      def first_sale(scope)
        scope.order("created_at DESC").first
      end

      ::Spree::Price.prepend self
    end
  end
end
