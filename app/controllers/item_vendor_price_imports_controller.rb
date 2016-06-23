class ItemVendorPriceImportsController < ApplicationController
  layout "admin"
  def new
    authorize! :create, ItemVendorPriceImport
    @item_import = ItemVendorPriceImport.new
  end

  def create
    authorize! :create, ItemVendorPriceImport
    @item_import = ItemVendorPriceImport.new(params[:item_vendor_price_import])
    if @item_import.save
      redirect_to new_item_vendor_price_import_path, notice: "Imported items successfully."
    else
      render :new
    end
  end
  
  # def allowed_attributes
  #   params.require(:file).permit(:number, :description, :price, :cost_price, :sale_price, :model_id, :is_serialized, :weight, :height, :width, :length, :item_type_id, :category_id)
  # end
  
end