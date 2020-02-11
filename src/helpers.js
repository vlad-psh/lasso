export default {
  stripBB(str) {
    return str.replace(/\[[a-zA-Z]*?\](.*?)\[\/[a-zA-Z]*?\]/g, "<b>$1</b>")
  },
  debounce(func, wait, immediate) {
    var timeout;
    return function() {
      var context = this,
        args = arguments;
      var callNow = immediate && !timeout;
      clearTimeout(timeout);
      timeout = setTimeout(function() {
        timeout = null;
        if (!immediate) {
          func.apply(context, args);
        }
      }, wait);
      if (callNow) func.apply(context, args);
    }
  },
}
