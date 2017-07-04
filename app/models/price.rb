class Price < ActiveRecord::Base

  PRICE_TYPES = ['Default', 'Sale', 'Bulk', 'Recurring']

  belongs_to :item
  belongs_to :appliable, polymorphic: true

  validates :_type, presence: true, inclusion: { in: PRICE_TYPES }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :min_qty, :max_qty, presence: true, if: Proc.new { |price| price._type == 'Bulk' }
  validates :min_qty, :max_qty, absence: true, if: Proc.new { |price| price._type != 'Bulk' }

  default_scope { where('(start_date < ? OR start_date IS NULL) AND (end_date > ? OR end_date IS NULL)', Date.today, Date.today)}
  scope :by_account, -> (account_id) { where('(appliable_type = ? AND appliable_id = ?) OR (appliable_type = ? AND appliable_id = ?)', 'Account', account_id, 'Group', Account.find(account_id).group) }
  scope :by_group, -> (group_id) { where(appliable_type: 'Group', appliable_id: group_id)}
  scope :by_item, -> (item_id) { where(item_id: item_id)}
  scope :by_qty, -> (qty) { where('min_qty <= ? AND max_qty >= ?', qty, qty) }
  scope :_public, -> () { where(appliable: nil)}
  scope :recurring, -> () { where(_type: 'Recurring')}
  scope :bulk, -> () { where(_type: 'Bulk')}
  scope :singular, -> () { where(_type: ['Default', 'Sale'])}
  scope :default, -> () { where(_type: 'Default') }

end