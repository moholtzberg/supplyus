class ChargesController < ApplicationController
  layout "admin"
  
  def index
    authorize! :read, Charge
    @charges = Charge.unbilled
    if params[:account_id]
      @charges.by_account(params[:account_id])
    end
    if params[:payment_plan_id]
      @charges.by_plan(params[:payment_plan_id])
    end
  end
  
  def new
    authorize! :create, Charge
    @accounts = Account.all
    @charge = Charge.new(:account_id => params[:account_id])
  end
  
  def create
    authorize! :create, Charge
    @unbilled_charges = Charge.by_account(params[:charge][:account_id]).unbilled
    @charge = Charge.new(:account_id => params[:charge][:account_id], :amount => params[:charge][:amount], :description => params[:charge][:description], :quantity => params[:charge][:quantity])
    respond_to do |format|
      if @charge.save
        format.html { redirect_to accounts_path(@charge.account_id) }
        format.js { }
      else
        format.html { render action: "new" }
        format.js { }
      end
    end
  end
  
  def destroy
    authorize! :destroy, Charge
    @charge = Charge.find(params[:id])
    account_id = @charge.account_id
    @charge.destroy
    @unbilled_charges = Charge.by_account(account_id).unbilled
  end
  
end