class DiscountCodeRulesController < ApplicationController
  layout "admin"
  before_action :set_discount_code_rule, only: [:destroy]
  load_and_authorize_resource
  
  def new
    @discount_code_rule = DiscountCodeRule.new(discount_code_rule_params)
  end
  
  def create
    @discount_code = DiscountCode.find(discount_code_rule_params[:discount_code_id])
    @discount_code_rule = DiscountCodeRule.create(discount_code_rule_params)
  end
  
  def destroy
    @discount_code = @discount_code_rule.code
    @discount_code_rule.destroy!
  end
  
  private

  def set_discount_code_rule
    @discount_code_rule = DiscountCodeRule.find(params[:id])
  end

  def discount_code_rule_params
    params.require(:discount_code_rule).permit(:quantity, :amount, :requirable_id, :requirable_type, :discount_code_id)
  end
end