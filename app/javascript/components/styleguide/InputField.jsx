import React from 'react'
import PropTypes from 'prop-types'
import classNames from 'classnames'

class InputField extends React.Component {
  constructor(props) {
    super(props)
    this.handleChange = this.handleChange.bind(this)
    this.handleFileChange = this.handleFileChange.bind(this)
    this.passImg = this.passImg.bind(this)
    this.state = {
      fileLocalUrl : null,
      fileLocalName: null,
      symbolCounter: this.props.value.length
    }
  }

  passImg({target:img}) {
    this.props.imgVerifier(img)
  }

  handleChange(event) {
    if (this.props.symbolLimit > 0) {
      if (event.target.value.length > this.props.symbolLimit) {
        return
      } else {
        this.setState({
          symbolCounter: event.target.value.length
        })
      }
    }
    this.props.eventHandler(event)
  }

  handleFileChange(event) {
    if (this.state.fileLocalUrl != null) {
      URL.revokeObjectURL(this.state.fileLocalUrl)
    }
    this.setState({
      fileLocalUrl : URL.createObjectURL(event.target.files[0]),
      fileLocalName: event.target.files[0].name
    })
    this.props.eventHandler(event)
  }

  render() {
    const {
      className,
      title,
      type,
      symbolLimit,
      required,
      recommended,
      disabled,
      checked,
      name,
      value,
      selectEntries,
      checkboxText,
      placeholder,
      pattern,
      readOnly,
      errorText,
      imgPreviewUrl,
      imgPreviewDimensions,
      imgRequirements,
      imgVerifier,
      imgInputRef,
      eventHandler,
      ...other
    } = this.props

    let d = eventHandler || imgVerifier

    let classnames = classNames(
      'input-field',
      (errorText ? 'input-field__error' : ''),
      className
    )

    return (
      <React.Fragment>
        <div className={classnames} {...other}>
          { type !== 'checkbox' &&
            <div className="input-field--title">
              <span className="input-field--title--title">{title}</span>
              <span className="input-field--title--required">
                {required &&
                  'required'
                }
                {recommended &&
                  'recommended'
                }
                {!required && !recommended &&
                  'optional'
                }
              </span>
              { symbolLimit > 0 &&
                <span className="input-field--title--counter">{this.state.symbolCounter}/{symbolLimit}</span>
              }
            </div>
          }
          <div className="input-field--content">

            { type === 'defined' &&
              <div className="input-field--content__defined">
                {value}
              </div>
            }

            { type === 'text' &&
              <input className="input-field--content__text"
                required={required}
                type={type}
                name={name}
                value={value}
                onChange={this.handleChange}
                placeholder={placeholder}
                pattern={pattern}
                readOnly={readOnly}
              />
            }

            { type === 'textarea' &&
              <textarea className="input-field--content__text"
                required={required}
                name={name}
                value={value}
                onChange={this.handleChange}
                placeholder={placeholder}
                pattern={pattern}
                readOnly={readOnly}
              />
            }

            { type === 'file' &&
              <React.Fragment>
                { (this.state.fileLocalUrl || imgPreviewUrl) &&
                  <img
                    className={
                      classNames(
                        'input-field--content__file--preview',
                        `input-field--content__file--preview__${imgPreviewDimensions}`
                      )
                    }
                    src={this.state.fileLocalUrl ? this.state.fileLocalUrl : imgPreviewUrl}
                    onLoad={this.passImg}
                  />
                }
                { this.state.fileLocalName &&
                  <div className="input-field--content__file--name">
                    {this.state.fileLocalName}
                  </div>
                }
                <input className="input-field--content__file"
                  accept="image/*"
                  required={(!this.state.fileLocalUrl && imgPreviewUrl) ? false : required}
                  type={type}
                  name={name}
                  ref={imgInputRef}
                  onChange={this.handleFileChange}
                />
                <span className="input-field--content__file--requirements">
                  {imgRequirements}
                </span>
              </React.Fragment>
            }

            { type === 'select' &&
              <select className="input-field--content__select"
                required={required}
                name={name}
                value={value}
                onChange={this.handleChange}
                disabled={disabled}
              >
                {selectEntries.map(([k, v]) =>
                  <option key={v} value={v}>{k}</option>
                )}
              </select>
            }

            { type === 'checkbox' &&
              <React.Fragment>
                <label className="input-field--content__label">
                  { checked &&
                    <span className="input-field--content__checkbox--icon__checked" />
                  }
                  { !checked &&
                    <span className="input-field--content__checkbox--icon__unchecked" />
                  }
                  { checkboxText !== '' &&
                    <span className="input-field--content__checkbox--text">{checkboxText}</span>
                  }
                  <input className="input-field--content__checkbox"
                    required={required}
                    type={type}
                    name={name}
                    value={value}
                    checked={checked}
                    onChange={this.handleChange}
                    readOnly={readOnly}
                  />
                </label>
              </React.Fragment>
            }

          </div>
          { errorText !== '' &&
            <div className="input-field--error">
              {errorText}
            </div>
          }
        </div>
      </React.Fragment>
    )
  }
}

InputField.propTypes = {
  className           : PropTypes.string,
  title               : PropTypes.string,
  type                : PropTypes.string,
  symbolLimit         : PropTypes.number,
  required            : PropTypes.bool,
  recommended         : PropTypes.bool,
  disabled            : PropTypes.bool,
  checked             : PropTypes.bool,
  name                : PropTypes.string,
  value               : PropTypes.string,
  selectEntries       : PropTypes.array,
  checkboxText        : PropTypes.string,
  eventHandler        : PropTypes.func,
  placeholder         : PropTypes.string,
  pattern             : PropTypes.string,
  readOnly            : PropTypes.bool,
  errorText           : PropTypes.string,
  imgPreviewUrl       : PropTypes.string,
  imgPreviewDimensions: PropTypes.string,
  imgRequirements     : PropTypes.string,
  imgVerifier         : PropTypes.func,
  imgInputRef         : PropTypes.any
}
InputField.defaultProps = {
  className           : '',
  title               : 'title',
  type                : 'text',
  symbolLimit         : 100,
  required            : false,
  recommended         : false,
  disabled            : false,
  checked             : false,
  name                : 'field',
  value               : '',
  selectEntries       : [],
  checkboxText        : '',
  eventHandler        : () => {},
  placeholder         : 'Please enter value',
  pattern             : '.*',
  readOnly            : false,
  errorText           : '',
  imgPreviewUrl       : '',
  imgPreviewDimensions: '40x40',
  imgRequirements     : '',
  imgVerifier         : () => {},
  imgInputRef         : null
}
export default InputField
