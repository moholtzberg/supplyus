class ReportsController < ApplicationController
  layout "admin"
  def index
    
  end
  
  def sales_tax_report
    @order_ids = Order.where("COALESCE(tax_total,0) <> 0").unpaid.ids
    @order_tax_rates = OrderTaxRate.where(order_id: @order_ids)
    @tax_rates = TaxRate.where(id: @order_tax_rates.map(&:tax_rate_id).uniq)
  end
  
  def vfv
    @ids = Account.where(group_id: @group.id).ids
    @items = OrderLineItem
    .unscoped
    .joins("INNER JOIN orders ON orders.id = order_line_items.order_id")
    .joins("RIGHT OUTER JOIN items ON items.id = order_line_items.item_id")
    .where("orders.account_id IN (?)", @ids)
    .where("completed_at < ?", Date.strptime(params[:to_date], '%m/%d/%y'))
    .where("quantity_fulfilled >= 0")
    .group("item_id, items.number")
    .select("SUM(COALESCE(quantity, 0) - COALESCE(quantity_canceled, 0)) AS qty, item_id AS item_id, items.number AS number")
    .having("item_id = item_id")
    .order("qty DESC")
    .includes(:item => [:group_item_prices, :item_vendor_prices])
  end
  
end