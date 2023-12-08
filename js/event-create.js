document.body.addEventListener("keydown", function(e) {
    // isTrusted 表示是用户输入还是JS生成
	console.log(e.isTrusted, e)	
});
var e = new KeyboardEvent("keydown", {bubbles : true, cancelable : true, key : "Q", char : "Q", shiftKey : true});
document.body.dispatchEvent(e);
