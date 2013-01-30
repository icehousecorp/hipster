class User < ActiveRecord::Base
  attr_accessible :harvest_id, :harvest_password, :harvest_subdomain, :harvest_username, :pivotal_id, :pivotal_password, :pivotal_username

  def to_s
    "#{harvest_username} - #{pivotal_username}"
  end
end
