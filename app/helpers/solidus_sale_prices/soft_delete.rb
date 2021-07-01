# frozen_string_literal :true

require 'discard'
module SolidusSalePrices
  module SoftDelete
    extend ActiveSupport::Concern

    included do
      acts_as_paranoid
      include Discard::Model
      self.discard_column = :deleted_at
  end
end
