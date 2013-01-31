class CreateIntegrations < ActiveRecord::Migration
  def change
    create_table :integrations do |t|
      t.integer :harvest_project_id
      t.string :harvest_project_name
      t.integer :pivotal_project_id
      t.string :pivotal_project_name
      t.references :user

      t.timestamps
    end
    add_index :integrations, :user_id
  end
end
