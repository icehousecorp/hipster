class PersonMappingsController < ApplicationController
  before_filter :find_integration, except: [:show, :edit, :destroy]

  def find_integration
    @integration = Integration.find(params[:integration_id])
  end

  def find_single_harvest_users
    unless @harvest_single_users
      api = Api::HarvestClient.new @integration.user
      @harvest_single_users = api.all_single_users(@integration.harvest_project_id)
    end
    @harvest_single_users
  end

  def find_single_pivotal_users
    unless @pivotal_single_users
      api = Api::PivotalClient.new @integration.user
      @pivotal_single_users = api.all_single_members(@integration.harvest_project_id)
    end
    @pivotal_single_users
  end

  # GET /person_mappings
  # GET /person_mappings.json
  def index
    @person_mappings = PersonMapping.where(integration_id: params[:integration_id])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @person_mappings }
    end
  end

  # GET /person_mappings/1
  # GET /person_mappings/1.json
  def show
    @person_mapping = PersonMapping.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @person_mapping }
    end
  end

  # GET /person_mappings/new
  # GET /person_mappings/new.json
  def new
    find_single_harvest_users
    find_single_pivotal_users
    @person_mapping = PersonMapping.new(integration_id: params[:integration_id])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @person_mapping }
    end
  end

  # GET /person_mappings/1/edit
  def edit
    @person_mapping = PersonMapping.find(params[:id])
  end

  # POST /person_mappings
  # POST /person_mappings.json
  def create
    @person_mapping = PersonMapping.new(params[:person_mapping])

    respond_to do |format|
      if @person_mapping.save
        format.html { redirect_to @person_mapping, notice: 'Person mapping was successfully created.' }
        format.json { render json: @person_mapping, status: :created, location: @person_mapping }
      else
        format.html { render action: "new" }
        format.json { render json: @person_mapping.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /person_mappings/1
  # PUT /person_mappings/1.json
  def update
    @person_mapping = PersonMapping.find(params[:id])

    respond_to do |format|
      if @person_mapping.update_attributes(params[:person_mapping])
        format.html { redirect_to @person_mapping, notice: 'Person mapping was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @person_mapping.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /person_mappings/1
  # DELETE /person_mappings/1.json
  def destroy
    @person_mapping = PersonMapping.find(params[:id])
    @person_mapping.destroy

    respond_to do |format|
      format.html { redirect_to person_mappings_url }
      format.json { head :no_content }
    end
  end
end
