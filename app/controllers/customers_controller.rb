class CustomersController < ApplicationController
  layout "admin"
  helper_method :sort_column, :sort_direction
  respond_to :html, :json
  
  def index
    authorize! :read, Customer
    @customers = Customer.order(sort_column + " " + sort_direction)
  end
  
  def new
    authorize! :create, Customer
    @customer = Customer.new
  end
  
  def show
    authorize! :read, Customer
    @customer = Customer.find(params[:id])
  end
  
  private
  
  def sort_column
    puts Account.column_names[0]
    Account.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end