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

  # Run on page ready then bind events
  awardPaymentType()
  $('#project_payment_type').change (e)->
    awardPaymentType()

  royaltyCalc()
  $('#project_royalty_percentage, #project_maximum_coins, #project_denomination').change (e) ->
    royaltyCalc()

awardPaymentType = () ->
  switch $('#project_payment_type option:selected').val()
    when 'project_coin'
      $('.revenue-sharing-terms').addClass('hide')
      $('.project-coin-terms').removeClass('hide')
      $('span.award-type').html('Project Coins')
    when 'revenue_share'
      $('.revenue-sharing-terms').removeClass('hide')
      $('.project-coin-terms').addClass('hide')
      $('span.award-type').html('Revenue Shares')

royaltyCalc = () ->
  return unless $('#project_denomination option:selected').html()
  percentage = $('#project_royalty_percentage').val()
  maxAwarded = $('#project_maximum_coins').val()

  schedule = $("<tbody>")

  for revenue in [1e3, 1e4, 1e5, 1e6]
    contributorPayment = revenue * percentage / 100
    currencyFromSelectedOption = $('#project_denomination option:selected').html().match(/\(([^)]+)\)/)[1]
    denomination = "<span class='denomination'>#{currencyFromSelectedOption}</span>"
    $(schedule).append "<tr><td>#{denomination}#{revenue.toLocaleString()}</td>" +
      "<td>#{denomination}#{contributorPayment.toLocaleString()}</td>"

  $('.royalty-calc tbody').replaceWith(schedule)
