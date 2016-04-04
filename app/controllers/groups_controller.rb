class GroupsController < ApplicationController
  layout "admin"
  helper_method :sort_column, :sort_direction
  
  def index
    @groups = Group.order(sort_column + " " + sort_direction)
    unless params[:term].blank?
      @groups = @groups.lookup(params[:term]) if params[:term].present?
    end
    respond_to do |format|
      format.html
      format.json {render :json => @groups.map(&:name)}
    end
  end
  
  def new
    @group = Group.new
  end
  
  def show
    @group = Group.find(params[:id])
  end

  
  def create
    @group = Group.new(group_params)
    if @group.save
      @groups = Group.order(sort_column + " " + sort_direction)
    end
  end

  private

  def group_params
    params.require(:group).permit(:group_type, :name, :description)
  end

  def sort_column
    puts Account.column_names[0]
    Account.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end