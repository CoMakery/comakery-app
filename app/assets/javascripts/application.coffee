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
# = require jquery-ui
# = require d3
# = require d3pie
# = require foundation
# = require moment
# = require underscore
# = require chart_colors
#  require cookieconsent
# = require_tree .

$ ->

  window.cookieconsent.initialise({
    "palette": {
      "popup": {
        "background": "#237afc"
      },
      "button": {
        "background": "#fff",
        "text": "#237afc"
      }
    }
  })

  $(document).foundation()
  $('.datepicker').datepicker({
    dateFormat: 'mm/dd/yy',
    defaultDate: '01/01/2000',
    changeYear: true,
    yearRange: '1950:2010'
  })

  $('.datepicker-no-limit').datepicker({
    dateFormat: 'mm/dd/yy',
    changeYear: true
  })

  if $('.datepicker').val()
    $('.datepicker').datepicker("setDate",new Date($('.datepicker').val()))
  if $('.datepicker-no-limit').val()
    $('.datepicker-nolimit').datepicker("setDate",new Date($('.datepicker').val()))

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

  $(document).on 'click', '.signin-with-metamask', ->
    loginWithMetaMask.handleClick()

  $(document).on 'click', '.scrollingBox.menu a', ->
    href = $(this).attr 'href'
    anchor = href.substr href.indexOf('#') + 1
    $('html, body').animate { scrollTop: $('div[data-id=' + anchor + ']').offset().top }, 1000
    if $(document).scrollTop() >= document.body.offsetHeight - window.innerHeight
      $('.scrollingBox.menu a').removeClass 'active-menu'
      $(this).addClass 'active-menu'
    else
      $(this).closest('.menu').attr 'data-hash', anchor

  $(document).on 'scroll', (event) ->
    limit = document.body.offsetHeight - window.innerHeight
    scrollPos = $(document).scrollTop() + 10
    currentAnchor = $('.scrollingBox.menu').attr 'data-hash'
    if currentAnchor
      topOfCurrentAnchor = $('div[data-id=' + currentAnchor + ']').offset().top
      $('.scrollingBox.menu a').removeClass 'active-menu'
      $('.scrollingBox.menu a[href$=' + currentAnchor + ']').addClass 'active-menu'
      if $(document).scrollTop() == topOfCurrentAnchor || $(document).scrollTop() >= limit
        $('.scrollingBox.menu').removeAttr 'data-hash'
    else
      $('.scrollingBox.menu a').each ->
        currLink = $(this)
        href = currLink.attr 'href'
        anchor = href.substr href.indexOf('#') + 1
        refElement = $('div[data-id=' + anchor + ']')
        if refElement.position().top <= scrollPos and refElement.position().top + refElement.height() > scrollPos
          $('.scrollingBox.menu a').removeClass 'active-menu'
          currLink.addClass 'active-menu'
        else
          currLink.removeClass 'active-menu'

    $('tr.award-row')
    .on 'mouseover', (e) ->
      $(@).find('.overlay').show()
    .on 'mouseout', (e) ->
      $(@).find('.overlay').hide()

  $('.copiable').click ->
    $(".copy-source").select()
    document.execCommand('Copy')

  $('input[name=mine]').click (e) ->
    window.location.href = $(@).val()

  $('#project_payment_type').change (e)->
    awardPaymentType()

  floatingLeftMenuItems()
  # Run on page ready then bind events
  awardPaymentType()

  royaltyCalc()
  $('#project_royalty_percentage, #project_maximum_tokens, #project_denomination').change (e) ->
    royaltyCalc()

  if $('.preview-content').height() > 310
    $('.read-more').show()

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

floatingLeftMenuItems = () ->
  offsetPixels = 150
  $(window).scroll ->
    if $(window).scrollTop() > offsetPixels
      $('.scrollingBox').css
        'position': 'fixed'
        'top': '50px'
        'width': $('.scrollingBox').closest('div').width() + 30
    else
      $('.scrollingBox').css 'position': 'static'
