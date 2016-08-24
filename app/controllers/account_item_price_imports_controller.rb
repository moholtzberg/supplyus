class AccountItemPriceImportsController < ApplicationController
  layout "admin"
  def new
    authorize! :create, AccountItemPriceImport
    @item_import = AccountItemPriceImport.new
  end

  def create
    authorize! :create, AccountItemPriceImport
    @item_import = AccountItemPriceImport.new(params[:account_item_price_import])
    if @item_import.save
      redirect_to new_account_item_price_import_path, notice: "Imported items successfully."
    else
      render :new
    end
  end
  
  # def allowed_attributes
  #   params.require(:file).permit(:number, :description, :price, :cost_price, :sale_price, :model_id, :is_serialized, :weight, :height, :width, :length, :item_type_id, :category_id)
  # end
  
end