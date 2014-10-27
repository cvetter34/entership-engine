class Contact < ActiveRecord::Base
  belongs_to :member
  belongs_to :company

  validates :subject, :body, presence: true

  def seen?
    !self.has_been_seen
  end

  def body_as_html
    Kramdown::Document.new(self.body).to_html.html_safe
  end
end
