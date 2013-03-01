# This migration comes from hiro (originally 20130219090537)
class CreateHiroAccountMappings < ActiveRecord::Migration
  def change
    create_table :hiro_account_mappings do |t|
      t.integer :harvest_expense_category_id
      t.string :harvest_expense_category_name, limit: 50
      t.string :harvest_department_prefix, limit: 10
      t.integer :xero_account_code
      t.string :xero_account_name, limit: 50
    end

    Hiro::AccountMapping.create(harvest_expense_category_id: 1241651, harvest_expense_category_name: 'M01 - Outpatient', harvest_department_prefix:'OH', xero_account_code:610007, xero_account_name:'Indirect Labor Medical Reimbursements')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1241651, harvest_expense_category_name: 'M01 - Outpatient', xero_account_code:510007, xero_account_name:'Direct Labor Medical Reimbursements')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1241653, harvest_expense_category_name: 'M02 - Dental', harvest_department_prefix:'OH', xero_account_code:610007, xero_account_name:'Indirect Labor Medical Reimbursements')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1241653, harvest_expense_category_name: 'M02 - Dental', xero_account_code:510007, xero_account_name:'Direct Labor Medical Reimbursements')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1241652, harvest_expense_category_name: 'M03 - Vision', harvest_department_prefix:'OH', xero_account_code:610007, xero_account_name:'Indirect Labor Medical Reimbursements')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1241652, harvest_expense_category_name: 'M03 - Vision', xero_account_code:510007, xero_account_name:'Direct Labor Medical Reimbursements')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1241656, harvest_expense_category_name: 'PR01 - Project Travel - Flights', xero_account_code:502001, xero_account_name:'Project Travel - Flights')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1241655, harvest_expense_category_name: 'PR02 - Project Travel - Local Transportation', xero_account_code:502002, xero_account_name:'Project Travel - Local Transportation')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1241654, harvest_expense_category_name: 'PR11 - Project Travel - Hotel/Accomodation', xero_account_code:502011, xero_account_name:'Project Travel - Hotel')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1243073, harvest_expense_category_name: 'PR21 - Project Travel - Food and Beverage', xero_account_code:502021, xero_account_name:'Project Travel - Food')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1243074, harvest_expense_category_name: 'PR31 - Project Travel - Per Diem', xero_account_code:502031, xero_account_name:'Project Travel - Per Diem')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1243075, harvest_expense_category_name: 'PR41 - Project Travel - Entertainment', xero_account_code:502041, xero_account_name:'Project Travel - Entertainment')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1243076, harvest_expense_category_name: 'PR51 - Project Travel - Miscellaneous', xero_account_code:502051, xero_account_name:'Project Travel - Miscellaneous')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1243077, harvest_expense_category_name: 'TR01 - General Travel - Flights', xero_account_code:612001, xero_account_name:'General Travel - Flights')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1243078, harvest_expense_category_name: 'TR02 - General Travel - Local Transportation', xero_account_code:612002, xero_account_name:'General Travel - Local Transportation')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1243079, harvest_expense_category_name: 'TR11 - General Travel - Hotel/Accomodation', xero_account_code:612011, xero_account_name:'General Travel - Hotel')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1243080, harvest_expense_category_name: 'TR21 - General Travel - Food and Beverage', xero_account_code:612021, xero_account_name:'General Travel - Food')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1243081, harvest_expense_category_name: 'TR31 - General Travel - Per Diem', xero_account_code:612031, xero_account_name:'General Travel - Per Diem')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1243082, harvest_expense_category_name: 'TR41 - Project Travel - Entertainment', xero_account_code:612041, xero_account_name:'General Travel - Entertainment')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1243083, harvest_expense_category_name: 'TR51 - Project Travel - Miscellaneous', xero_account_code:612051, xero_account_name:'General Travel - Miscellaneous')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1241656, harvest_expense_category_name: 'PR01 - Project Travel - Flights', harvest_department_prefix:'OH',  xero_account_code:502001, xero_account_name:'Project Travel - Flights')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1241655, harvest_expense_category_name: 'PR02 - Project Travel - Local Transportation', harvest_department_prefix:'OH',  xero_account_code:502002, xero_account_name:'Project Travel - Local Transportation')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1241654, harvest_expense_category_name: 'PR11 - Project Travel - Hotel/Accomodation', harvest_department_prefix:'OH',  xero_account_code:502011, xero_account_name:'Project Travel - Hotel')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1243073, harvest_expense_category_name: 'PR21 - Project Travel - Food and Beverage', harvest_department_prefix:'OH',  xero_account_code:502021, xero_account_name:'Project Travel - Food')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1243074, harvest_expense_category_name: 'PR31 - Project Travel - Per Diem', harvest_department_prefix:'OH',  xero_account_code:502031, xero_account_name:'Project Travel - Per Diem')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1243075, harvest_expense_category_name: 'PR41 - Project Travel - Entertainment', harvest_department_prefix:'OH',  xero_account_code:502041, xero_account_name:'Project Travel - Entertainment')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1243076, harvest_expense_category_name: 'PR51 - Project Travel - Miscellaneous', harvest_department_prefix:'OH',  xero_account_code:502051, xero_account_name:'Project Travel - Miscellaneous')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1243077, harvest_expense_category_name: 'TR01 - General Travel - Flights', harvest_department_prefix:'OH', xero_account_code:612001, xero_account_name:'General Travel - Flights')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1243078, harvest_expense_category_name: 'TR02 - General Travel - Local Transportation', harvest_department_prefix:'OH',  xero_account_code:612002, xero_account_name:'General Travel - Local Transportation')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1243079, harvest_expense_category_name: 'TR11 - General Travel - Hotel/Accomodation', harvest_department_prefix:'OH',  xero_account_code:612011, xero_account_name:'General Travel - Hotel')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1243080, harvest_expense_category_name: 'TR21 - General Travel - Food and Beverage', harvest_department_prefix:'OH',  xero_account_code:612021, xero_account_name:'General Travel - Food')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1243081, harvest_expense_category_name: 'TR31 - General Travel - Per Diem',  harvest_department_prefix:'OH', xero_account_code:612031, xero_account_name:'General Travel - Per Diem')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1243082, harvest_expense_category_name: 'TR41 - Project Travel - Entertainment', harvest_department_prefix:'OH',  xero_account_code:612041, xero_account_name:'General Travel - Entertainment')
    Hiro::AccountMapping.create(harvest_expense_category_id: 1243083, harvest_expense_category_name: 'TR51 - Project Travel - Miscellaneous', harvest_department_prefix:'OH',  xero_account_code:612051, xero_account_name:'General Travel - Miscellaneous')

  end
end
