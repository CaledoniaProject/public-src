
function RestoreRightClick()
{
  document.addEventListener("contextmenu", (event) => {
    event.returnValue = true;
    event.stopPropagation();
  }, true);
}
