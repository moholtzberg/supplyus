class MyAccount::OrdersController < ApplicationController
  layout 'shop'
  respond_to :html, :json
  before_filter :find_categories
  before_filter :set_order, only: [:show]
  skip_before_filter :check_authorization

  def index
    @orders = Order.where(account: current_user.account).paginate(:page => params[:page], :per_page => 25)
  end

  def show
    authorize! :read, @order
    @shipments = Shipment.where(:order_id => @order.id)
    if current_user.my_account_ids.include?(@order.account_id)
      respond_to do |format|
        format.html
        format.pdf do
          render :pdf => "#{@order.number}", :title => "#{@order.number}", :layout => 'admin_print.html.erb', :page_size => 'Letter', :background => false, :template => 'shop/view_order.html.erb', :print_media_type => true
        end
      end
    else
      redirect_to "/"
    end
  end

  private

  def set_order
    @order = Order.find_by(:number => params[:order_number])
  end

  def find_categories
    @menu = Category.is_parent.is_active.show_in_menu
  end  

end