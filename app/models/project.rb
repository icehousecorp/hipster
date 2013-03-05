class Project < ActiveRecord::Base
  set_table_name 'integrations'

  belongs_to :user
  has_many :person_mappings, :dependent => :destroy, foreign_key: :integration_id
  has_many :people, :through => :person_mappings
  attr_accessible :harvest_project_id, :pivotal_project_id, :user_id
  attr_accessible :harvest_project_name, :pivotal_project_name
  attr_accessible :project_name, :client_id, :client_name
  attr_accessible :harvest_project_code, :harvest_billable, :harvest_budget
  attr_accessible :pivotal_start_iteration, :pivotal_start_date

  attr_accessible :client_id, :person_ids
  
  attr_accessor :person_ids

  validates :harvest_budget, :format => { :with => /^\d+??(?:\.\d{0,2})?$/ }, :numericality => {:greater_than => 0}

  validates_uniqueness_of :harvest_project_id, message: ' has been mapped'
  validates_uniqueness_of :pivotal_project_id, message: ' has been mapped'
  validate :validate_client_not_empty, :on => :create, :unless => :project_already_exist?
  validate :validate_project_name_not_empty, :on => :create, :unless => :project_already_exist?
  validate :validate_harvest_project_id, :on => :create, :if => :project_already_exist?
  validate :validate_pivotal_project_id, :on => :create, :if => :project_already_exist?

  before_create :retrieve_existing_project, :if => :project_already_exist?
  
  before_create :create_remote_project, :unless => :project_already_exist?
  before_create :assign_person_mapping
  before_update :assign_person_mapping

  def harvest_api
    @harvest_api ||= Api::HarvestClient.new(self.user)
  end

  def pivotal_api
    @pivotal_api ||= Api::PivotalClient.new(self.user)
  end

  def project_already_exist?
    p "#{self.harvest_project_id.blank?} and #{self.pivotal_project_id.blank?}"
    !self.harvest_project_id.blank? && !self.pivotal_project_id.blank?
  end

  def create_remote_project
    pivotal_project = pivotal_api.create_project(self.project_name, self.pivotal_start_iteration)
    harvest_project = harvest_api.create_project(self)
    
    p harvest_project.inspect
    p pivotal_project.inspect

    if harvest_project.blank? || harvest_project.id.blank?
      errors.add(:project_name, ' Failed to create new project in Harvest')
    elsif pivotal_project.blank? || pivotal_project.id.blank?
      errors.add(:project_name, ' Failed to create new project in Pivotal Tracker')
    end

    self.harvest_project_id = harvest_project.id
    self.pivotal_project_id = pivotal_project.id
    self.harvest_project_name = project_name
    self.pivotal_project_name = project_name
  end

  def retrieve_existing_project
    harvest_project = harvest_api.find_project(self.harvest_project_id)
    pivotal_project = pivotal_api.find_project(self.pivotal_project_id)

    self.pivotal_project_name = pivotal_project.name
    self.pivotal_start_iteration = pivotal_project.week_start_day

    self.harvest_project_name = harvest_project.name
    self.harvest_billable = harvest_project.billable.to_s
    self.harvest_budget = harvest_project.cost_budget
    self.harvest_project_code = harvest_project.code

    self.project_name = pivotal_project.name
  end

  def assign_person_mapping
    project_member = []
    self.person_ids.each do |mapping_id|
      person = Person.find(mapping_id)

      membership = PivotalTracker::Membership.new(:role => "Member", :name => person.pivotal_name, :email => person.pivotal_email)
      pivotal_project = PivotalTracker::Project.new
      pivotal_project.id = self.pivotal_project_id
      membership = membership.assign(pivotal_project)

      user_assignment = harvest_api.assign_user(self.harvest_project_id, person.harvest_id)

      project_member << person
    end unless self.person_ids.blank?
    self.people = project_member
  end

  def to_s
    "#{harvest_project_name} - #{pivotal_project_name}"
  end

  def validate_client_not_empty
      errors.add(:client_id, " is required") if client_id.blank?
  end

  def validate_project_name_not_empty
      errors.add(:project_name, " is required") if project_name.blank?
  end

  def validate_harvest_project_id
      errors.add(:harvest_project_id, " is required") if harvest_project_id.blank?
  end

  def validate_pivotal_project_id
      errors.add(:pivotal_project_id, " is required") if pivotal_project_id.blank?
  end
end
