# frozen_string_literal: true

# This module implements functionality found in Solidus 3.1 as an intermediate bridge between earlier versions of Solidus.
# This should updated and deprecated as Solidus versions 2.11, and 3.0 are no longer supported.
module SolidusSalePrices
  module PriceMethod
    def self.price_for_options(variant, currency, country_iso = nil)
      options = ::Spree::Config.pricing_options_class.new(currency: currency,
        country_iso: country_iso)
      price_search(variant, options)
    end

    def self.price_search(variant, options)
      variant.currently_valid_prices.detect do |price|
        (price.country_iso == options.desired_attributes[:country_iso] ||
         price.country_iso.nil?
        ) && price.currency == options.desired_attributes[:currency]
      end
    end
  end
end
