class ReturnAuthorization < ActiveRecord::Base
  belongs_to :order
  belongs_to :customer
  belongs_to :reviewer, class_name: 'User'
  has_many :line_item_returns

  validates_presence_of :order_id, :customer_id
  validate :order_is_complete

  accepts_nested_attributes_for :line_item_returns

  state_machine :status, initial: :unconfirmed do
    state :received do
      validate :items_have_bins
    end

    event :cancel do
      transition %i[unconfirmed confirmed] => :canceled
    end

    event :confirm do
      transition %i[unconfirmed canceled] => :confirmed, :if => :enough_items
      transition :received => :confirmed
    end

    before_transition on: :confirm do |ra|
      ra.line_item_returns.each(&:destroy_inventory_transactions)
    end

    after_transition on: %i[confirm cancel] do |ra|
      ra.line_item_returns.each(&:recalculate_line_item)
    end

    event :receive do
      transition confirmed: :received
    end

    after_transition on: :receive do |ra|
      ra.line_item_returns.each(&:create_inventory_transactions)
      ra.set_refund_amount
    end

    event :refund do
      transition received: :refunded, if: :refund_payment
    end
  end

  def customer_name
    customer.try(:name)
  end

  def customer_name=(name)
    self.customer = Customer.find_by(name: name) if name.present?
  end

  def order_number
    order.try(:number)
  end

  def order_number=(number)
    self.order = Order.find_by(number: number) if number.present?
  end

  def order_is_complete
    return true if order.state == 'completed'
    errors.add(:order_id, 'Order should be completed before returning.')
  end

  def enough_items
    line_item_returns.each do |lir|
      oli = lir.order_line_item
      if lir.quantity + oli.quantity_returned.to_i > oli.actual_quantity.to_i
        errors.add(:base, 'Can\'t return more items then it was in order.')
      end
    end
  end

  def items_have_bins
    line_item_returns.each do |lir|
      if lir.bin.nil?
        errors.add(:base, 'Need to set bin for every line_item_return.')
      end
    end
  end

  def set_refund_amount
    total = line_item_returns.inject(0) do |sum, lir|
      sum + lir.calculate_refund
    end
    update_attribute(:amount, total)
  end

  def refund_payment
    order.payments.first.refund(amount)
  end
end
