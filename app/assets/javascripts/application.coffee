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
# = require underscore
# = require d3
# = require d3pie
# = require foundation
# = require_tree .

$ ->
  $(document).foundation()

  $("*[data-duplicate]").click (e)->
    e.preventDefault()
    templateSelector = $(e.target).attr('data-duplicate')
    template = $(templateSelector)
    newElement = template.clone()
    newElement.removeClass('hide')
    newElement.removeClass(templateSelector.replace('.', ''))
    template.parent().append(newElement)

  $(document).on "click", "*[data-mark-and-hide]", (e)->
    e.preventDefault()
    removeSelector = $(e.target).attr('data-mark-and-hide')
    removeElement = $(e.target).closest(removeSelector)
    removeElement.hide()
    removeElement.find("input[data-destroy]").val("1")

  window.pieChart = (selector, data)->
    pie = new d3pie(selector, _.extend({
#      "header": {
#        "title": {
#          "text": "Contributions",
#          "fontSize": 22,
#          "font": "verdana"
#        },
#        "subtitle": {
#          "color": "#999999",
#          "fontSize": 10,
#          "font": "verdana"
#        },
#        "location": "top-left",
#        "titleSubtitlePadding": 12
#      },
#      "footer": {
#        "color": "#999999",
#        "fontSize": 11,
#        "font": "open sans",
#        "location": "bottom-center"
#      },
      "size": {
        "canvasHeight": 250,
        "canvasWidth": 275,
        "pieOuterRadius": "88%"
      },
      "labels": {
        "outer": {
          "pieDistance": 32
        },
        "inner": {
          "format": "value"
        },
        "mainLabel": {
          "font": "verdana"
        },
        "percentage": {
          "color": "#e1e1e1",
          "font": "verdana",
          "decimalPlaces": 0
        },
        "value": {
          "color": "#e1e1e1",
          "font": "verdana"
        },
        "lines": {
          "enabled": true,
          "color": "#cccccc"
        },
        "truncation": {
          "enabled": true
        }
      },
      "tooltips": {
        "enabled": true,
        "type": "placeholder",
        "string": "{label}: {value}, {percentage}%"
      },
      "effects": {
        "pullOutSegmentOnClick": {
          "effect": "linear",
          "speed": 400,
          "size": 15
        }
      }
    }, {"data": data}))