class ItemImportsController < ApplicationController
  layout "admin"
  def new
    @item_import = ItemImport.new
  end

  def create
    @item_import = ItemImport.new(params[:item_import])
    if @item_import.save
      redirect_to items_path, notice: "Imported items successfully."
    else
      render :new
    end
  end
  
  # def allowed_attributes
  #   params.require(:file).permit(:number, :description, :price, :cost_price, :sale_price, :model_id, :is_serialized, :weight, :height, :width, :length, :item_type_id, :category_id)
  # end
  
end