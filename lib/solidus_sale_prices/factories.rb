module SolidusSalePrices::Factories; end

FactoryBot.define do
  # Define your Spree extensions Factories within this file to enable applications, and other extensions to use and override them.
  #
  # Example adding this to your spec_helper will load these Factories for use:
  # require 'spree_sale_prices/factories'

  factory :sale_price, class: Spree::SalePrice do
    value { 10.90 }
    start_at { nil }
    end_at { nil }
    enabled { false }
    calculator { Spree::Calculator::FixedAmountSalePriceCalculator.new }
    association :price, factory: :international_price

    factory :active_sale_price do
      start_at { Time.now }
      enabled { true }
    end
  end

  factory :international_price, parent: :price do
    currency { Money::Currency.all.map(&:iso_code).sample }
  end

  factory :eur_price, parent: :price do
    currency { 'EUR' }
  end

  factory :usd_price, parent: :price do
    currency { 'USD' }
  end

  factory :multi_price_variant, parent: :variant do
    after(:create) do |variant, _evaluator|
      create(:eur_price, variant: variant)
      create(:usd_price, variant: variant)
    end
  end
end
