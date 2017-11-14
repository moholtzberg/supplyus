class ItemListsController < ApplicationController
  layout 'admin'
  helper_method :sort_column, :sort_direction
  before_action :set_item_list, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  
  def index
    update_index
  end
  
  def new
    @item_list = ItemList.new
  end
  
  def create
    @item_list = ItemList.new(item_list_params)
    @item_list.save
    update_index
  end
  
  def show
  end
  
  def edit
  end
    
  def update
    @item_list.update_attributes(item_list_params)
    update_index
  end

  def destroy
    @item_list.destroy
    update_index
  end
    
  private

  def set_item_list
    @item_list = ItemList.find(params[:id])
  end

  def update_index
    @item_lists = ItemList.includes(:user).order(sort_column + " " + sort_direction)
    unless params[:term].blank?
      @item_lists = @item_lists.lookup(params[:term]) if params[:term].present?
    end
    @item_lists = @item_lists.paginate(:page => params[:page], :per_page => 25)
  end

  def item_list_params
    params.require(:item_list).permit(:name, :user_id)
  end

  def sort_column
    related_columns = ItemList.reflect_on_all_associations(:belongs_to).map {|a| a.klass.column_names.map {|col| "#{a.klass.table_name}.#{col}"}}
    columns = ItemList.column_names.map {|a| "item_lists.#{a}" }
    columns.push(related_columns).flatten!.uniq!
    columns.include?(params[:sort]) ? params[:sort] : "item_lists.name"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end