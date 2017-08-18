class OrderDatatable < AjaxDatatablesRails::Base

  def_delegators :@view, :dropdown, :number_to_currency

  def view_columns
    @view_columns ||= {
      number: { source: "Order.number" },
      account: { source: "Account.name" },
      total: { source: "", searchable: false },
      sub_total: { source: "Order.sub_total", cond: :eq },
      shipped: { source: "", searchable: false },
      fulfilled: { source: "", searchable: false },
      balance_due: { source: "", searchable: false },
      submitted_at: { source: "Order.submitted_at" },
      state: { source: "Order.state", cond: :eq },
      dropdown: { source: "", searchable: false }
    }
  end

  def data
    records.map do |record|
      {
        number: record.number,
        account: record.account&.name,
        total: number_to_currency(record.total),
        sub_total: number_to_currency(record.sub_total),
        shipped: number_to_currency(record.amount_shipped),
        fulfilled: number_to_currency(record.amount_fulfilled),
        balance_due: number_to_currency(record.balance_due),
        submitted_at: record.submitted_at&.strftime("%m/%d/%y %I:%M %p"),
        state: record.state,
        dropdown: dropdown(record.class, record)
      }
    end
  end

  private

  def get_raw_records
    Order.eager_load({:account => [:group]}, {:order_line_items => [:line_item_shipments, :line_item_fulfillments]}, :order_tax_rate, :order_payment_applications => [:payment])
  end

end