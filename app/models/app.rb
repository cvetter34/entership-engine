class App < ActiveRecord::Base
  belongs_to :member
  belongs_to :job

  default_scope { order( status: :asc ) }

  before_create :set_link_code

  enum ok_status: [ :approved, :pending, :declined ]

  def self.content_types
    {
      content_type: [
        "application/pdf",
        "text/plain",
        "text/rtf",
        "application/vnd.oasis.opendocument.text",
        "application/vnd.oasis.opendocument.spreadsheet",
        "application/vnd.oasis.opendocument.presentation",
        "application/vnd.oasis.opendocument.graphics",
        "application/vnd.ms-excel",
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "application/vnd.ms-powerpoint",
        "application/vnd.openxmlformats-officedocument.presentationml.presentation",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      ]
    }
  end

  has_attached_file :cv
  has_attached_file :doc_one
  has_attached_file :doc_two
  has_attached_file :doc_three
  has_attached_file :doc_four

  validates :status, presence: true

  validates_associated :member, :job

  validates_attachment :cv, :doc_one, :doc_two, :doc_three, :doc_four,
    content_type: App.content_types

  def title_with_company
    "#{self.job.title} (#{self.job.company.name})"
  end

  def title_with_member
    "#{self.member.name} (#{self.job.title})"
  end

  def name
    [ self.name_given, self.name_family ].compact.join(" ")
  end

  def nationality
    self.nationality_code.blank? ? "" : ISO3166::Country[self.nationality_code]
  end

  def country
    self.country_code.blank? ? "" : ISO3166::Country[self.country_code]
  end

  def work_permit_detail_as_html
    Kramdown::Document.new(self.work_permit_detail).to_html.html_safe
  end

  def comments_as_html
    Kramdown::Document.new(self.comments).to_html.html_safe
  end

  def personal_statement_as_html
    Kramdown::Document.new(self.personal_statement).to_html.html_safe
  end

  def is_open?
    self.status == App.ok_statuses[:pending]
  end

  def is_approved?
    self.status == App.ok_statuses[:approved]
  end

  def is_declined?
    self.status == App.ok_statuses[:declined]
  end

  private

  def set_link_code
    self.link_code = SecureRandom.urlsafe_base64
  end
end
