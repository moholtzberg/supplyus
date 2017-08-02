class InventoriesController < ApplicationController
  layout "admin"
  respond_to :html, :json

  def index
    authorize! :read, Inventory
    @inventories = Inventory.all
    unless params[:term].blank?
      @inventories = @inventories.lookup(params[:term]) if params[:term].present?
    end
    @inventories = @inventories.paginate(:page => params[:page], :per_page => 25)
  end
  
  def show
    authorize! :read, Inventory
    @inventory = Inventory.find_by(:id => params[:id])
  end
  
  def search
    authorize! :read, Inventory
    @results = Inventory.where(nil)
    search_term = params[:keywords] if params[:keywords].present?
    search_term = params[:term] if params[:term].present?
    @results = @results.lookup(search_term).paginate(:page => params[:page], :per_page => 25)
    respond_to do |format|
      format.json {render :json => @results.to_json}
    end
  end
end