class PersonMapping < ActiveRecord::Base
  belongs_to :project, foreign_key: :integration_id
  belongs_to :person

  attr_accessible :person_id, :integration_id
end
