class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps, id: :uuid do |t|
      t.integer    :status,                            index: true,   default: 1
      t.string     :name_given,          null: false
      t.string     :name_family,         null: false
      t.integer    :age
      t.string     :nationality_code,                  index: true
      t.string     :country_code,                      index: true
      t.string     :phone,               null: false
      t.string     :email,               null: false
      t.text       :comments
      t.text       :personal_statement
      t.boolean    :has_right_to_work,                                default: false
      t.boolean    :has_work_permit,                                  default: false
      t.text       :work_permit_detail
      t.uuid       :member_id,                          index: true
      t.uuid       :job_id,                             index: true
      t.attachment :cv
      t.attachment :doc_one
      t.attachment :doc_two
      t.attachment :doc_three
      t.attachment :doc_four
      t.string     :link_code,                          index: true

      t.timestamps
    end
  end
end
