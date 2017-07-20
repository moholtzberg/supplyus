class MigratePricesToNewModel < ActiveRecord::Migration
  def change
    AccountItemPrice.all.each do |aip|
      Price.create({
        item_id: aip.item_id,
        _type: 'Default',
        appliable_type: 'Account',
        appliable_id: aip.account_id,
        price: aip.price
        })
    end
    GroupItemPrice.all.each do |gip|
      if gip.active?
        Price.create({
          item_id: aip.item_id,
          _type: 'Default',
          appliable_type: 'Group',
          appliable_id: aip.group_id,
          price: aip.price
          })
      end
    end
  end
end
