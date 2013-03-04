class Person < ActiveRecord::Base
	has_many :person_mappings, :dependent => :destroy, foreign_key: :integration_id
	has_many :projects, :through => :person_mappings

  attr_accessible :harvest_email, :harvest_id, :harvest_name, :pivotal_email, :pivotal_id, :pivotal_name
  attr_accessor :harvest_user_email, :harvest_user_password, :harvest_sub_domain
  attr_accessible :harvest_user_email, :harvest_user_password, :harvest_sub_domain

  validates :harvest_email, :presence => true
  validates :pivotal_email, :presence =>true
  validate :harvest_name_validation

  before_create :prepare_integration

  def harvest_client
    @client ||= Harvest.client(self.harvest_sub_domain, self.harvest_user_email, self.harvest_user_password)
  end
  def prepare_integration
    split_name = self.harvest_name.split(' ')
    first_name = split_name[0]
    last_name =last_name(split_name)
    new_user = harvest_client.users.create(first_name: first_name, last_name: last_name,email: self.harvest_email)
    self.harvest_id = new_user.id
  end

  def last_name(split_name)
    last_name = ''
    if split_name.size >=2
      (1..split_name.size-1).each do |index|
        last_name = last_name + split_name[index].gsub(' ','')
      end
    end
    last_name
  end
  def harvest_info
  	"#{harvest_id}-#{harvest_name} (#{harvest_email})"
  end

  def pivotal_info
  	"#{pivotal_id}-#{pivotal_name} (#{pivotal_email})"
  end

  def name
    "[#{self.harvest_id}-#{self.harvest_name}] [#{self.pivotal_id}-#{self.pivotal_name}]"
  end

  def harvest_name_validation
    full_name = self.harvest_name.split(' ')
    if full_name.length < 2
      errors.add(:harvest_name, "should have last name")
    end
  end
end
