class Api::HarvestClient
  attr_accessor :client, :user
  def initialize(user)
    @user = user
    @client = Harvest.token_client(user.harvest_subdomain, user.harvest_token, ssl: true) if user.harvest_token
  end

  def authorize_url(redirect_uri)
    oauth_client.auth_code.authorize_url({redirect_uri:redirect_uri})
  end

  def oauth_client
    site = "https://#{user.harvest_subdomain}.harvestapp.com"
    options = {
      :site => site,
      :authorize_url => '/oauth2/authorize',
      :token_url => '/oauth2/token'
    }
    OAuth2::Client.new(user.harvest_identifier, user.harvest_secret, options)
  end

  def refresh_token! 
    token = OAuth2::AccessToken.new(oauth_client, user.harvest_token, refresh_token: user.harvest_refresh_token).refresh!
    user.harvest_token = token.token
    user.harvest_refresh_token = token.refresh_token
    user.save
  end

  def token(code, redirect_uri)
    token_params = {
      :code => code,
      :redirect_uri => redirect_uri,
      :client_id => user.harvest_identifier,
      :client_secret => user.harvest_identifier,
      :grant_type => 'authorization_code'
    }
    oauth_client.auth_code.get_token(code,{:redirect_uri => redirect_uri})
  end

  def should_retry?
    (@retry_count || 0) < 1
  end

  def increase_retry_counter
    @retry_count ||= 0
    @retry_count += 1
  end

  def all_projects
    @client.projects.all
  rescue Harvest::AuthenticationFailed
    refresh_token!
    all_projects if should_retry?
    increase_retry_counter
  end

  def all_users(project_id)
    assignments = @client.user_assignments.all(project_id)
    users = @client.users.all
    assigned_users = []
    assignments.each do |a|
      assigned_users << users.select {|u| u.id == a.user_id}.first
    end
    assigned_users
  rescue Harvest::AuthenticationFailed
    refresh_token!
    all_users(project_id) if should_retry?
    increase_retry_counter
  end

  def create(task_name, project_id)
    task = Harvest::Task.new
    task.name = task_name
    task = @client.tasks.create(task)
    assignment = Harvest::TaskAssignment.new
    assignment.task_id = task.id
    assignment.project_id = project_id
    @client.task_assignments.create(assignment)
    task
  rescue Harvest::AuthenticationFailed
    refresh_token!
    create(task_name, project_id) if should_retry?
    increase_retry_counter
  end

  def start_task(task_id, harvest_project_id, user_id)
    entries = find_entry(user_id, task_id)
    if entries.empty?
      entry = Harvest::TimeEntry.new
      entry.project_id = harvest_project_id
      entry.task_id = task_id
      puts "create time with task_id: #{task_id} and user: #{user_id}"
      @client.time.create(entry, user_id)
    end
  rescue Harvest::AuthenticationFailed
    refresh_token!
    start_task(task_id, harvest_project_id, user_id) if should_retry?
    increase_retry_counter
  end

  def stop_task(task_id, user_id)
    entries = find_entry(user_id, task_id)
    @client.time.toggle(entries.first.id, user_id) unless entries.empty?
  rescue Harvest::AuthenticationFailed
    refresh_token!
    stop_task(task_id, user_id) if should_retry?
    increase_retry_counter
  end

  def find_entry(user_id, task_id)
    # puts "finding entry for user: #{user_id} and task_id: #{task_id}"
    entries = @client.time.all(Time.now, user_id).select do |entry|
      entry.task_id.to_i == task_id.to_i && entry.ended_at.blank?
    end
  rescue Harvest::AuthenticationFailed
    refresh_token!
    find_entry(user_id, task_id) if should_retry?
    increase_retry_counter
  end
end

module Harvest
  module API
    class Time < Base
      def toggle(id, user=nil)
        response = request(:get, credentials, "/daily/timer/#{id.to_i}", query: of_user_query(user))
        Harvest::TimeEntry.parse(response.parsed_response).first
      end
      def create(entry, user=nil)
        response = request(:post, credentials, '/daily/add', :body => entry.to_json, query: of_user_query(user))
        Harvest::TimeEntry.parse(response.parsed_response).first
      end
    end
  end
