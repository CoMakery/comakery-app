import React from 'react'
import PropTypes from 'prop-types'
import ReactPaginate from 'react-paginate'

export default class HistoryTable extends React.Component {
  render() {
    return (
      <React.Fragment>
        <div className="columns medium-12 no-h-pad">
          <h4 style={{ border: 'none' }}>Awards</h4>
          <div className="table-scroll table-box full-width" style={{ marginRight: 0 }}>
            <table className="award-rows full-width">
              <tbody>
                <tr className="header-row">
                  <th className="small-4">Project</th>
                  <th className="small-1">Token</th>
                  <th className="small-2">Award</th>
                  <th className="small-2">Date</th>
                  <th className="small-3">Blockchain Transaction</th>
                </tr>
                {this.props.awards.map(award =>
                  <tr className="award-row" key={award.id}>
                    <td className="small-3">
                      <a href={award.project.awardsPath}>
                        {award.project.title}
                      </a>
                    </td>
                    <td className="small-1">
                      {award.tokenSymbol || 'pending'}
                    </td>
                    <td className="small-2">
                      {award.totalAmountPretty}
                    </td>
                    <td className="small-2">
                      {award.createdAt}
                    </td>
                    <td className="small-4">
                      {award.ethereumTransactionExplorerUrl
                        ? <a href={award.ethereumTransactionExplorerUrl} target="_blank">
                          {award.ethereumTransactionAddressShort}
                        </a>
                        : 'pending'}
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
        <div className="columns medium-12 no-h-pad text-right">
          <ReactPaginate
            containerClassName="react-pagination"
            activeClassName="active"
            pageCount={this.props.pageCount}
            marginPagesDisplayed={2}
            pageRangeDisplayed={2}
            initialPage={this.props.currentPage}
            onPageChange={data => {
              this.props.handlePageChange(data.selected)
            }}
          />
        </div>
      </React.Fragment>
    )
  }
}

HistoryTable.propTypes = {
  awards          : PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  pageCount       : PropTypes.number.isRequired,
  currentPage     : PropTypes.number.isRequired,
  handlePageChange: PropTypes.func.isRequired,
}
