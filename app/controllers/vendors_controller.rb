class VendorsController < ApplicationController
  layout "admin"
  helper_method :sort_column, :sort_direction
  
  def index
    @vendors = Vendor.order(sort_column + " " + sort_direction).where("name like ?", "%#{params[:term]}%")
    respond_to do |format|
      format.html
      format.json {render :json => @vendors.map(&:name)}
    end
  end
  
  def new
    @vendor = Vendor.new
  end
  
  def show
    @vendor = Vendor.find(params[:id])
  end
  
  def create
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