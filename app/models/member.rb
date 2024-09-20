class Member < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  # ゲストログイン（アカウント自動生成）
  GUEST_MEMBER_EMAIL = "guest@example.com"
  
  def self.guest
    find_or_create_by!(email: GUEST_MEMBER_EMAIL) do |member|
      member.password = SecureRandom.urlsafe_base64
      member.name = "ゲスト"
    end
  end
  
  def guest_member?
    email == GUEST_MEMBER_EMAIL
  end
  
  # アソシエーション
  has_many :posts, dependent: :destroy
  has_many :post_comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  has_many :followers, through: :passive_relationships, source: :follower
  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :followings, through: :active_relationships, source: :followed

  # フォローする
  def follow(member)
    active_relationships.create(followed_id: member.id)
  end
  
  # フォロー解除する
  def unfollow(member)
    active_relationships.find_by(followed_id: member.id).destroy
  end

  # フォローしているか確認
  def following?(member)
    followings.include?(member)
  end
  
  # バリデーション
  validates :name, length: { minimum: 1, maximum: 20 }, uniqueness: true
  validates :introduction, length: { maximum: 150 }
  validates :email, length: { maximum: 300 },
                  format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: "は正しい形式で入力してください。" }
  validates :password, length: { minimum: 6, message: "は6文字以上で入力してください" }, if: -> { password.present? }
  
  # 検索機能（分岐）設定
  def self.search_for(content, method)
    if method == "perfect"
      Member.where(name: content)
    elsif method == "forward"
      Member.where("name LIKE ?", content + "%")
    elsif method == "backward"
      Member.where("name LIKE ?", "%" + content)
    else
      Member.where("name LIKE ?", "%" + content + "%")
    end
  end
  
  # アイコン画像設定
  has_one_attached :profile_image
  
  def get_profile_image(width, height)
    unless profile_image.attached?
      file_path = Rails.root.join('app/assets/images/no_image.jpg')
      profile_image.attach(io: File.open(file_path), filename: 'default-image.jpg', content_type: 'image/jpeg')
    end
    profile_image.variant(resize_to_fit: [width, height]).processed
  end
  
end