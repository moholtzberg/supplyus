class Payment < ActiveRecord::Base
  
  self.inheritance_column = :payment_type
  belongs_to :account
  belongs_to :payment_method
  has_many :order_payment_applications, inverse_of: :payment
  has_many :orders, through: :order_payment_applications
  has_many :transactions
  accepts_nested_attributes_for :order_payment_applications

  validates :amount, :presence => true, :numericality => { greater_then: 0 }
  validates :payment_method, :presence => true
  validate :amount_refunded
  
  def self.lookup(word)
    includes(:account).where('lower(accounts.name) like (?) or cast( payments.amount as varchar(20)) like (?)'\
      ' or lower(payments.check_number) like (?) or lower(payments.authorization_code) like (?)',
      "%#{word.downcase}%", "%#{word.downcase}%", "%#{word.downcase}%", "%#{word.downcase}%").references(:account)
  end
  
  def account_name
    account.try(:name)
  end
  
  def account_name=(name)
    self.account = Account.find_by(:name => name) if name.present?
  end

  def finalize
    if !success?
      if capture
        confirm_order_payment
        true
      end
    end
  end
  
  def total_applications
    OrderPaymentApplication.where(payment_id: self.id).map(&:applied_amount).sum.to_d
  end
  
  def applied_amount
    OrderPaymentApplication.where(payment_id: self.id).map(&:applied_amount).sum.to_d
  end
  
  def unapplied_amount
    amount.to_d - OrderPaymentApplication.where(payment_id: self.id).map(&:applied_amount).sum.to_d
  end
  
  def number
    if payment_type == "CheckPayment"
      "CK# #{check_number}"
    elsif payment_type == "CreditCardPayment"
      "AUTH# #{authorization_code}"
    end
  end

  def confirm_order_payment
    orders.each(&:confirm_payment)
  end

  def amount_refunded
    return if amount.to_f >= refunded.to_f
    errors.add(:refunded, 'must be less than amount')
  end
end
