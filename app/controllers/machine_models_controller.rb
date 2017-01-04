class MachineModelsController < ApplicationController
  layout "admin"
  
  def index
    # authorize! :read, Model
    @models = MachineModel.order(sort_column + " " + sort_direction).includes(:make)
    unless params[:term].blank?
      @models = @models.lookup(params[:term]) if params[:term].present?
    end
    @models = @models.paginate(:page => params[:page], :per_page => 20)
  end
  
  
  
  private

  def account_params
    params.require(:equipment).permit(:number, :serial)
  end

  def sort_column
    MachineModel.column_names.include?(params[:sort]) ? params[:sort] : "number"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end