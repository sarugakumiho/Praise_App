class Tag < ApplicationRecord
  
  # アソシエーション
  has_many :post_tags, dependent: :destroy, foreign_key: 'tag_id'
  has_many :posts, through: :post_tags
  
  # バリデーション
  validates :tag_name, length: { maximum: 10 }, uniqueness: true
  
end