$(function () {

  function IsJsonString(str) {
    try {
      JSON.parse(str);
    } catch (e) {
      return false;
    }
    return true;
  }

  // *** For all ajax requests ***

  // Check that we have permissions error (ApplicationController -> CanCanCan Permission error handler, html | js | json)
  $(document).ajaxComplete(function (event, jqxhr) {
    if (jqxhr.hasOwnProperty('responseText')) {

      // responseText in json format
      if (IsJsonString(jqxhr.responseText)) {

        var parsed_response = JSON.parse(jqxhr.responseText);
        if (parsed_response.hasOwnProperty('permission_error')) {
          console.log(parsed_response.permission_error);
          Recurring.flash.showMsg('alert', "You need permission to perform this action.");
        }

      // responseText in text format
      } else {
        if (jqxhr.responseText == 'You need permission to perform this action.') {
          Recurring.flash.showMsg('alert', "You need permission to perform this action.");
        }
      }

    }
  });

});