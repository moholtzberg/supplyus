class UsersController < ApplicationController
  layout "admin"
  helper_method :sort_column, :sort_direction
  
  def index
    @users = User.order(sort_column + " " + sort_direction).includes(:account)
    @users = @users.paginate(:page => params[:page], :per_page => 25)
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      puts user_params[:email]
      if Account.find_by(:email => params[:user][:email])
        Account.find_by(:email => params[:user][:email]).update_attributes(:user_id => @user.id)
      end
      @users = User.order(sort_column + " " + sort_direction).includes(:account)
      @users = @users.paginate(:page => params[:page], :per_page => 25)
    end
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
  
  def user_params
     params.require(:user).permit(:email, :password, :password_confirmation)
  end
  
end