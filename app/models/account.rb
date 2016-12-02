class Account < ActiveRecord::Base
    
  devise :registerable
  self.inheritance_column = :account_type
  
  alias_attribute :address_1, :ship_to_address_1
  alias_attribute :address_2, :ship_to_address_2
  alias_attribute :city,      :ship_to_city
  alias_attribute :state,     :ship_to_state
  alias_attribute :zip,       :ship_to_zip
  alias_attribute :phone,     :ship_to_phone
  alias_attribute :fax,       :ship_to_fax
  
  belongs_to :user
  belongs_to :group
  belongs_to :sales_rep, :class_name => "User"
  has_many :users
  has_many :contacts
  has_many :equipment, :class_name => "Equipment"
  has_many :charges
  has_many :receipts
  has_many :payment_plans
  has_many :invoices
  has_many :credit_cards
  has_many :orders
  has_many :order_line_items, :through => :orders
  has_many :account_item_prices
  
  validates :name, :presence => true
  validates :ship_to_address_1, :presence => true
  validates :ship_to_city, :presence => true
  validates :ship_to_state, :presence => true
  validates :ship_to_zip, :presence => true
  
  # after_commit :sync_with_quickbooks if :persisted
  
  # validates_presence_of :creator, :on => :create, :message => "creator can't be blank"
  
  
  def use_bill_to_address
    ["address_1", "address_2", "city", "state", "zip", "email", "phone", "fax"].each do |prop|
      # puts prop
      # puts eval(prop)
      if eval(prop) != eval("bill_to_#{prop}")
        return false
      end
    end
  end
  
  def bill_address_1
    ship_to_address_1 if bill_to_address_1.blank?
  end
  
  def bill_address_2
    ship_to_address_2 if bill_to_address_2.blank?
  end
  
  def bill_city
    ship_to_city if bill_to_city.blank?
  end
  
  def bill_state
    ship_to_state if bill_to_state.blank?
  end
  
  def bill_zip
    ship_to_zip if bill_to_zip.blank?
  end
  
  def self.lookup(term)
    includes(:user).where("lower(users.first_name) like (?) or lower(users.last_name) like (?) or lower(users.email) like (?) or lower(accounts.name) like (?)", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%").references(:user)
  end
  
  def has_credit
    if credit_limit > 0 and credit_hold != true and credit_terms > 1
      true
    else
      false
    end
  end
  
  def payment_terms
    90
  end
  
  def is_taxable?
    if is_taxable == nil
      false
    else
      is_taxable
    end
  end
  
  def self.search(term)
    where("lower(name) like (?)", "%#{term.downcase}%")
  end
  
  def sales_rep_name
    sales_rep.try(:email)
  end
  
  def sales_rep_name=(name)
    self.sales_rep = User.find_by(:email => name) if name.present?
  end
  
  def group_name
    group.try(:name)
  end
  
  def group_name=(name)
    self.group = Group.find_by(:name => name) if name.present?
  end
  
  def outstanding_invoices
    orders.fulfilled.unpaid.map(&:total).sum
  end
  
  def sync_with_quickbooks
    set_qb_service
    customer = set_payload
    puts "QB Customer Id ---> #{qb_customer}"
    if self.qb_customer == nil
      response = $qbo_api.create(:customer, payload: customer)
    else
      response = $qbo_api.update(:customer, :id => qb_customer, payload: customer)
    end
  end
  
  def set_payload
    customer = { 
      CompanyName: name.gsub("&", "and"),
      DisplayName: name.gsub("&", "and"),
      BillAddr: { 
        Line1: bill_address_1,
        Line2: bill_address_2,
        City: bill_city, 
        CountrySubDivisionCode: bill_state,
        PostalCode: bill_zip
      },
      ShipAddr: { 
        Line1: address_1,
        Line2: address_2,
        City: city, 
        CountrySubDivisionCode: state,
        PostalCode: zip
      },
      PrimaryPhone: {
        FreeFormNumber: phone
      }
    }
    return customer
  end
  
  def qb_customer
    q = $qbo_api.esc("#{name}")
    q = q.gsub("&", "and")
    a = $qbo_api.query(%{SELECT DisplayName, Id FROM Customer WHERE DisplayName = '#{q}'})
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