class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.integer :harvest_id
      t.string :harvest_email
      t.string :harvest_name
      t.integer :pivotal_id
      t.string :pivotal_email
      t.string :pivotal_name

      t.timestamps
    end
  end
end
