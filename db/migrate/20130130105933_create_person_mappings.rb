class CreatePersonMappings < ActiveRecord::Migration
  def change
    create_table :person_mappings do |t|
      t.integer :harvest_id
      t.string :harvest_email
      t.string :harvest_name

      t.integer :pivotal_id
      t.string :pivotal_email
      t.string :pivotal_name

      t.references :integration
      t.timestamps
    end
    add_index :person_mappings, :integration_id
  end
end
