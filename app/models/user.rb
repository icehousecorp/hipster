class User < ActiveRecord::Base
  attr_accessible :harvest_id, :harvest_password, :harvest_subdomain, :harvest_username

  attr_accessor :pivotal_password
  attr_accessible :pivotal_id, :pivotal_password, :pivotal_username, :pivotal_token

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
