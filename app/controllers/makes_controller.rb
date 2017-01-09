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
    related_columns = Make.reflect_on_all_associations(:belongs_to).map {|a| a.klass.column_names.map {|col| "#{a.klass.table_name}.#{col}"}}
    columns = Make.column_names.map {|a| "makes.#{a}" }
    columns.push(related_columns).flatten!.uniq!
    columns.include?(params[:sort]) ? params[:sort] : "makes.id"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end