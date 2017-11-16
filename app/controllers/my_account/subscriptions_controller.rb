class MyAccount::SubscriptionsController < ApplicationController
  layout 'shop'
  respond_to :html, :json
  before_filter :find_categories
  skip_before_filter :check_authorization

  def index
    authorize! :read, Subscription
    @subscriptions =  Subscription.where(account: current_user.account, state: [:active, :paused])
  end

  def new
    authorize! :create, Subscription
    @subscription = Subscription.new(subscription_params)
  end

  def details
    authorize! :create, Subscription
    @subscription = Subscription.find(params[:id])
    @subscription.ship_to_address = Address.new
    @subscription.bill_to_address = Address.new
    @cards = current_user.account.main_service.credit_cards
    @payment = Payment.new
  end

  def update_details
    authorize! :create, Subscription
    @subscription = Subscription.find(params[:id])
    @subscription.ship_to_address = Address.find_or_create_by(subscription_params[:ship_to_address_attributes].merge(account_id: @subscription.account_id))
    @subscription.bill_to_address = Address.find_or_create_by(subscription_params[:bill_to_address_attributes].merge(account_id: @subscription.account_id))
    @subscription.payment_method = params[:payment_method]
    if !params[:credit_card_token].blank?
      @card = CreditCard.find_by(account_payment_service_id: @subscription.account.main_service.id, service_card_id: params[:credit_card_token])
    elsif @subscription.payment_method == 'credit_card'
      @card = CreditCard.create({
        cardholder_name: params[:cardholder_name],
        credit_card_number: params[:credit_card_number],
        card_security_code: params[:card_security_code],
        expiration_month: params[:expiration_month],
        expiration_year: params[:expiration_year],
        account_payment_service_id: @subscription.account.main_service.id
      })
    end
    @subscription.credit_card = @card
    @cards = @subscription.account.main_service.credit_cards
    SubscriptionServices::SetDayOfPeriod.new.call(@subscription)
    if @subscription.wait_for_next_order?
      if @subscription.activate && @subscription.save
        redirect_to my_account_subscriptions_path
      else
        render "details"
      end        
    else
      @order = SubscriptionServices::GenerateOrderFromSubscription.new.call(@subscription)
      @payment = SubscriptionServices::GeneratePayment.new.call(@order, @subscription, @card)
      if @payment.authorize
        @subscription.activate
        @order.submit
        @order.order_payment_applications.first.update_attribute(:applied_amount, @payment.amount)
        redirect_to my_account_subscriptions_path
      else
        render "details"
      end
    end
  end
  
  def create
    authorize! :create, Subscription
    @subscription = Subscription.create(subscription_params.merge(account_id: current_user.account_id))
    flash[:error] = @subscription.errors.full_messages.join(', ') if @subscription.errors.any?
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def destroy
    authorize! :destroy, Subscription
    @subscription = Subscription.find_by(:id => params[:id])
    @account = @subscription.account
    @subscription.destroy!
    respond_to do |format|
      format.js
    end
  end

  def edit
    authorize! :update, Subscription
    @subscription = Subscription.find_by(id: params[:id])
  end

  def update
    authorize! :update, Subscription
    @subscription = Subscription.find_by(id: params[:id])
    if @subscription.update_attributes(subscription_params)
      flash[:notice] = "\"#{@subscription.item.name}\" has been updated"
    else
      flash[:error] = "There were some problems with the form you submitted"
    end
  end
  
  def find_categories
     @menu = Category.is_parent.is_active.show_in_menu
  end
  
  private

  def subscription_params
    prms = params.require(:subscription).permit(:item_id, :quantity, :frequency, :address_id, :bill_address_id, :payment_method, :credit_card_id, :state,
      ship_to_address_attributes: [:address_1, :address_2, :city, :state, :zip, :phone],
      bill_to_address_attributes: [:address_1, :address_2, :city, :state, :zip, :phone]
    )
    prms[:bill_to_address_attributes] = prms[:ship_to_address_attributes] if params[:use_ship_to_address]
    prms
  end
end