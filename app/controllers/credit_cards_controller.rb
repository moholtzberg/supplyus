class CreditCardsController < ApplicationController
  layout "admin"
  
  # def index
  #   @credit_card = CreditCard.by_account(params[:account_id])
  # end
  
  def new
    authorize! :create, CreditCard
    @credit_card = CreditCard.new
    @account_id = params[:account_id]
  end
  
  def create
    authorize! :create, CreditCard
    a = Account.find_by_id(params[:credit_card][:account_id])
    puts a.stripe_customer_id
    customer = Stripe::Customer.retrieve(a.stripe_customer_id)
    card = customer.sources.create({:source => params[:card_token]})
    if card
      CreditCard.create(:account_id => a.id, :stripe_customer_id => a.stripe_customer_id, :stripe_card_id => card.id, :expiration => Date.parse("#{card.exp_month}/#{card.exp_year}").end_of_month)
      redirect_to account_path(a.id)
    else
      render :new
    end
  end
  
  def registration_params
    params.require(:credit_card, :source).permit(:account_id)
  end
  
end