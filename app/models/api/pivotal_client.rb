class Api::PivotalClient
  attr_accessor :token
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
end