# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130301000548) do

  create_table "hiro_account_mappings", :force => true do |t|
    t.integer "harvest_expense_category_id"
    t.string  "harvest_expense_category_name", :limit => 50
    t.string  "harvest_department_prefix",     :limit => 10
    t.integer "xero_account_code"
    t.string  "xero_account_name",             :limit => 50
  end

  create_table "hiro_expense_users", :force => true do |t|
    t.string   "expense_id"
    t.integer  "user_id"
    t.string   "name"
    t.string   "department"
    t.datetime "date_period"
    t.datetime "last_day_period"
    t.datetime "spent_at_expense"
    t.string   "description"
    t.string   "currency"
    t.float    "unit_price"
    t.string   "project_id"
    t.string   "project_name"
    t.string   "category_expense"
    t.boolean  "invoiced",         :default => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  create_table "hiro_project_mappings", :force => true do |t|
    t.integer "harvest_project_id"
    t.string  "harvest_project_name", :limit => 50
    t.string  "xero_project_name",    :limit => 50
  end

  create_table "identities", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "identities", ["user_id"], :name => "index_identities_on_user_id"

  create_table "integrations", :force => true do |t|
    t.integer  "harvest_project_id"
    t.string   "harvest_project_name"
    t.integer  "pivotal_project_id"
    t.string   "pivotal_project_name"
    t.integer  "user_id"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.string   "project_name"
    t.integer  "client_id"
    t.string   "client_name"
    t.string   "harvest_project_code"
    t.string   "harvest_billable"
    t.string   "harvest_budget"
    t.string   "pivotal_start_iteration"
  end

  add_index "integrations", ["user_id"], :name => "index_integrations_on_user_id"

  create_table "people", :force => true do |t|
    t.integer  "harvest_id"
    t.string   "harvest_email"
    t.string   "harvest_name"
    t.integer  "pivotal_id"
    t.string   "pivotal_email"
    t.string   "pivotal_name"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "person_mappings", :force => true do |t|
    t.integer  "integration_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "person_id"
  end

  add_index "person_mappings", ["integration_id"], :name => "index_person_mappings_on_integration_id"
  add_index "person_mappings", ["person_id"], :name => "index_person_mappings_on_person_id"

  create_table "task_stories", :force => true do |t|
    t.integer  "task_id"
    t.integer  "story_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.integer  "pivotal_id"
    t.string   "pivotal_token"
    t.string   "harvest_subdomain"
    t.string   "harvest_identifier"
    t.string   "harvest_secret"
    t.integer  "harvest_id"
    t.string   "harvest_token"
    t.string   "harvest_refresh_token"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

end
