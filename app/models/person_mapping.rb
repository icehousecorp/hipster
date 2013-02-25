class PersonMapping < ActiveRecord::Base
  belongs_to :integration
  attr_accessible :pivotal_email, :harvest_email, :integration_id
  attr_accessible :harvest_id, :harvest_name
  attr_accessible :pivotal_id, :pivotal_name

  attr_accessible :pivotal_user, :harvest_user
  attr_accessor :pivotal_user, :harvest_user

  validates(:pivotal_id, :presence => true)
  validates(:harvest_id, :presence => true)
  validates :harvest_id, :uniqueness => { :scope => [:pivotal_id, :integration_id], message: 'has been mapped' }

  before_create :prepare_person_mapping, :if => :require_user_retrieval

  def harvest_api
    @harvest_api ||= Api::HarvestClient.new(self.integration.user)
  end

  def pivotal_api
    @pivotal_api ||= Api::PivotalClient.new(self.integration.user)
  end

  def require_user_retrieval
    self.pivotal_name.blank? && self.pivotal_email.blank? && self.harvest_name.blank? && self.harvest_email.blank?
  end

  def prepare_person_mapping
    pivotal_users = pivotal_api.cached_users(self.integration.id, self.integration.pivotal_project_id)
    pivotal_user = pivotal_users.select{|user| user.id.to_i == pivotal_id.to_i}.first
    self.pivotal_name = pivotal_user.try(:name)
    self.pivotal_email = pivotal_user.try(:email)
    self.pivotal_id = pivotal_user.try(:id)

    harvest_users = harvest_api.cached_users(self.integration.id, self.integration.harvest_project_id)
    harvest_user = harvest_users.select{|user| user.id.to_i == harvest_id.to_i}.first
    self.harvest_name = "#{harvest_user.try(:first_name)} #{harvest_user.try(:last_name)}"
    self.harvest_email = harvest_user.try(:email)
  end

  def clone_mapping_to_project(integration)
    pm = PersonMapping.new
    new_project = PivotalTracker::Project.new
    new_project.id = integration.pivotal_project_id
    membership = PivotalTracker::Membership.new(:role => "Member", :name => self.pivotal_name, :email => self.pivotal_email)
    membership = membership.assign(new_project)

    pm.pivotal_name = self.pivotal_name
    pm.pivotal_email = self.pivotal_email
    pm.pivotal_id = membership.id

    user_assignment = harvest_api.assign_user(integration.harvest_project_id, self.harvest_id)

    pm.harvest_name = self.harvest_name
    pm.harvest_email = self.harvest_email
    pm.harvest_id = self.harvest_id

    pm.integration_id = integration.id
    pm
  end

  def harvest_info
  	"#{harvest_id}-#{harvest_name} (#{harvest_email})"
  end

  def pivotal_info
  	"#{pivotal_id}-#{pivotal_name} (#{pivotal_email})"
  end

  def name
    "[#{self.harvest_id}-#{self.harvest_name}] [#{self.pivotal_id}-#{self.pivotal_name}]"
  end
end

module PivotalTracker
  class Membership
    include HappyMapper

    class << self
      def all(project, options={})
        parse(Client.connection["/projects/#{project.id}/memberships"].get)
      end
    end

    element :id, Integer
    element :role, String

    # Flattened Attributes from <person>...</person>
    element :name, String, :deep => true
    element :email, String, :deep => true
    element :initials, String, :deep => true

    def initialize(attributes={})
      update_attributes(attributes)
    end

    def assign(project, options={})
      puts self.to_xml
      response = Client.connection["/projects/#{project.id}/memberships/"].post(self.to_xml, :content_type => 'application/xml')
      membership = Membership.parse(response)
      return membership
    end

    protected

      def to_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.membership {
            xml.role "#{role}"
            xml.person {
              xml.name "#{name}"
              xml.email "#{email}"
              xml.initials "#{initials}" unless initials.nil?
            }
          }
        end
        return builder.to_xml
      end

      def update_attributes(attrs)
        attrs.each do |key, value|
          self.send("#{key}=", value.is_a?(Array) ? value.join(',') : value )
        end
      end
  end
end
