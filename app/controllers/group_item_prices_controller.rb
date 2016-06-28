class GroupItemPricesController < ApplicationController
  layout "admin"
  
  def new
    authorize! :read, Group
    authorize! :create, GroupItemPrice
    @group_item_price = GroupItemPrice.new(:item_id => params[:item_id])
    if params["copy"] && params["copy"] == "true"
      @group = Group.find_by(:id => params[:group_id])
    end
  end
  
  def create
    authorize! :create, GroupItemPrice
    if params[:copy]
      copy
    else
      puts params.inspect
      item = Item.find_by(:number => params[:group_item_price][:item_number])
      group = Group.find_by(:name => params[:group_item_price][:group_name])
      group_price = GroupItemPrice.where(:item_id => item.id, :group_id => group.id).first
      puts group_price
      if group_price.nil?
        group_price = GroupItemPrice.new(:item_id => item.id, :group_id => group.id)
      end
      group_price.price = params[:group_item_price][:price]
      group_price.save
      @item = item
    end
  end
  
  def copy
    authorize! :create, GroupItemPrice
    puts "WE ARE IN THE COPY ACTION"
    from_acct = Account.find_by(name: params[:group_item_price][:copy_from])
    to_group = Group.find_by(id: params[:group_id])
    factor = params[:price_factor].blank? ? 1 : params[:price_factor].to_f
    AccountItemPrice.where(account_id: from_acct).each do |aip|
      GroupItemPrice.create(group_id: to_group.id, item_id: aip.item_id, price: (aip.price * factor))
    end
    render :js => "window.location.href = '#{group_path(to_group.id)}'"
  end
  
  def destroy
    authorize! :destroy, GroupItemPrice
    GroupItemPrice.find_by(:id => params[:id]).destroy
  end
  
end

