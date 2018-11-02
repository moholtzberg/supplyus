class ItemReferencesController < ApplicationController
  layout 'admin'
  
  def create
    @item_ref = ItemReference.new(item_reference_params)
    @item_ref.save
    @item = Item.find(@item_ref.original_item_id)
  end
  
  def delete
    @item_ref = ItemReference.find(params[:id])
    @item_ref.destroy
  end
  
  private
  
  def item_reference_params
    params.require(:item_reference).permit(:original_item_number, :original_uom, :original_uom_qty, :replacement_item_number, :repacement_uom, :replacement_uom_qty, :comments, :match_type, :xref_type)
  end
  
end