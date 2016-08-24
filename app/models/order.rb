class Order < ActiveRecord::Base
  
  include ApplicationHelper
  
  scope :is_locked, -> () { where(:locked => true) }
  scope :is_unlocked, -> () { where.not(:locked => true) }
  scope :is_complete, -> () { where.not(:completed_at => nil)}
  scope :is_incomplete, -> () { where(:completed_at => nil)}
  scope :has_account, -> () { where.not(:account_id => nil) }
  scope :no_account, -> () { where(:account_id => nil) }
  scope :by_date_range, -> (from, to) { where("due_date >= ? AND due_date <= ?", from, to) }
  # scope :shipped, -> () { where(:id => OrderLineItem.shipped.pluck(:order_id).uniq) }
  # scope :fulfilled, -> () { where(:id => LineItemFulfillment.pluck(:invoice_id).unpaid.uniq) }
  # scope :fulfilled, -> () { where(:id => OrderLineItem.fulfilled.pluck(:order_id).uniq) }
  scope :past_due_90, -> {fulfilled.unpaid.where(due_date: 61.days.ago..90.days.ago) }
  
  belongs_to :account
  belongs_to :user
  has_one :order_shipping_method, :dependent => :destroy, :inverse_of => :order
  has_one :order_tax_rate, :dependent => :destroy, :inverse_of => :order
  has_many :order_line_items, :dependent => :destroy, :inverse_of => :order
  has_many :items, :through => :order_line_items
  has_many :order_payment_applications
  has_many :payments, :through => :order_payment_applications
  has_many :credit_card_payments, :through => :order_payment_applications
  
  accepts_nested_attributes_for :order_line_items, :allow_destroy => true
  
  before_save :make_record_number
  
  after_commit :flush_cache
  after_commit :update_order_tax_rate
  after_commit :create_inventory_transactions_for_line_items
  
  # after_commit :sync_with_quickbooks if :persisted
      
  def create_inventory_transactions_for_line_items
    unless completed_at.blank?
      order_line_items.each {|a| a.create_inventory_transactions }
    end
  end
  
  def update_order_tax_rate
    
  end
  
  def self.lookup(term)
    includes({:account => [:group]}, {:order_line_items => [:item]}).where("lower(orders.number) like (?) or lower(orders.po_number) like (?) or lower(items.number) like (?) or lower(items.name) like (?) or lower(items.description) like (?) or lower(groups.name) like (?)", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%").references({:account => [:group]}, {:order_line_items => [:item]})
  end
  
  def flush_cache
    Rails.cache.delete([self.class.name,"open_orders"])
  end
  
  def self.fulfilled
    # Rails.cache.fetch([name, "fulfilled_orders"]) {
    #   ids = Order.joins(:order_line_items).distinct(:order_id).map {|o| if o.fulfilled == true then o.id end }
    #   Order.where(id: ids)
    # }
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_fulfilled_orders"]) {
      # Rails.cache.delete("#{self.class.to_s.downcase}_fulfilled_orders")
      ids = Order.is_complete.where(:id => OrderLineItem.all.map {|a| if a.fulfilled then a.order_id end}).map(&:fulfilled_id)
      Order.where(id: ids)
    # }
  end
  
  def self.unshipped
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_unshipped_orders"]) {
      # Rails.cache.delete("#{self.class.to_s.downcase}_unshipped_orders")
      ids = Order.is_complete.where(:id => OrderLineItem.all.map {|a| if a.unshipped then a.order_id end}).map(&:unshipped_id)
      Order.where(id: ids)
    # }
  end
  
  def self.unfulfilled
    # Rails.cache.fetch([name, "fulfilled_orders"]) {
    #   ids = Order.joins(:order_line_items).distinct(:order_id).map {|o| if o.fulfilled == true then o.id end }
    #   Order.where(id: ids)
    # }
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_unfulfilled_orders"]) {
      # Rails.cache.delete("#{self.class.to_s.downcase}_unfulfilled_orders")
      ids = Order.is_complete.where(:id => OrderLineItem.all.map {|a| if a.unfulfilled then a.order_id end}).map(&:unfulfilled_id)
      Order.where(id: ids)
    # }
  end
  
  def self.shipped
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_shipped_orders"]) {
      # Rails.cache.delete("#{self.class.to_s.downcase}_shipped_orders")
      ids = Order.is_complete.where(:id => OrderLineItem.all.map {|a| if a.shipped then a.order_id end}).map(&:shipped_id)
      Order.where(id: ids)
    # }
  end
  
  def self.unpaid
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_unpaid_orders"]) {
    #   Rails.cache.delete("#{self.class.to_s.downcase}_unpaid_orders")
    #   Order.is_complete.where.not(:id => OrderPaymentApplication.select(:order_id).uniq).order(:due_date)
    # }
    order_ids = OrderPaymentApplication.select(:order_id).uniq
    Order.is_complete.where.not(:id => order_ids).order(:due_date)
  end
  
  def self.empty
    Order.includes(:order_line_items).where(:order_line_items => {:order_id => nil})
  end
  
  def sub_total
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_sub_total"]) {
    #   OrderLineItem.where(order_id: id).group(:order_line_number, :price, :quantity, :quantity_canceled).sum(:price, :quantity).inject(0) {|sum, k| sum + (k[0][1].to_f * (k[0][2].to_f - k[0][3].to_f))}
    # }
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_sub_total"]) {
      Rails.cache.delete("#{self.class.to_s.downcase}_sub_total")
      order_line_items.map(&:sub_total).sum
    }
  end
  
  def shipping_total
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_shipping_total"]) {
      Rails.cache.delete("#{self.class.to_s.downcase}_shipping_total")
      order_shipping_method.amount unless order_shipping_method.nil?
    }
  end
  
  def tax_total
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_tax_total"]) {
      Rails.cache.delete("#{self.class.to_s.downcase}_tax_total")
      order_tax_rate.amount unless order_tax_rate.nil?
    }
  end
  
  def total
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_total"]) {
      Rails.cache.delete("#{self.class.to_s.downcase}_total")
      sub_total + shipping_total.to_f.to_d + tax_total.to_f.to_d
    }
  end
  
  def profit
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_profit"]) {
      Rails.cache.delete("#{self.class.to_s.downcase}_profit")
      order_line_items.map(&:profit).sum
    }
  end
  
  def quantity
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_quantity"]) {
      Rails.cache.delete("#{self.class.to_s.downcase}_quantity")
      order_line_items.map(&:actual_quantity).sum
    }
  end
  
  def shipped
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_shipped"]) {
      Rails.cache.delete("#{self.class.to_s.downcase}_shipped")
      quantity_shipped == quantity
    }
  end
  
  def shipped_id
    id if shipped
  end
  
  def unshipped
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_shipped"]) {
    #   if self.order_line_items
    #     total = 0
    #     self.order_line_items.each {|i| total += i.quantity_shipped.to_i }
    #     total == quantity
    #   else
    #     false
    #   end
    # }
    quantity_shipped != quantity
  end
  
  def unfulfilled
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_shipped"]) {
    #   if self.order_line_items
    #     total = 0
    #     self.order_line_items.each {|i| total += i.quantity_shipped.to_i }
    #     total == quantity
    #   else
    #     false
    #   end
    # }
    quantity_fulfilled != quantity
  end
  
  def unshipped_id
    id if unshipped
  end
  
  def quantity_shipped
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_quantity_shipped"]) {
      Rails.cache.delete("#{self.class.to_s.downcase}_quantity_shipped")
      order_line_items.map(&:quantity_shipped).sum
    }
  end
  
  def amount_shipped
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_amount_shipped"]) {
      Rails.cache.delete("#{self.class.to_s.downcase}_amount_shipped")
      order_line_items.map(&:amount_shipped).sum
    }
  end
  
  def fulfilled
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_fulfilled"]) {
      Rails.cache.delete("#{self.class.to_s.downcase}_fulfilled")
      quantity_fulfilled.to_i == quantity.to_i
    }
  end
  
  def fulfilled_id
    id if fulfilled
  end
  
  def unfulfilled_id
    id if unfulfilled
  end
  
  def quantity_fulfilled
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_quantity_fulfilled"]) {
    #   if self.order_line_items
    #     total = 0
    #     self.order_line_items.each {|i| total += i.quantity_fulfilled }
    #     total
    #   end
    # }
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_quantity_fulfilled"]) {
    order_line_items.map(&:quantity_fulfilled).sum
    # }
  end
  
  def amount_fulfilled
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_amount_fulfilled"]) {
    #   if self.order_line_items
    #     total = 0
    #     self.order_line_items.each {|i| total += (i.quantity_fulfilled.to_f * i.price.to_f) }
    #     total
    #   end
    # }
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_amount_fulfilled"]) {
      order_line_items.map(&:amount_fulfilled).sum
    }
  end
  
  def payments_total
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_payments_total"]) {
      total_paid = 0.0
      self.order_payment_applications.each {|a| total_paid = total_paid + a.applied_amount}
      total_paid
    }
  end
  
  def paid
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_paid"]) {
      Rails.cache.delete("#{self.class.to_s.downcase}_paid")
      total_paid = 0.0
      self.order_payment_applications.each {|a| total_paid = total_paid + a.applied_amount}
      total_paid.to_d == self.total.to_d ? true : false
    }
  end
  
  def balance_due
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_balance_due"]) {
      Rails.cache.delete("#{self.class.to_s.downcase}_balance_due")
      total_paid = 0.0
      puts self.payments.count
      self.order_payment_applications.each {|a| total_paid = total_paid + a.applied_amount}
      return (self.total.to_d - total_paid.to_d)
    }
  end
  
  def due_on
    if self.due_date
      self.due_date
    else
      if account.payment_terms
        self.completed_at + account.payment_terms
      else
        self.completed_at + 30.days
      end
    end
  end
  
  def past_due_days
    if self.due_date
      (Date.today.to_date - self.due_date.to_date).to_i
    else
      if account.payment_terms
        (Date.today.to_date - (self.completed_at + account.payment_terms).to_date).to_i
      else
        (Date.today.to_date - (self.completed_at + 30.days).to_date).to_i
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
    set_qb_service
    unless completed_at.blank?
    puts "--------> STARTING TO SYNC INVOICE WITH  QB #{fulfilled}"
      if fulfilled
        puts "--------> INVOICE IS FULFILLED"
        invoice = set_payload
        puts "--------> INVOICE PAYLOAD IS LOADED #{invoice}"
        if self.qb_invoice == nil
          response = $qbo_api.create(:invoice, payload: invoice)
        else
          response = $qbo_api.update(:invoice, :id => qb_invoice, payload: invoice)
        end
      end
    end
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
      TxnDate: completed_at.to_s,
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
   
end