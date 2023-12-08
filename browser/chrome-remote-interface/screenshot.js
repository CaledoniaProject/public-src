const CDP = require('chrome-remote-interface');
const fs = require('fs');

async function take_screenshot(url, filename) {
    console.log (url, filename)

    let client;
    try {
        client = await CDP();
        client._ws._socket.setTimeout(5000, function () {
            this.destroy();
            console.log('Request timeout')
        });

        const {DOM, Emulation, Network, Page, Runtime} = client;
        Network.requestWillBeSent((params) => {
            console.log(params.request.url);
        });

        const deviceMetrics = {
            width: 1200,
            height: 800,
            deviceScaleFactor: 0,
            mobile: false,
            fitWindow: false,
        };
        await Emulation.setDeviceMetricsOverride(deviceMetrics);
        await Emulation.setVisibleSize({width: deviceMetrics.width, height: deviceMetrics.height});

        await Network.enable();
        await Network.setUserAgentOverride({'userAgent': 'Mozilla/5.0 (Windows NT 5.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.90 Safari/537.36'});

        await Page.enable();
        await Page.navigate({url: url});
        await Page.loadEventFired();
        const {data} = await Page.captureScreenshot();
        fs.writeFileSync(filename, Buffer.from(data, 'base64'));
    } catch (err) {
        console.error(err);
    } finally {
        if (client) {
            await client.close();
        }
    }
}

var run = async function() {
    await take_screenshot('https://www.baidu.com', '1.jpg');
    await take_screenshot('https://www.bing.com', '2.jpg');
}

run()
