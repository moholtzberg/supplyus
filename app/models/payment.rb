class Payment < ActiveRecord::Base
  
  # has_and_belongs_to_many :invoices
  belongs_to :account
  belongs_to :payment_method
  has_many :order_payment_applications
  has_many :transactions
  accepts_nested_attributes_for :order_payment_applications
  
  def account_name
    account.try(:name)
  end
  
  def account_name=(name)
    self.account = Account.find_by(:name => name) if name.present?
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
  
  
end