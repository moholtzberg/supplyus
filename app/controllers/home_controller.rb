class HomeController < ApplicationController
  layout "admin"
  
  def show
    @account = Account.new
    @upcoming_charges = PaymentPlan.all.active
    @invoices = Invoice.all
  end
  
end