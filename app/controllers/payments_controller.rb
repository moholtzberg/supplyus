class PaymentsController < ApplicationController
  layout 'admin'
  helper_method :sort_column, :sort_direction
  before_action :set_payment, only: [:edit, :update, :destroy, :finalize]
  load_and_authorize_resource except: [:finalize]
  
  def index
    update_index
    respond_to do |format|
      format.html
      format.js
      format.json {render :json => @payments.map(&:number)}
    end
  end
  
  def new
    @payment = Payment.new
  end
  
  def create
    @payment = Payment.create(payment_params)
    @payment = @payment.becomes @payment.payment_type
    @payment.authorize
    udpate_index
  end

  def edit
  end

  def update
    @payment.update_attributes(payment_params)
  end
  
  def finalize
    authorize! :update, Payment
    @payment.finalize
  end

  private

  def set_payment
    @payment = Payment.find(params[:id])
  end

  def update_index
    @payments = Payment.includes(:account).order(sort_column + " " + sort_direction).includes(:order_payment_applications => [:order])
    unless params[:term].blank?
      @payments = @payments.lookup(params[:term]) if params[:term].present?
    end
    @payments = @payments.paginate(:page => params[:page], :per_page => 25)
  end
  
  def payment_params
    params.require(:payment).permit(:amount, :account_name, :payment_method_id, :credit_card_id, :check_number, :date)
  end
  
  def sort_column
    related_columns = Payment.reflect_on_all_associations(:belongs_to).map {|a| a.klass.column_names.map {|col| "#{a.klass.table_name}.#{col}"}}
    columns = Payment.column_names.map {|a| "payments.#{a}" }
    columns.push(related_columns).flatten!.uniq!
    columns.include?(params[:sort]) ? params[:sort] : "payments.id"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end