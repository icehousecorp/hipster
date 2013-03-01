class IntegrationsController < ApplicationController
  CACHE_PERIODE = 3.minutes
  before_filter :find_user, except: [:callback, :reload]
  before_filter :initialize_callback, only: [:callback]
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

  def fetch_clients
    @harvest_clients ||= harvest_api.cached_clients
  end

  def fetch_projects
    @harvest_projects ||= harvest_api.cached_projects.select do |project_entry|
          Integration.where(harvest_project_id: project_entry.id).first.nil?
      end
    @pivotal_projects ||= pivotal_api.cached_projects.select do |project_entry|
          Integration.where(pivotal_project_id: project_entry.id).first.nil?
      end
  end

  def store(activity)
    puts "#{params[:id]} - #{activity.instance_variables.inspect}"
  end

  def find_task_for_story(story_id)
    @task_story ||= TaskStory.where(story_id: story_id).first
    @task_story.try(:task_id)
  end

  def initialize_callback
    @integration = Integration.find(params[:id])
    @current_user = @integration.user
  end

  def callback
    activity = ActivityParam.new(params)
    harvest_user = PersonMapping.where(pivotal_name: activity.author, integration_id: @integration.id).first
    harvest_id = harvest_user.harvest_id unless harvest_user.nil?

    case activity.type
    when ActivityParam::CREATE_STORY
      harvest_id ||= harvest_api.get_project_manager_harvest_id(@integration.harvest_project_id)
      puts "Using harvest id #{harvest_id}"
      task = harvest_api.create(activity.task_name, @integration.harvest_project_id, harvest_id)
      TaskStory.create(task_id: task.id, story_id: activity.story_id)
    when ActivityParam::START_STORY
      task_id = find_task_for_story(activity.story_id)
      harvest_api.start_task(task_id, @integration.harvest_project_id, harvest_id)
    when ActivityParam::FINISH_STORY
      task_id = find_task_for_story(activity.story_id)
      harvest_api.stop_task(task_id, harvest_id)
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

  def find_people_list
    @people_list ||= Person.all
  end

  # GET /integrations/new
  # GET /integrations/new.json
  def new
    @integration = Integration.new(user_id: params[:user_id])
    find_people_list

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @integration }
    end
  end

  # GET /integrations/1/edit
  def edit
    @integration = Integration.find(params[:id])
  end

  # POST /integrations
  # POST /integrations.json
  def create
    @integration = Integration.new(params[:integration])
    if @integration.save
      redirect_to user_integration_path(@user, @integration), notice: 'Integration was successfully created.'
    else
      fetch_projects
      fetch_clients
      render action: "new"
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

  def task_name
    "[##{story_id}] #{story_name}"
  end
end

