class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.integer :pivotal_id
      t.string :pivotal_token
      t.string :harvest_subdomain
      t.string :harvest_identifier
      t.string :harvest_secret
      t.integer :harvest_id
      t.string :harvest_token
      t.string :harvest_refresh_token
      t.timestamps
    end
  end
end
