class IntegrationsController < ApplicationController
  before_filter :find_user
  before_filter :fetch_projects, only: [:new , :edit]

  def find_user
    @user = User.find(params[:user_id])
  end

  class ProjectCache
    attr_accessor :id, :name
    def initialize project=nil
      self.id = project.try(:id)
      self.name = project.try(:name)
    end
    def to_hash
      {id: self.id, name: self.name}
    end
    def self.new_from_hash hash
      instance = new
      instance.id = hash[:id]
      instance.name = hash[:name]
      instance
    end
  end

  def harvest_projects
    projects = session[:harvest_projects]
    unless projects
      projects = Api::HarvestClient.new(@user).all_projects
      projects = projects.collect do |p|
        ProjectCache.new(p)
      end
      session[:harvest_projects] = projects.map(&:to_hash)
    end
    session[:harvest_projects].collect do |hash|
      ProjectCache.new_from_hash(hash)
    end
  end

  def pivotal_projects
    projects = session[:pivotal_projects]
    unless projects
      projects = Api::PivotalClient.new(@user).all_projects
      projects = projects.collect do |p|
        ProjectCache.new(p)
      end
      session[:pivotal_projects] = projects.map(&:to_hash)
    end
    session[:pivotal_projects].collect do |hash|
      ProjectCache.new_from_hash(hash)
    end
  end

  def fetch_projects
    @harvest_projects = harvest_projects
    @pivotal_projects = pivotal_projects
  end

  def callback
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

  # POST /integrations
  # POST /integrations.json
  def create
    @integration = Integration.new(params[:integration])

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
      if @integration.update_attributes(params[:integration])
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
#     @mapping = ProjectMapping.find(params[:id])
#     activity = ActivityParam.new(params)
#     case activity.type
#     when CREATE_STORY:
#       harvest_api.create(activity.task_name, activity.project_id)
#     when START_STORY:
#       task_id = find_task_for_story(activity.story_id)
#       harvest_api.start_task(task_id, @mapping.harvest_project_id, activity.user_id)
#     when FINISH_STORY:
#       task_id = find_task_for_story(activity.story_id)
#       harvest_api.stop_task(task_id, activity.user_id)
#     else
#       # do nothing just log it
#     end
#     # persist activity param incase we need it in the future
#     store(activity)
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
    Person.where(pivotal_name: author).harvest_id
  end

  def task_name
    "[##{story_id}] #{story_name}"
  end
end

