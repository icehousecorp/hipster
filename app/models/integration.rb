class Integration < ActiveRecord::Base
  belongs_to :user
  has_many :person_mappings
  attr_accessible :harvest_project_id, :pivotal_project_id, :user_id
  validates :harvest_project_id, :uniqueness => { :scope => :pivotal_project_id, message: 'has been mapped' }

  def to_s
    "#{harvest_project_id} - #{pivotal_project_id}"
  end
end
