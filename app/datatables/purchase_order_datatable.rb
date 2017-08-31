class PurchaseOrderDatatable < AjaxDatatablesRails::Base

  def_delegators :@view, :dropdown, :number_to_currency

  def view_columns
    @view_columns ||= {
      number: { source: "PurchaseOrder.number" },
      vendor: { source: "Vendor.name" },
      total: { source: "", searchable: false },
      notes: { source: "PurchaseOrder.notes", cond: :eq },
      amount_received: { source: "", searchable: false },
      completed_at: { source: "PurchaseOrder.completed_at" },
      locked: { source: "PurchaseOrder.locked" }
    }
  end

  def data
    records.map do |record|
      {
        number: record.number,
        vendor: record.vendor&.name,
        total: number_to_currency(record.total),
        notes: record.notes,
        amount_received: number_to_currency(record.amount_received),
        completed_at: record.completed_at&.strftime("%m/%d/%y %I:%M %p"),
        locked: record.locked ? 'Yes' : 'No',
        dropdown: dropdown(record.class, record)
      }
    end
  end

  private

  def get_raw_records
    PurchaseOrder.eager_load(:vendor)
  end

end