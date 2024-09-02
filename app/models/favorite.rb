class Favorite < ApplicationRecord
  
  belongs_to :member
  belongs_to :post

  validates :member_id, uniqueness: {scope: :post_id}
  
end