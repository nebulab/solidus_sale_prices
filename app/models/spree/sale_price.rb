module Spree
  class SalePrice < ActiveRecord::Base

    if ::Spree.solidus_gem_version >= Gem::Version.new('2.11')
      include Spree::SoftDeletable
    else
      include SolidusSalePrices::SoftDelete
    end

    belongs_to :price, class_name: "Spree::Price", touch: true
    belongs_to :price_with_deleted, -> { with_discarded }, class_name: "Spree::Price", foreign_key: :price_id

    delegate :currency, :currency=, to: :price, allow_nil: true

    has_one :variant, through: :price_with_deleted
    has_one :product, through: :variant

    has_one :calculator, class_name: "Spree::Calculator", as: :calculable, dependent: :destroy
    validates :calculator, :price, presence: true
    accepts_nested_attributes_for :calculator

    before_save :compute_calculated_price

    scope :ordered, -> { order(Arel.sql('start_at IS NOT NULL, start_at ASC')) }
    scope :active, -> { where(enabled: true).where('(start_at <= ? OR start_at IS NULL) AND (end_at >= ? OR end_at IS NULL)', Time.now, Time.now) }

    # TODO make this work or remove it
    #def self.calculators
    #  Rails.application.config.spree.calculators.send(self.to_s.tableize.gsub('/', '_').sub('spree_', ''))
    #end

    def self.for_product(product)
      ids = product.variants_including_master
      ordered.where(price_id: Spree::Price.where(variant_id: ids))
    end

    def calculator_type
      calculator.class.to_s if calculator
    end

    def enable
      update_attribute(:enabled, true)
    end

    def disable
      update_attribute(:enabled, false)
    end

    def active?
      Spree::SalePrice.active.include? self
    end

    def start(end_time = nil)
      end_time = nil if end_time.present? && end_time <= Time.now # if end_time is not in the future then make it nil (no end)
      attr = { end_at: end_time, enabled: true }
      attr[:start_at] = Time.now if self.start_at.present? && self.start_at > Time.now # only set start_at if it's not set in the past
      update(attr)
    end

    def stop
      update({ end_at: Time.now, enabled: false })
    end

    # Convenience method for displaying the price of a given sale_price in the table
    def display_price
      Spree::Money.new(value || 0, { currency: price.currency })
    end

    def update_calculated_price!
      save!
    end

    private

    def compute_calculated_price
      self.calculated_price = calculator.compute self
    end
  end
end
