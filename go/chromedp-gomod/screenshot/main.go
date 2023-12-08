package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"sync"

	"github.com/chromedp/cdproto/cdp"
	"github.com/chromedp/cdproto/emulation"
	"github.com/chromedp/cdproto/network"
	"github.com/chromedp/cdproto/page"
	"github.com/chromedp/chromedp"
)

type RequestData struct {
	Type     network.ResourceType
	Request  *network.Request
	Response *network.Response
}

func main() {
	var (
		buf            []byte
		requestMapping = map[string]*RequestData{}
		mapLock        = &sync.Mutex{}
	)

	chromeOpts := append(
		chromedp.DefaultExecAllocatorOptions[:],
		chromedp.Headless,
		chromedp.DisableGPU,
		chromedp.NoFirstRun,
		chromedp.NoDefaultBrowserCheck,
		chromedp.Flag("ignore-certificate-errors", true),
	)
	allocContext, cancel := chromedp.NewExecAllocator(context.Background(), chromeOpts...)
	defer cancel()

	ctx, cancel := chromedp.NewContext(
		allocContext,
		// chromedp.WithDebugf(log.Printf),
	)
	defer cancel()

	chromedp.ListenTarget(ctx, func(ev interface{}) {
		switch ev := ev.(type) {

		case *network.EventRequestWillBeSent:
			fmt.Printf("[network.EventRequestWillBeSent] id=%s, url=%s\n", ev.RequestID, ev.Request.URL)

			mapLock.Lock()
			requestMapping[ev.RequestID.String()] = &RequestData{
				Request: ev.Request,
			}
			mapLock.Unlock()

		case *network.EventLoadingFinished:
			if data, ok := requestMapping[ev.RequestID.String()]; !ok {
				fmt.Printf("[network.EventLoadingFinished] ID=%s, url is unknown\n", ev.RequestID.String())
			} else {
				go func() {
					respCtx := chromedp.FromContext(ctx)
					body, err := network.GetResponseBody(ev.RequestID).Do(cdp.WithExecutor(ctx, respCtx.Target))
					if len(body) > 50 {
						body = body[0:50]
					}

					fmt.Printf("[network.EventLoadingFinished] type=%s, id=%s, url=%s, headers=%s, body=%s, err = %v\n",
						data.Type, ev.RequestID.String(), data.Request.URL, data.Response.Headers, string(body), err)
				}()
			}

		case *network.EventResponseReceived:
			mapLock.Lock()
			if data, ok := requestMapping[ev.RequestID.String()]; ok {
				data.Response = ev.Response
				data.Type = ev.Type
			}
			mapLock.Unlock()

			fmt.Printf("[network.EventResponseReceived] id=%s, url=%s\n", ev.RequestID, ev.Response.URL)
		}
	})

	if err := chromedp.Run(ctx, fullScreenshot(`https://www.baidu.com`, 100, &buf)); err != nil {
		log.Fatal(err)
	}
	if err := os.WriteFile("/tmp/fullScreenshot.png", buf, 0o644); err != nil {
		log.Fatal(err)
	}

	log.Printf("wrote /tmp/fullScreenshot.png")
}

func fullScreenshot(urlstr string, quality int, res *[]byte) chromedp.Tasks {
	return chromedp.Tasks{
		chromedp.Navigate(urlstr),
		chromedp.ActionFunc(func(ctx context.Context) error {

			// force viewport emulation
			err := emulation.SetDeviceMetricsOverride(1280, 800, 1, false).
				WithScreenOrientation(&emulation.ScreenOrientation{
					Type:  emulation.OrientationTypePortraitPrimary,
					Angle: 0,
				}).
				Do(ctx)
			if err != nil {
				return err
			}

			// capture screenshot
			*res, err = page.CaptureScreenshot().
				WithQuality(100).
				WithClip(&page.Viewport{
					X:      0,
					Y:      0,
					Width:  1280,
					Height: 800,
					Scale:  1,
				}).Do(ctx)
			if err != nil {
				return err
			}
			return nil
		}),
	}
}
