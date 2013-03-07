class RemoveItemsFromPersonMapping < ActiveRecord::Migration
  def up
    remove_column :person_mappings, :harvest_id
    remove_column :person_mappings, :harvest_name
    remove_column :person_mappings, :harvest_email
    remove_column :person_mappings, :pivotal_id
    remove_column :person_mappings, :pivotal_name
    remove_column :person_mappings, :pivotal_email

    add_column :person_mappings, :person_id, :integer
    add_index :person_mappings, :person_id
  end

  def down
    add_column :person_mappings, :harvest_id, :string
    add_column :person_mappings, :harvest_name, :string
    add_column :person_mappings, :harvest_email, :string
    add_column :person_mappings, :pivotal_id, :string
    add_column :person_mappings, :pivotal_name, :string
    add_column :person_mappings, :pivotal_email, :string
  end
end
