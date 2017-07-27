class PriceImportsController < ApplicationController
  layout "admin"
  def new
    authorize! :create, PriceImport
    @price_import = PriceImport.new
  end

  def create
    authorize! :create, PriceImport
    @price_import = PriceImport.new(params[:price_import])
    if @price_import.save
      redirect_to new_price_import_path, notice: "Imported prices successfully."
    else
      render :new
    end
  end
  
  # def allowed_attributes
  #   params.require(:file).permit(:number, :description, :price, :cost_price, :sale_price, :model_id, :is_serialized, :weight, :height, :width, :length, :item_type_id, :category_id)
  # end
  
end