class MachineModelsController < ApplicationController
  layout "admin"
  helper_method :sort_column, :sort_direction
  
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
    related_columns = MachineModel.reflect_on_all_associations(:belongs_to).map {|a| a.klass.column_names.map {|col| "#{a.klass.table_name}.#{col}"}}
    columns = MachineModel.column_names.map {|a| "models.#{a}" }
    columns.push(related_columns).flatten!.uniq!
    columns.include?(params[:sort]) ? params[:sort] : "models.id"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end