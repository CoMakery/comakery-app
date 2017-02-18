

Stripe.bankAccount.createToken({
  country: $('#country').val(),
  currency: $('#currency').val(),
  routing_number: $('#routing_number').val(),
  account_number: $('#account_number').val(),
  account_holder_name: $('#account_holder_name').val(),
  account_holder_type: $('#account_holder_type').val()
}, stripeResponseHandler);
