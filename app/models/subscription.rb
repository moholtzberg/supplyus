class Subscription < ActiveRecord::Base

  belongs_to :account
  belongs_to :ship_to_address, foreign_key: :address_id, class_name: Address
  belongs_to :bill_to_address, foreign_key: :bill_address_id, class_name: Address
  belongs_to :item
  belongs_to :credit_card
  has_many :orders

  validates :account_id, presence: true
  validates :item_id, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :frequency, presence: true, numericality: { greater_than: 0 }
  accepts_nested_attributes_for :ship_to_address
  accepts_nested_attributes_for :bill_to_address

  state_machine initial: :new do
    state :set_address do
      validates :ship_to_address, presence: true
      validates :bill_to_address, presence: true
    end

    state :set_credit_card do
      validates :credit_card, presence: true
    end

    event :set_credit_card do
      transition any => :set_credit_card
    end

    event :set_address do
      transition any => :set_address
    end

    event :activate do
      transition [:set_address, :set_credit_card] => :active
    end
  end

  def build_order
    order = self.orders.build({
      account_id: account_id,
      ship_to_account_name: account.name,
      ship_to_address_1: ship_to_address.address_1,
      ship_to_address_2: ship_to_address.address_2,
      ship_to_attention: "#{account.users.first.first_name} #{account.users.first.last_name}",
      ship_to_city: ship_to_address.city,
      ship_to_state: ship_to_address.state,
      ship_to_zip: ship_to_address.zip,
      ship_to_phone: ship_to_address.phone,
      bill_to_account_name: account.name,
      bill_to_address_1: ship_to_address.address_1,
      bill_to_address_2: ship_to_address.address_2,
      bill_to_attention: "#{account.users.first.first_name} #{account.users.first.last_name}",
      bill_to_city: ship_to_address.city,
      bill_to_state: ship_to_address.state,
      bill_to_zip: ship_to_address.zip,
      bill_to_phone: ship_to_address.phone,
      email: account.email,
      bill_to_email: account.email,
    })
    order.order_line_items.build({
      order_line_number: 1,
      item_id: item_id,
      quantity: quantity,
      price: item.prices.select{|p| p._type == 'Recurring'}[0].price
    })
    order
  end
  
end