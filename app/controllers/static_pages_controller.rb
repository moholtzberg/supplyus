class StaticPagesController < ApplicationController
  layout 'admin'
  helper_method :sort_column, :sort_direction
  before_action :set_static_page, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  
  def index
    update_index
  end
  
  def new
    @static_page = StaticPage.new
  end
  
  def create
    @static_page = StaticPage.new(static_page_params)
    @static_page.save
    update_index
  end
  
  def show
  end
  
  def edit
  end
    
  def update
    @static_page.update_attributes(static_page_params)
    update_index
  end

  def destroy
    @static_page.destroy
    update_index
  end
    
  private

  def set_static_page
    @static_page = StaticPage.find(params[:id])
  end

  def update_index
    @static_pages = StaticPage.order(sort_column + " " + sort_direction)
    unless params[:term].blank?
      @static_pages = @static_pages.lookup(params[:term]) if params[:term].present?
    end
    @static_pages = @static_pages.paginate(:page => params[:page], :per_page => 25)
  end

  def static_page_params
    params.require(:static_page).permit(:title, :content)
  end

  def sort_column
    StaticPage.column_names.include?(params[:sort]) ? params[:sort] : "static_pages.title"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end