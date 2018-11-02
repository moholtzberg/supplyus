class ShippingMethodsController < ApplicationController
  layout 'admin'
  helper_method :sort_column, :sort_direction
  before_action :set_address, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  
  def index
    update_index
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @shipping_methods.to_json }
    end
  end
  
  def new
    @shipping_method = ShippingMethod.new
  end
  
  def create
    @shipping_method = ShippingMethod.create(shipping_method_params)
    update_index
  end
  
  def show
  end
  
  def edit
  end
    
  def update
    @shipping_method.update_attributes(shipping_method_params)
    update_index
  end

  def destroy
    @shipping_method.destroy!
  end
  
  private

  def set_shipping_method
    @shipping_method = ShippingMethod.find(params[:id])
  end

  def update_index
    @shipping_methods = ShippingMethod.includes(:shipping_calculator).order(sort_column + " " + sort_direction)
    unless params[:term].blank?
      @shipping_methods = @shipping_methods.lookup(params[:term]) if params[:term].present?
    end
    @shipping_methods = @shipping_methods.paginate(:page => params[:page], :per_page => 25)
  end

  def shipping_method_params
    params.require(:shipping_method).permit(:name, :address_1, :address_2, :city, :state, :zip, :phone, :fax, :main, :account_id, :account_name)
  end

  def sort_column
    related_columns = ShippingMethod.reflect_on_all_associations(:belongs_to).map {|a| a.klass.column_names.map {|col| "#{a.klass.table_name}.#{col}"}}
    columns = ShippingMethod.column_names.map {|a| "addresses.#{a}" }
    columns.push(related_columns).flatten!.uniq!
    columns.include?(params[:sort]) ? params[:sort] : "shipping_methods.id"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end