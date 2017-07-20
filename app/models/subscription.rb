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
    state :active do
      validates :ship_to_address, presence: true
      validates :bill_to_address, presence: true
      validates :credit_card, presence: true, if: Proc.new{ |f| f.payment_method == "credit_card"  }
    end

    event :activate do
      transition any => :active
    end
  end

end