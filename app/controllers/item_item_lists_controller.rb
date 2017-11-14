class ItemItemListsController < ApplicationController
  layout "admin"
  before_action :set_item_item_list, only: [:destroy]
  load_and_authorize_resource
  
  def new
    @item_item_list = ItemItemList.new(item_item_list_params)
  end
  
  def create
    @item_list = ItemList.find(item_item_list_params[:item_list_id])
    @item_item_list = ItemItemList.create(item_item_list_params)
  end
  
  def destroy
    @item_list = @item_item_list.item_list
    @item_item_list.destroy!
  end
  
  private

  def set_item_item_list
    @item_item_list = ItemItemList.find(params[:id])
  end

  def item_item_list_params
    params.require(:item_item_list).permit(:item_id, :item_list_id)
  end
end