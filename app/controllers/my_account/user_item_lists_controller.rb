class MyAccount::UserItemListsController < ApplicationController
  layout 'shop'
  before_filter :find_cart, only: :show
  before_filter :find_categories, only: [:index, :show]
  skip_before_filter :check_authorization
  
  def new
    @item_list = ItemList.find(params[:item_list_id])
    @user_item_list = UserItemList.new(item_list_id: @item_list.id)
  end

  def create
    @item_list = UserItemList.create(user_item_list_params)
  end
  
  def users
    base = current_user&.group_id&.present? ? current_user&.group&.accounts.map(&:id) : current_user&.account.id
    @users = User.where.not(id: current_user.id).where(id: base)
    @users = User.all
    unless params[:term].blank?
      @users = @users.lookup(params[:term]) if params[:term].present?
    end
    # respond_to do |format|
#       format.json {render :json => @users.map { |g| {id: g.id, name: g.email, text: g.email, label: g.email, value: g.id} }}
#     end
    respond_to do |format|
      format.html
      format.js
      format.json {render :json => @users.map(&:email)}
    end
  end

  def find_categories
    @store_name = StoreSetting.store_name
    @store_phone_number = StoreSetting.store_phone_number
    @store_address = StoreSetting.store_address
    @store_city = StoreSetting.store_city
    @store_state = StoreSetting.store_state
    @store_zip = StoreSetting.store_zip
    @menu = Category.is_parent.is_active.show_in_menu.includes(:children)
  end

  def find_cart
    if !cookies.permanent.signed[:cart_id].blank? and cookies.permanent.signed[:cart_id].is_a? Numeric
      unless !Cart.find_by(:id => cookies.permanent.signed[:cart_id]).nil?
        cookies.permanent.signed[:cart_id] = Cart.create.id
      end
    else
      cookies.permanent.signed[:cart_id] = Cart.create.id
    end
    @cart = Cart.find_by(:id => cookies.permanent.signed[:cart_id])
  end

  def user_item_list_params
    params.require(:user_item_list).permit(:user_name, :item_list_id)
  end

end
