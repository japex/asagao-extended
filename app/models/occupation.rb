class Occupation < ActiveRecord::Base
  scope :in_display_order, -> { order(:display_order) }
end
