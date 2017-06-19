class MyAccount::ItemListsController < ApplicationController

  def new
    authorize! :create, ItemList
    @item_list = ItemList.new(item_list_params.merge(user_id: current_user.id))
  end

  def create
    authorize! :create, ItemList
    @item_list = ItemList.create(item_list_params.merge(user_id: current_user.id))
  end

  def item_list_params
    params.require(:item_list).permit(:name, item_item_lists_attributes: [:item_id])
  end

end
