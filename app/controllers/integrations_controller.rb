class IntegrationsController < ApplicationController
  CACHE_PERIODE = 3.minutes
  before_filter :find_user, except: [:callback, :reload]
  before_filter :fetch_projects, :fetch_clients, only: [:new , :edit]

  def find_user
    @user = User.find(params[:user_id])
    if @user.harvest_secret.blank? || @user.harvest_subdomain.blank? || @user.harvest_identifier.blank? || @user.pivotal_token.blank?
      redirect_to edit_user_path(@user), notice: "Incomplete user profile"
    end
    @user
  end

  def reload
    Rails.cache.clear
    redirect_to root_url
  end

  def harvest_projects
    @harvest_projects ||= Rails.cache.fetch('harvest_projects', expires_in: CACHE_PERIODE) do
      projects = Api::HarvestClient.new(@user).all_projects
    end
  end

  def pivotal_projects
    @pivotal_projects ||= Rails.cache.fetch('pivotal_projects', expires_in: CACHE_PERIODE) do
      projects = Api::PivotalClient.new(@user).all_projects
    end
  end

  def harvest_clients
    @harvest_clients ||= Rails.cache.fetch('harvest_clients', expires_in: CACHE_PERIODE) do
      clients = Api::HarvestClient.new(@user).all_clients
    end
  end

  def fetch_clients
    harvest_clients
  end

  def fetch_projects
    @harvest_projects = harvest_projects.select do |project_entry|
          Integration.where(harvest_project_id: project_entry.id).first.nil?
      end
    @pivotal_projects = pivotal_projects.select do |project_entry|
          Integration.where(pivotal_project_id: project_entry.id).first.nil?
      end
  end

  def harvest_api
    @harvest_api ||= Api::HarvestClient.new(@integration.user)
  end

  def store(activity)
    puts "#{params[:id]} - #{activity.instance_variables.inspect}"
  end

  def find_task_for_story(story_id)
    @task_story ||= TaskStory.where(story_id: story_id).first
    @task_story.try(:task_id)
  end

  def callback
    @integration = Integration.find(params[:id])
    activity = ActivityParam.new(params)
    case activity.type
    when ActivityParam::CREATE_STORY
      task = harvest_api.create(activity.task_name, @integration.harvest_project_id)
      TaskStory.create(task_id: task.id, story_id: activity.story_id)
    when ActivityParam::START_STORY
      task_id = find_task_for_story(activity.story_id)
      harvest_api.start_task(task_id, @integration.harvest_project_id, activity.user_id)
    when ActivityParam::FINISH_STORY
      task_id = find_task_for_story(activity.story_id)
      harvest_api.stop_task(task_id, activity.user_id)
    else
      # do nothing just log it
    end
    # persist activity param incase we need it in the future
    store(activity)
    head :no_content
  end

  # GET /integrations
  # GET /integrations.json
  def index
    @integrations = Integration.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @integrations }
    end
  end

  # GET /integrations/1
  # GET /integrations/1.json
  def show
    @integration = Integration.find(params[:id])
    # @person_mappings = PersonMapping.where(integration_id: params[:id])

    # respond_to do |format|
      render :template => "layouts/webhook", :layout => nil
      # format.html # show.html.erb
      # format.json { render json: @integration }
    # end
  end

  def detail
    @integration = Integration.find(params[:id])
    @person_mappings = PersonMapping.where(integration_id: params[:id])
    render "show"
  end

  # GET /integrations/new
  # GET /integrations/new.json
  def new
    @integration = Integration.new(user_id: params[:user_id])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @integration }
    end
  end

  # GET /integrations/1/edit
  def edit
    @integration = Integration.find(params[:id])
  end

  def harvest_project_name(pid)
    p = harvest_projects.select{|project| project.id.to_i == pid.to_i}.first
    p.name
  end

  def pivotal_project_name(pid)
    p = pivotal_projects.select{|project| project.id.to_i == pid.to_i}.first
    p.name
  end

  def create_harvest_project(project_name, harvest_client_id)
    harvest_project = Api::HarvestClient.new(@user).create_project(project_name, harvest_client_id)
  end

  def create_pivotal_project(project_name)
    pivotal_project = Api::PivotalClient.new(@user).create_project(project_name)
  end

  def integration_param
    if params[:selection].eql? "auto"
      harvest_project = create_harvest_project(params[:integration][:project_name], params[:integration][:client_id])
      pivotal_project = create_pivotal_project(params[:integration][:project_name])

      if harvest_project.blank? || harvest_project.id.blank?
        redirect_to new_user_integration_path(@user), notice: 'Failed to create new project in Harvest. Please try again'
      elsif pivotal_project.blank? || pivotal_project.id.blank?
        redirect_to new_user_integration_path(@user), notice: 'Failed to create new project in Pivotal Tracker. Please try again'
      end

      params[:integration][:harvest_project_id] = harvest_project.id
      params[:integration][:harvest_project_name] = harvest_project.name
      params[:integration][:pivotal_project_id] = pivotal_project.id
      params[:integration][:pivotal_project_name] = pivotal_project.name
    else
      params[:integration][:harvest_project_name] = harvest_project_name(params[:integration][:harvest_project_id])
      params[:integration][:pivotal_project_name] = pivotal_project_name(params[:integration][:pivotal_project_id])
    end
    
    params[:integration].delete(:client_id)
    params[:integration].delete(:project_name)
    params[:integration]
  end

  # POST /integrations
  # POST /integrations.json
  def create
    if (params[:selection].eql? "auto") && params[:integration][:client_id].blank?
      redirect_to new_user_integration_path(@user), notice: 'Please select the client'
    elsif(params[:selection].eql? "auto") && params[:integration][:project_name].blank?
      redirect_to new_user_integration_path(@user), notice: 'Please specify project name'
    elsif (params[:selection].eql? "manual") && (params[:integration][:harvest_project_id].blank? || params[:integration][:pivotal_project_id].blank?)
      redirect_to new_user_integration_path(@user), notice: 'Harvest and Pivotal projects are required'
    else 
      @integration = Integration.new(integration_param)
      if @integration.save
        redirect_to user_integration_path(@user, @integration), notice: 'Integration was successfully created.'
      else
        fetch_projects
        render action: "new"
      end
    end
  end

  # PUT /integrations/1
  # PUT /integrations/1.json
  def update
    @integration = Integration.find(params[:id])

    if @integration.update_attributes(integration_param)
      redirect_to user_integration_path(@user, @integration), notice: 'Integration was successfully updated.'
    else
      fetch_projects
      render action: "edit"
    end
  end

  # DELETE /integrations/1
  # DELETE /integrations/1.json
  def destroy
    @integration = Integration.find(params[:id])
    @integration.destroy

    respond_to do |format|
      format.html { redirect_to user_integrations_url(@integration.user) }
      format.json { head :no_content }
    end
  end
