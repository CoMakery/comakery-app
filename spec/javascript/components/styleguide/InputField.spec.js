import React from 'react'
import { shallow } from 'enzyme'
import InputField from 'components/styleguide/InputField'

describe('InputField', () => {
  it('renders correctly without props', () => {
    const wrapper = shallow(<InputField />)

    expect(wrapper).toMatchSnapshot()
    expect(wrapper.exists('.input-field')).toBe(true)

    expect(wrapper.exists('.input-field--error')).toBe(false)
    expect(wrapper.exists('.input-field--title')).toBe(true)
    expect(wrapper.find('.input-field--title--title').text()).toBe('title')
    expect(wrapper.find('.input-field--title--required').text()).toBe('optional')
    expect(wrapper.find('.input-field--title--counter').text()).toBe('0/100')

    expect(wrapper.exists('.input-field--content')).toBe(true)
    expect(wrapper.find('.input-field--content__text').props().required).not.toBe()
    expect(wrapper.find('.input-field--content__text').props().type).toBe('text')
    expect(wrapper.find('.input-field--content__text').props().name).toBe('field')
    expect(wrapper.find('.input-field--content__text').props().value).toBe('')
    expect(wrapper.find('.input-field--content__text').props().placeholder).toBe('Please enter value')
    expect(wrapper.find('.input-field--content__text').props().pattern).toBe('.*')
    expect(wrapper.find('.input-field--content__text').props().readOnly).not.toBe()
  })

  it('renders correctly with custom className', () => {
    const wrapper = shallow(<InputField className="__test" />)

    expect(wrapper.exists('.input-field.__test')).toBe(true)
  })

  it('renders correctly with type=textarea', () => {
    const wrapper = shallow(<InputField type="textarea" />)

    expect(wrapper.find('.input-field--content__text').name()).toBe('textarea')
  })

  it('renders correctly with type=defined', () => {
    const wrapper = shallow(<InputField type="defined" />)

    expect(wrapper.find('.input-field--content__defined').text()).toBe('')
  })

  it('renders correctly with type=defined and value', () => {
    const wrapper = shallow(<InputField type="defined" value="test" />)

    expect(wrapper.find('.input-field--content__defined').text()).toBe('test')
  })

  it('renders correctly with type=file', () => {
    const wrapper = shallow(<InputField type="file" />)

    expect(wrapper.find('.input-field--content__file').props().type).toBe('file')
    expect(wrapper.find('.input-field--content__file').props().name).toBe('field')
  })

  it('renders correctly with type=file and imgRequirements', () => {
    const wrapper = shallow(<InputField type="file" imgRequirements="test" />)

    expect(wrapper.find('.input-field--content__file--requirements').text()).toBe('test')
  })

  it('renders correctly with type=file and imgPreviewUrl', () => {
    const wrapper = shallow(<InputField type="file" imgPreviewUrl="/test.jpg" />)

    expect(wrapper.find('.input-field--content__file--preview').props().src).toBe('/test.jpg')
    expect(wrapper.exists('.input-field--content__file--preview')).toBe(true)
    expect(wrapper.exists('.input-field--content__file--preview__40x40')).toBe(true)
  })

  it('renders correctly with type=file and imgPreviewDimensions', () => {
    const wrapper = shallow(<InputField type="file" imgPreviewUrl="/test.jpg" imgPreviewDimensions="100x100" />)

    expect(wrapper.exists('.input-field--content__file--preview__100x100')).toBe(true)
  })

  it('renders correctly with type=select', () => {
    const wrapper = shallow(<InputField type="select" />)

    expect(wrapper.find('.input-field--content__select').props().required).not.toBe()
    expect(wrapper.find('.input-field--content__select').props().name).toBe('field')
    expect(wrapper.find('.input-field--content__select').props().value).toBe('')
    expect(wrapper.find('.input-field--content__select').props().disabled).not.toBe()
  })

  it('renders correctly with type=select and disabled flag', () => {
    const wrapper = shallow(<InputField type="select" disabled />)

    expect(wrapper.find('.input-field--content__select').props().disabled).toBe(true)
  })

  it('renders correctly with type=select and selectEntries', () => {
    const wrapper = shallow(<InputField type="select" selectEntries={[['k1', 'v1'], ['k2', 'v2']]} />)

    expect(wrapper.find('.input-field--content__select > option').first().text()).toBe('k1')
    expect(wrapper.find('.input-field--content__select > option').first().props().value).toBe('v1')
    expect(wrapper.find('.input-field--content__select > option').last().text()).toBe('k2')
    expect(wrapper.find('.input-field--content__select > option').last().props().value).toBe('v2')
  })

  it('renders correctly with type=checkbox', () => {
    const wrapper = shallow(<InputField type="checkbox" />)

    expect(wrapper.find('.input-field--content__checkbox').props().required).not.toBe(true)
    expect(wrapper.find('.input-field--content__checkbox').props().type).toBe('checkbox')
    expect(wrapper.find('.input-field--content__checkbox').props().name).toBe('field')
    expect(wrapper.find('.input-field--content__checkbox').props().checked).toBe(false)
    expect(wrapper.find('.input-field--content__checkbox').props().readOnly).not.toBe()
  })

  it('renders correctly with type=checkbox and checkboxText', () => {
    const wrapper = shallow(<InputField type="checkbox" checkboxText="test" />)

    expect(wrapper.find('.input-field--content__label').text()).toBe('test')
  })

  it('renders correctly with type=checkbox and checked', () => {
    const wrapper = shallow(<InputField type="checkbox" checked />)

    expect(wrapper.find('.input-field--content__checkbox').props().checked).toBe(true)
  })

  it('renders correctly with custom title', () => {
    const wrapper = shallow(<InputField title="test" />)

    expect(wrapper.find('.input-field--title--title').text()).toBe('test')
  })

  it('renders correctly with custom name', () => {
    const wrapper = shallow(<InputField name="test" />)

    expect(wrapper.find('.input-field--content__text').props().name).toBe('test')
  })

  it('renders correctly with custom pattern', () => {
    const wrapper = shallow(<InputField pattern="test" />)

    expect(wrapper.find('.input-field--content__text').props().pattern).toBe('test')
  })

  it('renders correctly with custom placeholder', () => {
    const wrapper = shallow(<InputField placeholder="test" />)

    expect(wrapper.find('.input-field--content__text').props().placeholder).toBe('test')
  })

  it('renders correctly with required flag', () => {
    const wrapper = shallow(<InputField required />)

    expect(wrapper.find('.input-field--content__text').props().required).toBe(true)
    expect(wrapper.find('.input-field--title--required').text()).toBe('required')
  })

  it('renders correctly with recommended flag', () => {
    const wrapper = shallow(<InputField recommended />)

    expect(wrapper.find('.input-field--content__text').props().required).toBe(false)
    expect(wrapper.find('.input-field--title--required').text()).toBe('recommended')
  })

  it('renders correctly with readOnly flag', () => {
    const wrapper = shallow(<InputField readOnly />)

    expect(wrapper.find('.input-field--content__text').props().readOnly).toBe(true)
  })

  it('renders correctly with copyOnClick flag', () => {
    const wrapper = shallow(<InputField copyOnClick />)

    expect(wrapper.exists('.input-field--content__text__copyable')).toBe(true)
  })

  it('renders correctly with errorText', () => {
    const wrapper = shallow(<InputField errorText="test" />)

    expect(wrapper.find('.input-field--error').text()).toBe('test')
    expect(wrapper.exists('.input-field__error')).toBe(true)
  })

  it('sets symbol counter and symbolLimit on initial state', () => {
    const wrapper = shallow(<InputField value="test" symbolLimit={20} />)

    expect(wrapper.find('.input-field--title--counter').text()).toBe('4/20')
  })

  it('updates symbol counter on input', () => {
    const wrapper = shallow(<InputField value="test" />)

    expect(wrapper.find('.input-field--title--counter').text()).toBe('4/100')
    wrapper.find('.input-field--content__text').simulate('change', {target: {value: 'v'}})
    expect(wrapper.find('.input-field--title--counter').text()).toBe('1/100')
  })

  it('limits number of symbols with symbolLimit', () => {
    const wrapper = shallow(<InputField value="test" symbolLimit={4} />)

    wrapper.find('.input-field--content__text').simulate('change', {target: {value: 'tests'}})
    expect(wrapper.find('.input-field--title--counter').text()).toBe('4/4')
  })

  it('passes event to handler function', (done) => {
    const handler = function(event) {
      expect(event.target.value).toBe('test')
      done()
    }
    const wrapper = shallow(<InputField eventHandler={handler} />)

    wrapper.find('.input-field--content__text').simulate('change', {target: {value: 'test'}})
  })
})
