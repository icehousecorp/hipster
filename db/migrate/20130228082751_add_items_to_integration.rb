class AddItemsToIntegration < ActiveRecord::Migration
  def change
    add_column :integrations, :project_name, :string
    add_column :integrations, :client_id, :integer
    add_column :integrations, :client_name, :string
    add_column :integrations, :harvest_project_code, :string
    add_column :integrations, :harvest_billable, :string
    add_column :integrations, :harvest_budget, :string
    add_column :integrations, :pivotal_start_iteration, :string
    add_column :integrations, :pivotal_start_date, :string
  end
end
