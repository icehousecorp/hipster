class Integration < ActiveRecord::Base
  belongs_to :user
  has_many :person_mappings
  attr_accessible :harvest_project_id, :pivotal_project_id, :user_id
  attr_accessible :harvest_project_name, :pivotal_project_name
  attr_accessor :project_name
  attr_accessor :client_id
  #validates :harvest_project_id, :uniqueness => { :scope => :pivotal_project_id, message: 'has been mapped' }
  validates_uniqueness_of :harvest_project_id, message: 'has been mapped'
  validates_uniqueness_of :pivotal_project_id, message: 'has been mapped'
  def to_s
    "#{harvest_project_name} - #{pivotal_project_name}"
  end
end
