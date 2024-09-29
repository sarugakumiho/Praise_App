class Post < ApplicationRecord
  
   # ------------------------------------------------------------------------------------------------------------------
  # 投稿画像設定
  has_one_attached :image
  # ------------------------------------------------------------------------------------------------------------------
  # アソシエーション
  belongs_to :member
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags
  has_many :favorites, dependent: :destroy
  has_many :post_comments, dependent: :destroy
  # ------------------------------------------------------------------------------------------------------------------
  # バリデーション
  validates :title, presence: true, length: { maximum: 30 }
  validates :memo, length: { maximum: 100 }
  validates :situation_status, presence: true
  validates :post_status, presence: true
  validates :image, presence: true, blob: { content_type: ['image/png', 'image/jpg', 'image/jpeg'], size_range: 1..5.megabytes }
  # ------------------------------------------------------------------------------------------------------------------
  # enum設定
  enum situation_status: { from_now: 0, accomplished: 1 }
  enum post_status: { unpublished: 0, published: 1 }
  # ------------------------------------------------------------------------------------------------------------------
  # タグ設定
  def save_tag(sent_tags)
    current_tags = self.tags.pluck(:tag_name) unless self.tags.nil?  # 現在存在するタグの取得
    old_tags = current_tags - sent_tags  # 古いタグの取得
    new_tags = sent_tags - current_tags  # 新しいタグの取得
    
    old_tags.each do |old|  # 新しいタグの保存(古いタグ削除)
      self.tags.delete Tag.find_by(tag_name: old)
    end
    
    new_tags.each do |new|  # 新しいタグの保存(新しいタグをデータベースに保存)
      new_post_tag = Tag.find_or_create_by(tag_name: new)
      self.tags << new_post_tag
    end
  end
  # ------------------------------------------------------------------------------------------------------------------
  # いいねボタン設定
  def favorited_by?(member)
    favorites.exists?(member_id: member.id)
  end
  # ------------------------------------------------------------------------------------------------------------------
  # 検索機能（分岐）設定(公開されている投稿のみ検索対象)
  def self.search_for(content, method)
    if method == "perfect"
      Post.where(post_status: 'published').where(title: content)
    elsif method == "forward"
      Post.where(post_status: 'published').where("title LIKE ?", content + "%")
    elsif method == "backward"
      Post.where(post_status: 'published').where("title LIKE ?", "%" + content)
    else
      Post.where(post_status: 'published').where("title LIKE ?", "%" + content + "%")
    end
  end
  # ------------------------------------------------------------------------------------------------------------------
  # 1週間以内の投稿を取得するスコープ
  scope :from_last_week, -> { where("created_at >= ?", 1.week.ago) }
  # ------------------------------------------------------------------------------------------------------------------
  # 投稿画像設定
  def get_image
    unless image.attached?
      file_path = Rails.root.join('app/assets/images/no_image.jpg')
      image.attach(io: File.open(file_path), filename: 'default-image.jpg', content_type: 'image/jpeg')
    end
    image
  end
  # ------------------------------------------------------------------------------------------------------------------
end