class CategoriesController < ApplicationController
  layout "admin"
  # respond_to :html, :json
  def index
    authorize! :read, Category
    term = params[:keywords]
    @categories = Category.includes(:parent).order(:parent_id).where("lower(name) like ?", "%#{term}%")
    @categories = @categories.paginate(:page => params[:page], :per_page => 25)
    respond_to do |format|
      format.html
      format.json {render :json => @categories.map(&:name)}
    end
  end
  
  def new
    authorize! :create, Category
    @category = Category.new
  end
  
  def show
    authorize! :read, Category
    @category = Category.find_by(:id => params[:id])
  end
  
  def create
    authorize! :create, Category
    @category = Category.create(registration_params)
    @categories = Category.all
  end
  
  def edit
    authorize! :update, Category
    @category = Category.find_by(:id => params[:id])
  end
  
  def update
    authorize! :update, Category
    @category = Category.find_by(:id => params[:id])
    if @category.update_attributes(registration_params)
      flash[:notice] = "\"#{@category.name}\" has been updated"
    else
      flash[:error] = "There were some problems with the form you submitted"
    end
  end
  
  private

  def registration_params
    params.require(:category).permit(:name, :active, :slug, :show_in_menu, :menu_id, :parent_name)
  end
  
end