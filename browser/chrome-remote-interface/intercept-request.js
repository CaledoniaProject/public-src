// npm install --save atob btoa chrome-launcher chrome-remote-interface

const chromeLauncher = require('chrome-launcher');
const CDP = require('chrome-remote-interface');
const atob = require('atob');
const btoa = require('btoa');

async function main() {
  const chrome = await chromeLauncher.launch({
    chromeFlags: [
      '--window-size=1200,800',
      '--user-data-dir=/tmp/chrome-testing',
      '--auto-open-devtools-for-tabs'
    ]
  });

  const protocol = await CDP({ port: chrome.port });

  const { Runtime, Network } = protocol;
  await Promise.all([Runtime.enable(), Network.enable()]);

  Runtime.consoleAPICalled(({ args, type }) => console[type].apply(console, args.map(a => a.value)));

  await Network.setRequestInterception({ patterns: [{ urlPattern: '*.js*', resourceType: 'Script', interceptionStage: 'HeadersReceived' }] });

  Network.requestIntercepted(async ({ interceptionId, request}) => {
    console.log(`Intercepted ${request.url} {interception id: ${interceptionId}}`);

    const response = await Network.getResponseBodyForInterception({ interceptionId });
    const bodyData = response.base64Encoded ? atob(response.body) : response.body;

    const newBody = bodyData + `\nconsole.log('Executed modified resource for ${request.url}');`;

    const newHeaders = [
      'Date: ' + (new Date()).toUTCString(),
      'Connection: closed',
      'Content-Length: ' + newBody.length,
      'Content-Type: text/javascript'
    ];

    Network.continueInterceptedRequest({
      interceptionId,
      rawResponse: btoa('HTTP/1.1 200 OK' + '\r\n' + newHeaders.join('\r\n') + '\r\n\r\n' + newBody)
    });
  });

}

main();
