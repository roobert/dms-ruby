
//Vue.component("App", {
//  template: '<h1>test</h2>'
//})

//var store = {
//  debug: true,
//  state: {
//    message: 'Hello!'
//  },
//  setMessageAction (newValue) {
//    if (this.debug) console.log('setMessageAction triggered with', newValue)
//    this.state.message = newValue
//  },
//  clearMessageAction () {
//    if (this.debug) console.log('clearMessageAction triggered')
//    this.state.message = ''
//  }
//}

var app = new Vue({
  el: '#app',
  data: function() {
    return {
      list: [],
      timer: ''
    }
  },
  created: function() {
    this.fetchData();
    this.timer = setInterval(this.fetchData, 5000)
  },
  methods: {
    fetchData: function() {
      this.$http.get('/api/all', function(data) {
        console.log(data);
        this.list = data;
      }).bind(this);
    },
    cancelAutoUpdate: function () {
      clearInterval(this.timer)
    }
  },
  beforeDestroy() {
    clearInterval(this.timer)
  }
})

