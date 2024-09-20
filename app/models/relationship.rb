class Relationship < ApplicationRecord
  
  # アソシエーション
  belongs_to :follower, class_name: "Member"
  belongs_to :followed, class_name: "Member"
  
end