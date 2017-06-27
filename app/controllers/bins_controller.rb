class BinsController < ApplicationController
  layout "admin"
  respond_to :html, :json
  def index
    authorize! :read, Bin
    @bins = Bin.all
    unless params[:term].blank?
      @bins = @bins.lookup(params[:term]) if params[:term].present?
    end
    @bins = @bins.paginate(:page => params[:page], :per_page => 25)
    respond_to do |format|
      format.html
      format.json {render :json => @bins.map { |bin| {id: bin.id, label: bin.name } }}
    end
  end
  
  def new
    authorize! :create, Bin
    @bin = Bin.new
    # @brands = Brand.active
    # @categories = Category.all
  end
  
  def show
    authorize! :read, Bin
    @bin = Bin.find_by(:id => params[:id])
    @inventories = @bin.inventories.with_items.joins(:item).order(:item_id)
    unless params[:term].blank?
      @inventories = @inventories.lookup(params[:term]) if params[:term].present?
    end
    @inventories = @inventories.paginate(:page => params[:page], :per_page => 25)
  end
  
  def search
    authorize! :read, Bin
    @results = Bin.where(nil)
    search_term = params[:keywords] if params[:keywords].present?
    search_term = params[:term] if params[:term].present?
    @results = @results.lookup(search_term).paginate(:page => params[:page], :per_page => 25)
    respond_to do |format|
      format.json {render :json => @results.to_json}
    end
  end
  
  def create
    authorize! :create, Bin
    @bin = Bin.create(bin_params)
    @bins = Bin.all
    @bins = @bins.paginate(:page => params[:page], :per_page => 25)
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def edit
    authorize! :update, Bin
    @bin = Bin.find_by(:id => params[:id])
  end
  
  def update
    authorize! :update, Bin
    @bin = Bin.find_by(:id => params[:id])
    if @bin.update_attributes(bin_params)
      flash[:notice] = "\"#{@bin.name}\" has been updated"
    else
      flash[:error] = "There were some problems with the form you submitted"
    end
    @bins = Bin.all
    @bins = @bins.paginate(:page => params[:page], :per_page => 25)
    respond_to do |format|
      format.html
      format.js
      format.json do 
        respond_with_bip(@bin)
      end
    end
  end
  
  def destroy
    authorize! :destroy, Bin
    e = Bin.find_by(:id => params[:id])
    e.destroy!
    @bins = Bin.all
    @bins = @bins.paginate(:page => params[:page], :per_page => 25)
    respond_to do |format|
      format.js
    end
  end
  
  private

  def bin_params
    params.require(:bin).permit(:name, :_type)
  end
  
end