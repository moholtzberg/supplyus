module SubscriptionServices
  class GenerateOrderFromSubscription
    def call(subscription)
      if subscription
        order = subscription.orders.build({
          account_id: subscription.account_id,
          ship_to_account_name: subscription.account.name,
          ship_to_address_1: subscription.ship_to_address.address_1,
          ship_to_address_2: subscription.ship_to_address.address_2,
          ship_to_attention: "#{subscription.account.users.first.first_name} #{subscription.account.users.first.last_name}",
          ship_to_city: subscription.ship_to_address.city,
          ship_to_state: subscription.ship_to_address.state,
          ship_to_zip: subscription.ship_to_address.zip,
          ship_to_phone: subscription.ship_to_address.phone,
          bill_to_account_name: subscription.account.name,
          bill_to_address_1: subscription.ship_to_address.address_1,
          bill_to_address_2: subscription.ship_to_address.address_2,
          bill_to_attention: "#{subscription.account.users.first.first_name} #{subscription.account.users.first.last_name}",
          bill_to_city: subscription.ship_to_address.city,
          bill_to_state: subscription.ship_to_address.state,
          bill_to_zip: subscription.ship_to_address.zip,
          bill_to_phone: subscription.ship_to_address.phone,
          email: subscription.account.email,
          bill_to_email: subscription.account.email,
        })
        order.order_line_items.build({
          order_line_number: 1,
          item_id: subscription.item_id,
          quantity: subscription.quantity,
          price: subscription.item.prices.actual.select{|p| p._type == 'Recurring'}[0].price
        })
        order
      end
    end
  end
end