class PersonMappingsController < ApplicationController
  CACHE_PERIODE = 5.minutes
  before_filter :find_integration, except: [:show, :edit, :destroy]

  def find_integration
    @integration = Integration.find(params[:integration_id])
  end

  def find_all_harvest_users
    Rails.cache.fetch("harvest_users_#{@integration.id}", expires_in: CACHE_PERIODE) do
      api = Api::HarvestClient.new @integration.user
      api.all_users(@integration.harvest_project_id)
    end
  end

  def find_single_harvest_users
    @harvest_single_users ||= find_all_harvest_users
    mapped_id = @integration.person_mappings.map(&:harvest_id)
    @harvest_single_users.reject!{|user| mapped_id.include?(user.id) }
  end

  def find_all_pivotal_users
    Rails.cache.fetch("pivotal_users_#{@integration.id}", expires_in: CACHE_PERIODE) do
      api = Api::PivotalClient.new @integration.user
      api.all_users(@integration.harvest_project_id)
    end
  end

  def find_single_pivotal_users
    @pivotal_single_users ||= find_all_pivotal_users
    mapped_email = @integration.person_mappings.map(&:email)
    @pivotal_single_users.reject!{|user| mapped_email.include?(user.email) }
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

  def person_mapping_params
    pivotal_id = params[:person_mapping].delete(:pivotal_name)
    pivotal_users = find_all_pivotal_users
    puts pivotal_users.inspect
    pivotal_user = pivotal_users.select{|user| user.id == pivotal_id.to_i}.first
    # params[:person_mapping][:pivotal_id] = pivotal_id
    params[:person_mapping][:pivotal_name] = pivotal_user.name
    params[:person_mapping][:email] = pivotal_user.email
    params[:person_mapping]
  end

  # POST /person_mappings
  # POST /person_mappings.json
  def create
    @person_mapping = PersonMapping.new(person_mapping_params)

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
      format.html { redirect_to integration_person_mappings_url(@person_mapping.integration_id) }
      format.json { head :no_content }
    end
  end
end
