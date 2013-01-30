class Integration < ActiveRecord::Base
  belongs_to :user
  attr_accessible :harvest_project_id, :pivotal_project_id
end
