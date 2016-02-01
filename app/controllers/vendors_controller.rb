class VendorsController < ApplicationController
  layout "admin"
  
  def index
    @vendors = Vendor.all
  end
  
  def new
    @vendor = Vendor.new
  end
  
  def show
    @vendor = Vendor.find(params[:id])
  end
  

  private

  def registration_params
    params.require(:vendor).permit(:name, :email, :address_1, :address_2, :city, :state, :zip, :phone, :fax)
  end
  
end