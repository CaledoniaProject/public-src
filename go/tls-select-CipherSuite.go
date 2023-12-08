package main

import (
    "crypto/tls"
    "fmt"
)

func GetTlsCipherSuites() []*tls.CipherSuite {
    suites := []*tls.CipherSuite{}

    for _, row := range tls.CipherSuites() {
        if row.ID == tls.TLS_RSA_WITH_3DES_EDE_CBC_SHA || row.ID == tls.TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA {
            continue
        }

        suites = append(suites, row)
    }

    return suites
}

func main() {
    for _, row := range GetTlsCipherSuites() {
        fmt.Printf("%v\n", row)
    }
}
