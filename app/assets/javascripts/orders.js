var orders_table = null;
$(document).on('turbolinks:load', function() {
  if ($('#orders-table').length != 0) {
    orders_table = $('#orders-table').dataTable({
      "initComplete": function () {
        var self = this;
        $('.filters input, .filters select').on('change', function(e) {
          th = $(e.target).closest("th")
          self.api().column(th.index()).search($(e.target).val()).draw()   
        });
      },
      "processing": true,
      "serverSide": true,
      "responsive": true,
      "sServerMethod": 'POST',
      "ajax": $('#orders-table').data('source'),
      "pagingType": "full_numbers",
      "autoWidth": false,
      "sDom": 'rt<"row"<"col-sm-2"l><"col-sm-5"i><"col-sm-5"p>>',
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
  }
});

$(document).on('turbolinks:before-cache', function() {
  if ($('#orders-table_wrapper').length != 0) {
    orders_table.fnDestroy();
    orders_table = null;
  }
})