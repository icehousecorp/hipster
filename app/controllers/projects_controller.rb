class ProjectsController < ApplicationController
  CACHE_PERIODE = 3.minutes
  before_filter :find_user, except: [:callback, :reload]
  before_filter :initialize_callback, only: [:callback]

  def find_user
    @user = current_user
    if @user.nil? || @user.harvest_secret.blank? || @user.harvest_subdomain.blank? || @user.harvest_identifier.blank? || @user.pivotal_token.blank?
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
          Project.where(harvest_project_id: project_entry.id).first.nil?
      end
    @pivotal_projects ||= pivotal_api.cached_projects.select do |project_entry|
          Project.where(pivotal_project_id: project_entry.id).first.nil?
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
    @project = Project.find(params[:id])
    @current_user = @project.user
  end

  def callback
    activity = ActivityParam.new(params)
    harvest_user = @project.people.where(pivotal_name: activity.author).first
    harvest_id = harvest_user.harvest_id unless harvest_user.nil?

    case activity.type
    when ActivityParam::CREATE_STORY
      harvest_id ||= harvest_api.get_project_manager_harvest_id(@project.harvest_project_id)
      puts "Using harvest id #{harvest_id}"
      task = harvest_api.create(activity.task_name, @project.harvest_project_id, harvest_id)
      TaskStory.create(task_id: task.id, story_id: activity.story_id)
    when ActivityParam::START_STORY
      task_id = find_task_for_story(activity.story_id)
      harvest_api.start_task(task_id, @project.harvest_project_id, harvest_id) unless harvest_id.blank?
    when ActivityParam::FINISH_STORY
      task_id = find_task_for_story(activity.story_id)
      harvest_api.stop_task(task_id, harvest_id) unless harvest_id.blank?
    else
      # do nothing just log it
    end
    # persist activity param incase we need it in the future
    store(activity)
    head :no_content
  end

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @project = Project.find(params[:id])
    
    render :template => "layouts/webhook", :layout => nil
  end

  def detail
    @project = Project.find(params[:id])
    render "show"
  end

  def find_people_list
    @people_list ||= Person.all
  end

  # GET /projects/new
  # GET /projects/new.json
  def new
    @project = Project.new(user_id: current_user.id)
    find_people_list
    fetch_clients

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
    end
  end

  def edit
    @project = Project.find(params[:id])
    find_people_list.select! do |person| 
      !@project.people.include? person
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/new_link
  # GET /projects/new_link.json
  def new_link
    @project = Project.new(user_id: current_user.id)
    fetch_projects

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
    end
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(params[:project])
    if @project.save
      redirect_to project_path(@project), notice: 'Project had been created successfully.'
    else
      find_people_list
      fetch_clients
      render action: "new"
    end
  end

   # POST /projects
  # POST /projects.json
  def update
    @project = Project.find(params[:id])
    @project.person_ids = params[:project][:person_ids]

    if @project.save
      redirect_to detail_project_path(@project), notice: 'Project had been updated successfully.'
    else
      find_people_list.select! do |person| 
        !@project.people.include? person
      end
      render action: "edit"
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project = Project.find(params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to projects_url }
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

