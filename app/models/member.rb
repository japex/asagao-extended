class Member < ActiveRecord::Base
  include EmailAddressChecker

  before_validation :skip_validation_of_occupation_description_if_not_needed

  belongs_to :occupation
  has_one :occupation_detail, dependent: :destroy
  accepts_nested_attributes_for :occupation_detail
  has_many :entries, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :voted_entries, through: :votes, source: :entry
  has_one :image, class_name: "MemberImage", dependent: :destroy
  accepts_nested_attributes_for :image, allow_destroy: true
  has_many :member_connections, foreign_key: "follower_id", dependent: :destroy
  has_many :followees, through: :member_connections
  has_many :following_entries, through: :followees, source: :entries
  has_many :reverse_member_connections, class_name: "MemberConnection",
    foreign_key: "followee_id", dependent: :destroy
  has_many :followers, through: :reverse_member_connections

  validates :number, presence: true,
    numericality: { only_integer: true,
      greater_than: 0, less_than: 100, allow_blank: true },
    uniqueness: true
  validates :name, presence: true,
    format: { with: /\A[A-Za-z]\w*\z/, allow_blank: true,
              message: :invalid_member_name },
    length: { minimum: 2, maximum: 20, allow_blank: true },
    uniqueness: { case_sensitive: false }
  validates :full_name, length: { maximum: 20 }
  validate :check_email
  validates :password, presence: { on: :create },
    confirmation: { allow_blank: true }

  attr_accessor :password, :password_confirmation

  def password=(val)
    if val.present?
      self.hashed_password = BCrypt::Password.create(val)
    end
    @password = val
  end

  def votable_for?(entry)
    entry && entry.author != self && !votes.exists?(entry_id: entry.id)
  end

  def destroy_unnecessary_occupation_detail
    occupation_detail.try(:destroy) unless occupation.needs_description
  end

  private
  def check_email
    if email.present?
      errors.add(:email, :invalid) unless well_formed_as_email_address(email)
    end
  end

  def skip_validation_of_occupation_description_if_not_needed
    if occupation && !occupation.needs_description
      occupation_detail.skips_validations_for_description = true
    end
    true
  end

  class << self
    def search(query)
      rel = order("number")
      if query.present?
        rel = rel.where("name LIKE ? OR full_name LIKE ?",
          "%#{query}%", "%#{query}%")
      end
      rel
    end

    def authenticate(name, password)
      member = find_by(name: name)
      if member && ((member.hashed_password.present? &&
        BCrypt::Password.new(member.hashed_password) == password) ||
        (Rails.env == 'development' && password == 'p'))
        member
      else
        nil
      end
    end
  end
end
