'use strict';
const puppeteer = require('puppeteer');
const fs = require('fs-extra');

async function take_screenshot(url, filename) {
    console.log(url, filename)

    const browser = await puppeteer.launch({
        headless: true,
        ignoreHTTPSErrors: true,
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    });

    const page = await browser.newPage();
    await page.setViewport({width: 1280, height: 800, deviceScaleFactor: 0});
    await page.setUserAgent('Mozilla/5.0 (Windows NT 5.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.90 Safari/537.36');
    await page.goto(url, {
        waitUntil: 'load',
        timeout: 20000
    }).catch(function (err) {
        console.log('got err', err)
    });
    await page.screenshot({
        path: filename,
        fullPage: true
    });

    browser.close()
}

function parse_nmap_grep(data)
{
    var result = []
    data.split("\n").forEach (function (line) {
        var match = /Host: ([^\s]+).*Ports: (.*)/.exec(line)
        if (! match) {
            return
        }

        var host  = match[1]
        var ports = match[2]

        ports.split(", ").forEach(function (part) {
            var port = part.split('/')[0]
            if (part.indexOf('/https/') != -1) {
                result.push('https://' + host + ':' + port)
            } else if (part.indexOf('/http/') != -1) {
                result.push('http://' + host + ':' + port)
            }
        })
    })

    return result
}

var run = async function() {
    await take_screenshot('https://www.baidu.com/', '1.jpg');
    await take_screenshot('https://www.bing.com', '2.jpg');
}

run()
