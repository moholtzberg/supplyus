class GroupsController < ApplicationController
  layout "admin"
  helper_method :sort_column, :sort_direction
  
  def index
    authorize! :read, Group
    @groups = Group.order(sort_column + " " + sort_direction)
    unless params[:term].blank?
      @groups = @groups.lookup(params[:term]) if params[:term].present?
    end
    respond_to do |format|
      format.html
      format.json {render :json => @groups.map { |g| {id: g.id, name: g.name, text: g.name} }}
    end
  end
  
  def new
    authorize! :create, Group
    @group = Group.new
  end
  
  def show
    authorize! :read, Group
    @group = Group.find(params[:id])
  end

  
  def create
    authorize! :create, Group
    @group = Group.new(group_params)
    if @group.save
      @groups = Group.order(sort_column + " " + sort_direction)
    end
  end
  
  def statements
    @group = Group.find_by(:id => params[:id])
    @accounts = @group.accounts
    @from = Date.strptime(params[:from_date], '%m/%d/%y').kind_of?(Date) ? Date.strptime(params[:from_date], '%m/%d/%y') : Date.today
    @to = Date.strptime(params[:to_date], '%m/%d/%y').kind_of?(Date) ? Date.strptime(params[:to_date], '%m/%d/%y') : Date.today
    @orders = Order.where(:account_id => @accounts.ids).unpaid
    
    respond_to do |format|
      format.html
      format.pdf do
        render :pdf => "#{@group.name}_statement_#{@from}-#{@to}", :title => "#{@group.name} statement #{@from}-#{@to}", :layout => 'admin_print.html.erb', :page_size => 'Letter', :background => false, :orientation => 'Landscape', :template => 'groups/statements.html.erb', :print_media_type => true, :show_as_html => params[:debug].present?
      end
    end
    if params[:deliver_notification]
      GroupMailer::statement_notification(@group.id, params[:from_date], params[:to_date]).deliver_later
    end
  end
  
  def items
    @group = Group.find(params[:id])
    @ids = Account.where(group_id: @group.id).ids
    @items = OrderLineItem
    .unscoped
    .joins("INNER JOIN orders ON orders.id = order_line_items.order_id")
    .joins("RIGHT OUTER JOIN items ON items.id = order_line_items.item_id")
    .where("orders.account_id IN (?)", @ids)
    .where("submitted_at < ?", Date.strptime(params[:to_date], '%m/%d/%y'))
    .where("quantity_fulfilled >= 0")
    .group("item_id, items.number")
    .select("SUM(COALESCE(quantity, 0) - COALESCE(quantity_canceled, 0)) AS qty, item_id AS item_id, items.number AS number")
    .having("item_id = item_id")
    .order("qty DESC")
    .includes(:item => [:prices, :item_vendor_prices])
  end
  
  def invoices_by_customer
    @group = Group.find(params[:id])
    @ids = Account.where(group_id: @group.id).ids
    @from = Date.strptime(params[:from_date], '%m/%d/%y').kind_of?(Date) ? Date.strptime(params[:from_date], '%m/%d/%y') : Date.today
    @to = Date.strptime(params[:to_date], '%m/%d/%y').kind_of?(Date) ? Date.strptime(params[:to_date], '%m/%d/%y') : Date.today
    # @orders = Order.where(:account_id => @ids).unpaid
  end
  
  def items_by_customer
    @group = Group.find(params[:id])
    @ids = Account.where(group_id: @group.id).ids
    @items = OrderLineItem
    .unscoped
    .joins("INNER JOIN orders ON orders.id = order_line_items.order_id")
    .joins("RIGHT OUTER JOIN items ON items.id = order_line_items.item_id")
    .where("orders.account_id IN (?)", @ids)
    .where("submitted_at > ?", Date.strptime(params[:from_date], '%m/%d/%y'))
    .where("submitted_at < ?", Date.strptime(params[:to_date], '%m/%d/%y'))
    .where("quantity_shipped >= 0")
    .group("item_id, items.number")
    .select("SUM(COALESCE(quantity, 0) - COALESCE(quantity_canceled, 0)) AS qty, item_id AS item_id, items.number AS number")
    .having("item_id = item_id")
    .order("qty DESC")
    .includes(:item => [:prices, :item_vendor_prices])
  end
  
  def items_for_customer
    # @group = Group.find(params[:id])
    # @ids = Account.where(group_id: @group.id).ids
    # @items = OrderLineItem
    # .unscoped
    # .joins("INNER JOIN orders ON orders.id = order_line_items.order_id")
    # .joins("RIGHT OUTER JOIN items ON items.id = order_line_items.item_id")
    # .where("orders.account_id IN (?)", @ids)
    # .where("submitted_at < ?", Date.strptime(params[:to_date], '%m/%d/%y'))
    # .where("quantity_fulfilled >= 0")
    # .group("item_id, items.number")
    # .select("SUM(COALESCE(quantity, 0) - COALESCE(quantity_canceled, 0)) AS qty, item_id AS item_id, items.number AS number")
    # .having("item_id = item_id")
    # .order("qty DESC")
    # .includes(:item => [:item_vendor_prices])
    # puts items.map(&:id)
    @items = Item.where(number: ["AVT75450","UNV15520","BICBLP51WASST","UNV20742","BOSEPS4BK","UNV20746","BRTTZE231","UNV20748","END246050","UNV20821","AVE30600","UNV21129","IVR61027","MMM684RDSH","QUA46071","UNV35210","QUA50562","UNV35260","SAN30001","UNV35264","SAN80653","UNV35610","UNV00133","UNV35668","UNV00700","UNV43118","UNV05562","UNV43138","UNV08100","UNV55400","UNV08109","UNV59022","UNV08864","UNV72210","UNV10054","UNV72220","UNV10200","UNV74325","UNV10210","UNV75606","UNV10220","UNV79000","UNV12113","UNV83412","UNV14115","UNV86920","UNV45000","UNV92010","UNV15001","UNV95223","UNV15262"])
  end
  
  def equipment_by_customer
    @group = Group.find(params[:id])
    @ids = Account.where(group_id: @group.id).ids
  end

  private

  def group_params
    params.require(:group).permit(:group_type, :name, :description)
  end

  def sort_column
    puts Group.column_names[0]
    Group.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end