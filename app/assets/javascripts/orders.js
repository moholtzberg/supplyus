$(document).on('turbolinks:load', function() {
  $('#orders-table').dataTable({
    "processing": true,
    "serverSide": true,
    "responsive": true,
    "sServerMethod": 'POST',
    "ajax": $('#orders-table').data('source'),
    "pagingType": "full_numbers",
    "autoWidth": false,
    "columns": [
      {"data": "number", className: "all"},
      {"data": "account", className: "all"},
      {"data": "total", sortable: false, className: "all"},
      {"data": "sub_total", className: "all"},
      {"data": "shipped", sortable: false, className: "min-desktop"},
      {"data": "fulfilled", sortable: false, className: "min-desktop"},
      {"data": "balance_due", sortable: false, className: "min-desktop"},
      {"data": "submitted_at", className: "min-desktop"},
      {"data": "state", className: "all"},
      {"data": "dropdown", sortable: false, className: "all"}
    ]
  });
});