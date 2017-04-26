class ReportsController < ApplicationController
  layout "admin"
  def index
    
  end
  
  def sales_tax
    @order_ids = Order.where("COALESCE(tax_total,0) <> 0").unpaid.ids
    @order_tax_rates = OrderTaxRate.where(order_id: @order_ids)
    @tax_rates = TaxRate.where(id: @order_tax_rates.map(&:tax_rate_id).uniq)
  end
  
  def item_usage
    @group = Group.find(params[:group_id])
    @ids = Account.where(group_id: @group.id).ids
    @from_date =  Date.strptime(params[:from_date], '%m/%d/%y')
    @to_date =  Date.strptime(params[:to_date], '%m/%d/%y')
  end
  
  def ar_aging
    @orders = Order.fulfilled.unpaid
  end
  
end