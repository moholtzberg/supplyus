class EquipmentImportsController < ApplicationController
  layout "admin"
  def new
    # authorize! :create, EquipmentImport
    @item_import = EquipmentImport.new
  end

  def create
    # authorize! :create, EquipmentImport
    @item_import = EquipmentImport.new(params[:equipment_import])
    if @item_import.save
      redirect_to equipment_index_path, notice: "Imported equipment successfully."
    else
      render :new
    end
  end
  
end