class Api::PivotalClient
  attr_accessor :token
  CACHE_PERIODE = 3.minutes

  def initialize(user)
    if user.pivotal_token
      self.token = PivotalTracker::Client.token = user.pivotal_token
    else
      self.token = PivotalTracker::Client.token(user.pivotal_username, user.pivotal_password)
    end
  end

  def all_projects
    PivotalTracker::Project.all
  end

  def all_users(project_id)
    project = PivotalTracker::Project.find(project_id)

    if project.blank?
      response = PivotalTracker::Client.connection["/projects/#{project_id}"].get
      project = PivotalTracker::Project.parse(response)
    end
    result = project.memberships.all
  end

  def find_project(project_id)
    PivotalTracker::Project.find(project_id)
  end

  def list_all_story_by_project(project_id)
    PivotalTracker::Story.all find_project(project_id) 
  end

  def create_project(project_name, pivotal_start_iteration, pivotal_start_date)
    project = PivotalTracker::Project.new
    project.name = project_name
    project.week_start_day = week_day_options[pivotal_start_iteration]
    project.start_date = pivotal_start_date
    project.point_scale = "0,1,2,3,5,8"
    project.time_zone = "Jakarta"
    p project
    project = project.create
  end

  def get_pivotal_project_name(pid)
    p = cached_projects.select{|project| project.id.to_i == pid.to_i}.first
    p.name if !p.blank?
  end

  def cached_projects
    Rails.cache.fetch('pivotal_projects', expires_in: CACHE_PERIODE) do
      projects = all_projects
    end
  end

  def cached_users(integration_id, project_id)
    Rails.cache.fetch("pivotal_users_#{integration_id}", expires_in: CACHE_PERIODE) do
      all_users(project_id)
    end
  end

  def week_day_options
    @week_day_options ||= {"Sunday"=>"0", "Monday"=>"1", "Tuesday"=>"2", "Wednesday"=>"3", "Thursday"=>"4", "Friday"=>"5", "Saturday"=>"6"}
  end
end