class Api::HarvestClient
  attr_accessor :client, :user
  NON_AUTHENTICATION_HARVEST_EXCEPTIONS = [Harvest::ServerError, Harvest::BadRequest, Harvest::Unavailable, Harvest::RateLimited, Harvest::InformHarvest]
  CACHE_PERIODE = 3.minutes

  def initialize(user)
    @user = user
    @client = Harvest.token_client(user.harvest_subdomain, user.harvest_token, ssl: true) if user.harvest_token
  end

  def safe_invoke args
    attempt = 0
    begin
      yield(args)
    rescue Harvest::NotFound
      admin_user = User.find(4)
      @client = Harvest.token_client(admin_user.harvest_subdomain, admin_user.harvest_token, ssl: true) if admin_user.harvest_token
      attempt += 1
      retry if attempt < 2
      if attempt >= 2 && !args[:email_message].blank?
        email_address = Person.where(harvest_id: args[:harvest_user_id]).first.harvest_email
        UserMailer.alert_email(email_address, "#{args[:email_message]}<br/>#{e.inspect}").deliver
      end
    rescue Harvest::AuthenticationFailed
      result = refresh_token!
      attempt += 1
      retry if attempt < 3 
      if attempt >= 3 && !result
        email_address = Person.where(harvest_id: args[:harvest_user_id]).first.harvest_email
        UserMailer.alert_email(email_address, "PLease go to your Hipster Profile and click Confirm Harvest Connection").deliver
      end
    rescue *NON_AUTHENTICATION_HARVEST_EXCEPTIONS => e
      puts e.inspect
      if !args[:email_message].blank?
        email_address = Person.where(harvest_id: args[:harvest_user_id]).first.harvest_email
        UserMailer.alert_email(email_address, "#{args[:email_message]}<br/>#{e.inspect}").deliver
      end
    end
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

    @client = Harvest.token_client(user.harvest_subdomain, user.harvest_token, ssl: true) if user.harvest_token
    user.save
    rescue OAuth2::Error
      false
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

  def create_project(integration)
    safe_invoke Hash[:integration => integration] do |args|
      integration = args[:integration]
      project = Harvest::Project.new
      project.name = integration.project_name
      project.client_id = integration.client_id
      project.code = integration.harvest_project_code
      project.billable = integration.harvest_billable
      project.budget_by = "project_cost"  #always use project_cost option
      project.cost_budget = integration.harvest_budget

      project = @client.projects.create(project)
      project
    end
  end

  def cached_projects
    Rails.cache.fetch('harvest_projects', expires_in: CACHE_PERIODE) do
      projects = all_projects
    end
  end

  def cached_clients
    Rails.cache.fetch('harvest_clients', expires_in: CACHE_PERIODE) do
      clients = all_clients
    end
  end

  def cached_users(integration_id, project_id)
    Rails.cache.fetch('harvest_users_#{integration.id}', expires_in: CACHE_PERIODE) do
      all_users(project_id)
    end
  end

  def get_project_manager_harvest_id(project_id)
    Rails.cache.fetch('harvest_manager_#{project_id}', expires_in: CACHE_PERIODE) do
      safe_invoke Hash[:project_id=>project_id] do |args| 
        pm_assignments = @client.user_assignments.all(args[:project_id]).select do |asg|
          asg.is_project_manager?
        end

        pm_assignments.first.user_id unless pm_assignments.blank?
      end
    end 
  end

  def get_harvest_project_name(pid)
    p = cached_projects.select{|project| project.id.to_i == pid.to_i}.first
    p.name if !p.blank?
  end

  def get_harvest_project(id)
    safe_invoke [] { @client.projects.find(id) }
  end

  def get_harvest_user_by_email(integration_id, project_id, email_address)
    cached_users(integration_id, project_id).select do |harvest_user|
      puts "email #{email_address} and harvest #{harvest_user.email}"
      email_address.eql? harvest_user.email
    end
  end

  def find_project(project_id)
    safe_invoke Hash[:project_id=>project_id] do |args|
       @client.projects.find(args[:project_id])
    end
  end

  def all_clients
    safe_invoke [] { @client.clients.all }
  end

  def all_projects
    safe_invoke [] { @client.projects.all }
  end

  def all_tasks
    safe_invoke [] { @client.tasks.all }
  end

  def all_users(project_id)
    safe_invoke Hash[:project_id => project_id] do |args|
       assignments = @client.user_assignments.all(args[:project_id])
      users = @client.users.all
      assigned_users = []
      assignments.each do |a|
        assigned_users << users.select {|u| u.id == a.user_id}.first
      end
      assigned_users
    end
  end

   def create(task_name, project_id, user_id)
    email_message = "Failed to create new story #{task_name} on project id #{project_id}"

    safe_invoke Hash[:task_name=>task_name, :project_id=>project_id, :harvest_user_id=>user_id, :email_message=>email_message] do |args| 
      task = Harvest::Task.new
      task.name = args[:task_name]
      task = @client.tasks.create(task)
      assignment = Harvest::TaskAssignment.new
      assignment.task_id = task.id
      assignment.project_id = args[:project_id]
      @client.task_assignments.create(assignment)
      task
    end
  end

  def new_user(first_name, last_name, email)
    safe_invoke Hash[:first_name=>first_name, :last_name=>last_name, :email=>email] do |args|
      @client.users.create(first_name: args[:first_name], last_name: args[:last_name] ,email: args[:email])
    end
  end

  def assign_user(project_id, user_id)
    email_message = "Failed to assign harvest user #{user_id} to project #{project_id}"

    safe_invoke Hash[:project_id=>project_id, :user_id=>user_id] do |args|
      user_assignment = Harvest::UserAssignment.new(:user_id => args[:user_id], :project_id => args[:project_id])
      @client.user_assignments.create(user_assignment)
      user_assignment
    end
  end

  def start_task(task_id, harvest_project_id, user_id)
    return if user_id == nil

    email_message = "Failed to start new harvest entry with task id #{task_id} on harvest project id #{harvest_project_id}"

    safe_invoke Hash[:task_id => task_id, :harvest_project_id => harvest_project_id, 
      :harvest_user_id => user_id, :email_message => email_message] do |args|
      entries = find_entry(args[:harvest_user_id], args[:task_id])
      if entries.empty?
        entry = Harvest::TimeEntry.new
        entry.project_id = args[:harvest_project_id]
        entry.task_id = args[:task_id]
        @client.time.create(entry, args[:harvest_user_id])
      end
    end
  end

  def stop_task(task_id, user_id)
    return if user_id == nil
    
    email_message = "Failed to stop a harvest entry with task id #{task_id} on user #{user_id}"

    safe_invoke Hash[:task_id => task_id, :harvest_user_id => user_id, :email_message => email_message] do |args|
      entries = find_entry(args[:harvest_user_id], args[:task_id])
      @client.time.toggle(entries.first.id, user_id) unless entries.empty?
    end
  end

  def find_entry(user_id, task_id)
    entries = @client.time.all(Time.now, user_id).select do |entry|
      entry.task_id.to_i == task_id.to_i && entry.ended_at.blank? && !entry.timer_started_at.blank?
    end
  end

end