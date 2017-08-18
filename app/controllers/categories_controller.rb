class CategoriesController < ApplicationController
  layout "admin"
  respond_to :html, :json
  before_action :set_category, only: [:show, :edit, :update, :destroy]

  def datatables
    authorize! :read, Category
    render json: CategoryDatatable.new(view_context)
  end

  def autocomplete
    authorize! :read, Category
    term = params[:keywords]
    @categories = Category.includes(:parent).order(:parent_id)
    unless params[:term].blank?
      @categories = @categories.lookup(params[:term]) if params[:term].present?
    end
    @categories = @categories.paginate(:page => params[:page], :per_page => 25)
    render json: @categories.map { |cat| {id: cat.id, label: cat.name } }
  end
  
  def index
    authorize! :read, Category
  end
  
  def new
    authorize! :create, Category
    @category = Category.new
    flash[:error] = @category.errors.any? ? @category.errors.full_messages.join(', ') : nil
  end
  
  def create
    authorize! :create, @category
    @category = Category.create(category_params)
    flash[:error] = @category.errors.any? ? @category.errors.full_messages.join(', ') : nil
  end
  
  def show
    authorize! :read, @category
  end
  
  def edit
    authorize! :update, @category
  end
  
  def update
    authorize! :update, @category
    @category.update_attributes(category_params)
    flash[:error] = @category.errors.any? ? @category.errors.full_messages.join(', ') : nil
  end
  
  def destroy
    authorize! :destroy, @category
    @category.destroy
  end
    
  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :active, :slug, :show_in_menu, :menu_id, :parent_name)
  end
  
end