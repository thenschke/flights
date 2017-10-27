var telInput = $("#phone"),
button = $("#phone_button")

$(':input[type="submit"]').prop('disabled', true);

// initialise plugin
telInput.intlTelInput({
  autoPlaceholder: true,
  separateDialCode: false,
  customPlaceholder: "510002555",
  initialCountry: "pl",
  preferredCountries: [ "pl", "de" ],
  utilsScript: "https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/12.1.2/js/utils.js"
});

var reset = function() {
  telInput.removeClass("error");
  button.removeClass("active_button");
};

// on blur: validate
telInput.blur(function() {
  reset();
  if ($.trim(telInput.val())) {
    if (telInput.intlTelInput("isValidNumber")) {
      $(':input[type="submit"]').prop('disabled', false);
      button.removeClass("inactive_button");
      button.addClass("active_button");
    } else {
      telInput.addClass("error");
      $(':input[type="submit"]').prop('disabled', true);
      button.removeClass("active_button");
      button.addClass("inactive_button");
    }
  }
});

// on keyup / change flag: reset
telInput.on("keyup change", reset);
