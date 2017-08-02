require 'sidekiq-scheduler'

class CreateOrdersForSubscriptions
  
  include Sidekiq::Worker

  def perform
    today = Date.today
    days_of_week = [(today + 1 - Date.today.beginning_of_week).to_i]

    current_month_day_count = Date.today.end_of_month.day
    current_month_day = (today + 1 - Date.today.beginning_of_month).to_i
    days_of_month = [current_month_day]

    case current_month_day_count
    when 28
      days_of_month = [28,29,30,31] if current_month_day == 28
    when 29
      days_of_month = [29,30,31] if current_month_day == 29
    when 30
      days_of_month = [30,31] if current_month_day == 30
    end

    current_quarter_day_count = Date.today.end_of_quarter.day
    current_quarter_day = (today + 1 - Date.today.beginning_of_quarter).to_i
    days_of_quarter = [current_quarter_day]

    case current_quarter_day_count
    when 90
      days_of_quarter = [90,91,92] if current_quarter_day == 90
    when 91
      days_of_quarter = [91,92] if current_quarter_day == 91
    end

    subscriptions = Subscription.where.not(id: Subscription.includes(:orders).where(orders: {created_at: (Date.today.beginning_of_day..Date.today.end_of_day)}).ids).
      where(state: 'active').joins(:account).where('("subscriptions"."frequency" = ? AND "accounts"."subscription_week_day" IN (?)) OR '\
                                                    '("subscriptions"."frequency" = ? AND "accounts"."subscription_month_day" IN (?)) OR '\
                                                    '("subscriptions"."frequency" = ? AND "accounts"."subscription_quarter_day" IN (?))', 
                                                    'week', days_of_week, 'month', days_of_month, 'quarter', days_of_quarter)
    subscriptions.each do |subscription|
      order = SubscriptionServices::GenerateOrderFromSubscription.new.call(subscription)
      order.save
      order.submit
      payment = SubscriptionServices::GeneratePayment.new.call(order, subscription.credit_card)
      if payment.authorize
        payment.save
        OrderPaymentApplication.create(payment: payment, order: order, applied_amount: payment.amount)
      else
        OrderMailer.order_failed_authorization(order.id).deliver_later
        SubscriptionMailer.update_cc(subscription).devliver_later
      end
    end
  end
end
