import { Controller } from 'stimulus'
import { fetch } from 'whatwg-fetch'

export default class extends Controller {
  follow(projectId, specialtyId = null) {
    return fetch(this._followPath(projectId), {
      credentials: 'same-origin',
      method     : 'POST',
      headers: {
        'Content-Type': 'application/json'
      }
    })
  }

  unfollow(projectId) {
    return fetch(this._unfollowPath(projectId), {
      credentials: 'same-origin',
      method     : 'DELETE',
      headers    : {
        'Content-Type': 'application/json'
      }
    })
  }

  _followPath(projectId) {
    return `/projects/${projectId}/project_roles`
  }

  _unfollowPath(projectId) {
    return `/projects/${projectId}/project_roles/0`
  }
}
