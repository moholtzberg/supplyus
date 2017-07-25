class Subscription < ActiveRecord::Base

  FREQUENCIES = ['month', 'quarter']
  PAYMENT_METHODS = ['check', 'credit_card']

  belongs_to :account
  belongs_to :ship_to_address, foreign_key: :address_id, class_name: Address
  belongs_to :bill_to_address, foreign_key: :bill_address_id, class_name: Address
  belongs_to :item
  belongs_to :credit_card
  has_many :orders

  validates :account_id, presence: true
  validates :item_id, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :frequency, presence: true, inclusion: { in: FREQUENCIES }  
  accepts_nested_attributes_for :ship_to_address
  accepts_nested_attributes_for :bill_to_address

  before_save :check_payment_method
  after_update :check_failed_payments, if: Proc.new { |s| s.credit_card_id_changed? && s.credit_card_id }

  state_machine initial: :new do
    state :active do
      validates :ship_to_address, presence: true
      validates :bill_to_address, presence: true
      validates :credit_card, presence: true, if: Proc.new{ |f| f.payment_method == "credit_card" }, inclusion: {in: proc { |f| f.account.main_service.credit_cards }}
    end

    event :activate do
      transition any => :active
    end
  end

  def check_payment_method
    self.credit_card_id = nil if self.payment_method == 'check'
  end

  def check_failed_payments
    self.orders.where(state: 'hold').each do |order|
      order.payments.where(success: false).each do |payment|
        if payment.authorize
          order.resume
        else
          OrderMailer.order_failed_authorization(order.id).deliver_later
          SubscriptionMailer.update_cc(self).devliver_later
        end
      end
    end
  end

  def wait_for_next_order?
    today = Date.today
    subscription_frequency_day = account.send("subscription_" + frequency + "_day")
    prev_period_subscription_date = today.send('beginning_of_' + frequency).send('prev_' + frequency) + subscription_frequency_day - 1
    current_period_subscription_date = today.send('beginning_of_' + frequency) + subscription_frequency_day - 1
    next_period_subscription_date = today.send('beginning_of_' + frequency).send('next_' + frequency) + subscription_frequency_day - 1
    if today > current_period_subscription_date
      today - current_period_subscription_date > next_period_subscription_date - today
    elsif today < current_period_subscription_date
      today - prev_period_subscription_date < current_period_subscription_date - today
    else
      false
    end
  end

end