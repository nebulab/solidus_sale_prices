module SolidusSalePrices
  module Spree
    module Product
      module Base
        def self.prepended(base)
          base.has_many :sale_prices, through: :prices

          # Essentially all read values here are delegated to reading the value on the Master variant
          # All write values will write to all variants (including the Master) unless that method's all_variants parameter is
          # set to false, in which case it will only write to the Master variant.

          base.delegate :active_sale_in,
                        :current_sale_in,
                        :next_active_sale_in,
                        :next_current_sale_in,
                        :sale_price_in,
                        :on_sale_in?,
                        :original_price_in,
                        :discount_percent_in,
                        :on_sale?,
                        :discount_percent, :discount_percent=,
                        :sale_price, :sale_price=,
                        :original_price, :original_price=,
                        to: :master
        end

        # TODO also accept a class reference for calculator type instead of only a string
        def put_on_sale(value, params = {}, selected_variants = [])
          all_variants = params[:all_variants] || true
          run_on_variants(all_variants, selected_variants) { |v| v.put_on_sale(value, params) }
          self.touch
        end

        alias :create_sale :put_on_sale

        def enable_sale(all_variants = true)
          run_on_variants(all_variants) { |v| v.enable_sale }
          self.touch
        end

        def disable_sale(all_variants = true)
          run_on_variants(all_variants) { |v| v.disable_sale }
          self.touch
        end

        def start_sale(end_time = nil, all_variants = true)
          run_on_variants(all_variants) { |v| v.start_sale(end_time) }
          self.touch
        end

        def stop_sale(all_variants = true)
          run_on_variants(all_variants) { |v| v.stop_sale }
          self.touch
        end

        private

        def run_on_variants(all_variants, selected_variants = [], &block)
          if selected_variants.present?
            scope = variants_including_master
            scope = scope.where(id: selected_variants) if selected_variants.present?
            scope.each { |v| block.call v }
          else
            if all_variants && variants.present?
              variants.each { |v| block.call v }
            end
            block.call master
          end
        end
      end
    end
  end
end
