const puppeteer = require('puppeteer');

const post = async (page: *, url: string, formData: URLSearchParams) => {
  const formDataEntries = formData.entries();

  let formHtml = '';

  for (const [name, value] of formDataEntries) {
    formHtml += `
      <input
        type='hidden'
        name='${name}'
        value='${value}'
      />
    `;
  }

  formHtml = `
    <form action='${url}' method='post'>
      ${formHtml}

      <input type='submit' />
    </form>
  `;

  await page.setContent(formHtml);

  const inputElement = await page.$('input[type=submit]');

  await inputElement.click();
};

(async () => {
    const browser = await puppeteer.launch();
    const page = await browser.newPage();
    await post(page => page, url => 'https://www.baidu.com', formData => 'a=1&b=2')

    await page.screenshot({path: 'baidu.png'});
    browser.close();
})();
