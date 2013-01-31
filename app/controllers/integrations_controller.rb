class IntegrationsController < ApplicationController
  CACHE_PERIODE = 3.minutes
  before_filter :find_user, except: [:callback, :reload]
  before_filter :fetch_projects, only: [:new , :edit]

  def find_user
    @user = User.find(params[:user_id])
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

  def fetch_projects
    @harvest_projects = harvest_projects
    @pivotal_projects = pivotal_projects
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
    @integrations = Integration.where(user_id: params[:user_id])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @integrations }
    end
  end

  # GET /integrations/1
  # GET /integrations/1.json
  def show
    @integration = Integration.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @integration }
    end
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

  def integration_param
    params[:integration][:harvest_project_name] = harvest_project_name(params[:integration][:harvest_project_id])
    params[:integration][:pivotal_project_name] = pivotal_project_name(params[:integration][:pivotal_project_id])
    params[:integration]
  end

  # POST /integrations
  # POST /integrations.json
  def create
    @integration = Integration.new(integration_param)

    respond_to do |format|
      if @integration.save
        format.html { redirect_to user_integration_path(@user, @integration), notice: 'Integration was successfully created.' }
      else
        fetch_projects
        format.html { render action: "new" }
      end
    end
  end

  # PUT /integrations/1
  # PUT /integrations/1.json
  def update
    @integration = Integration.find(params[:id])

    respond_to do |format|
      if @integration.update_attributes(integration_param)
        format.html { redirect_to @integration, notice: 'Integration was successfully updated.' }
        format.json { head :no_content }
      else
        fetch_projects
        format.html { render action: "edit" }
        format.json { render json: @integration.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /integrations/1
  # DELETE /integrations/1.json
  def destroy
    @integration = Integration.find(params[:id])
    @integration.destroy

    respond_to do |format|
      format.html { redirect_to integrations_url }
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

