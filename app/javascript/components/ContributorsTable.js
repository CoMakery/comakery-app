import React from 'react'
import PropTypes from 'prop-types'

class ContributorsTable extends React.Component {
  render() {
    return (
      <React.Fragment>
        <div className='table-scroll table-box contributors'>
          <table className='table-scroll' style={{width: '100%'}}>
            <tbody>
              <tr className='header-row'>
                <th>
                  Contributors
                </th>
                <th>
                  Total Tokens Awarded
                </th>
              </tr>

              {this.props.tableData.map((t) =>
                <tr className='award-row' key={t.name}>
                  <td className='contributor'>
                    <img src={t.imageUrl} className='icon avatar-img' />
                    <div className='margin-small margin-collapse inline-block'>
                      {t.name}
                      <table className='table-scroll table-box overlay' style={{display: 'none'}}>
                        <tbody>
                          <tr>
                            <th style={{paddingBottom: '20px'}}>
                              Contribution Summary
                            </th>
                          </tr>

                          {t.awards.map((a) =>
                            <tr key={a.name}>
                              <td>
                                {a.name}
                              </td>
                              <td>
                                {a.total}
                              </td>
                            </tr>
                          )}
                        </tbody>
                      </table>
                    </div>
                  </td>

                  <td className='awards-earned financial'>
                    <span className='margin-small'>{t.total}</span>
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>

      </React.Fragment>
    )
  }
}

ContributorsTable.propTypes = {
  tableData: PropTypes.array.isRequired
}
ContributorsTable.defaultProps = {
  tableData: []
}
export default ContributorsTable
