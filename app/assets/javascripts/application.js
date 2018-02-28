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
//= require_tree .

$(document).on('turbolinks:load', function () {
  $('input[type="file"]').change(function(event) {
    $(this).closest('form').submit();
  });

  function setFormSubmitDisabled($form) {
    var emptyFields = $form.find('input[required]').filter(function (ix, el) {
      return !el.value;
    });
    $form.find('input[type=submit]').prop('disabled', emptyFields.length !== 0);
  }

  $('form.disable-until-required input[required]').keyup(function (_event) {
    var form = $(this).closest('form');
    setFormSubmitDisabled($(form));
  }).change(function (_event) {
    var form = $(this).closest('form');
    setFormSubmitDisabled($(form));
  });

  $('form.disable-until-required').each(function (ix, el) {
    setFormSubmitDisabled($(el))
  });

  function setControlVisibility($el, controllingElements) {
    var shouldBeVisible = $(controllingElements + ":checked").val() === "true";
    $el.toggleClass('hidden', !shouldBeVisible);
    $el.find('input').each(function (ix, el) {
      var $input = $(this);
      if (shouldBeVisible) {
        $input.prop('required', $input.data('was-required'));
      } else {
        $input.prop('required', false);
        $input.data('was-required', true);
      }
    });
  }

  $('[data-visible-by]').each(function (ix, el) {
    var $el = $(el);
    var controller = $el.data('visible-by');
    var controllingElements = 'input[name="' + controller + '"]';
    $(controllingElements).on('change', function () {
      setControlVisibility($el, controllingElements);
    });
    setControlVisibility($el, controllingElements);
  });
});
