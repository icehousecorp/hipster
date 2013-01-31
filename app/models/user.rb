class User < ActiveRecord::Base
  attr_accessible :harvest_id, :harvest_password, :harvest_subdomain, :harvest_username, :pivotal_id, :pivotal_password, :pivotal_username

  validates(:harvest_password, :presence => true)
  validates(:harvest_subdomain, :presence => true)
  # validates(:harvest_id, :presence => true)
  validates(:harvest_username, :presence => true)
  # validates(:pivotal_id, :presence => true)
  validates(:pivotal_username, :presence => true)
  validates(:pivotal_password, :presence => true)

  def to_s
    "#{harvest_username} - #{pivotal_username}"
  end
end
