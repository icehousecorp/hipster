class Integration < ActiveRecord::Base
  belongs_to :user
  attr_accessible :harvest_project_id, :pivotal_project_id, :user_id
  validates :harvest_project_id, :uniqueness => { :scope => :pivotal_project_id, message: 'has been mapped' }
end
