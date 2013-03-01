class PersonMapping < ActiveRecord::Base
  belongs_to :integration
  belongs_to :person

  attr_accessible :person_id, :integration_id

  #validates(:pivotal_id, :presence => true)
  #validates(:harvest_id, :presence => true)
  #validates :harvest_id, :uniqueness => { :scope => [:pivotal_id, :integration_id], message: 'has been mapped' }

  #before_create :prepare_person_mapping, :if => :require_user_retrieval

  def harvest_api
    @harvest_api ||= Api::HarvestClient.new(self.integration.user)
  end

  def pivotal_api
    @pivotal_api ||= Api::PivotalClient.new(self.integration.user)
  end

  # def require_user_retrieval
  #   self.pivotal_name.blank? && self.pivotal_email.blank? && self.harvest_name.blank? && self.harvest_email.blank?
  # end

  # def prepare_person_mapping
  #   pivotal_users = pivotal_api.cached_users(self.integration.id, self.integration.pivotal_project_id)
  #   pivotal_user = pivotal_users.select{|user| user.id.to_i == pivotal_id.to_i}.first
  #   self.pivotal_name = pivotal_user.try(:name)
  #   self.pivotal_email = pivotal_user.try(:email)
  #   self.pivotal_id = pivotal_user.try(:id)

  #   harvest_users = harvest_api.cached_users(self.integration.id, self.integration.harvest_project_id)
  #   harvest_user = harvest_users.select{|user| user.id.to_i == harvest_id.to_i}.first
  #   self.harvest_name = "#{harvest_user.try(:first_name)} #{harvest_user.try(:last_name)}"
  #   self.harvest_email = harvest_user.try(:email)
  # end

end