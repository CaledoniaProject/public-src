// https://antoinevastel.github.io/bot%20detection/2018/01/17/detect-chrome-headless-v2.html
if (navigator.webdriver) {
    console.log("Chrome headless detected 1");
}

navigator.permissions.query({name:'notifications'}).then(function(permissionStatus) {
    if (Notification.permission === 'denied' && permissionStatus.state === 'prompt') {
        console.log ("Chrome headless detected 4");
    }
});
