class BrandImportsController < ApplicationController
  layout "admin"
  def new
    authorize! :create, BrandImport
    @item_import = BrandImport.new
  end

  def create
    authorize! :create, BrandImport
    @item_import = BrandImport.new(params[:brand_import])
    if @item_import.save
      redirect_to brands_path, notice: "Imported brands successfully."
    else
      render :new
    end
  end
  
end