class VendorsController < ApplicationController
  layout "admin"
  helper_method :sort_column, :sort_direction

  # For checking rights permissions here we use alias for vendor -> :vendor, not Class (Vendor), because Vendor inherits from Account. It described in ability.rb

  def index
    authorize! :read, :vendor
    @vendors = Vendor.order(sort_column + " " + sort_direction).where("name like ?", "%#{params[:term]}%")
    respond_to do |format|
      format.html
      format.json {render :json => @vendors.map(&:name)}
    end
  end
  
  def new
    authorize! :create, :vendor
    @vendor = Vendor.new
  end
  
  def show
    authorize! :read, :vendor
    @vendor = Vendor.find(params[:id])
  end
  
  def create
    authorize! :create, :vendor
    @vendor = Vendor.new(vendor_params)
    if @vendor.save
      @vendors = Vendor.order(sort_column + " " + sort_direction)
    end
  end
  
  private

  def vendor_params
    params.require(:vendor).permit(:name, :email, :address_1, :address_2, :city, :state, :zip, :phone, :fax, :email)
  end
  
  def sort_column
    puts Vendor.column_names[0]
    Vendor.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end