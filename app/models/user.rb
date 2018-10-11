class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token
  before_save :downcase_email
  before_create :create_activation_digest

  validates :name, { presence: true, uniqueness: true, length: { maximum: 50} }
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

  private

    def downcase_email
      self.email.downcase!
    end

    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
