import React from 'react'
import { mount } from 'enzyme'
import MissionForm from 'components/MissionForm'

describe('MissionForm', () => {
  beforeEach(() => {
    fetch.resetMocks()
  })

  it('renders correctly without props', () => {
    const wrapper = mount(<MissionForm />)

    expect(wrapper).toMatchSnapshot()
    expect(wrapper.exists('Layout[title="Create a New Mission"]')).toBe(true)
    expect(wrapper.exists('.mission-form')).toBe(true)
    expect(wrapper.exists('ButtonBorder[value="cancel"]')).toBe(true)
    expect(wrapper.exists('ButtonBorder[value="create"]')).toBe(true)
    expect(wrapper.exists('Button[value="create & close"]')).toBe(true)
    expect(wrapper.exists('.mission-form--message')).toBe(false)
    expect(wrapper.exists('.mission-form--form')).toBe(true)
    expect(wrapper.exists('#mission-form--form')).toBe(true)

    expect(wrapper.exists(
      'InputFieldWhiteDark[title="Name"][symbolLimit=100][required][name="name"]'
    )).toBe(true)
    expect(wrapper.exists(
      'InputFieldDropdownHalfed[title="Token"][required][name="token"]'
    )).toBe(true)
    expect(wrapper.exists(
      'InputFieldWhiteDark[title="Subtitle"][required][name="subtitle"]'
    )).toBe(true)
    expect(wrapper.exists(
      'InputFieldDescription[title="Description"][required][name="description"]'
    )).toBe(true)
    expect(wrapper.exists(
      'InputFieldUploadFile[title="Mission Logo"][required][name="logo"]'
    )).toBe(true)
    expect(wrapper.exists(
      'InputFieldUploadFile[title="Mission Image"][required][name="image"]'
    )).toBe(true)
  })

  it('renders correctly with props', () => {
    const mission = {
      'id'         : 0,
      'name'       : 'Test Mission',
      'token'      : '1',
      'subtitle'   : 'test subtitle',
      'description': 'test description',
      'logoUrl'    : '/logo.png',
      'imageUrl'   : '/image.png'
    }
    const tokens = [['token1', 1], ['token2', 2]]
    const wrapper = mount(<MissionForm mission={mission} tokens={tokens} />)

    expect(wrapper.find(
      'InputFieldWhiteDark[title="Name"][symbolLimit=100][required][name="name"]'
    ).props().value).toBe('Test Mission')

    expect(wrapper.find(
      'InputFieldDropdownHalfed[title="Token"][required][name="token"]'
    ).props().value).toBe('1')
    expect(wrapper.find(
      'InputFieldWhiteDark[title="Subtitle"][required][name="subtitle"]'
    ).props().value).toBe('test subtitle')
    expect(wrapper.find(
      'InputFieldDescription[title="Description"][required][name="description"]'
    ).props().value).toBe('test description')
    expect(wrapper.find(
      'InputFieldUploadFile[title="Mission Logo"][required][name="logo"]'
    ).props().imgPreviewUrl).toBe('/logo.png')
    expect(wrapper.find(
      'InputFieldUploadFile[title="Mission Image"][required][name="image"]'
    ).props().imgPreviewUrl).toBe('/image.png')
  })

  it('uses formUrl', () => {
    const wrapper = mount(<MissionForm formUrl="/test" />)

    expect(wrapper.state('formUrl')).toBe('/test')
  })

  it('uses formAction', () => {
    const wrapper = mount(<MissionForm formAction="PUT" />)

    expect(wrapper.state('formAction')).toBe('PUT')
  })

  it('uses urlOnSuccess', () => {
    const wrapper = mount(<MissionForm urlOnSuccess="/test" />)

    expect(wrapper.props().urlOnSuccess).toBe('/test')
  })

  it('displays messages', () => {
    const wrapper = mount(<MissionForm />)

    wrapper.setState({
      errorMessage: 'test error',
      infoMessage : 'test info'
    })

    wrapper.update()

    expect(wrapper.exists('Message[severity="error"][text="test error"]')).toBe(true)
    expect(wrapper.exists('Message[severity="warning"][text="test info"]')).toBe(true)
  })

  it('displays errors', () => {
    const wrapper = mount(<MissionForm />)

    wrapper.setState({
      errors: {
        'name'       : 'name error',
        'token'      : 'token error',
        'subtitle'   : 'subtitle error',
        'description': 'description error',
        'logo'       : 'logo error',
        'image'      : 'image error'
      }
    })

    wrapper.update()

    expect(wrapper.exists(
      'InputFieldWhiteDark[title="Name"][symbolLimit=100][required][name="name"][errorText="name error"]'
    )).toBe(true)
    expect(wrapper.exists(
      'InputFieldDropdownHalfed[title="Token"][required][name="token"][errorText="token error"]'
    )).toBe(true)
    expect(wrapper.exists(
      'InputFieldWhiteDark[title="Subtitle"][required][name="subtitle"][errorText="subtitle error"]'
    )).toBe(true)
    expect(wrapper.exists(
      'InputFieldDescription[title="Description"][required][name="description"][errorText="description error"]'
    )).toBe(true)
    expect(wrapper.exists(
      'InputFieldUploadFile[title="Mission Logo"][required][name="logo"][errorText="logo error"]'
    )).toBe(true)
    expect(wrapper.exists(
      'InputFieldUploadFile[title="Mission Image"][required][name="image"][errorText="image error"]'
    )).toBe(true)
  })
})
