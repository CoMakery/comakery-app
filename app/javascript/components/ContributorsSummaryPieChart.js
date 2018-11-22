import React from 'react'
import PropTypes from 'prop-types'
import * as d3 from 'd3'
import D3Pie from 'd3pie'

class ContributorsSummaryPieChart extends React.Component {
  constructor(props) {
    super(props)
    this.createPieChart = this.createPieChart.bind(this)
    this.destroyPieChart = this.destroyPieChart.bind(this)
  }

  componentDidMount() {
    this.createPieChart()
  }

  componentWillUnmount() {
    this.destroyPieChart()
  }

  createPieChart() {
    if (this.props.chartData.length) {
      this.pieChart = new D3Pie('#award-percentages', {
        'misc': {
          'colors': {
            'background': null,
            'segments'  : [
              '#7B00D7',
              '#E5004F',
              '#0884FF',
              '#73C30E',
              '#D5E301',
              '#F6A504',
              '#C500FF',
              '#00C3EB',
              '#F85900',
              '#b00000',
              '#e4e400',
              '#baba00',
              '#878700',
              '#00b000',
              '#008700',
              '#00ffff',
              '#00b0b0',
              '#008787',
              '#b0b0ff',
              '#8484ff',
              '#4949ff',
              '#0000ff',
              '#ff00ff',
              '#b000b0'
            ],
            'segmentStroke': '#ffffff'
          }
        },
        'size': {
          'canvasHeight'  : 300,
          'canvasWidth'   : 450,
          'pieOuterRadius': '80%'
        },
        'labels': {
          'outer': {
            'pieDistance': 14
          },
          'inner': {
            'format': 'percentage'
          },
          'mainLabel': {
            'fontSize': 12,
          },
          'percentage': {
            'color'        : '#e1e1e1',
            'decimalPlaces': 2
          },
          'value': {
            'color': '#e1e1e1',
          },
          'lines': {
            'enabled': true,
            'color'  : '#cccccc'
          },
          'truncation': {
            'enabled': true
          }
        },
        'tooltips': {
          'enabled': true,
          'type'   : 'placeholder',
          'string' : '{label}: {percentage}%'
        },
        'effects': {
          'pullOutSegmentOnClick': {
            'effect': 'linear',
            'speed' : 400,
            'size'  : 10
          }
        },
        'data': {
          'content': this.props.chartData
        }
      })
    }
  }

  destroyPieChart() {
    this.pieChart.destroy()
  }

  render() {
    return (
      <React.Fragment>
        <div className="columns large-4 medium-12 summary float-left">
          <h3>Total Tokens Awarded To Contributors</h3>
          <div id="award-percentages" className="royalty-pie" />
        </div>
      </React.Fragment>
    )
  }
}

ContributorsSummaryPieChart.propTypes = {
  chartData: PropTypes.array.isRequired
}
ContributorsSummaryPieChart.defaultProps = {
  chartData: []
}
export default ContributorsSummaryPieChart
