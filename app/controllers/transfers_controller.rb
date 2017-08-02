class TransfersController < ApplicationController
  layout "admin"
  respond_to :html, :json

  def new
    authorize! :create, Transfer
    @transfer = Transfer.new(from_id: params[:inventory_id], quantity: params[:quantity])
  end
  
  def create
    authorize! :create, Transfer
    bin = Bin.find_by(name: params[:transfer][:bin_name])
    @transfer = Transfer.new(transfer_params.merge(to_id: bin.id))
    if @transfer.save
      redirect_to inventories_path
    end
  end

  private

  def transfer_params
    params.require(:transfer).permit(:from_id, :quantity)
  end

end