class Food < ApplicationRecord
  validates_presence_of :title, :address
  belongs_to :user
  has_many :cart_foods,dependent: :destroy
  has_many :carts, through: :cart_foods

  has_many :order_items
  geocoded_by :address, latitude: :lat, longitude: :lng
  after_validation :geocode
  # --------------------------------------callback---------------------
  # --------------------------------------dirty object
end
