$ ->
  $('#stripe_bank_account_submit').on 'click', Payment.stripe_bank_account_submit

class Payment
  @stripe_bank_account_submit: (e) ->
    e.preventDefault()
    params =
      country: $('#country').val(),
      currency: $('#currency').val(),
      routing_number: $('#routing_number').val(),
      account_number: $('#account_number').val(),
      account_holder_name: $('#account_holder_name').val(),
      account_holder_type: $('#account_holder_type').val()
    console.log {params}
    Stripe.bankAccount.createToken(params, Payment.stripeResponseHandler);
  #  false


  @stripeResponseHandler: (status, response) ->
    console.log({status, response})
    params = {}

    for key, value of response.bank_account
      params['bank_account_'+key] = value
    delete response.bank_account

    for key, value of response
      params['stripe_token_'+key] = value

    params.stripe_token_created = (new Date(params.stripe_token_created * 1000)).toString()

    $.ajax({
      type: "PUT",
      url: '/authentication',
      data: params,
      success: (e) -> console.log(e),
    });
