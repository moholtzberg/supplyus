var purchase_orders_table = null;
$(document).on('turbolinks:load', function() {
  if ($('#purchase-orders-table').length != 0) {
    purchase_orders_table = $('#purchase-orders-table').dataTable({
      "processing": true,
      "serverSide": true,
      "responsive": true,
      "sServerMethod": 'POST',
      "ajax": $('#purchase-orders-table').data('source'),
      "pagingType": "full_numbers",
      "autoWidth": false,
      "columns": [
        {"data": "number", className: "all"},
        {"data": "vendor", className: "all"},
        {"data": "total", sortable: false, className: "all"},
        {"data": "notes", className: "all"},
        {"data": "amount_received", sortable: false, className: "min-desktop"},
        {"data": "completed_at", className: "min-desktop"},
        {"data": "locked", className: "min-desktop"},
        {"data": "dropdown", sortable: false, className: "all"}
      ]
    });
  }
});

$(document).on('turbolinks:before-cache', function() {
  if ($('#purchase-orders-table_wrapper').length != 0) {
    purchase_orders_table.fnDestroy();
    purchase_orders_table = null;
  }
})