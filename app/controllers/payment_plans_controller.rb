class PaymentPlansController < ApplicationController
  layout "admin"
  
  def index
    authorize! :read, Account
    @plans = PaymentPlan.all
  end
  
  def show
    authorize! :read, Account
    @plan = PaymentPlan.find(params[:id])
  end
  
  def new
    authorize! :create, Account
    if !params[:payment_plan_template_id].nil?
      @template = PaymentPlanTemplate.find(params[:payment_plan_template_id])
    else
      @template = nil
    end
    
    @account = Account.find(params[:account_id])
    @plan = PaymentPlan.new
  end
  
  def create
    authorize! :create, Account
    @plan = PaymentPlan.new(registration_params.merge(name: params[:payment_plan][:name], account_id: params[:payment_plan][:account_id], payment_plan_template_id: params[:payment_plan][:payment_plan_template_id], billing_start: params[:payment_plan][:billing_start], amount: params[:payment_plan][:amount]))
    if @plan.save
      redirect_to account_path(@plan.account_id)
    else
      render :new
    end
  end
  
  private
  
  def registration_params
    params.require(:payment_plan).permit(:name, :account_id, :payment_plan_template_id, :billing_start, :billing_end, :last_billing_date, :amount)
  end
  
end