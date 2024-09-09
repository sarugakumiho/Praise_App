class Post < ApplicationRecord
    
  # アソシエーション
  belongs_to :member
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags
  has_many :favorites, dependent: :destroy
  has_many :post_comments, dependent: :destroy
  
  # バリデーション
  validates :title, presence: true, length: { maximum: 30 }
  validates :memo, length: { maximum: 100 }
  validates :situation_status, presence: true
  validates :post_status, presence: true
  
  # いいねボタン設定
  def favorited_by?(member)
    favorites.exists?(member_id: member.id)
  end
  
  # enum設定
  enum situation_status: { from_now: 0, accomplished: 1 }
  enum post_status: { unpublished: 0, published: 1 }
  
  # 投稿画像設定
  has_one_attached :image
  
  def get_image
    unless image.attached?
      file_path = Rails.root.join('app/assets/images/no_image.jpg')
      image.attach(io: File.open(file_path), filename: 'default-image.jpg', content_type: 'image/jpeg')
    end
    image
  end
  
end