package main

import (
    "fmt"
)

func main() {
    a := make([]int, 10)
    b := a[3:5]
    fmt.Println(len(b))
    fmt.Println(cap(b))
}
