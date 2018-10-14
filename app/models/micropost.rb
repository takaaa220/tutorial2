class Micropost < ApplicationRecord
  belongs_to :user
  has_many :likes, dependent: :destroy
  has_many :iine_users, through: :likes, source: :user

  default_scope -> { order(created_at: :desc) }
  # replyを含ませるためのScope
  # scope :including_replies, -> (id){ where("in_reply_to = ?
  #   OR in_reply_to = ? OR user_id = ?", id, 0, id)}
  # scope :including_replies, -> (id){ where(in_reply_to: [id, 0]).or(Micropost.where(user_id: id))}
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }

  before_save :set_in_reply_to

  # いいねする
  def iine(user)
    likes.create(user_id: user.id)
  end

  # いいねの取り消し
  def uuun(user)
    likes.find_by(user_id: user.id).destroy
  end

  # いいねしているかどうか
  def iine?(user)
    iine_users.include?(user)
  end

  # def self.including_replies(id)
  #   where("in_reply_to = ? OR in_reply_to = ? OR user_id = ?", id, 0, id)
  #   # where(in_reply_to: [id, 0]).or(Micropost.where(user_id: id))
  # end
  def Micropost.including_replies(id)
    where("in_reply_to = ?", id)
  end

  private
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB.")
      end
    end

    # ツイートからin_reply_toに値をセットする
    def set_in_reply_to
      if @index = content.index("@")
        reply_name = ""
        while /\w|-/.match(content[@index+1])
          @index += 1
          reply_name += content[@index]
        end
        self.in_reply_to = reply_to_user(reply_name)
      else
        self.in_reply_to = 0
      end
    end

    # usernameを持つUserが存在すれば，reply_to_userにuser.idをセット，
    # 存在しない場合は0をセットする
    def reply_to_user(username)
      if user = User.find_by(name: username)
        return user.id
      end
      return 0
    end
end
