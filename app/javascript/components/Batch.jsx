import React from 'react'
import PropTypes from 'prop-types'
import styled from 'styled-components'
import Icon from './styleguide/Icon'
import ContentElement from './ContentElement'
import CurrencyAmount from './CurrencyAmount'
import Userpics from './Userpics'

const Wrapper = styled.div`
  display: flex;
  flex-direction: row;
  box-shadow: 0 5px 10px 0 rgba(0, 0, 0, 0.1);
  height: 90px;
`

const RightBorder = styled.div`
  width: 2px;
  height: 90px;
  box-shadow: 0 5px 10px 0 rgba(0, 0, 0, .2);
  background-color: #5037f7;
  z-index: 10;
  position: absolute;
  margin-left: -1px;
`

const Image = styled.img`
  width: 65px;
  height: 65px;
  padding: 13px 15px 12px 17px;
`

const Info = styled.div`
  display: flex;
  flex-direction: column;
  width: 100%;
`

const Title = styled.div`
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  padding-right: 15px;
`

const Name = styled.div`
  padding: 15px 15px 7px 15px;
  font-family: Montserrat;
  font-size: 14px;
  font-weight: bold;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  text-transform: capitalize;
`

const Details = styled.div`
  display: flex;
  padding: 7px 15px 11px 15px;
  width: 100%;
`

const Buttons = styled.div`
  display: flex;
  width: 45px;
  justify-content: space-between;
  margin-right: 30px;
  align-self: flex-end;
  margin-left: auto;
`

const StyledIcon = styled(Icon)`
  height: 15px;
`

class Batch extends React.Component {
  render() {
    return (
      <React.Fragment>
        <Wrapper>
          <RightBorder />
          {this.props.batch.diagramUrl &&
            <Image src={this.props.batch.diagramUrl} alt="Batch Image" />
          }
          <Info>
            <Title>
              <Name>
                {this.props.batch.name}
              </Name>

              <CurrencyAmount
                amount={this.props.batch.totalAmount}
                currency={this.props.batch.currency}
                logoUrl={this.props.batch.currencyLogo}
              />
            </Title>

            <Details>
              <ContentElement title="progress">
                {`${this.props.batch.completedTasks} / ${this.props.batch.totalTasks} Completed`}
              </ContentElement>

              <ContentElement title="team members">
                <Userpics pics={this.props.batch.teamPics} limit={3} />
              </ContentElement>

              <Buttons>
                <a href={this.props.batch.editPath}>
                  <StyledIcon name="iconEdit.svg" />
                </a>
                <a rel="nofollow" data-method="delete" href={this.props.batch.destroyPath}>
                  <StyledIcon name="iconTrash.svg" />
                </a>
              </Buttons>
            </Details>
          </Info>
        </Wrapper>
      </React.Fragment>
    )
  }
}

Batch.propTypes = {
  batch: PropTypes.object
}
Batch.defaultProps = {
  batch: {
    diagramUrl: null
  }
}
export default Batch
