SpreeSalePrices = {
  init: function() {
    flatpickr.localize({
      weekdays: {
        shorthand: Spree.t('abbr_day_names')
      },
      months: {
        longhand: Spree.t('month_names')
      }
    });

    datetimepickers = document.querySelectorAll(".datetimepicker");

    for(var datetimepicker of datetimepickers){
      fp = flatpickr(datetimepicker, {
        enableTime: true,
        allowInput: true,
        dateFormat: 'Y/m/d G:i K'
      });
    }
  }
}

$(document).ready(function() {
  SpreeSalePrices.init();
});
