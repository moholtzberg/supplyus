class Subscription < ActiveRecord::Base
  FREQUENCIES = %w[month quarter]
  PAYMENT_METHODS = %w[check credit_card terms]
  scope :with_today_orders, lambda {
    includes(:orders).where(
      orders: {
        created_at: Date.today.beginning_of_day..Date.today.end_of_day
      }
    )
  }
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

    state :paused

    event :activate do
      transition any => :active
    end
  end

  def self.lookup(word)
    includes(:account, :item).where('lower(accounts.name) like (?) or lower(items.number) like (?)', "%#{word.downcase}%", "%#{word.downcase}%").references(:account, :item)
  end

  def self.trigger_today
    where.not(id: with_today_orders.ids)
         .where(state: 'active').joins(:account).where(
           "(frequency = 'week' AND subscription_week_day IN (?)) OR "\
           "(frequency = 'month' AND subscription_month_day IN (?)) OR "\
           "(frequency = 'quarter' AND subscription_quarter_day IN (?))",
           days_of_week, days_of_month, days_of_quarter
         )
  end

  def self.days_of_week
    [(Date.today + 1 - Date.today.beginning_of_week).to_i]
  end

  def self.days_of_month
    (1..31).to_a.select do |i|
      i > Date.today.all_month.to_a.length ||
        i == Date.today + 1 - Date.today.beginning_of_month
    end
  end

  def self.days_of_quarter
    (1..92).to_a.select do |i|
      i > Date.today.all_quarter.to_a.length ||
        i == Date.today + 1 - Date.today.beginning_of_quarter
    end
  end

  def check_payment_method
    self.credit_card_id = nil if self.payment_method == 'check' || self.payment_method == 'terms'
  end

  def check_failed_payments
    self.orders.where(state: :pending).each do |order|
      order.payments.where(success: false).each do |payment|
        if payment.authorize
          order.passed_authorization
        else
          OrderMailer.order_failed_authorization(order.id).deliver_later
          SubscriptionMailer.update_cc(self).devliver_later
        end
      end
    end
  end

  def next_order_date
    if state == 'active'
      today = Date.today
      subscription_frequency_day = account.send("subscription_" + frequency + "_day")
      current_period_subscription_date = today.send('beginning_of_' + frequency) + subscription_frequency_day - 1
      next_period_subscription_date = today.send('beginning_of_' + frequency).send('next_' + frequency) + subscription_frequency_day - 1
      today > current_period_subscription_date ? next_period_subscription_date : current_period_subscription_date
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
      today - prev_period_subscription_date > current_period_subscription_date - today
    else
      false
    end
  end

  def account_name
    account.try(:name)
  end
  
  def account_name=(name)
    self.account = Account.find_by(:name => name) if name.present?
  end
  
  def item_number
    item.try(:number)
  end
  
  def item_number=(name)
    puts name
    self.item = Item.find_by(:number => name) if name.present?
    puts self.item.number
  end
end