import React from 'react'
import PropTypes from 'prop-types'
import styled from 'styled-components'

const Wrapper = styled.div`
  display: flex;
  flex-direction: row;
  align-items: center;
`

const Users = styled.div`
  margin-right: 8px;
`

const Userpic = styled.img`
  border-radius: 50%;
  width: 15px;
  height: 15px;
  border: solid 1px #ffffff;
  margin-right: -5px;
`

const More = styled.div`
  font-family: Montserrat;
  font-size: 10px;
  font-weight: bold;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  color: #3a3a3a;
`

class Userpics extends React.Component {
  render() {
    return (
      <React.Fragment>
        <Wrapper>
          <Users>
            {this.props.pics.slice(0, this.props.limit).map((u, i) =>
              <Userpic key={i} src={u} />
            )}
          </Users>

          {this.props.pics.length - this.props.limit > 0 &&
          <More>
            {`+${this.props.pics.length - this.props.limit}`}
          </More>
          }
        </Wrapper>
      </React.Fragment>
    )
  }
}

Userpics.propTypes = {
  pics : PropTypes.array,
  limit: PropTypes.number
}
Userpics.defaultProps = {
  pics : [],
  limit: 3
}
export default Userpics
