class AccountItemPricesController < ApplicationController
  layout "admin"
  
  def new
    authorize! :create, AccountItemPrice
    @account_item_price = AccountItemPrice.new(:item_id => params[:item_id])
    if params["copy"] && params["copy"] == "true"
      @account = Account.find_by(:id => params[:account_id])
    end
  end
  
  def create
    authorize! :create, AccountItemPrice
    if params[:copy]
      copy
    else
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
  
  def copy
    authorize! :create, AccountItemPrice
    puts "WE ARE IN THE COPY ACTION"
    from_acct = Account.find_by(name: params[:account_item_price][:copy_from])
    to_acct = Account.find_by(id: params[:account_id])
    factor = params[:price_factor].blank? ? 1 : params[:price_factor].to_f
    AccountItemPrice.where(account_id: from_acct).each do |aip|
      AccountItemPrice.create(account_id: to_acct.id, item_id: aip.item_id, price: (aip.price * factor))
    end
    render :js => "window.location.href = '#{account_path(to_acct.id)}'"
  end
  
  def destroy
    authorize! :destroy, AccountItemPrice
    AccountItemPrice.where(id: params[:id]).destroy!
  end
  
end