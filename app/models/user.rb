class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :books
	has_many :favorites, dependent: :destroy
	has_many :book_comments, dependent: :destroy
  attachment :profile_image, destroy: false

  validates :name, length: { minimum: 2, maximum: 20 }, uniqueness: true
  validates :introduction, length: { maximum: 50 }
  
  
  # フォローする人を取得
  has_many :follower, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  # 自分がフォローしているユーザ
  has_many :followed_users, through: :follower, source: :followed
  
  # フォローされる人を取得
  has_many :followed, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  # 自分をフォローしているユーザ
  has_many :following_users, through: :followed, source: :follower
  
  def follow(user_id)
    follower.create(followed_id: user_id)
  end
  
  def unfollow(user_id)
    follower.find_by(followed_id: user_id).destroy
  end
  
  def following?(user)
    followed_users.include?(user)
  end
  
  def self.search(search, keyword)
    if search == "perfect_match"
      @user = User.where(name: "#{keyword}")
    elsif search == "forward_match"
      @user = User.where("name LIKE?", "#{keyword}%")
    elsif search == "backward_match"
      @user = User.where("name LIKE?", "%#{keyword}")
    elsif search == "partial_match"
      @user = User.where("name LIKE?", "%#{keyword}%")
    else
      @user = User.all
    end
  end
  
end
