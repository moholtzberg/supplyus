class InventoriesController < ApplicationController
  layout "admin"
  
  def index
    @inventory = Inventory.all
  end
  
end