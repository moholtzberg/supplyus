class CategoriesController < ApplicationController
  layout 'admin'
  respond_to :html, :json
  before_action :set_category, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource except: [:datatables, :autocomplete]

  def datatables
    authorize! :read, Category
    render json: CategoryDatatable.new(view_context)
  end

  def autocomplete
    authorize! :read, Category
    @categories = Category.includes(:parent).order(:parent_id)
    unless params[:term].blank?
      @categories = @categories.lookup(params[:term]) if params[:term].present?
    end
    @categories = @categories.paginate(:page => params[:page], :per_page => 25)
    render json: @categories.map { |cat| {id: cat.id, label: cat.name, name: cat.name, text: cat.name } }
  end
  
  def index
  end
  
  def new
    @category = Category.new
  end
  
  def create
    @category = Category.create(category_params)
  end
  
  def show
    @items = @category.items
    unless params[:term].blank?
      @items = @items.lookup(params[:term]) if params[:term].present?
    end
    @items = @items.paginate(:page => params[:page], :per_page => 25)
  end
  
  def edit
  end
  
  def update
    @category.update_attributes(category_params)
  end
  
  def destroy
    @category.destroy
  end
    
  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :active, :slug, :show_in_menu, :menu_id, :position, :parent_id)
  end
  
end