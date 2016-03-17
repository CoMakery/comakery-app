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
# = require_tree .

$ ->
  $(document).foundation()

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

  $(document).on "click", "*[data-mark-and-hide]", (e)->
    e.preventDefault()
    removeSelector = $(e.target).attr('data-mark-and-hide')
    removeElement = $(e.target).closest(removeSelector)
    removeElement.hide()
    removeElement.find("input[data-destroy]").val("1")