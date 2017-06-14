class ItemsController < ApplicationController
  layout "admin"
  respond_to :html, :json
  def index
    # @items = Item.joins("INNER JOIN order_line_items ON items.id=order_line_items.item_id").order("order_line_items.quantity DESC").group("items.id, order_line_items.quantity")
    # unless params[:keywords].blank?
    #   # search = Item.search do
    #   #   fulltext params[:keywords], :highlight => true
    #   #   paginate :page => params[:page]
    #   # end
    #   # @items = search.results
    #   # puts @items.inspect
    # else
    #   @items = Item.paginate(:page => params[:page], :per_page => 25)
    # end
    # @items
    # ====
    authorize! :read, Item
    @items = Item.all
    if params[:times_ordered].present?
      @items = @items.times_ordered
    end
    unless params[:term].blank?
      @items = @items.lookup(params[:term]) if params[:term].present?
    end
    @items = @items.paginate(:page => params[:page], :per_page => 25)
    respond_to do |format|
      format.html
      format.json {render :json => @items.map { |item| {id: item.id, label: item.name } }}
    end
  end
  
  def new
    authorize! :create, Item
    @item = Item.new
    # @brands = Brand.active
    # @categories = Category.all
  end
  
  def show
    authorize! :read, Item
    @item = Item.find_by(:id => params[:id])
  end
  
  def search
    authorize! :read, Item
    @results = Item.where(nil)
    search_term = params[:keywords] if params[:keywords].present?
    search_term = params[:term] if params[:term].present?
    @results = @results.lookup(search_term).paginate(:page => params[:page], :per_page => 25)
    respond_to do |format|
      # format.json { render :json => @results.map {|a| [{:number => a.number}, {:name => a.name}] }}
      format.json {render :json => @results.map(&:number)}
    end
  end
  
  def create
    authorize! :create, Item
    @item = Item.create(registration_params)
    @items = Item.all
    @items = @items.paginate(:page => params[:page], :per_page => 25)
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def edit
    authorize! :update, Item
    @item = Item.find_by(:id => params[:id])
    # @brands = Brand.active
    # @categories = Category.all
  end
  
  def update
    authorize! :update, Item
    @item = Item.find_by(:id => params[:id])
    if @item.update_attributes(registration_params)
      flash[:notice] = "\"#{@item.number}\" has been updated"
    else
      flash[:error] = "There were some problems with the form you submitted"
    end
    @items = Item.all
    @items = @items.paginate(:page => params[:page], :per_page => 25)
    respond_to do |format|
      format.html
      format.js
      format.json do 
        respond_with_bip(@item)
      end
    end
    
  end
  
  def delete
    authorize! :destroy, Item
    @item = Item.find_by(:id => params[:id])
  end
  
  def destroy
    authorize! :destroy, Item
    e = Item.find_by(:id => params[:id])
    e.destroy!
    respond_to do |format|
      format.js { alert("ITem Detelet") }
    end
  end
  
  def actual_price_by_item_number_and_account_id
    account_id = Account.find_by(name: params[:account_name]).id
    @price = Item.find_by(number: params["item_number"]).actual_price(account_id)
    respond_to do |format|
      format.json {render :json => @price}
    end
  end
  
  # GET
  # def import_items
  # end

  # # POST
  # def upload_file
  #   return redirect_to import_file_path, alert: "File is required." unless params[:file].present?
  #   ImportItemWorker.perform_async(params[:file].path)
  #   redirect_to import_file_path, notice: "File pushed to the buckground worker, please see logs for more details about rows importation"
  # end
  
  private

  def registration_params
    params.require(:item).permit(:number, :name, :description, :price, :cost_price, :sale_price, :model_id, :is_serialized, :weight, :height, :width, :length, :item_type_id, :category_id, :brand_id, :brand_name, :category_name, :active, :category_tokens)
  end
  
end