class MyAccount::AddressesController < ApplicationController
  respond_to :html, :json
  
  def new
    authorize! :create, Address
    @address = Address.new(address_params)
  end
  
  def create
    authorize! :create, Address
    @account = Account.find(address_params[:account_id])
    @address = Address.create(address_params)
    flash[:error] = @address.errors.full_messages.join(', ') if @address.errors.any?
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def destroy
    authorize! :destroy, Address
    @address = Address.find_by(:id => params[:id])
    @account = @address.account
    @address.destroy!
    respond_to do |format|
      format.js
    end
  end
  
  private

  def address_params
    params.require(:address).permit(:address_1, :address_2, :city, :state, :zip, :phone, :fax, :main, :account_id)
  end
end