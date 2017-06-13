class DiscountCodeRulesController < ApplicationController
  layout "admin"
  respond_to :html, :json
  
  def new
    authorize! :create, DiscountCodeRule
    @discount_code_rule = DiscountCodeRule.new(discount_code_rule_params)
  end
  
  def create
    authorize! :create, DiscountCodeRule
    @discount_code = DiscountCode.find(discount_code_rule_params[:discount_code_id])
    @discount_code_rule = DiscountCodeRule.create(discount_code_rule_params)
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def destroy
    authorize! :destroy, DiscountCodeRule
    @discount_code_rule = DiscountCodeRule.find_by(:id => params[:id])
    @discount_code = @discount_code_rule.code
    @discount_code_rule.destroy!
    respond_to do |format|
      format.js
    end
  end
  
  private

  def discount_code_rule_params
    params.require(:discount_code_rule).permit(:quantity, :amount, :requirable_id, :requirable_type, :discount_code_id)
  end
end