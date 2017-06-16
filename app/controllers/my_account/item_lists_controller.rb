class MyAccount::ItemListsController < ApplicationController

  def new
    @item_list = ItemList.new(user: current_user)
  end

  def create

  end

  def add_item

  end  

end
