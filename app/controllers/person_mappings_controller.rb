class PersonMappingsController < ApplicationController
  # DELETE /person_mappings/1
  # DELETE /person_mappings/1.json
  def destroy
    @person_mapping = PersonMapping.find(params[:id])
    @person_mapping.destroy

    respond_to do |format|
      format.html { redirect_to detail_project_url(@person_mapping.project) }
      format.json { head :no_content }
    end
  end
end
