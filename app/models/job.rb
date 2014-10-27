class Job < ActiveRecord::Base

  scope :active,     -> { joins(:company).where("companies.deleted_at" => nil, "companies.is_vetted" => true, :expired_on => nil) }

  scope :verified,   -> { where( is_verified: true  ) }
  scope :unverified, -> { where( is_verified: false ) }

  scope :visible,    -> { active.where( is_verified: true  ) }
  scope :hidden,     -> { active.where( is_verified: false ) }

  attr_accessor :mine

  belongs_to :company

  has_many :apps, dependent: :destroy

  monetize :salary_cents, with_model_currency: :salary_currency,
    as: :salary, allow_nil: true

  before_save :set_verification_code

  enum ok_contract_type: [
    "Full Time",
    "Part Time",
    "Project",
    "Internship"
  ]

  enum ok_experience_level: [
    "Less than 2 years",
    "2 to 5 years",
    "5 to 10 years",
    "10 to 20 years",
    "20 years or more"
  ]

  enum ok_frequency: [ :year, :month, :week, :day, :hour ]

  def self.currencies
    hkd = []
    out = Money::Currency.table.map do |k,v|
      hkd << [ "#{v[:name]} (#{v[:iso_code]})", v[:iso_code] ] if v[:iso_code] == "HKD"
      [ "#{v[:name]} (#{v[:iso_code]})", v[:iso_code] ]
    end.compact.sort { |a,b| a[0] <=> b[0] }
    hkd + out
  end

  def self.find_by_code(code)
    Job.find_by verification_code: code
  end

  validates :title, :contract_type, :sector, :country_code,
    :email, presence: true
  validates :job_reference, uniqueness: { scope: :company }, allow_blank: true

  validates :num_positions, :salary_cents, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }

  validates_associated :company

  def description_as_html
    Kramdown::Document.new(self.description).to_html.html_safe
  end

  def responsibilities_as_html
    Kramdown::Document.new(self.responsibilities).to_html.html_safe
  end

  def ideal_candidate_as_html
    Kramdown::Document.new(self.ideal_candidate).to_html.html_safe
  end

  def expire_now
    self.expired_on = Date.today
    self.save
  end

  def is_open?
    self.expired_on.blank?
  end

  def country
    self.country_code.blank? ? "" : ISO3166::Country[self.country_code]
  end

  def request_verification
    self.is_verified = false
    self.verification_code = SecureRandom.urlsafe_base64
    self.save
  end

  def verify
    self.is_verified = true
    self.verification_code = nil
    self.save
  end

  def open_apps
    self.apps.select {|a| a.is_open? }
  end

  def has_apps?
    not self.apps.empty?
  end

  def has_open_apps?
    not self.open_apps.empty?
  end

  private

  def set_verification_code
    unless self.is_verified
      self.verification_code = SecureRandom.urlsafe_base64
    end
  end

  def set_salary
    self.currency = Money.new(self.salary_amount * 100, self.currency) unless self.salary_amount.blank?
  end
end
