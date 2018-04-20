# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https:#github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
# = require jquery
# = require jquery_ujs
# = require d3
# = require d3pie
# = require foundation
# = require moment
# = require underscore
# = require chart_colors
# = require_tree .

$ ->
  $(document).foundation()

  # lets hope we never have more than 1000 initial records (award types only have 3 by default)
  nextIdentifier = 1000
  $("*[data-duplicate]").click (e)->
    e.preventDefault()
    templateSelector = $(e.target).attr('data-duplicate')
    template = $(templateSelector)
    newElement = template.clone()
    newElement.removeClass('hide')
    newElement.removeClass(templateSelector.replace('.', ''))
    newElementIdentifier = nextIdentifier++
    _.each $(newElement).find("input"), (input)->
      currentName = $(input).attr("name")
      number = +currentName.match(/[0-9]+/)[0]
      fixedName = currentName.replace(/\[[0-9]+\]/, "[" + (number + nextIdentifier) + "]")
      $(input).attr("name", fixedName)

    template.parent().append(newElement)

  $(document).on "click", "*[data-toggles]", (e)->
    selector = $(e.target).attr('data-toggles')
    $(selector).toggleClass("hide")

  $(document).on "click", "*[data-mark-and-hide]", (e)->
    e.preventDefault()
    removeSelector = $(e.target).attr('data-mark-and-hide')
    removeElement = $(e.target).closest(removeSelector)
    removeElement.hide()
    removeElement.find("input[data-destroy]").val("1")

  $(document).on "change", ".provider_select", (e) ->
    $('.active-channel').removeClass('active-channel')
    $closest = $(@).closest('.row')
    $closest.addClass('active-channel')
    $id = $closest.find('.team_select').attr('id')
    $data = {elem_id: $id, provider: $(@).val()}
    $.get("/teams.js", $data)

  $(document).on "change", ".team_select", (e) ->
    $('.active-channel').removeClass('active-channel')
    $closest = $(@).closest('.row')
    $closest.addClass('active-channel')
    $id = $closest.find('.channel_select').attr('id')
    $data = {elem_id: $id}
    $.get("/teams/" + $(@).val() + "/channels.js", $data)

  $(document).on "change", ".fetch-channel-users", (e) ->
    if $(@).val()
      $('.award-email').attr('name','')
      $('.uid-email').addClass('hide')
      $('.uid-select').removeClass('hide')
      $.get("/channels/" + $(@).val() + "/users.js")
    else
      $('.member-select').attr('name','')
      $('.award-email').attr('name','award[uid]')
      $('.uid-email').removeClass('hide')
      $('.uid-select').addClass('hide')

  $(document).on "keyup", "input#award_quantity", (e) ->
    value = $(@).val()
    arr=value.split('.')
    if arr[1]
      if arr[1].length > 2
        $(@).val(value.slice(0,-1))
        return false

  $('tr.award-row')
    .on 'mouseover', (e) ->
      $(@).find('.overlay').show()
    .on 'mouseout', (e) ->
      $(@).find('.overlay').hide()

  # Run on page ready then bind events
  awardPaymentType()
  $('#project_payment_type').change (e)->
    awardPaymentType()

  royaltyCalc()
  $('#project_royalty_percentage, #project_maximum_tokens, #project_denomination').change (e) ->
    royaltyCalc()

awardPaymentType = () ->
  switch $('#project_payment_type option:selected').val()
    when 'project_token'
      $('.revenue-sharing-terms').addClass('hide')
      $('.project-token-terms').removeClass('hide')
      $('span.award-type').html('Project Tokens')
    when 'revenue_share'
      $('.revenue-sharing-terms').removeClass('hide')
      $('.project-token-terms').addClass('hide')
      $('span.award-type').html('Revenue Shares')

royaltyCalc = () ->
  return unless $('#project_denomination option:selected').html()
  percentage = $('#project_royalty_percentage').val()
  maxAwarded = $('#project_maximum_tokens').val()

  schedule = $("<tbody>")
  currencyFromSelectedOption = $('#project_denomination option:selected').html().match(/\((.+?)\)/)[1]
  denomination = "<span class='denomination'>#{currencyFromSelectedOption}</span>"

  for revenue in [1e3, 1e4, 1e5, 1e6]
    contributorPayment = revenue * percentage / 100
    $(schedule).append "<tr><td>#{denomination}#{revenue.toLocaleString()}</td>" +
      "<td>#{denomination}#{contributorPayment.toLocaleString()}</td>"

  $('.royalty-calc tbody').replaceWith(schedule)
