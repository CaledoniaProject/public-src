function hex_at(str, index) {
  var r = str.substr(index, 2);
  return parseInt(r, 16);
}
function decrypt(ciphertext) {
  var output = "";
  var key = hex_at(ciphertext, 0);
  for(var i = 2; i < ciphertext.length; i += 2) {
    var plaintext = hex_at(ciphertext, i) ^ key;
    output += String.fromCharCode(plaintext);
  }
  output = decodeURIComponent(escape(output));
  return output;
}

console.log(decrypt("6e040b1d1d0b040b1d1d0b5f5c5d2e09030f0702400d0103"))
