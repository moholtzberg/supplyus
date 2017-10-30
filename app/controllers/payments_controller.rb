class PaymentsController < ApplicationController
  layout 'admin'
  helper_method :sort_column, :sort_direction
  before_action :set_payment, only: %i[edit update destroy finalize]
  load_and_authorize_resource except: [:finalize]

  def index
    update_index
    respond_to do |format|
      format.html
      format.js
      format.json { render :json => @payments.map(&:number) }
    end
  end

  def new
    @payment = Payment.new
  end

  def create
    @payment = Payment.new(payment_params)
    @payment.save if @payment.valid? && @payment.authorize
    update_index
  end

  def edit; end

  def update
    @payment.update_attributes(payment_params)
  end

  def finalize
    authorize! :update, Payment
    @payment.finalize
    update_index
  end

  private

  def set_payment
    @payment = Payment.find(params[:id])
  end

  def update_index
    @payments = Payment.includes(:account)
                       .order(sort_column + ' ' + sort_direction)
                       .includes(:order_payment_applications => [:order])
    @payments = @payments.lookup(params[:term]) if params[:term].present?
    @payments = @payments.paginate(:page => params[:page], :per_page => 25)
  end

  def payment_params
    params.require(:payment).permit(
      :amount, :account_name, :payment_method_id, :credit_card_id,
      :check_number, :date, :payment_type,
      order_payment_applications_attributes: [:order_id, :applied_amount]
    )
  end

  def sort_column
    default = 'payments.id'
    columns = [Account, Payment].inject([]) do |a, c|
      a + c.column_names.map do |cn|
        "#{c.table_name}.#{cn}"
      end
    end
    columns.include?(params[:sort]) ? params[:sort] : default
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
end
