class Person < ActiveRecord::Base
	has_many :person_mappings, :dependent => :destroy
	has_many :integrations, :through => :person_mappings

  	attr_accessible :harvest_email, :harvest_id, :harvest_name, :pivotal_email, :pivotal_id, :pivotal_name

  	def harvest_info
  	"#{harvest_id}-#{harvest_name} (#{harvest_email})"
  end

  def pivotal_info
  	"#{pivotal_id}-#{pivotal_name} (#{pivotal_email})"
  end

  def name
    "[#{self.harvest_id}-#{self.harvest_name}] [#{self.pivotal_id}-#{self.pivotal_name}]"
  end
end
