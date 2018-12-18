// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require turbolinks
//= require jquery3
//= require popper
//= require bootstrap-sprockets
//= require cfa_styleguide_main
//= require vue
//= require_tree .

$(document).on('turbolinks:load', function () {
  function controlElementActive(el) {
    if ($(el)[0].type === 'radio' || $(el)[0].type === 'checkbox') {
      return $(el + ":checked").val() === "true";
    }
    else {
      return !!$(el).val();
    }
  }

  function setControlVisibility($el, controllingElements) {
    var shouldBeVisible = controlElementActive(controllingElements);
    $el.toggleClass('hidden', !shouldBeVisible);
    $el.find('input').each(function (ix, el) {
      var $input = $(this);
      if (shouldBeVisible) {
        $input.prop('required', $input.data('was-required'));
      } else {
        if ($input.prop('required')) {
          $input.data('was-required', true);
          $input.prop('required', false);
        }
      }
    });
  }

  $('[data-visible-by]').each(function (ix, el) {
    var $el = $(el);
    var controller = $el.data('visible-by');
    var controllingElements = 'input[name="' + controller + '"]';
    $(controllingElements).on('change keyup', function () {
      setControlVisibility($el, controllingElements);
    });
    setControlVisibility($el, controllingElements);
  });

  $('#financial_information_household_size').on('keyup', updateMonthlyIncomeLimit);
  updateMonthlyIncomeLimit();
  function updateMonthlyIncomeLimit() {
    var incomeLimit = monthlyIncomeLimit(parseInt($('#financial_information_household_size').val()));
    $('#monthly_income_limit_amount').text(formatCurrency(incomeLimit));
    $('#financial_information_monthly_income_limit').val(incomeLimit);

  }

  function monthlyIncomeLimit(householdSize) {
    return baseMonthlyIncomeLimit + householdSizeIncomeModifier * householdSize;
  }

  function formatCurrency(floatValue) {
    return floatValue.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
  }
});
