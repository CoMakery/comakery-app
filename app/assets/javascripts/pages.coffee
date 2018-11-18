# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $('a.interest').click (e)->
    closest = $(@).closest('div')
    $.post '/add-interest',
      protocol: $(@).data('protocol')
      project: $(@).data('project')
      (resp) ->
        closest.find('.interest-done').show()
        closest.find('.interest').remove()
