class MyAccount::CreditCardsController < ApplicationController
  layout 'shop'
  before_filter :find_categories
  skip_before_filter :check_authorization

  def new
    authorize! :create, CreditCard
    @credit_card = CreditCard.new(account_payment_service_id: current_user.account.main_service.id)
  end

  def create
    authorize! :create, CreditCard
    @credit_card = CreditCard.store(active_merchant_params.merge(customer_id: current_user.account.main_service.service_id, account_payment_service_id: current_user.account.main_service.id))
    flash[:error] = 'The credit card you provided was declined. Please double check your information and try again.' unless @credit_card
  end

  def edit
    authorize! :update, CreditCard
    @credit_card = CreditCard.find(params[:id])
  end

  def update
    authorize! :create, CreditCard
    @credit_card = CreditCard.find(params[:id])
    @credit_card.assign_attributes(cardholder_name: params[:cardholder_name], expiration: "#{params[:expiration_month]}/#{params[:expiration_year]}")
    flash[:error] = 'Credit card data is not valid.' unless @credit_card.save
  end

  def destroy
    @credit_card = CreditCard.find(params[:id])
    authorize! :destroy, @credit_card
    @credit_card.destroy
  end

  def index
    authorize! :read, CreditCard
    @credit_cards = current_user.account.main_service.credit_cards
  end
  
  def find_categories
     @menu = Category.is_parent.is_active.show_in_menu
  end

  def credit_card_params
    params.require(:credit_card).permit()
  end

  def active_merchant_params
    params.permit(:cardholder_name, :number, :expiration_month, :expiration_year, :cvv)
  end

end