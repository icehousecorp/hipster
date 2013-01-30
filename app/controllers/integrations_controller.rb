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
