class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :pivotal_id
      t.string :pivotal_username
      t.string :pivotal_password
      t.string :harvest_subdomain
      t.integer :harvest_id
      t.string :harvest_username
      t.string :harvest_password

      t.timestamps
    end
  end
end
