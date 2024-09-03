class PostTag < ApplicationRecord
  
  # アソシエーション
  belongs_to :post
  belongs_to :tag
  
end