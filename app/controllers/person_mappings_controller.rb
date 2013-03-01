class PersonMappingsController < ApplicationController
  CACHE_PERIODE = 5.minutes
  HARVEST_EXCEPTIONS = [Harvest::NotFound, Harvest::ServerError, Harvest::AuthenticationFailed, RestClient::ResourceNotFound]
  before_filter :find_integration, except: [:show, :edit, :destroy]

  def find_integration
    @integration = Project.find(params[:integration_id])
  end

  def safe_invoke
    begin
      yield
    rescue *HARVEST_EXCEPTIONS
      redirect_to detail_project_path(@integration), notice: 'The project might have been deleted or there was an error occured in Harvest and/or Pivotal server.'
    end
  end

  def find_single_harvest_users
    @harvest_single_users ||= harvest_api.cached_users(@integration.id, @integration.harvest_project_id)
    mapped_id = @integration.person_mappings.map(&:harvest_id)
    @harvest_single_users.reject!{|user| mapped_id.include?(user.id) }
  end

  def find_single_pivotal_users
    @pivotal_single_users ||= pivotal_api.cached_users(@integration.id, @integration.pivotal_project_id)
    mapped_email = @integration.person_mappings.map(&:pivotal_email)
    @pivotal_single_users.reject!{|user| mapped_email.include?(user.email) }
  end

  def populate
    pivotal_users = pivotal_api.cached_users(@integration.id, @integration.pivotal_project_id)
    pivotal_users.select do |pivotal_user|
      harvest_user = harvest_api.get_harvest_user_by_email(@integration.id, @integration.harvest_project_id, pivotal_user.email).first
      unless harvest_user.blank?
        @person_mapping = @integration.create_mapping(pivotal_user, harvest_user)
        @person_mapping.save
      end
      false
    end unless pivotal_users.blank?
    redirect_to detail_project_path(@integration)
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
    safe_invoke {
      find_single_harvest_users
      find_single_pivotal_users
      
      @person_mapping = PersonMapping.new(integration_id: params[:integration_id])

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @person_mapping }
      end
    }
  end

  # GET /person_mappings/1/edit
  def edit
    safe_invoke {
      @person_mapping = PersonMapping.find(params[:id])
      @integration = @person_mapping.integration
      find_single_harvest_users
      find_single_pivotal_users
    }
  end

  # POST /person_mappings
  # POST /person_mappings.json
  def create
    safe_invoke {
      @person_mapping = PersonMapping.new(params[:person_mapping])
    
      respond_to do |format|
        if @person_mapping.save
          format.html { redirect_to detail_project_url(@integration), notice: 'Person mapping was successfully created.' }
          format.json { render json: @person_mapping, status: :created, location: @person_mapping }
        else
          find_single_harvest_users
          find_single_pivotal_users
          format.html { render action: "new" }
          format.json { render json: @person_mapping.errors, status: :unprocessable_entity }
        end
      end
  }
  end

  # PUT /person_mappings/1
  # PUT /person_mappings/1.json
  def update
    safe_invoke {
      @person_mapping = PersonMapping.find(params[:id])

      respond_to do |format|
        if @person_mapping.update_attributes(person_mapping_params)
          format.html { redirect_to @person_mapping, notice: 'Person mapping was successfully updated.' }
          format.json { head :no_content }
        else
          @integration = @person_mapping.integration
          find_single_harvest_users
          find_single_pivotal_users

          format.html { render action: "edit" }
          format.json { render json: @person_mapping.errors, status: :unprocessable_entity }
        end
      end
    }
  end

  # DELETE /person_mappings/1
  # DELETE /person_mappings/1.json
  def destroy
    @person_mapping = PersonMapping.find(params[:id])
    @person_mapping.destroy

    respond_to do |format|
      format.html { redirect_to detail_project_url(@person_mapping.integration) }
      format.json { head :no_content }
    end
  end
end
