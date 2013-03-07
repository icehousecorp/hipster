class User < ActiveRecord::Base
  attr_accessible :username
  attr_accessible :harvest_id, :harvest_subdomain, :harvest_identifier, :harvest_secret
  attr_accessible :pivotal_id, :pivotal_token

  validates(:username, :presence => true)

  has_many :identities
  
  def to_s
    "#{username}"
  end

  def self.from_googleauth(auth)
    create(username: auth['info']['name'])
  end
end
