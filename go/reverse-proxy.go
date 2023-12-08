package main

import (
	"fmt"
	"net/http"
	"net/http/httputil"
	"net/url"
	"time"
)

func addLogger(handler http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		r.Host = r.URL.Host

		fmt.Printf("\nDate:\n%s\n\nURL:\n%s\n\nHeaders:\n%s\n\nPostForm:\n%s\n\n",
			time.Now().Format(time.RFC3339),
			r.URL, r.Header, r.PostForm)
		handler.ServeHTTP(w, r)
	})
}

func main() {
	var (
		certPEM = "/tmp/cert.pem"
		certKEY = "/tmp/key.pem"
	)

	serverUrl, _ := url.Parse("https://mail.163.com/")
	reverseProxy := httputil.NewSingleHostReverseProxy(serverUrl)

	fmt.Println("Listening normally on 443")
	http.ListenAndServeTLS(":443", certPEM, certKEY, addLogger(reverseProxy))
}
