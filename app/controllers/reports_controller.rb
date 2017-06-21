class ReportsController < ApplicationController
  layout "admin"
  def index
    
  end
  
  def sales_tax
    @paid_order_ids = Order.where("COALESCE(tax_total,0) <> 0").fulfilled.unpaid.ids
    @paid_order_tax_rates = OrderTaxRate.where.not(order_id: @paid_order_ids)
    @paid_tax_rates = TaxRate.where(id: @paid_order_tax_rates.map(&:tax_rate_id).uniq)

    @unpaid_order_ids = Order.where("COALESCE(tax_total,0) <> 0").fulfilled.unpaid.ids
    @unpaid_order_tax_rates = OrderTaxRate.where(order_id: @unpaid_order_ids)
    @unpaid_tax_rates = TaxRate.where(id: @unpaid_order_tax_rates.map(&:tax_rate_id).uniq)
  end
  
  def item_usage
    @from_date =  params[:from_date] ? Date.strptime(params[:from_date], '%m/%d/%y') : Date.strptime("01/01/16", '%m/%d/%y')
    @to_date =  params[:to_date] ? Date.strptime(params[:to_date], '%m/%d/%y') : Date.today
  end

  def item_usage_by_group
    @group = Group.find(params[:group_id])
    @ids = Account.where(group_id: @group.id).ids
    @from_date =  Date.strptime(params[:from_date], '%m/%d/%y')
    @to_date =  Date.strptime(params[:to_date], '%m/%d/%y')
  end
  
  def ar_aging
    @orders = Order.fulfilled.unpaid
  end
  
end