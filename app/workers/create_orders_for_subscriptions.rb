require 'sidekiq-scheduler'

class CreateOrdersForSubscriptions
  
  include Sidekiq::Worker

  def perform
    today = Date.today
    accounts_with_active_subscriptions = Account.where('subscription_week_day = ? OR subscription_month_day = ? OR subscription_quarter_day = ?', 
      Date.today.beginning_of_week - today, Date.today.beginning_of_month - today, Date.today.beginning_of_quarter - today)
    accounts_with_active_subscriptions.each do |account|
      account.subscriptions.includes(:orders).where.not(orders: {created_at: (Date.today.beginning_of_day..Date.today.end_of_day)}).where(state: 'active').each do |subscription|
        order = SubscriptionServices::GenerateOrderFromSubscription.new.call(subscription)
        payment = SubscriptionServices::GeneratePayment.new.call(order, subscription.card)
        order.save
        payment.save
        if payment.authorize
          OrderPaymentApplication.create(:order_id => order.id, :payment_id => payment.id, :applied_amount => payment.amount)
        else
          order.hold
          OrderMailer.order_failed_authorization(order.id).deliver_later
          SubscriptionMailer.update_cc(subscription).devliver_later
        end
    end
  end
end
