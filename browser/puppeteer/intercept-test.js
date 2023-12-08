const puppeteer = require('puppeteer');

(async () => {
    const browser = await puppeteer.launch();
    const page = await browser.newPage();

    await page.setViewport({width: 800, height: 800, deviceScaleFactor: 2});
    await page.setRequestInterceptionEnabled(true);
    page.on('request', request => {
        const overrides = {};
        if (request.url === 'https://www.baidu.com') {
            overrides.method = 'POST';
            overrides.postData = 'a=b&c=d';
        }
        request.continue(overrides);
    });
    await page.goto('https://www.baidu.com');
    await page.screenshot({path: 'baidu.png'});

    browser.close();
})();


