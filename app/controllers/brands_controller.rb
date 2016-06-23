class BrandsController < ApplicationController
  layout "admin"
  
  def index
    authorize! :read, Brand
    @brands = Brand.order(:name).where("name like ?", "%#{params[:term]}%")
    respond_to do |format|
      format.html
      format.json {render :json => @brands.map(&:name)}
    end
  end
  
  def new
    authorize! :create, Brand
    @brand = Brand.new
  end
  
  def show
    authorize! :read, Brand
    @brand = Brand.find_by(:id => params[:id])
  end
  
  def create
    authorize! :create, Brand
    @brand = Brand.create(:name => params[:brand][:name], :active => params[:brand][:active], :preferred => params[:brand][:preferred])
    @brands = Brand.all
  end
  
  def edit
    authorize! :update, Brand
    @brand = Brand.find_by(:id => params[:id])
  end
  
  def update
    authorize! :update, Brand
    @brand = Brand.find_by(:id => params[:id])
    if @brand.update_attributes(:name => params[:brand][:name], :active => params[:brand][:active], :preferred => params[:brand][:preferred])
      flash[:notice] = "\"#{@brand.name}\" has been updated"
    else
      flash[:error] = "There were some problems with the form you submitted"
    end
    @brands = Brand.all
  end
  
  private

  def registration_params
    params.require(:brand).permit(:name, :active, :preferred)
  end
  
end