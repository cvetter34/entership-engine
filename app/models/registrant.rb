class Registrant < ActiveRecord::Base

  TIME_TO_COMPLETE_SIGN_UP = 1.day

  before_validation :downcase_attributes, :set_code
  before_save :set_sign_up_expiration

  validates :email, :sign_up_code, :sign_up_expires_at, presence: true
  validates :email, uniqueness: { case_sensitive: false }

  def self.destroy_expired_registrants
    Registrant.where( "sign_up_expires_at < ?", Time.now.gmtime ).destroy_all
  end

  def self.find_by_code(code, is_company = false)
    Registrant.destroy_expired_registrants

    qry = "sign_up_code = ? AND sign_up_expires_at >= ? AND is_company = "
    qry += is_company ? "TRUE" : "FALSE"

    if registrant = Registrant.where( qry, code, Time.now.gmtime ).first
      registrant.save
    end

    registrant
  end

  def set_sign_up_expiration
    self.sign_up_expires_at = TIME_TO_COMPLETE_SIGN_UP.from_now
  end

  private

  def downcase_attributes
    self.email.downcase!
  end

  def set_code
    self.sign_up_code = SecureRandom.urlsafe_base64 if self.sign_up_code.blank?
    set_sign_up_expiration
  end
end
