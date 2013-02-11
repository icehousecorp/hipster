class User < ActiveRecord::Base
  attr_accessible :username
  attr_accessible :harvest_id, :harvest_subdomain, :harvest_identifier, :harvest_secret
  attr_accessible :pivotal_id, :pivotal_token

  validates(:username, :presence => true)

  has_many :identities
  # validates(:harvest_password, :presence => true)
  # validates(:harvest_subdomain, :presence => true)
  # validates(:harvest_id, :presence => true)
  # validates(:harvest_username, :presence => true)
  # validates(:pivotal_id, :presence => true)
  # validates(:pivotal_username, :presence => true)
  # validates(:pivotal_password, :presence => true)

  def to_s
    "#{harvest_username}"
  end

  def self.from_googleauth(auth)
    create(username: auth['info']['name'])
  end
end
