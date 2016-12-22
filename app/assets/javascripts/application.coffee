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

  $('#project_payment_type').change (e)->
    switch $('#project_payment_type option:selected').val()
      when 'project_coin'
        $('#royalty-legal-terms').addClass('hide')
        $('span.denomination').html('Project Coins')
      when 'royalty_usd'
        $('#royalty-legal-terms').removeClass('hide')
        $('span.denomination').html('$')
      when 'royalty_btc'
        $('#royalty-legal-terms').removeClass('hide')
        $('span.denomination').html('฿')

  royaltyCalc()
  $('#project_royalty_percentage, #project_maximum_coins').on 'ready change', (e) ->
    royaltyCalc()

royaltyCalc = () ->
  percentage = $('#project_royalty_percentage').val()
  maxAwarded = $('#project_maximum_coins').val()

  schedule = $("<tbody>")

  for monthlyRevenue in [100, 1000, 10000, 100000]
    monthlyPayment = monthlyRevenue * percentage / 100
    yearsToPay = maxAwarded / monthlyPayment
    denomination = "<span class='denomination'>#{$('span.denomination').html()}</span>"
    $(schedule).append("<tr><td>#{denomination}#{monthlyRevenue.toFixed()}</td><td>#{denomination}#{monthlyPayment.toFixed(2)}</td><td>#{yearsToPay.toFixed(2)}</td></tr>")

  $('.royalty-calc tbody').replaceWith(schedule)
