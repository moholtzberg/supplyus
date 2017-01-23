class MachineModelItemsController < ApplicationController
  layout "admin"
  before_action :set_machine_model_item, only: [:show, :edit, :update, :destroy]

  # GET /machine_model_items
  # GET /machine_model_items.json
  def index
    @machine_model_items = MachineModelItem.all
  end

  # GET /machine_model_items/1
  # GET /machine_model_items/1.json
  def show
  end

  # GET /machine_model_items/new
  def new
    @machine_model_item = MachineModelItem.new
  end

  # GET /machine_model_items/1/edit
  def edit
  end

  # POST /machine_model_items
  # POST /machine_model_items.json
  def create
    @machine_model_item = MachineModelItem.new(machine_model_item_params)

    respond_to do |format|
      if @machine_model_item.save
        format.html { redirect_to @machine_model_item, notice: 'Machine model item was successfully created.' }
        format.json { render :show, status: :created, location: @machine_model_item }
      else
        format.html { render :new }
        format.json { render json: @machine_model_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /machine_model_items/1
  # PATCH/PUT /machine_model_items/1.json
  def update
    respond_to do |format|
      if @machine_model_item.update(machine_model_item_params)
        format.html { redirect_to @machine_model_item, notice: 'Machine model item was successfully updated.' }
        format.json { render :show, status: :ok, location: @machine_model_item }
      else
        format.html { render :edit }
        format.json { render json: @machine_model_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /machine_model_items/1
  # DELETE /machine_model_items/1.json
  def destroy
    @machine_model_item.destroy
    respond_to do |format|
      format.html { redirect_to machine_model_items_url, notice: 'Machine model item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_machine_model_item
      @machine_model_item = MachineModelItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def machine_model_item_params
      params.require(:machine_model_item).permit(:machine_model_number, :item_number, :supply_type, :supply_color, :priority)
    end
end
