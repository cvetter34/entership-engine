class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs, id: :uuid do |t|
      t.string     :title,             null: false,  index: true
      t.string     :job_reference,                   index: true
      t.text       :description
      t.text       :responsibilities
      t.text       :ideal_candidate
      t.integer    :num_positions,     null: false,                 default: 1
      t.integer    :contract_type,     null: false,  index: true
      t.integer    :sector,            null: false,  index: true
      t.string     :city,                            index: true
      t.string     :country_code,      null: false,  index: true
      t.string     :postal_code,                     index: true
      t.string     :email,             null: false,  index: true
      t.integer    :experience_level
      t.money      :salary,            null: true,                  default: nil
      t.integer    :salary_frequency,                               default: Job.ok_frequencies[:month]
      t.string     :contact_person
      t.date       :posted_on,                         index: true
      t.date       :deadline_on,                       index: true
      t.date       :expired_on,                        index: true
      t.boolean    :is_verified,                       index: true, default: false
      t.string     :verification_code,                 index: true
      t.uuid       :company_id,                        index: true

      t.timestamps
    end

    add_index :jobs, [ :job_reference, :company_id ], unique: true
  end
end
