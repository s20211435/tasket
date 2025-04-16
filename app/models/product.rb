class Product < ApplicationRecord
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :description, presence: true

  def self.ransackable_attributes(auth_object = nil)
    %w[name price stock description]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[category]
  end

  def to_s
    name
  end
end
