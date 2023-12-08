package main

import (
	"context"
	"fmt"
	"log"

	"github.com/chromedp/chromedp"
)

func main() {
	var (
		bodyString = ""
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

	if err := chromedp.Run(ctx,
		chromedp.Navigate("https://popl16-aec.seas.harvard.edu"),
		chromedp.OuterHTML("html", &bodyString, chromedp.ByQuery)); err != nil {
		log.Fatal(err)
	}
	fmt.Println(bodyString)
}
