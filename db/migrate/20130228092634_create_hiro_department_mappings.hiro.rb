# This migration comes from hiro (originally 20130220042019)
class CreateHiroDepartmentMappings < ActiveRecord::Migration
  def change
    create_table :hiro_department_mappings do |t|
      t.integer :harvest_department_id
      t.string :harvest_department_name, limit: 50
      t.string :xero_department_mapping, limit: 50
    end

    Hiro::DepartmentMapping.create(harvest_department_name:'DI01 - Engineers' ,xero_department_mapping:'Engineers')
    Hiro::DepartmentMapping.create(harvest_department_name:'DI02 - Project Managers' ,xero_department_mapping:'Project Managers')
    Hiro::DepartmentMapping.create(harvest_department_name:'DI03 - Designers' ,xero_department_mapping:'Designers')
    Hiro::DepartmentMapping.create(harvest_department_name:'DI04 - Architects' ,xero_department_mapping:'Architects')
    Hiro::DepartmentMapping.create(harvest_department_name:'OH01 - Board' ,xero_department_mapping:'Board')
    Hiro::DepartmentMapping.create(harvest_department_name:'OH02 - General Affairs' ,xero_department_mapping:'General Affairs')
    Hiro::DepartmentMapping.create(harvest_department_name:'OH03 - Finance' ,xero_department_mapping:'Finance')
    Hiro::DepartmentMapping.create(harvest_department_name:'OH04 - HR' ,xero_department_mapping:'HR')
    Hiro::DepartmentMapping.create(harvest_department_name:'OH05 - Admin' ,xero_department_mapping:'Admin')
  end
end
