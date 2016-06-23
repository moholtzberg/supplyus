class MeterReadingsController < ApplicationController
  layout "admin"
  
  def show
    authorize! :read, Account
    @meter_reading = MeterReading.find_by(:id => params[:meter_id])
  end
  
  def new
    authorize! :create, Account
    @meter_id = params[:meter_id]
    @meter_reading = MeterReading.new
    @last_meter = Meter.find_by(:id => params[:meter_id]).last_valid_meter
  end
  
  def create
    authorize! :create, Account
    @meter_id = params[:meter_reading][:meter_id]
    puts "------>>> #{Meter.find_by(:id => params[:meter_reading][:meter_id]).equipment.inspect}"
    @account = Meter.find_by(:id => params[:meter_reading][:meter_id]).equipment.account
    puts "--------> #{@account.id} ---> #{@account.equipment.inspect}"
    @meter_reading = MeterReading.new(:meter_id => params[:meter_reading][:meter_id], :display => params[:meter_reading][:display], :source => params[:meter_reading][:source], :is_estimate => params[:meter_reading][:is_estimate], :is_valid => params[:meter_reading][:is_valid])
    if @meter_reading.save
      puts "--------> #{@meter_reading.errors.any?}"
    else
      flash[:error] = "Meter reading was not saved, please check error mesages for details!"
    end
  end
  
end