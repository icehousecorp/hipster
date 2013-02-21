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
      puts response.inspect
      project = PivotalTracker::Project.parse(response)
    end
    # puts project.inspect
    result = project.memberships.all
    # puts result.inspect
    # result
  end

  def create_project(project_name)
    project = PivotalTracker::Project.new(:name => project_name)
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
end