class Api::PivotalClient
  def initialize(user)
    PivotalTracker::Client.token(user.pivotal_username, user.pivotal_password)
  end

  def all_projects
    PivotalTracker::Project.all
  end

  def all_users(project_id)
    project = PivotalTracker::Project.find(Integration.first.pivotal_project_id)
    puts project.inspect
    result = project.memberships.all
    puts result.inspect
    result
  end
end