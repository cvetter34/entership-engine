class CreateRegistrants < ActiveRecord::Migration
  def change
    create_table :registrants, id: :uuid do |t|
      t.string    :email,                null:false,  index: true
      t.string    :sign_up_code,         null:false,  index: true
      t.timestamp :sign_up_expires_at,   null:false,  index: true
      t.boolean   :is_company,           null:false,  index: true,  default: false

      t.timestamps
    end

    add_index :registrants, :email,        unique: true
    add_index :registrants, :sign_up_code, unique: true
  end
end
