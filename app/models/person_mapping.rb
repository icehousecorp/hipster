class PersonMapping < ActiveRecord::Base
  belongs_to :integration
  attr_accessible :pivotal_email, :harvest_email, :integration_id
  attr_accessible :harvest_id, :harvest_name
  attr_accessible :pivotal_id, :pivotal_name

  validates(:pivotal_email, :presence => true)
  validates(:pivotal_email, :presence => true)
  validates :harvest_id, :uniqueness => { :scope => [:pivotal_email, :integration_id], message: 'has been mapped' }

  def harvest_info
  	"#{harvest_id}-#{harvest_name} (#{harvest_email})"
  end

  def pivotal_info
  	"#{pivotal_id}-#{pivotal_name} (#{pivotal_email})"
  end
end
