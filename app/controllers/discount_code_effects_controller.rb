class DiscountCodeEffectsController < ApplicationController
  layout "admin"
  before_action :set_discount_code_effect, only: [:edit, :update]
  load_and_authorize_resource
  
  def edit
  end
  
  def update
    @discount_code_effect.update_attributes(discount_code_effect_params)
  end
  
  private

  def set_discount_code_effect
    @discount_code_effect = DiscountCodeEffect.find(params[:id])
  end

  def discount_code_effect_params
    params.require(:discount_code_effect).permit(:name, :amount, :percent, :shipping, :quantity, :item_id, :appliable_id, :appliable_type)
  end
end