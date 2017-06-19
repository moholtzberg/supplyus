class MyAccount::ItemItemListsController < ApplicationController

  def create
    authorize! :create, ItemItemList
    @item_item_list = ItemItemList.create(item_item_list_params)
  end

  def item_item_list_params
    params.require(:item_item_list).permit(:item_list_id, :item_id)
  end

end
