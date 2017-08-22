class SubscriptionsController < ApplicationController
  layout 'admin'
  helper_method :sort_column, :sort_direction
  before_action :set_subscription, only: [:show, :edit, :update, :destroy, :generate_order]
  load_and_authorize_resource except: [:generate_order]
  
  def index
    update_index
    respond_to do |format|
      format.html
      format.js
      format.json {render :json => @subscriptions.map(&:name)}
    end
  end
  
  def new
    @subscription = Subscription.new
  end
  
  def show
  end
  
  def create
    @subscription = Subscription.create(subscription_params)
    update_index
  end
  
  def edit
  end
  
  def update
    @subscription.update_attributes(subscription_params)
    update_index
  end
  
  def destroy
    @subscription.destroy
    update_index
  end

  def generate_order
    authorize! :create, Subscription
    @order = SubscriptionServices::GenerateOrderFromSubscription.new.call(@subscription)
    @payment = SubscriptionServices::GeneratePayment.new.call(@order, @subscription, @subscription.credit_card)
    if @payment.authorize
      @subscription.activate
      @order.submit
      @order.order_payment_applications.first.update_attribute(:applied_amount, @payment.amount)
      redirect_to subscription_path(@subscription)
    end
  end
  
  private

  def set_subscription
    @subscription = Subscription.find(params[:id])
  end

  def update_index
    @subscriptions = Subscription.includes(:account, :item).order(sort_column + " " + sort_direction)
    unless params[:term].blank?
      @subscriptions = @subscriptions.lookup(params[:term]) if params[:term].present?
    end
    @subscriptions = @subscriptions.paginate(:page => params[:page], :per_page => 25)
  end

  def subscription_params
    params.require(:subscription).permit(:account_name, :item_number, :item_id, :quantity, :frequency, :address_id, :bill_address_id, :payment_method, :credit_card_id, :state)
  end
  
  def sort_column
    account_columns = Account.column_names.map {|a| "accounts.#{a}" }
    item_columns = Item.column_names.map {|a| "items.#{a}" }
    subscription_columns = Subscription.column_names.map {|a| "subscriptions.#{a}" }
    columns = subscription_columns + item_columns + account_columns
    columns.include?(params[:sort]) ? params[:sort] : "subscriptions.id"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end