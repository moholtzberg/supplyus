class DiscountCodeEffectsController < ApplicationController
  layout "admin"
  respond_to :html, :json
  
  def edit
    authorize! :update, DiscountCodeEffect
    @discount_code_effect = DiscountCodeEffect.find_by(:id => params[:id])
  end
  
  def update
    authorize! :update, DiscountCodeEffect
    @discount_code_effect = DiscountCodeEffect.find_by(:id => params[:id])
    @discount_code_effect.update_attributes(discount_code_effect_params)
  end
  
  private

  def discount_code_effect_params
    params.require(:discount_code_effect).permit(:name, :amount, :percent, :shipping, :quantity, :item_id, :appliable_id, :appliable_type)
  end
end