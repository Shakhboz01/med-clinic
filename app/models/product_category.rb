# weight 1 means that Product is from local production and the combination of other packs
class ProductCategory < ApplicationRecord
  has_one_attached :image
  validates_presence_of :name
  validates_uniqueness_of :name
  has_many :products
  has_many :packs
end
