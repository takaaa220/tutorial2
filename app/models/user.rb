class User < ApplicationRecord
  before_save { downcase }
  validates :name, { presence: true, uniqueness: true, length: { maximum: 50} }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i # 大文字スタートは定数
  validates :email, { presence: true, uniqueness: { case_sensitive: false } ,
    length: { maximum: 255}, format: { with: VALID_EMAIL_REGEX } }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }


  private

    def downcase
      self.email.downcase!
    end

end
