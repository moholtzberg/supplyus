class Order < ActiveRecord::Base
  
  include ApplicationHelper
  
  scope :is_locked, -> () { where(:locked => true) }
  scope :is_complete, -> () { where(state: [:completed, :fulfilled])}
  scope :is_unlocked, -> () { where.not(:locked => true) }
  scope :is_submitted, -> () { where.not(:submitted_at => nil) }
  scope :not_submitted, -> () { where(:submitted_at => nil) }
  scope :is_canceled, -> () { where(:state => :canceled) }
  scope :not_canceled, -> () { where.not(:state => :canceled) }
  scope :has_account, -> () { where.not(:account_id => nil) }
  scope :no_account, -> () { where(:account_id => nil) }
  scope :by_date_range, -> (from, to) { where("due_date >= ? AND due_date <= ?", from, to) }
  scope :lookup, lambda { |q|
    includes(
      :account => [:group],
      :order_line_items => [:item]
    ).where(
      'lower(orders.number) like (?) or lower(orders.po_number) like (?) or '\
      'lower(accounts.name) like (?) or lower(items.number) like (?) or '\
      'lower(items.name) like (?) or lower(items.description) like (?) or lower(groups.name) like (?)',
      "%#{q.downcase}%", "%#{q.downcase}%", "%#{q.downcase}%", "%#{q.downcase}%",
      "%#{q.downcase}%", "%#{q.downcase}%", "%#{q.downcase}%"
    ).references(:account, :group, :order_line_items, :item)
  }
  # scope :shipped, -> () { where(:id => OrderLineItem.shipped.pluck(:order_id).uniq) }
  # scope :fulfilled, -> () { where(:id => LineItemFulfillment.pluck(:invoice_id).unpaid.uniq) }
  # scope :fulfilled, -> () { where(:id => OrderLineItem.fulfilled.pluck(:order_id).uniq) }
  scope :past_due_90, -> {fulfilled.unpaid.where(due_date: 61.days.ago..90.days.ago) }
  
  belongs_to :customer, :foreign_key => "account_id"
  belongs_to :account
  belongs_to :user
  belongs_to :sales_rep, :class_name => "User"
  belongs_to :subscription
  has_one :order_shipping_method, :dependent => :destroy, :inverse_of => :order
  has_one :order_tax_rate, :dependent => :destroy, :inverse_of => :order
  has_one :order_discount_code
  has_one :discount_code, through: :order_discount_code, source: :code
  has_many :return_authorizations
  has_many :order_line_items, :dependent => :destroy, :inverse_of => :order
  has_many :items, :through => :order_line_items
  has_many :shipments, :through => :order_line_items
  has_many :order_payment_applications
  has_many :payments, :through => :order_payment_applications
  has_many :credit_card_payments, :through => :order_payment_applications
  has_many :purchase_order_line_items, :through => :order_line_items
  
  accepts_nested_attributes_for :order_line_items, :allow_destroy => true
  accepts_nested_attributes_for :order_discount_code, :allow_destroy => true
  
  before_save :make_record_number
  
  after_commit :flush_cache
  after_update :update_order_tax_rate
  after_commit :update_totals, :if => :persisted?
  
  # after_commit :sync_with_quickbooks if :persisted

  state_machine initial: :incomplete do
    before_transition on: :submit do |order|
      order.submitted_at = Time.now
    end

    before_transition on: :cancel do |order|
      order.order_line_items.each do |oli|
        oli.update_attribute(:quantity_canceled, oli.quantity)
      end
    end

    before_transition on: :remove_hold do |order|
      order.credit_hold = false
    end

    before_transition any => :awaiting_payment do |order|
      order.update_attribute(:locked, true)
    end

    before_transition any => :awaiting_shipment do |order|
      order.create_full_invoice unless order.terms_payment?
    end

    event :submit do
      transition :incomplete => :pending
    end

    event :failed_authorization do
      transition :pending => :failed_authorization
    end

    event :passed_authorization do
      transition :failed_authorization => :pending
    end

    event :cancel do
      transition [:incomplete, :pending] => :canceled
    end

    event :approve do
      transition :pending => :credit_hold, if: -> (order) { order.terms_payment? and order.credit_hold? }
      transition :pending => :awaiting_shipment, if: -> (order) { order.terms_payment? or order.paid }
      transition :pending => :awaiting_payment
    end

    event :remove_hold do
      transition :credit_hold => :awaiting_shipment, if: -> (order) { order.terms_payment? }
    end

    event :confirm_payment do
      transition [:awaiting_payment, :partially_paid] => :awaiting_shipment, if: :paid
      transition [:awaiting_payment, :partially_paid] => :partially_paid
      transition :fulfilled => :completed
    end

    event :confirm_shipment do
      transition [:awaiting_shipment, :partially_shipped] => :completed, if: -> (order) { order.shipped and order.fulfilled }
      transition [:awaiting_shipment, :partially_shipped] => :awaiting_fulfillment, if: -> (order) { order.shipped }
      transition [:awaiting_shipment, :partially_shipped] => :partially_shipped
    end

    event :confirm_fulfillment do
      transition [:awaiting_fulfillment, :partially_fulfilled] => :completed, if: -> (order) { order.paid and order.fulfilled }
      transition [:awaiting_fulfillment, :partially_fulfilled] => :fulfilled, if: :fulfilled
      transition [:awaiting_fulfillment, :partially_fulfilled] => :partially_fulfilled
    end

  end

  def terms_payment?
    payments.map {|p| p.payment_method.name }.uniq == ['terms'] and account.has_enough_credit
  end

  def account_name
    account.try(:name)
  end
  
  def account_name=(name)
    self.account = Account.find_by(:name => name) if name.present?
  end
  
  def sales_rep_name
    sales_rep.try(:email)
  end
  
  def sales_rep_name=(name)
    self.sales_rep = User.find_by(:email => name) if name.present?
  end
  
  def shipping_method
    order_shipping_method.try(:shipping_method_id)
  end
  
  def shipping_method=(method)
    order_shipping_method = OrderShippingMethod.find_or_create_by(:order_id => id) if method.present?
    order_shipping_method.shipping_method_id = method if method.present?
    order_shipping_method.save
  end
  
  def shipping_amount
    order_shipping_method.try(:amount)
  end
  
  def shipping_amount=(name)
    order_shipping_method.amount = name if name.present?
    order_shipping_method.save
  end
  
  ######
  
  def update_order_tax_rate
    if is_taxable?
      order_tax_rate = OrderTaxRate.find_or_create_by(:order_id => id)
      order_tax_rate.tax_rate = TaxRate.find_by(zip_code: ship_to_zip)
      order_tax_rate.amount = order_tax_rate.calculate
      order_tax_rate.save
    else
      order_tax_rate = OrderTaxRate.find_by(:order_id => id)
      if order_tax_rate.present?
        order_tax_rate.amount = 0.0
        order_tax_rate.save
      end
    end
  end
  
  def update_totals
    subtotal = sub_total_sum
    shippingtotal = shipping_total_sum
    taxtotal = tax_total_sum
    discounttotal = discount_code ? discount_code.effect.calculate(self) : 0
    self.update_columns(:sub_total => subtotal, :shipping_total => shippingtotal, :tax_total => taxtotal, :discount_total => discounttotal)
  end
  
  def is_taxable?
    if is_taxable == nil
      if account
        account.is_taxable?
      else
        false
      end
    else
      is_taxable
    end
  end
  
  def tax_rate
    order_tax_rate.try(:tax_rate_id)
  end
  
  def tax_rate=(method)
    if method.present?
      order_tax_rate = OrderTaxRate.find_or_create_by(:order_id => id) if method.present?
      order_tax_rate.tax_rate = TaxRate.find_by(zip_code: method) if method.present?
      order_tax_rate.save
    end
  end
  
  def tax_amount
    order_tax_rate.try(:amount)
  end
  
  def tax_amount=(name)
    if name.present? and tax_rate.present?
      order_tax_rate.amount = name if name.present?
      order_tax_rate.save
    end
  end
  
  #####
  
  def quantities_not_linked_to_po
    order_line_items.map(&:quantities_not_linked_to_po).sum.to_i
  end
  
  def not_linked_to_po
    puts "not linked to PO -> #{number} -> #{quantities_not_linked_to_po != 0}"
    quantities_not_linked_to_po != 0
  end
  
  def self.not_linked_to_po
    # ids = Order
    # .includes(:order_line_items => [:purchase_order_line_items]).map {|a| if a.not_linked_to_po == true then a.id end}
    # where(id: ids)
    ids = Order
    .joins(:order_line_items => [:purchase_order_line_items])
    .group("orders.id")
    .having("SUM(COALESCE(purchase_order_line_items.quantity,0)) = SUM(COALESCE(order_line_items.quantity,0) - COALESCE(order_line_items.quantity_canceled,0))").ids
    where.not(id: ids).order("number")
  end
  
  # def self.lookup(q)
  #   ids = Order
  #   .joins({:account => [:group]}, {:order_line_items => [:item]})
  #   .where("lower(orders.number) like (?) or lower(orders.po_number) like (?) or lower(items.number) like (?) or lower(items.name) like (?) or lower(items.description) like (?) or lower(groups.name) like (?)", "%#{q.downcase}%", "%#{q.downcase}%", "%#{q.downcase}%", "%#{q.downcase}%", "%#{q.downcase}%", "%#{q.downcase}%").ids
  #   where(id: ids)
  # end
  
  def flush_cache
    Rails.cache.delete([self.class.name,"open_orders"])
  end
  
  def self.fulfilled
    ids = Order
    .joins(:order_line_items)
    .group("orders.id")
    .having("SUM(order_line_items.quantity_fulfilled) = SUM(COALESCE(order_line_items.quantity,0) - COALESCE(order_line_items.quantity_canceled,0))").ids
    where(id: ids)
  end
  
  def self.unshipped
    ids = Order
    .joins(:order_line_items)
    .group("orders.id")
    .having("SUM(order_line_items.quantity_shipped) <> SUM(COALESCE(order_line_items.quantity,0) - COALESCE(order_line_items.quantity_canceled,0))").ids
    where(id: ids)
  end
  
  def self.unfulfilled
    ids = Order
    .joins(:order_line_items)
    .group("orders.id")
    .having("SUM(order_line_items.quantity_fulfilled) <> SUM(COALESCE(order_line_items.quantity,0) - COALESCE(order_line_items.quantity_canceled,0))").ids
    where(id: ids)
  end
  
  def self.shipped
    ids = Order
    .joins(:order_line_items)
    .group("orders.id")
    .having("SUM(order_line_items.quantity_shipped) = SUM(COALESCE(order_line_items.quantity,0) - COALESCE(order_line_items.quantity_canceled,0))").ids
    where(id: ids)
  end
  
  def self.unpaid
    ids = Order.where.not(state: [:incomplete, :failed_authorization, :canceled])
    .joins("LEFT OUTER JOIN order_payment_applications ON order_payment_applications.order_id = orders.id")
    .joins("LEFT OUTER JOIN payments ON order_payment_applications.payment_id = payments.id AND payments.success = 't'")
    .group("orders.id")
    .having("AVG(COALESCE(sub_total,0) + COALESCE(shipping_total,0) + COALESCE(tax_total,0) - COALESCE(discount_total,0)) <> (COALESCE(SUM(applied_amount),0))")
  end
  
  def self.empty
    Order.includes(:order_line_items).where(:order_line_items => {:order_id => nil})
  end
  
  def sub_total_sum
    order_line_items.sum("(COALESCE(quantity,0) - COALESCE(quantity_canceled,0)) * price").to_d
  end
  
  def shipping_total_sum
    if order_shipping_method&.amount.nil?
      0
    else
      order_shipping_method.amount
    end
  end
  
  def tax_total_sum
    if order_tax_rate.nil?
      0
    else
      order_tax_rate.amount
    end
  end
  
  def total
    sub_total + shipping_total + tax_total - discount_total
  end
  
  def profit
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_profit"]) {
      Rails.cache.delete("#{self.class.to_s.downcase}_profit")
      order_line_items.map(&:profit).sum
    }
  end
  
  def quantity
    order_line_items.sum("COALESCE(quantity,0) - COALESCE(quantity_canceled,0)")
  end
  
  def shipped
    quantity_shipped == quantity
  end
  
  def shipped_id
    id if shipped
  end
  
  def unshipped
    quantity_shipped != quantity
  end
  
  def unfulfilled
    quantity_fulfilled != quantity
  end
  
  def unshipped_id
    id if unshipped
  end
  
  def quantity_shipped
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_quantity_shipped"]) {
    #   Rails.cache.delete("#{self.class.to_s.downcase}_quantity_shipped")
    #   order_line_items.map(&:quantity_shipped).sum
    # }
    order_line_items.sum("quantity_shipped")
  end
  
  def amount_shipped
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_amount_shipped"]) {
    #   Rails.cache.delete("#{self.class.to_s.downcase}_amount_shipped")
    #   order_line_items.map(&:amount_shipped).sum
    # }
    order_line_items.sum("quantity_shipped * price")
  end
  
  def fulfilled
    quantity_fulfilled.to_i == quantity.to_i
    # order_line_items.sum("COALESCE(quantity,0) - COALESCE(quantity_canceled,0)")
  end
  
  def fulfilled_id
    id if fulfilled
  end
  
  def unfulfilled_id
    id if unfulfilled
  end
  
  def quantity_fulfilled
    order_line_items.sum("quantity_fulfilled")
  end
  
  def amount_fulfilled
    order_line_items.sum("quantity_fulfilled * price")
  end
  
  def payments_total
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_payments_total"]) {
      total_paid = 0.0
      self.order_payment_applications.includes(:payment).each {|a| total_paid = total_paid + a.applied_amount if a.payment.success? }
      total_paid
    }
  end

  def unauthorized_payment_amount
    order_payment_applications.includes(:payment).inject(total) do |remaining, a|
      remaining - (a.payment.authorized? ? a.applied_amount : 0.0)
    end
  end
  
  def paid
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_paid"]) {
      Rails.cache.delete("#{self.class.to_s.downcase}_paid")
      total_paid = 0.0
      self.order_payment_applications.includes(:payment).each {|a| total_paid = total_paid + a.applied_amount if a.payment.success? }
      total_paid.to_d == self.total.to_d ? true : false
    }
  end
  
  def balance_due
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_balance_due"]) {
      # Rails.cache.delete("#{self.class.to_s.downcase}_balance_due")
      order_payment_applications.includes(:payment).inject(total) do |balance, a|
        balance - (a.payment.success? ? a.applied_amount : 0.0)
      end
    # }
  end
  
  def due_on
    if self.due_date
      self.due_date
    else
      if account.payment_terms
        self.submitted_at + account.payment_terms
      else
        self.submitted_at + 30.days
      end
    end
  end
  
  def past_due_days
    if self.due_date
      (Date.today.to_date - self.due_date.to_date).to_i
    else
      if account.payment_terms
        (Date.today.to_date - (self.submitted_at + account.payment_terms).to_date).to_i
      else
        (Date.today.to_date - (self.submitted_at + 30.days).to_date).to_i
      end
    end
  end
  
  def self.past_due_up_to_30
    # fulfilled.unpaid.map {|o| if (o.past_due_days <= 30) then o end }
    where("due_date > ?", 30.days.ago).fulfilled.unpaid
  end
  
  def self.past_due_up_to_60
    # fulfilled.unpaid.map {|o| if (o.past_due_days >= 31 and o.past_due_days <= 60) then o end }
    where("due_date <= ? AND due_date > ?", 30.days.ago, 60.days.ago).fulfilled.unpaid
  end
  
  def self.past_due_up_to_90
    # fulfilled.unpaid.map {|o| if (o.past_due_days >= 61 and o.past_due_days <= 90) then o end }
    where("due_date <= ? AND due_date > ?", 60.days.ago, 90.days.ago).fulfilled.unpaid
  end
  
  def self.past_due_over_90
    # fulfilled.unpaid.map {|o| if (o.past_due_days >= 90) then o end }
    where("due_date <= ?", 90.days.ago).fulfilled.unpaid
  end
  
  def sync_with_quickbooks
    # set_qb_service
    # unless completed_at.blank?
    # puts "--------> STARTING TO SYNC INVOICE WITH  QB #{fulfilled}"
    #   if fulfilled
    #     puts "--------> INVOICE IS FULFILLED"
    #     invoice = set_payload
    #     puts "--------> INVOICE PAYLOAD IS LOADED #{invoice}"
    #     if self.qb_invoice == nil
    #       response = $qbo_api.create(:invoice, payload: invoice)
    #     else
    #       response = $qbo_api.update(:invoice, :id => qb_invoice, payload: invoice)
    #     end
    #   end
    # end
  end
  
  def set_payload
    puts "--------> INVOICE SETTING THE PAYLOAD"
    line_items_array = []
    order_line_items.each do |li|
      line_items_array << {
        Amount: li.sub_total.to_s,
        Description: li.item.name,
        DetailType: "SalesItemLineDetail",
        SalesItemLineDetail: {
          ItemRef: {
            value: li.item.sync_with_quickbooks,
            name: li.item.name
          },
          UnitPrice: li.price.to_s,
          Qty: li.actual_quantity.to_i,
          TaxCodeRef: {
            value: "TAX"
          }
        }
      }
    end
    
    invoice = {
      DueDate: due_date.to_s,
      TxnDate: submitted_at.to_s,
      DocNumber: number,
      Line: line_items_array,
      CustomerRef: {
        value: account.qb_customer
      },
      TxnTaxDetail: {
        # TxnTaxCodeRef: {
        #   value: 90
        # },
        TotalTax: tax_total.to_s,
        TaxLine: [{
          Amount: "#{order_tax_rate.amount if order_tax_rate}",
          DetailType: "TaxLineDetail",
          TaxLineDetail: {
            PercentBased: true,
            TaxPercent: "#{order_tax_rate.tax_rate.rate if (order_tax_rate and order_tax_rate.tax_rate)}",
            NetAmountTaxable: sub_total.to_s
          }
        }]
      }
    }
    return invoice
  end
  
  def qb_invoice
    a = $qbo_api.query(%{SELECT DocNumber, Id FROM Invoice WHERE DocNumber = '#{number}'})
    if !a.nil?
      return a[0]["Id"]
    else
      return nil
    end
  end
  
  def set_qb_service
    token = Setting.find_by(:key => "qb_token").value
    secret = Setting.find_by(:key => "qb_secret").value
    realm_id = Setting.find_by(:key => "qb_realm").value
    $qbo_api = QboApi.new(token: token, token_secret: secret, realm_id: realm_id, consumer_key: QB_KEY, consumer_secret: QB_SECRET)
  end

  def create_full_invoice
    invoice = Invoice.new(date: Date.today, order_id: id, due_date: Date.today)
    invoice.order_line_items = order_line_items
    invoice.line_item_fulfillments.each do |lif|
      lif.quantity_fulfilled = lif.order_line_item.actual_quantity
    end
    if invoice.save
      self.update_attributes(date: invoice.date, due_date: invoice.due_date)
    end
  end
   
end