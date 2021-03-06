class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship",
      foreign_key: "follower_id", dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship",
      foreign_key: "followed_id", dependent: :destroy

  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  has_many :likes, dependent: :destroy
  has_many :shares, dependent: :destroy

  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :downcase_email
  before_create :create_activation_digest

  # VALID_NAME_REGEX = /\A(?!.*\s).*\z/u
  VALID_NAME_REGEX = /\A[\w-]+\z/
  validates :name, { presence: true, uniqueness: true,
    length: { maximum: 50}, format: { with: VALID_NAME_REGEX }}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i # 大文字スタートは定数
  validates :email, { presence: true, uniqueness: { case_sensitive: false } ,
    length: { maximum: 255}, format: { with: VALID_EMAIL_REGEX } }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # ハッシュ値 return
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # return random token
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # remember token for parmanent session
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # compare digest on database with token
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def activate
    update_attributes(activated: true, activated_at: Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_attributes(reset_digest: User.digest(reset_token),
                        reset_sent_at: Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago # 2時間より前ならTrue
  end

  # followしている人のツイートとリツイート，リツイートしたツイート，自分のツイートをFeedとする
  def feed
    # self_and_following_ids = ":user_id, (SELECT followed_id FROM relationships
    #                 WHERE follower_id = :user_id)"
    # self_and_following_retweets_ids = "SELECT micropost_id FROM shares WHERE user_id IN (#{self_and_following_ids})"
    Micropost.including_replies(id).or(Micropost.where("user_id IN (#{get_self_and_following_ids})
            OR id IN (#{get_self_and_following_retweets_ids})", user_id: id))
  end

  def follow(other_user)
    following << other_user
  end

  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  def following?(other_user)
    following.include?(other_user)
  end

  def likes
    post_ids = "SELECT micropost_id FROM likes WHERE user_id = :user_id"
    Micropost.where("id IN (#{post_ids})", user_id: id)
  end

  # user.microposts を user.get_microposts に代用して，リツイートした投稿も含める
  def get_microposts
    # self_and_following_ids = ":user_id, (SELECT followed_id FROM relationships
    #                 WHERE follower_id = :user_id)"
    # self_and_following_retweets_ids = "SELECT micropost_id FROM shares WHERE user_id IN (#{self_and_following_ids})"
    Micropost.where("user_id = :user_id OR id IN (#{get_self_and_following_retweets_ids})", user_id: id)
  end

  private

    def downcase_email
      self.email.downcase!
    end

    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end

    def get_self_and_following_ids
      ":user_id, (SELECT followed_id FROM relationships WHERE follower_id = :user_id)"
    end

    def get_self_and_following_retweets_ids
      "SELECT micropost_id FROM shares WHERE user_id IN (#{get_self_and_following_ids})"
    end
end
