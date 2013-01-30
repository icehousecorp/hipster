class PersonMapping < ActiveRecord::Base
  belongs_to :integration
  attr_accessible :email, :harvest_id, :pivotal_name
end
