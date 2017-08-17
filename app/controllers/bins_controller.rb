class BinsController < ApplicationController
  layout 'admin'
  helper_method :sort_column, :sort_direction
  before_action :set_bin, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  def index
    update_index
    respond_to do |format|
      format.html
      format.js
      format.json {render :json => @bins.map { |bin| {id: bin.id, label: bin.name } }}
    end
  end
  
  def new
    @bin = Bin.new
  end
  
  def show
    @inventories = @bin.inventories.with_items.joins(:item).order(:item_id)
    unless params[:term].blank?
      @inventories = @inventories.lookup(params[:term]) if params[:term].present?
    end
    @inventories = @inventories.paginate(:page => params[:page], :per_page => 25)
  end
  
  def create
    @bin = Bin.create(bin_params)
    update_index
  end
  
  def edit
  end
  
  def update
    @bin.update_attributes(bin_params)
    update_index
    respond_to do |format|
      format.html
      format.js
      format.json do 
        respond_with_bip(@bin)
      end
    end
  end
  
  def destroy
    @bin.destroy
    update_index
  end
  
  private

  def set_bin
    @bin = Bin.find(params[:id])
  end

  def update_index
    @bins = Bin.order(sort_column + " " + sort_direction)
    unless params[:term].blank?
      @bins = @bins.lookup(params[:term]) if params[:term].present?
    end
    @bins = @bins.paginate(:page => params[:page], :per_page => 25)
  end

  def bin_params
    params.require(:bin).permit(:name, :_type, :warehouse_id)
  end
  
  def sort_column
    Bin.column_names.include?(params[:sort]) ? params[:sort] : "bins.name"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end