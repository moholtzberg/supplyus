class MakesController < ApplicationController
  layout "admin"
  
  def index
    # authorize! :read, Model
    @makes = Make.order(sort_column + " " + sort_direction).includes(:models)
    unless params[:term].blank?
      @makes = @makes.lookup(params[:term]) if params[:term].present?
    end
    @makes = @makes.paginate(:page => params[:page], :per_page => 10)
  end
  
  
  
  private

  def make_params
    params.require(:make).permit(:name)
  end

  def sort_column
    Make.column_names.include?(params[:sort]) ? params[:sort] : "id"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end