end

class Harvest::User
  def name
    "#{first_name} #{last_name}"
  end
end

module Harvest
  class Base
    def initialize(credentials, options = {})
      options[:ssl] = true if options[:ssl].nil?
      @credentials = credentials
      raise InvalidCredentials unless credentials.valid?
    end
  end
  class << self
    def client(subdomain, username, password, options = {})
      credentials = PasswordCredentials.new(subdomain, username, password, options[:ssl])
      Harvest::Base.new(credentials, options)
    end

    def token_client(subdomain, token, options = {})
      credentials = TokenCredentials.new(subdomain, token, options[:ssl])
      Harvest::Base.new(credentials, options)
    end

    def hardy_token_client(subdomain,token, options = {})
      retries = options.delete(:retry)
      Harvest::HardyClient.new(token_client(subdomain, token, options), (retries || 5))
    end

    def hardy_client(subdomain, username, password, options = {})
      retries = options.delete(:retry)
      Harvest::HardyClient.new(client(subdomain, username, password, options), (retries || 5))
    end
  end
end

module Harvest
  module API
    class Base
      attr_reader :credentials

      def initialize(credentials)
        @credentials = credentials
      end

      class << self
        def api_model(klass)
          class_eval <<-END
            def api_model
              #{klass}
            end
          END
        end
      end

      protected
        def request(method, credentials, path, options = {})
          params = {}
          params[:path] = path
          params[:options] = options
          params[:method] = method

          response = HTTParty.send(method, "#{credentials.host}#{credentials.build_path(path)}",
            :query => options[:query],
            :body => options[:body],
            :format => :plain,
            :headers => {
              "Accept" => "application/json",
              "Content-Type" => "application/json; charset=utf-8",
              "User-Agent" => "Harvestable/#{Harvest::VERSION}",
            }.update(options[:headers] || {}).merge(credentials.headers || {})
          )

          params[:response] = response.inspect.to_s

          case response.code
          when 200..201
            response
          when 400
            raise Harvest::BadRequest.new(response, params)
          when 401
            raise Harvest::AuthenticationFailed.new(response, params)
          when 404
            raise Harvest::NotFound.new(response, params)
          when 500
            raise Harvest::ServerError.new(response, params)
          when 502
            raise Harvest::Unavailable.new(response, params)
          when 503
            raise Harvest::RateLimited.new(response, params)
          else
            raise Harvest::InformHarvest.new(response, params)
          end
        end

        def of_user_query(user)
          query = user.nil? ? {} : {"of_user" => user.to_i}
        end
    end
  end
end

module Harvest
  class Credentials
    attr_accessor :subdomain, :ssl
    
    def initialize(subdomain, ssl = true)
      @subdomain, @ssl = subdomain, ssl
    end
    
    def valid?
      !subdomain.nil?
    end
    
    def basic_auth
    end

    def build_path(path)
      path
    end

    def headers
      {}
    end
    
    def host
      "#{ssl ? "https" : "http"}://#{subdomain}.harvestapp.com"
    end
  end
  class PasswordCredentials < Credentials
    attr_accessor :username, :password
    
    def initialize(subdomain, username, password, ssl = true)
      super(subdomain, ssl)
      @username, @password = username, password
    end
    
    def valid?
      super && !username.nil? && !password.nil?
    end
    
    def basic_auth
      Base64.encode64("#{username}:#{password}").delete("\r\n")
    end
    def headers
      {"Authorization" => "Basic #{basic_auth}"}
    end
  end

  class TokenCredentials < Credentials
    attr_accessor :token
    
    def initialize(subdomain, token, ssl = true)
      super(subdomain, ssl)
      @token = token
    end
    
    def valid?
      super && !token.nil?
    end

    def build_path(path)
      "#{super(path)}?access_token=#{CGI::escape(token)}"
    end
  end
end
