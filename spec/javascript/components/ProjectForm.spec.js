import React from 'react'
import { mount } from 'enzyme'
import ProjectForm from 'components/ProjectForm'

describe('ProjectForm', () => {
  it('renders correctly without props', () => {
    const wrapper = mount(<ProjectForm />)

    expect(wrapper).toMatchSnapshot()

    expect(wrapper.exists('Layout[navTitle]')).toBe(true)
    expect(wrapper.exists('.project-form')).toBe(true)
    expect(wrapper.exists('ButtonBorder[value="cancel"]')).toBe(true)
    expect(wrapper.exists('ButtonBorder[value="create"]')).toBe(true)
    expect(wrapper.exists('Button[value="create & close"]')).toBe(true)
    expect(wrapper.exists('.project-form--message')).toBe(false)
    expect(wrapper.exists('.project-form--form')).toBe(true)
    expect(wrapper.exists('#project-form--form')).toBe(true)

    expect(wrapper.exists(
      'InputFieldDropdown[title="mission"][required][name="project[mission_id]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'InputFieldDropdown[title="token"][required][name="project[token_id]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'InputFieldWhiteDark[title="title"][required][name="project[title]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'InputFieldDescription[title="description"][required][name="project[description]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'InputFieldWhiteDark[title="narrated video overview"][recommended][name="project[video_url]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'InputFieldDropdown[title="visibility"][required][name="project[visibility]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'InputFieldUploadFile[title="project image – square"][required][name="project[square_image]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'InputFieldUploadFile[title="project image – panoramic"][required][name="project[panoramic_image]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'input[type="hidden"][name="authenticity_token"]'
    )).toBe(true)
  })

  it('renders correctly with tokens', () => {
    const tokens = {
      'token1': 1,
      'token2': 2
    }
    const wrapper = mount(<ProjectForm tokens={tokens} />)

    expect(wrapper.find(
      'InputFieldDropdown[title="token"][required][name="project[token_id]"]'
    ).props().value).toBe('1')

    expect(wrapper.find(
      'InputFieldDropdown[title="token"][required][name="project[token_id]"]'
    ).props().selectEntries).toEqual(Object.entries(tokens))
  })

  it('renders correctly with missions', () => {
    const missions = {
      'mission1': 1,
      'mission2': 2
    }
    const wrapper = mount(<ProjectForm missions={missions} />)

    expect(wrapper.find(
      'InputFieldDropdown[title="mission"][required][name="project[mission_id]"]'
    ).props().value).toBe('1')

    expect(wrapper.find(
      'InputFieldDropdown[title="mission"][required][name="project[mission_id]"]'
    ).props().selectEntries).toEqual(Object.entries(missions))
  })

  it('renders correctly with visibilities', () => {
    const visibilities = {
      'visibility 1': 'visibility1',
      'visibility 2': 'visibility2'
    }
    const wrapper = mount(<ProjectForm visibilities={visibilities} />)

    expect(wrapper.find(
      'InputFieldDropdown[title="visibility"][required][name="project[visibility]"]'
    ).props().value).toBe('visibility1')

    expect(wrapper.find(
      'InputFieldDropdown[title="visibility"][required][name="project[visibility]"]'
    ).props().selectEntries).toEqual(Object.entries(visibilities))
  })

  it('renders correctly with project', () => {
    const project = {
      'id'               : 2,
      'mission_id'       : 2,
      'token_id'         : 2,
      'title'            : 'title',
      'description'      : 'desc',
      'video_url'        : 'https://youtube.com/',
      'visibility'       : 'visibility2',
      'squareImageUrl'   : '/s.png',
      'panoramicImageUrl': '/p.png'
    }
    const visibilities = {
      'visibility 1': 'visibility1',
      'visibility 2': 'visibility2'
    }
    const missions = {
      'mission1': 1,
      'mission2': 2
    }
    const tokens = {
      'token1': 1,
      'token2': 2
    }
    const wrapper = mount(<ProjectForm
      project={project}
      tokens={tokens}
      missions={missions}
      visibilities={visibilities}
    />)

    expect(wrapper.find(
      'InputFieldDropdown[title="mission"][required][name="project[mission_id]"]'
    ).props().value).toBe('2')

    expect(wrapper.find(
      'InputFieldDropdown[title="token"][required][name="project[token_id]"]'
    ).props().value).toBe('2')

    expect(wrapper.find(
      'InputFieldWhiteDark[title="title"][required][name="project[title]"]'
    ).props().value).toBe('title')

    expect(wrapper.find(
      'InputFieldDescription[title="description"][required][name="project[description]"]'
    ).props().value).toBe('desc')

    expect(wrapper.find(
      'InputFieldWhiteDark[title="narrated video overview"][recommended][name="project[video_url]"]'
    ).props().value).toBe('https://youtube.com/')

    expect(wrapper.find(
      'InputFieldDropdown[title="visibility"][required][name="project[visibility]"]'
    ).props().value).toBe('visibility2')

    expect(wrapper.find(
      'InputFieldUploadFile[title="project image – square"][required][name="project[square_image]"]'
    ).props().imgPreviewUrl).toBe('/s.png')

    expect(wrapper.find(
      'InputFieldUploadFile[title="project image – panoramic"][required][name="project[panoramic_image]"]'
    ).props().imgPreviewUrl).toBe('/p.png')
  })

  it('renders correctly with csrfToken', () => {
    const wrapper = mount(<ProjectForm csrfToken="test" />)

    expect(wrapper.find(
      'input[type="hidden"][name="authenticity_token"]'
    ).props().value).toBe('test')
  })

  it('uses formUrl', () => {
    const wrapper = mount(<ProjectForm formUrl="/test" />)

    expect(wrapper.state('formUrl')).toBe('/test')
  })

  it('uses formAction', () => {
    const wrapper = mount(<ProjectForm formAction="PUT" />)

    expect(wrapper.state('formAction')).toBe('PUT')
  })

  it('uses urlOnSuccess', () => {
    const wrapper = mount(<ProjectForm urlOnSuccess="/test" />)

    expect(wrapper.props().urlOnSuccess).toBe('/test')
  })

  it('displays messages', () => {
    const wrapper = mount(<ProjectForm />)

    wrapper.setState({
      errorMessage: 'test error',
      infoMessage : 'test info'
    })

    wrapper.update()

    expect(wrapper.exists('Message[severity="error"][text="test error"]')).toBe(true)
    expect(wrapper.exists('Message[severity="warning"][text="test info"]')).toBe(true)
  })

  it('displays errors', () => {
    const wrapper = mount(<ProjectForm />)

    wrapper.setState({
      errors: {
        'project[title]'       : 'title error',
        'project[mission_id]'  : 'mission_id error',
        'project[square_image]': 'square_image error'
      }
    })

    wrapper.update()

    expect(wrapper.exists(
      'InputFieldWhiteDark[errorText="title error"][title="title"][required][name="project[title]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'InputFieldDropdown[errorText="mission_id error"][title="mission"][required][name="project[mission_id]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'InputFieldUploadFile[errorText="square_image error"][title="project image – square"][required][name="project[square_image]"]'
    )).toBe(true)
  })
})
