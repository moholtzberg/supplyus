class EquipmentController < ApplicationController
  layout "admin"
  
  def index
    authorize! :read, Account
    Equipment.all.each {|e| e.destroy!}
    @equipment = Equipment.all
  end
  
  def new
    authorize! :create, Account
    @equipment = Equipment.new
    @account_id = params[:account_id]
  end
  
  def show
    authorize! :read, Account
    @equipment = Equipment.find(params[:id])
  end
  
  def create
    authorize! :create, Account
    @account = Account.find_by(:id => params[:equipment][:account_id])
    @equipment = Equipment.create(:account_id => params[:equipment][:account_id], :number => params[:equipment][:number], :serial => params[:equipment][:serial], :make => params[:equipment][:make], :model => params[:equipment][:model])
    puts "--- #{@account.equipment.inspect}"
  end
  
  def delete
    authorize! :destroy, Account
    @equipment = Equipment.find_by(:id => params[:id])
  end
  
  def destroy
    authorize! :destroy, Account
    e = Equipment.find_by(:id => params[:id])
    e.destroy!
    @account = Account.find_by(:id => e.account_id)
  end
  
end