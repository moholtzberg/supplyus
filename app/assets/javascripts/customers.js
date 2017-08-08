jQuery(document).ready(function() {
  $('#customers-table').dataTable({
    "processing": true,
    "serverSide": true,
    "responsive": true,
    "ajax": $('#customers-table').data('source'),
    "pagingType": "full_numbers",
    "autoWidth": false,
    "columns": [
      {"data": "id", className: "min-desktop"},
      {"data": "group", className: "all"},
      {"data": "name", className: "all"},
      {"data": "address_1", className: "min-desktop"},
      {"data": "city", className: "min-desktop"},
      {"data": "state", className: "min-desktop"},
      {"data": "zip", className: "min-desktop"},
      {"data": "phone", className: "min-desktop"},
      {"data": "dropdown", sortable: false, className: "all"}
    ]
    // pagingType is optional, if you want full pagination controls.
    // Check dataTables documentation to learn more about
    // available options.
  });
});