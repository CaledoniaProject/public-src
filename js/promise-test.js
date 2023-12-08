let a = new Promise((resolve, reject) => {
  if (Math.random() > 0.5) {
    resolve('成功');
  }
  reject('失敗')
})

a.then((str) => {
  console.log('SUCC: ' + str)
}).catch((str) => {
  console.log('FAIL: ' + str)
}).finally((str) => {
  console.log('FINI: ' + str)
})
