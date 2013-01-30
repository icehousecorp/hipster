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

ActiveRecord::Schema.define(:version => 20130130105933) do

  create_table "integrations", :force => true do |t|
    t.integer  "harvest_project_id"
    t.integer  "pivotal_project_id"
    t.integer  "user_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "integrations", ["user_id"], :name => "index_integrations_on_user_id"

  create_table "person_mappings", :force => true do |t|
    t.integer  "harvest_id"
    t.string   "email"
    t.string   "pivotal_name"
    t.integer  "integration_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "person_mappings", ["integration_id"], :name => "index_person_mappings_on_integration_id"

  create_table "users", :force => true do |t|
    t.integer  "pivotal_id"
    t.string   "pivotal_username"
    t.string   "pivotal_password"
    t.string   "harvest_subdomain"
    t.integer  "harvest_id"
    t.string   "harvest_username"
    t.string   "harvest_password"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

end
