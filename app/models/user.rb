class User < ActiveRecord::Base
  has_paper_trail
  acts_as_token_authenticatable
  
  rolify
  
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  
  validates :password, :confirmation => true
  validate :account_is_valid
  
  belongs_to :account
  belongs_to :customer
  belongs_to :group
  has_one :budget, as: :budgetable
  has_many :managed_accounts, through: :group, source: :accounts
  has_many :user_accounts
  has_many :orders, :through => :account
  has_many :item_lists
  belongs_to :contact
  
  accepts_nested_attributes_for :account
  
  def my_account_ids
    res = [account.id]
    if user_accounts.size > 0
      res << user_accounts.map(&:account_id)
    end
    res.flatten.uniq
  end
  
  def account_name
    account.try(:name)
  end
  
  def account_name=(name)
    self.account = Account.find_by(:name => name) if name.present?
  end
  
  def display_name
    "#{first_name} #{last_name}"
  end
  
  def has_account
    self.account.nil? ? false : true
  end
  
  def account_is_valid
    puts "check if the account is valid"
    return true
  end
  
  def budget
    all_budgets = Budget.all
    if all_budgets.where('(budgetable_type = ? AND budgetable_id = ?)', "User", id).present?
      budget = all_budgets.where('(budgetable_type = ? AND appliable_id = ?)', "User", id).last
    else all_budgets.where('(budgetable_type = ? AND budgetable_id = ?)', "Account", account_id).present?
      budget = all_budgets.where('(budgetable_type = ? AND budgetable_id = ?)', "Account", account_id).last
    end
    return budget
  end
  
  def self.lookup(term)
    includes(:account).where("lower(first_name) like (?) or lower(last_name) like (?) or lower(users.email) like (?) or lower(accounts.name) like (?)", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%").references(:account)
  end

  # Redefine Rolify method: we delete user role from users_roles, NOT role in Roles table (Rolify way: if we use original method - if user role has deleted and it was last user role with specific role name - it delete role from Roles table too) - in this case we will lose all role permissions too!
  def remove_role(role_name)
    role = Role.find_by_name role_name
    sql = "Delete from users_roles Where (user_id=#{self.id} AND role_id=#{role.id})"
    ActiveRecord::Base.connection.execute(sql)
  end

  def self.current
    Thread.current[:current_user]
  end

  def self.current=(usr)
    Thread.current[:current_user] = usr
  end  
end
