module SubscriptionServices
  class SetDayOfPeriod
    def call(subscription)
      if subscription.account.send('subscription_' + subscription.frequency + '_day').nil?
        day_of_period = (Date.today - Date.today.send('beginning_of_' + subscription.frequency) ).to_i + 1
        subscription.account.update_column('subscription_' + subscription.frequency + '_day', day_of_period)
      end
    end
  end
end