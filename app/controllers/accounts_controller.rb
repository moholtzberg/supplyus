class AccountsController < ApplicationController
  layout "admin"
  helper_method :sort_column, :sort_direction
  
  def index
    @accounts = Account.order(sort_column + " " + sort_direction).where("name like ?", "%#{params[:term]}%")
    respond_to do |format|
      format.html
      format.json {render :json => @accounts.map(&:name)}
    end
  end
  
  def new
    @account = Account.new
  end
  
  def show
    @account = Account.find(params[:id])
    @item_prices = AccountItemPrice.where(account_id: @account.id).includes(:item)
  end
  # def create
  #   account = Account.create(params[:new_account])
  #   if account.save!
  #     redirect_to accounts_path
  #   else
  #     render "new"
  #   end
  # end
  
  # def create
  #   @amount = 500
  # 
  #   customer = Stripe::Customer.create(
  #     :email => 'example@stripe.com',
  #     :card  => params[:stripeToken]
  #   )
  # 
  #   charge = Stripe::Charge.create(
  #     :customer    => customer.id,
  #     :amount      => @amount,
  #     :description => 'Rails Stripe customer',
  #     :currency    => 'usd'
  #   )
  # 
  # rescue Stripe::CardError => e
  #   flash[:error] = e.message
  #   redirect_to new_account_path
  # end
  
  def create
    @account = Account.new(registration_params.merge(email: params[:account][:email], name: params[:account][:name], address_1: params[:account][:address_1], address_2: params[:account][:address_2], city: params[:account][:city], state: params[:account][:state], zip: params[:account][:zip], phone: params[:account][:phone], fax: params[:account][:fax]))
    puts params["card_token"]
    account = Stripe::Customer.create(:email => @account.email, :card => params["card_token"])
    puts account.sources
    puts account.nil?
    @account.stripe_customer_id = account.id
    @account.save!
    raise "Please, check registration errors" if account.nil?
    # charge = Stripe::Charge.create(:customer => account.id, :amount => 500, :description => "Test charge!", :currency => "usd")
    redirect_to accounts_path, notice: 'Registration was successfully created.'
  rescue Exception => e
    @account = Account.new
    flash[:error] = e.message
    render :new
  end

  private

  def registration_params
    params.require(:account).permit(:name, :email, :address_1, :address_2, :city, :state, :zip, :phone, :fax)
  end

  def sort_column
    puts Account.column_names[0]
    Account.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end