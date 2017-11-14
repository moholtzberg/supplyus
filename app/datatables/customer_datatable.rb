class CustomerDatatable < AjaxDatatablesRails::Base

  def_delegator :@view, :dropdown

  def view_columns
    @view_columns ||= {
      id:  { source: "Customer.id", cond: :eq },
      group:  { source: "Group.name" },
      name:  { source: "Customer.name" },
      address_1:  { source: "Address.address_1" },
      city: { source: "Address.city" },
      state: { source: "Address.state" },
      zip: { source: "Address.zip" },
      phone: { source: "Address.phone" },
      dropdown: { source: "", searchable: false },
    }
  end

  def data
    records.map do |record|
      {
        id: record.id,
        group: record.group_name,
        name: record.name,
        address_1: record.address_1,
        city: record.city,
        state: record.state,
        zip: record.zip,
        phone: record.phone,
        dropdown: dropdown(record.class, record)
      }
    end
  end

  private

  def get_raw_records
    Customer.joins(:main_address).joins('LEFT OUTER JOIN groups ON groups.id = accounts.group_id')
  end

end
