// 对react框架有效
function changeValue(input,value)
{
  var nativeInputValueSetter = Object.getOwnPropertyDescriptor(
    window.HTMLInputElement.prototype,
    "value"
  ).set;
  nativeInputValueSetter.call(input, value);

  var inputEvent = new Event("input", { bubbles: true });
  input.dispatchEvent(inputEvent);
}

changeValue(document.querySelector('#username'), 'MyUser');
changeValue(document.querySelector('#password'), 'MyPassword');
