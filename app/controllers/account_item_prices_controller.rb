class AccountItemPricesController < ApplicationController
  layout "admin"
  
  def new
    @account_item_price = AccountItemPrice.new(:item_id => params[:item_id])
  end
  
  def create
    puts params.inspect
    item = Item.find_by(:number => params[:account_item_price][:item_number])
    acct = Account.find_by(:name => params[:account_item_price][:account_name])
    item_price = AccountItemPrice.where(:item_id => item.id, :account_id => acct.id).first
    puts item_price
    if item_price.nil?
      item_price = AccountItemPrice.new(:item_id => item.id, :account_id => acct.id)
    end
    item_price.price = params[:account_item_price][:price]
    item_price.save
    @item = item
  end
  
end