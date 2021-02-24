var data    = "{123123132}"
var newBlob = new Blob([data], {type: "application/json"})
window.navigator.msSaveOrOpenBlob(newBlob, '1.txt')
