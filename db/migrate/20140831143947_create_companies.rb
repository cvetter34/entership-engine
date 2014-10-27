class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies, id: :uuid do |t|
      t.string     :slug,                      null: false,  index: true
      t.string     :email,                     null: false,  index: true
      t.string     :salt,                      null: false
      t.string     :fish,                      null: false
      t.string     :password_reset_code,                     index: true
      t.timestamp  :password_reset_expires_at,               index: true
      t.string     :name,                      null: false,  index: true
      t.string     :package,                   null: false,  index: true
      t.string     :country_code,              null: false,  index: true
      t.integer    :sectors,                   null: false,                default: [],    array: true
      t.string     :phone,                     null: false,  index: true
      t.string     :website_url,               null: false
      t.text       :address,                   null: false
      t.text       :address_alt
      t.string     :contact_email,             null: false
      t.string     :contact_person
      t.integer    :company_type,                            index: true
      t.integer    :company_size,                            index: true
      t.string     :mobile
      t.string     :fax
      t.integer    :year_founded
      t.text       :description
      t.boolean    :is_vetted,                                             default: false
      t.attachment :logo
      t.timestamp  :deleted_at,                              index: true

      t.timestamps
    end

    add_index :companies, :slug, unique: true
    add_index :companies, [ :name, :country_code ], unique: true
  end
end
