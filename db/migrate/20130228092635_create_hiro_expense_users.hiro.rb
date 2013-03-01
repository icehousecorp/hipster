# This migration comes from hiro (originally 20130221011702)
class CreateHiroExpenseUsers < ActiveRecord::Migration
  def change
    create_table :hiro_expense_users do |t|
      t.string :expense_id
      t.integer :user_id
      t.string :name
      t.string :department
      t.datetime :date_period
      t.datetime :last_day_period
      t.datetime :spent_at_expense
      t.string :description
      t.string :currency
      t.float :unit_price
      t.string :project_id
      t.string :project_name
      t.string :category_expense
      t.boolean :invoiced, default:false
      
      t.timestamps
    end
  end
end

