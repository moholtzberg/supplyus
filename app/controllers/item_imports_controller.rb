class ItemImportsController < ApplicationController
  layout "admin"
  imported = 0

  def new
    authorize! :create, ItemImport
    @item_import = ItemImport.new
  end

  def create
    authorize! :create, ItemImport
    @item_import = ItemImport.new(params[:item_import])
    if @item_import.save
      redirect_to items_path, notice: "Imported items successfully."
    end
    #Return error if file doesn't exist
    return redirect_to new_item_import_path, alert: "File is required." unless params[:item_import].present?
    import_hisotry = ImportHistory.create(nb_imported: 0, nb_failed:0, nb_in_queue: 0, is_processing: 1)
    # Launch the worker
    ImportItemWorker.perform_async(params[:item_import]["file"].path, import_hisotry.id)
    redirect_to new_item_import_path, notice: "File pushed to the buckground worker"
    
    # @item_import = ItemImport.new(params[:item_import])
    # if @item_import.save
    #   redirect_to items_path, notice: "Imported items successfully."
    # else
    #   render :new
    # end
  end
  



  def check_for_import
    #This method id for check the rows importation
    import_item = ImportHistory.last
    if import_item
      render json: {nb_imported: import_item.nb_imported, nb_failed:import_item.nb_failed, nb_in_queue: import_item.nb_in_queue, failed_lines: import_item.failed_lines, is_processing: import_item.is_processing}
    else
      render json: {nb_imported: 0, nb_failed:0, nb_in_queue: 0}
    end
  end
  
  # def allowed_attributes
  #   params.require(:file).permit(:number, :description, :price, :cost_price, :sale_price, :model_id, :is_serialized, :weight, :height, :width, :length, :item_type_id, :category_id)
  # end
  
end