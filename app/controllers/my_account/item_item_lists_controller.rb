class MyAccount::ItemItemListsController < ApplicationController

  def check_authorization
    
  end
  
  def create
    authorize! :create, ItemItemList
    @item_item_list = ItemItemList.create(item_item_list_params)
  end

  def destroy
    @item_item_list = ItemItemList.find(params[:id])
    authorize! :destroy, @item_item_list
    @item_item_list.destroy
  end

  def item_item_list_params
    params.require(:item_item_list).permit(:item_list_id, :item_id)
  end

end
