require 'sidekiq-scheduler'

class CreateOrdersForSubscriptions
  include Sidekiq::Worker
  include JobLogger

  def perform
    add_log "started to generate orders for #{Date.today} subscriptions"
    Subscription.trigger_today.each do |subscription|
      order = SubscriptionServices::GenerateOrderFromSubscription.new.call(subscription)
      order.save
      order.submit
      payment = SubscriptionServices::GeneratePayment.new.call(order, subscription, subscription.credit_card)
      if payment.authorize
        payment.save
        OrderPaymentApplication.create(payment: payment, order: order, applied_amount: payment.amount)
        add_log "generated order for subscription #{subscription.id}"
      else
        order.failed_authorization
        OrderMailer.order_failed_authorization(order.id).deliver_later
        SubscriptionMailer.update_cc(subscription).devliver_later
        add_log "failed to authorize payment for subscription #{subscription.id}"
      end
    end
    add_log "finished"
  end
end
