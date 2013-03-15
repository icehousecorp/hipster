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

  attr_accessible :person_ids, :create_method
  attr_accessor :person_ids, :create_method

  #For new project created through hipster
  with_options :if => :is_new_project? do |project|
    project.validates :project_name, :client_id, :pivotal_start_iteration, :pivotal_start_date, :presence => true
    project.validates :harvest_budget, :format => { :with => /^\d+??(?:\.\d{0,2})?$/ }, :numericality => {:greater_than => 0}
    project.validate :project_and_sprint_day_match

    project.after_validation :prepare_create
    
    project.before_create :project_created_at_pivotal_server
    project.before_create :project_created_at_harvest_server
    project.before_create :assign_person_mapping
  end

  #For existing harvest and pivotal project to integrate through hipster
  with_options :unless => :is_new_project? do |project|
    project.validates :harvest_project_id, :pivotal_project_id, :presence => true
    project.validates :harvest_project_id, :uniqueness => true
    project.validates :pivotal_project_id, :uniqueness => true

    project.before_create :retrieve_existing_project
    project.after_create :create_task_from_existing_project
  end
  
  before_update :assign_person_mapping

  def harvest_api
    @harvest_api ||= Api::HarvestClient.new(self.user)
  end

  def pivotal_api
    @pivotal_api ||= Api::PivotalClient.new(self.user)
  end

  def is_new_project?
    self.create_method.eql? 'new'
  end

  def project_and_sprint_day_match
    errors.add(:pivotal_start_iteration, " does not match project start date") unless Date.parse(self.pivotal_start_date).strftime("%A").eql? self.pivotal_start_iteration
  rescue ArgumentError
    #catch if the date format is invalid
    errors.add(:pivotal_start_date, " is invalid")
  end

  def project_created_at_pivotal_server
    start_date_formatted = Date.parse(self.pivotal_start_date).strftime("%m/%d/%Y")
    pivotal_project = pivotal_api.create_project(self.project_name, self.pivotal_start_iteration, start_date_formatted)
    p pivotal_project.inspect
    
    self.pivotal_project_id = pivotal_project.id
    errors.add(:project_name, ' Failed to create new project in Harvest') if pivotal_project.blank? || pivotal_project.id.blank?
  end

  def project_created_at_harvest_server
    harvest_project = harvest_api.create_project(self)

    self.harvest_project_id = harvest_project.id
    errors.add(:project_name, ' Failed to create new project in Harvest') if harvest_project.blank? || harvest_project.id.blank?
  end

  def prepare_create
    self.harvest_project_name = self.project_name
    self.pivotal_project_name = self.project_name
  end

  def retrieve_existing_project
    harvest_project = harvest_api.find_project(self.harvest_project_id)
    pivotal_project = pivotal_api.find_project(self.pivotal_project_id)

    self.client_id = harvest_project.client_id
    
    self.pivotal_project_name = pivotal_project.name
    self.pivotal_start_iteration = pivotal_project.week_start_day
    self.pivotal_start_date = pivotal_project.start_date 

    self.harvest_project_name = harvest_project.name
    self.harvest_billable = harvest_project.billable.to_s
    self.harvest_budget = harvest_project.cost_budget
    self.harvest_project_code = harvest_project.code

    self.project_name = pivotal_project.name
  end

  def create_task_from_existing_project
    #ambil semua task
    stories = pivotal_api.list_all_story_by_project(self.pivotal_project_id)
    tasks = harvest_api.all_tasks.map(&:name)
    harvest_id = harvest_api.get_project_manager_harvest_id(self.harvest_project_id)
    #loop buat task di harvest
    #CREATE task story
    stories.each do |story|
      tmp = "[##{story.id}] #{story.name}"
      if !tasks.include? tmp
        task = harvest_api.create(tmp, self.harvest_project_id, harvest_id)
        TaskStory.create(task_id: task.id, story_id: story.id)
      end
    end
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
    self.people = self.people + project_member
  end

  def to_s
    "#{harvest_project_name} - #{pivotal_project_name}"
  end
end
