import store from 'store'

export default {
  set(key, value, expires = 86400) {
    store.set(key, {
      value,
      expired_at: Number(new Date()) + expires * 1000
    })
  },
  get(key, defaultValue) {
    const temp = store.get(key)
    try {
      const value = temp.value
      if (value === undefined || temp.expired_at < Number(new Date())) {
        return defaultValue
      }
      return value
    } catch (e) {
      return defaultValue
    }
  },
  getNetwork() {
    return this.get('network', 'mainnet')
  },
  getMode() {
    return this.get('mode', 'normal')
  }
}
