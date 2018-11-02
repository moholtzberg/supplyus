class MyAccount::FlaggedOrderLineItemsController < ApplicationController
  layout 'shop'
  respond_to :html, :json
  before_filter :find_categories
  skip_before_filter :check_authorization

  def index
    
  end

  def show
    
  end
  
  def update
    @flagged_order_line_item = FlaggedOrderLineItem.find_by(order_line_item_id: params[:id])
    @flagged_order_line_item.review_state = params["review_state"]
    @flagged_order_line_item.reviewed_at = Time.now
    @flagged_order_line_item.save
    @flagged_order_line_item.order_line_item.order.review_items_over_price_limit!
  end
  
  private

  def find_categories
    @menu = Category.is_parent.is_active.show_in_menu
  end  

end