var _ = require("underscore");

function keyCharAt(key, i) {
  return key.charCodeAt(Math.floor(i % key.length));
}

function xor_encrypt(key, data) {
  return _.map(data, function(c, i) {
    return c.charCodeAt(0) ^ keyCharAt(key, i);
  });
}

function xor_decrypt(key, data) {
  return _.map(data, function(c, i) {
    return String.fromCharCode(c ^ keyCharAt(key, i));
  }).join("");
}

function cow001() {
  eval(xor_decrypt(arguments.callee.name, [0, 0, 25, 67, 95, 93, 6, 65, 27, 95, 87, 25, 68, 34, 22, 92, 89, 82, 10, 0, 2, 67, 16, 114, 12, 1, 3, 85, 94, 69, 67, 59, 5, 89, 87, 86, 6, 29, 4, 16, 120, 84, 17, 10, 87, 17, 23, 24]));
}

function pyth001() {
  eval(xor_decrypt(arguments.callee.name, [19, 22, 3, 88, 0, 1, 25, 89, 66]));
}

function pippo() {
  pyth001();
}

pippo();