end




#   def callback
#   end

#   def store
#     ActivityLog.create(text: activity.to_json, mapping_id: @mapping.id)
#   end

#   def harvest_api
#     User user = @mapping.user
#     @harvest ||= HarvestApi.new(user.harvest_subdomain, user.harvest_username, user.harvest_password)
#   end

#   def find_task_for_story(story_id)
#     TaskStory.where(story_id: story_id).first.try(:task_id)
#   end
# end

class ActivityParam
  CREATE_STORY = 0
  START_STORY = 1
  FINISH_STORY = 2

  attr_accessor :id, :event_type, :project_id, :author, :description, :story_id, :story_name, :story_state
  def initialize params={}
    self.id = params[:id]
    params = params[:activity]
    self.event_type = params[:event_type]
    self.project_id = params[:project_id]
    self.author = params[:author]
    self.description = params[:description]
    self.story_id = params[:stories][0][:id]
    self.story_name = params[:stories][0][:name]
    self.story_state = params[:stories][0][:current_state]
  end

  def type
    if event_type == 'story_create'
      return CREATE_STORY
    end

    if event_type == 'story_update'
      case story_state
      when 'started'
        return START_STORY
      when 'finished'
        return FINISH_STORY
      end
    end
  end

  def user_id
    PersonMapping.where(pivotal_name: author).first.harvest_id
  end

  def task_name
    "[##{story_id}] #{story_name}"
  end
end

