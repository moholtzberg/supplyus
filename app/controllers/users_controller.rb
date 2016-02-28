class UsersController < ApplicationController
  layout "admin"
  helper_method :sort_column, :sort_direction
  
  def index
    @users = User.order(sort_column + " " + sort_direction)
    @users = @users.paginate(:page => params[:page], :per_page => 25)
  end
  
  def new
    @user = User.new
  end
  
  def show
    @users = User.find(params[:id])
  end
  
  private
  
  def sort_column
    related_columns = User.reflect_on_all_associations(:belongs_to).map {|a| a.klass.column_names.map {|col| "#{a.klass.table_name}.#{col}"}}
    columns = User.column_names.map {|a| "users.#{a}" }
    columns.push(related_columns).flatten!.uniq!
    columns.include?(params[:sort]) ? params[:sort] : "users.id"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
  
end