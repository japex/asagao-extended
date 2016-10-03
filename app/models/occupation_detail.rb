class OccupationDetail < ActiveRecord::Base
  attr_accessor :skips_validations_for_description

  validates :description, presence: true, length: {maximum: 10},
              unless: -> { skips_validations_for_description }
end
