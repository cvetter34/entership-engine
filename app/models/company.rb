class Company < ActiveRecord::Base
  extend FriendlyId

  scope :active,   -> { where(:deleted_at => nil)  }
  scope :deleted,  -> { where("deleted_at IS NOT NULL") }

  scope :expired,  ->(time) { where( "deleted_at > ?", time) }

  scope :vetted,   -> { where(:is_vetted => true)  }
  scope :unvetted, -> { where(:is_vetted => false) }

  friendly_id :slug_candidates, :use => [:slugged, :finders]

  def slug_candidates
    [
      :name,
      [:name, :country_code]
    ]
  end

  enum ok_sector: [
    "Chartering Services",
    "Logistics & Support Services",
    "Marine Surveying Services",
    "Maritime Education",
    "Maritime Insurance, Reinsurance and P & I",
    "Maritime Legal Service",
    "Port Operations",
    "Ship Broking",
    "Ship Bunkering",
    "Ship Finance",
    "Ship Management Services",
    "Ship Operator",
    "Shipowner"
  ]

  enum ok_company_type: [
    "Public Company",
    "Privately Held",
    "Partnership",
    "Self Owned"
  ]

  enum ok_company_size: [
    "1",
    "2-10",
    "11-50",
    "51-200",
    "201-500",
    "501-1000",
    "1001-5000",
    "5001-10000",
    "10001+"
  ]

  enum ok_package: [ "Cape", "Handy" ]

  has_many :jobs, dependent: :destroy
  has_many :apps, through: :jobs
  has_many :contacts

  has_attached_file :logo,
    styles: {
      original: '800x600>',
      small:    '240x80',
      medium:   '480x160'
    }

  TIME_TO_COMPLETE_PASSWORD_RESET = 1.day

  attr_accessor :password, :password_confirmation

  before_validation :remove_http
  before_create :set_random_password, unless: :password
  before_save :encrypt_password, if: :password
  before_save :downcase_attributes

  def self.country_codes
    ISO3166::Country.all.map { |country| country[1] }
  end

  validates :slug, :email, uniqueness: { case_sensitive: false }
  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :country_code }
  validates :country_code, :sectors, presence: true
  validates :country_code, inclusion: { in: Company.country_codes }
  validates :year_founded, inclusion: { in: 1730..(Date.today.year),
    message: "is not a valid year." }, allow_blank: true

  validates_attachment :logo,
    content_type: {
      content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"]
    }

  def self.nullify_expired_password_reset_codes
    Company.where(
      "password_reset_expires_at < ?", Time.now.gmtime
    ).update_all(
      "password_reset_code = NULL, password_reset_expires_at = NULL"
    )
  end

  def self.find_by_code(code)
    Company.nullify_expired_password_reset_codes

    if company = Company.find_by(
        "password_reset_code = ? AND password_reset_expires_at >= ?",
        code, Time.now.gmtime
      )
      company.set_password_reset_expiration
    end

    company
  end

  def self.authenticate(email, password)
    company = Company.find_by email: email.downcase
    company if company and company.authenticate(password)
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

  def reset_password(company_params)
    if company_params[:password].blank?
      self.errors.add :password, "can't be blank"
      return false
    else
      self.update_attributes(company_params.merge({
        password_reset_code: nil,
        password_reset_expires_at: nil
      }))
    end
  end

  def description_as_html
    Kramdown::Document.new(self.description).to_html.html_safe
  end

  def country
    self.country_code.blank? ? "" : ISO3166::Country[self.country_code]
  end

  def unvetted?
    !self.is_vetted
  end

  def toggle_vetting
    self.is_vetted = !self.is_vetted
    self.save
  end

  def website
    self.website_url.sub( /^www\./, "" )
  end

  # def apps
  #   self.jobs.map {|j| j.apps }.flatten
  # end

  def open_jobs
    jobs.select {|j| j.is_open? }
  end

  def has_jobs?
    not jobs.empty?
  end

  def has_open_apps?
    not open_jobs.empty?
  end

  def open_apps
    apps.select {|a| a.is_open? }
  end

  def has_apps?
    not apps.empty?
  end

  def has_open_apps?
    not open_apps.empty?
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
