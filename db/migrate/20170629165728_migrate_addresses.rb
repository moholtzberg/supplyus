class MigrateAddresses < ActiveRecord::Migration
  def change
    Account.all.each do |account|
      Address.create({
        account_id: account.id,
        address_1: account.ship_to_address_1,
        address_2: account.ship_to_address_2,
        city: account.ship_to_city,
        state: account.ship_to_state,
        zip: account.ship_to_zip,
        phone: account.ship_to_phone,
        fax: account.ship_to_fax,
        main: true
      })
      Address.create({
        account_id: account.id,
        address_1: account.bill_to_address_1,
        address_2: account.bill_to_address_2,
        city: account.bill_to_city,
        state: account.bill_to_state,
        zip: account.bill_to_zip,
        phone: account.bill_to_phone,
        fax: account.bill_to_fax,
        main: false
      })
    end
  end
end
