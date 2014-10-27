class Member < ActiveRecord::Base
  extend FriendlyId

  default_scope { where(:deleted_at => nil) }

  scope :showing, -> { where(:is_public => true)  }
  scope :hidden,  -> { where(:is_public => false) }

  friendly_id :slug_candidates, :use => [:slugged, :finders]

  def slug_candidates
    [
      :name,
      [:name, :birth_year],
      [:name, :birth_month, :birth_year],
      [:name, :birth_day, :birth_month, :birth_year]
    ]
  end

  enum ok_title:[ "Dr.", "Miss", "Mr.", "Mrs.", "Ms." ]

  enum ok_sector: [
    "Chartering & Broking",
    "Executive Positions",
    "Finance & Accounts",
    "HR & Admin",
    "Legal",
    "Marine Insurance and P&I",
    "Operations & Ship Management",
    "PR, Publishing & Research",
    "Sales & Marketing",
    "Technical",
    "Trading & Agency"
  ]

  enum ok_notice: [
    "Less than 1 week",
    "Between 1 week and 1 month",
    "Between 1 month and 3 months",
    "More than 3 months"
  ]

  enum ok_status: [
    "Looking for all types of work",
    "Looking for contract work",
    "Looking for full time work",
    "Looking for part time work",
    "Not looking for another job just yet",
    "Open to new opportunities"
  ]

  enum ok_experience: [
    "Student (Higher Education/Graduate)",
    "Entry Level",
    "Manager (Manager/Supervisor of Staff)",
    "Experienced (Non-manager)",
    "Executive (Director, Department Head)",
    "Senior Executive (Chairman, MD, CEO)"
  ]

  has_many :apps, dependent: :destroy
  has_many :contacts, dependent: :destroy

  has_attached_file :photo,
    styles: {
      original: '600x800>',
      small:    '120x180',
      medium:   '240x360'
    }

  TIME_TO_COMPLETE_PASSWORD_RESET = 1.day

  attr_accessor :password, :password_confirmation

  before_validation :remove_http
  before_create :set_random_password, unless: :password
  before_save :encrypt_password, if: :password
  before_save :downcase_attributes

  validate :must_be_eighteen, unless: "born_on.nil?"

  validates :email, :title, :name_given, :name_family, :born_on,
    :street_address, :city, :postal_code, :phone, :current_status,
    :experience, presence: true
  validates :slug, :email, uniqueness: { case_sensitive: false }
  validates :password, confirmation: true
  validates :nationality_code, :country_code,
    inclusion: { in: Company.country_codes }

  validates_attachment :photo, content_type: {
    content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"]
  }

  def has_apps?
    !self.apps.empty?
  end

  def has_pending_apps?
    !self.apps.where( status: App.ok_statuses[:pending] ).empty?
  end

  def name
    [ self.name_given, self.name_family ].compact.join(" ")
  end

  def full_name
    [ Member.ok_titles.to_a[self.title][0], self.name ].compact.join(" ")
  end

  def age
    unless self.born_on.nil?
      now = Time.now.utc.to_date
      dob = self.born_on
      now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
    end
  end

  def street_address_as_html
    Kramdown::Document.new(self.street_address).to_html.html_safe
  end

  def self.nullify_expired_password_reset_codes
    Member.where(
      "password_reset_expires_at < ?", Time.now.gmtime
    ).update_all(
      "password_reset_code = NULL, password_reset_expires_at = NULL"
    )
  end

  def self.find_by_code(code)
    Member.nullify_expired_password_reset_codes

    if member = Member.find_by(
        "password_reset_code = ? AND password_reset_expires_at >= ?",
        code, Time.now.gmtime
      )
      member.set_password_reset_expiration
    end

    member
  end

  def self.authenticate(email, password)
    member = Member.find_by email: email.downcase
    member if member and member.authenticate(password)
  end

  def authenticate(password)
    self.fish == BCrypt::Engine.hash_secret(password, self.salt)
  end

  def set_password_reset_code
    self.password_reset_code = SecureRandom.urlsafe_base64
    set_password_reset_expiration
  end

  def set_password_reset_expiration
    self.password_reset_expires_at = TIME_TO_COMPLETE_PASSWORD_RESET.from_now
    self.save
  end

  def reset_password(member_params)
    if member_params[:password].blank?
      self.errors.add :password, "can't be blank"
      return false
    else
      self.update_attributes(member_params.merge({
        password_reset_code: nil,
        password_reset_expires_at: nil
      }))
    end
  end

  def nationality
    self.nationality_code.blank? ? "" : ISO3166::Country[self.nationality_code]
  end

  def country
    self.country_code.blank? ? "" : ISO3166::Country[self.country_code]
  end

  def website
    self.website_url.sub( /^www\./, "" )
  end

  private

  def remove_http
    unless self.website_url.blank? or self.website_url[0..3].downcase != "http"
      uri = Addressable::URI.parse(self.website_url)

      if uri.host.nil?
        self.website_url = nil
      elsif uri.path.length > 1 or (!uri.query.nil? or !uri.fragment.nil?)
        self.website_url = [
          uri.host, uri.path, uri.query, uri.fragment
        ].compact.join("")
      else
        self.website_url = uri.host
      end
    end
  end

  def must_be_eighteen
    if born_on.present? && born_on > (Date.today - 18.years)
      errors[:base] << "You must be at least 18 years of age to use this site."
    end
  end

  def birth_year
    self.born_on.blank? ? 0 : self.born_on.year
  end

  def birth_month
    self.born_on.blank? ? 0 : self.born_on.month
  end

  def birth_day
    self.born_on.blank? ? 0 : self.born_on.day
  end

  def downcase_attributes
    self.email.downcase!
  end

  def set_salt
    self.salt = BCrypt::Engine.generate_salt
  end

  def encrypt_password
    self.fish = BCrypt::Engine.hash_secret(password, set_salt)
  end

  def set_random_password
    if self.fish.blank?
      self.fish = BCrypt::Engine.hash_secret(SecureRandom.base64(32), set_salt)
    end
  end
end
