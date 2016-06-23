class MetersController < ApplicationController
  layout "admin"
  
  def index
    authorize! :read, Account
    @meters = Meter.all
    if params[:account_id]
      @meters.by_account(params[:account_id])
    end
    if  params[:equipment_id]
      @meters.by_equipment(params[:account_id])
    end
  end
  
  def new
    authorize! :create, Account
    @meter = Meter.new
    @equipment_id = params[:equipment_id]
  end
  
  def create
    authorize! :create, Account
    @account = Account.find_by(:id => Equipment.find_by(:id => params[:meter][:equipment_id]).id)
    @contact = Meter.create(:equipment_id => params[:meter][:equipment_id])
  end
  
end