import React from 'react'
import { mount } from 'enzyme'
import BatchIndex from 'components/BatchIndex'

describe('BatchIndex', () => {
  it('renders correctly without props', () => {
    const wrapper = mount(<BatchIndex />)

    expect(wrapper).toMatchSnapshot()
    expect(wrapper.exists('.batch-index')).toBe(true)
    expect(wrapper.exists('.batch-index--sidebar')).toBe(true)
    expect(wrapper.exists('.batch-index--sidebar SidebarItemBold')).toBe(true)
    expect(wrapper.find('.batch-index--sidebar SidebarItemBold').props().iconLeftName).toBe('BATCH/WHITE.svg')
    expect(wrapper.find('.batch-index--sidebar SidebarItemBold').props().iconRightName).toBe('PLUS.svg')
    expect(wrapper.exists('.batch-index--sidebar--info')).toBe(false)
    expect(wrapper.exists('.batch-index--view')).toBe(false)
  })

  it('renders correctly with batches', () => {
    const batches = [
      {
        'id'         : 10,
        'projectId'  : 3,
        'name'       : 'Write a book',
        'description': 'Write a book',
        'goal'       : 'Write a book',
        'specialty'  : 'writing',
        'editPath'   : '/projects/3/batches/10/edit',
        'destroyPath': '/projects/3/batches/10',
        'newTaskPath': '/projects/3/batches/10/tasks/new',
        'tasks'      : [
          {
            'id'          : 21,
            'description' : 'Chapter VII',
            'name'        : 'Chapter VII',
            'why'         : 'Chapter VII',
            'requirements': 'Chapter VII',
            'status'      : 'ready',
            'amount'      : '1000.0',
            'tokenSymbol' : 'DMT',
            'awardPath'   : '/projects/3/batches/10/tasks/21',
            'editPath'    : '/projects/3/batches/10/tasks/21/edit',
            'destroyPath' : '/projects/3/batches/10/tasks/21'
          },
          {
            'id'          : 22,
            'description' : 'Chapter VIII',
            'quantity'    : '1.21',
            'totalAmount' : '1210.0',
            'name'        : 'Chapter VIII',
            'why'         : 'Chapter VIII',
            'requirements': 'Chapter VIII',
            'status'      : 'done',
            'amount'      : '100.0',
            'tokenSymbol' : 'DMT',
            'awardPath'   : '/projects/3/batches/10/tasks/21',
            'editPath'    : '/projects/3/batches/10/tasks/21/edit',
            'destroyPath' : '/projects/3/batches/10/tasks/21'
          },
        ]
      }
    ]

    const wrapper = mount(<BatchIndex batches={batches} />)

    expect(wrapper.find('.batch-index--sidebar--info').text()).toBe('Please select batch:')

    expect(wrapper.exists('SidebarItem[text="Write a book"]')).toBe(true)
  })

  it('displays correct token details on sidebar item click', () => {
    const batches = [
      {
        'id'         : 10,
        'projectId'  : 3,
        'name'       : 'Write a book',
        'description': 'Write a book',
        'goal'       : 'Write a book',
        'specialty'  : 'writing',
        'editPath'   : '/projects/3/batches/10/edit',
        'destroyPath': '/projects/3/batches/10',
        'newTaskPath': '/projects/3/batches/10/tasks/new',
        'tasks'      : [
          {
            'id'          : 21,
            'description' : 'Chapter VII',
            'name'        : 'Chapter VII',
            'why'         : 'Chapter VII',
            'requirements': 'Chapter VII',
            'status'      : 'ready',
            'amount'      : '1000.0',
            'tokenSymbol' : 'DMT',
            'awardPath'   : '/projects/3/batches/10/tasks/21',
            'editPath'    : '/projects/3/batches/10/tasks/21/edit',
            'destroyPath' : '/projects/3/batches/10/tasks/21'
          },
          {
            'id'          : 22,
            'description' : 'Chapter VIII',
            'quantity'    : '1.21',
            'totalAmount' : '1210.0',
            'name'        : 'Chapter VIII',
            'why'         : 'Chapter VIII',
            'requirements': 'Chapter VIII',
            'status'      : 'done',
            'amount'      : '100.0',
            'tokenSymbol' : 'DMT',
            'awardPath'   : '/projects/3/batches/10/tasks/21',
            'editPath'    : '/projects/3/batches/10/tasks/21/edit',
            'destroyPath' : '/projects/3/batches/10/tasks/21'
          },
        ]
      },
      {
        'id'         : 11,
        'projectId'  : 3,
        'name'       : 'Write a blog post',
        'description': 'Write a blog post',
        'goal'       : 'Write a blog post',
        'specialty'  : 'writing',
        'editPath'   : '/projects/3/batches/11/edit',
        'destroyPath': '/projects/3/batches/11',
        'newTaskPath': '/projects/3/batches/11/tasks/new',
        'tasks'      : []
      }
    ]

    const wrapper = mount(<BatchIndex batches={batches} />)

    expect(wrapper.exists('.batch-index--view')).toBe(false)

    wrapper.find('SidebarItem[text="Write a book"]').simulate('click')
    expect(wrapper.find('.batch-index--view').text()).toMatch(/Write a book/)

    wrapper.find('SidebarItem[text="Write a blog post"]').simulate('click')
    expect(wrapper.find('.batch-index--view').text()).toMatch(/Write a blog post/)
    expect(wrapper.find('.batch-index--view').text()).not.toMatch(/Write a book/)
  })
})
