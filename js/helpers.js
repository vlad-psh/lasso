export default {
  stripBB(str) {
    return str.replace(/\[[a-zA-Z]*?\](.*?)\[\/[a-zA-Z]*?\]/g, "<b>$1</b>")
  }
}
