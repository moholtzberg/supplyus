class MyAccount::UsersController < ApplicationController
  layout 'shop'
  before_filter :find_cart, only: :show
  before_filter :find_categories, only: [:index, :show]
  skip_before_filter :check_authorization
  
  def new
    @account = Account.find(params[:id])
    @user = User.new(account_id: @account.id)
  end

  def create
    @user = User.create(user_params)
    @account = Account.find(@user.account_id)
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

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone_number, :password, :password_confirmation, :account_id)
  end

end
