import Vue from 'vue'
const ShortKey = require('vue-shortkey')

// add any custom shortkey config settings here
Vue.use(ShortKey, {
  prevent: ['input:not(.shortkey-enabled)', 'textarea:not(.shortkey-enabled)'],
})

export default ShortKey
