class Api::PivotalClient
  def initialize(user)
    PivotalTracker::Client.token(user.pivotal_username, user.pivotal_password)
  end

  def all_projects
    PivotalTracker::Project.all
  end
end