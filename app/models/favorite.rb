class Favorite < ApplicationRecord
  
  # アソシエーション
  belongs_to :member
  belongs_to :post
  
  # バリデーション
  validates :member_id, uniqueness: {scope: :post_id}
  
end