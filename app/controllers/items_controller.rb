class ItemsController < ApplicationController
  layout "admin"
  respond_to :html, :json
  before_action :set_item, only: [:show, :edit, :update, :destroy, :add_image, :remove_image]

  def datatables
    authorize! :read, Item
    render json: ItemDatatable.new(view_context)
  end

  def autocomplete
    authorize! :read, Item
    @results = Item.where(nil)
    search_term = params[:keywords] if params[:keywords].present?
    search_term = params[:term] if params[:term].present?
    @results = @results.lookup(search_term).paginate(:page => params[:page], :per_page => 25)
    render json: @results.map { |item| {id: item.id, label: item.number, name: item.name} }
  end
  
  def index
    authorize! :read, Item
  end

  def new
    authorize! :create, Item
    @item = Item.new
    flash[:error] = @item.errors.any? ? @item.errors.full_messages.join(', ') : nil
  end
  
  def create
    authorize! :create, Item
    @item = Item.create(item_params)
    flash[:error] = @item.errors.any? ? @item.errors.full_messages.join(', ') : nil
  end
  
  def show
    authorize! :read, @item
  end
  
  def edit
    authorize! :update, @item
  end
  
  def update
    authorize! :update, @item
    @item.update_attributes(item_params)
    flash[:error] = @item.errors.any? ? @item.errors.full_messages.join(', ') : nil
    respond_to do |format|
      format.html do
        redirect_to @item
      end
      format.js
      format.json do 
        respond_with_bip(@item)
      end
    end
    
  end
  
  def destroy
    authorize! :destroy, Item
    @item.destroy
  end
  
  def actual_price_by_item_number_and_account_id
    account_id = Account.find_by(name: params[:account_name])&.id
    @price = Item.find_by(number: params["item_number"])&.actual_price(account_id)
    render json: @price
  end

  def add_image
    authorize! :update, @item
    @image = @item.images.create(attachment: params[:file_data])
    render json: {
      error: (@image.errors.full_messages.join(', ') if @image.errors.any?),
      initialPreview: [@image.attachment&.url],
      initialPreviewConfig: [{caption: @image.attachment_file_name.gsub(/(.*)\.\w*$/, '\1'), key: @image.id, extra: @image.position}]
    }
  end

  def remove_image
    authorize! :update, @item
    @image = Image.find(params[:key]).destroy
    render json: {
      error: (@image.errors.full_messages.join(', ') if @image.errors.any?)
    }
  end

  def image_position
    @image = Image.find(params[:key]).update_attribute(:position, params[:extra])
    head :no_content
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

  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:number, :name, :description, :price, :cost_price, :sale_price, :model_id, 
      :is_serialized, :weight, :height, :width, :length, :item_type_id, :category_id, :brand_id, :brand_name, 
      :category_name, :active, :category_tokens, prices_attributes: [:id, :_type, :price, :start_date, :end_date, :min_qty, :max_qty, :appliable_type, :appliable_id, :combinable, :_destroy])
  end
  
end