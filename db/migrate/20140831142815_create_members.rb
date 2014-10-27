class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members, id: :uuid do |t|
      t.string     :slug,                      null: false,  index: true
      t.string     :email,                     null: false,  index: true
      t.string     :salt,                      null: false
      t.string     :fish,                      null: false
      t.string     :password_reset_code,                     index: true
      t.timestamp  :password_reset_expires_at,               index: true
      t.integer    :title,                     null: false,                 default: 2
      t.string     :name_given,                null: false
      t.string     :name_family,               null: false
      t.date       :born_on,                   null: false
      t.string     :nationality_code,                        index: true
      t.string     :country_code,                            index: true
      t.text       :street_address,            null: false
      t.string     :city,                      null: false
      t.string     :postal_code,               null: false
      t.string     :occupation
      t.integer    :sectors,                                                default: [],   array: true
      t.string     :phone,                     null: false
      t.string     :mobile
      t.string     :website_url
      t.integer    :notice
      t.boolean    :will_relocate,             null: false,                 default: false
      t.integer    :current_status,            null: false
      t.integer    :experience,                null: false
      t.boolean    :hide_born_on,              null: false,                 default: false
      t.boolean    :hide_status,               null: false,                 default: false
      t.boolean    :is_public,                                              default: true
      t.attachment :photo
      t.timestamp  :deleted_at,                              index: true

      t.timestamps
    end

    add_index :members, :slug,                unique: true
    add_index :members, :email,               unique: true
    add_index :members, :password_reset_code, unique: true
  end
end
