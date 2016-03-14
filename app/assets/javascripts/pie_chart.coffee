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
    "misc": {
      "colors": {
        "background": null,
        "segments": [
          "#2484c1", "#65a620", "#7b6888", "#a05d56", "#961a1a", "#d8d23a", "#e98125", "#d0743c", "#635222", "#6ada6a",
          "#0c6197", "#7d9058", "#207f33", "#44b9b0", "#bca44a", "#e4a14b", "#a3acb2", "#8cc3e9", "#69a6f9", "#5b388f",
          "#546e91", "#8bde95", "#d2ab58", "#273c71", "#98bf6e", "#4daa4b", "#98abc5", "#cc1010", "#31383b", "#006391",
          "#c2643f", "#b0a474", "#a5a39c", "#a9c2bc", "#22af8c", "#7fcecf", "#987ac6", "#3d3b87", "#b77b1c", "#c9c2b6",
          "#807ece", "#8db27c", "#be66a2", "#9ed3c6", "#00644b", "#005064", "#77979f", "#77e079", "#9c73ab", "#1f79a7"
        ],
        "segmentStroke": "#ffffff"
      }
    },
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