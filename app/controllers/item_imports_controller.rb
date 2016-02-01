class ItemImportsController < ApplicationController
  layout "admin"
  def new
    @item_import = ItemImport.new
  end

  def create
    @item_import = ItemImport.new(params[:item_import])
    if @item_import.save
      redirect_to root_url, notice: "Imported items successfully."
    else
      render :new
    end
  end
  
end