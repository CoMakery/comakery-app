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
                      <a href={award.project.awards_path}>
                        {award.project.title}
                      </a>
                    </td>
                    <td className="small-1">
                      {award.token_symbol || 'pending'}
                    </td>
                    <td className="small-2">
                      {award.total_amount_pretty}
                    </td>
                    <td className="small-2">
                      {award.created_at}
                    </td>
                    <td className="small-4">
                      {award.ethereum_transaction_explorer_url
                        ? <a href={award.ethereum_transaction_explorer_url} target="_blank">
                          {award.ethereum_transaction_address_short}
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
