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

    @credit_card = CreditCard.new(active_merchant_params.merge(account_payment_service_id: current_user.account.main_service.id))
    @credit_card.store
    @credit_card.save if @credit_card.errors.empty?

  end



  def edit

    authorize! :update, CreditCard

    @credit_card = CreditCard.find(params[:id])

  end



  def update

    authorize! :create, CreditCard

    @credit_card = CreditCard.find(params[:id])

    @credit_card.assign_attributes(cardholder_name: params[:cardholder_name], expiration: "#{params[:expiration_month]}/#{params[:expiration_year]}")

    @credit_card.save

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

    params.permit(:cardholder_name, :credit_card_number, :expiration_month, :expiration_year, :card_security_code)

  end



end