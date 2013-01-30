class IntegrationsController < ApplicationController
  before_filter :find_user
  before_filter :fetch_projects, only: [:new , :edit]

  def find_user
    @user = User.find(params[:user_id])
  end

  def fetch_projects
    api = Api::HarvestClient.new(@user)
    @harvest_projects = api.all_projects
    @pivotal_projects = []
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
        format.html { redirect_to @integration, notice: 'Integration was successfully created.' }
        format.json { render json: @integration, status: :created, location: @integration }
      else
        fetch_projects
        format.html { render action: "new" }
        format.json { render json: @integration.errors, status: :unprocessable_entity }
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
