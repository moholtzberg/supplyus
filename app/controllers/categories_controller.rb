class CategoriesController < ApplicationController
  layout "admin"
  
  def index
    @categories = Category.includes(:item_categories).order(:parent_id).where("name like ?", "%#{params[:term]}%")
    respond_to do |format|
      format.html
      format.json {render :json => @categories.map(&:name)}
    end
  end
  
  def new
    @brand = Brand.new
  end
  
  def show
    @brand = Brand.find_by(:id => params[:id])
  end
  
  def create
    @brand = Brand.create(:name => params[:brand][:name], :active => params[:brand][:active], :preferred => params[:brand][:preferred])
    @brands = Brand.all
  end
  
  def edit
    @brand = Brand.find_by(:id => params[:id])
  end
  
  def update
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