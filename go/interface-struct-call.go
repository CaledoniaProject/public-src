package main

import "fmt"

type Plugin interface {
	Run() bool
}
type Plugin1 struct{}
type Plugin2 struct{}

func (p Plugin1) Run() bool {
	fmt.Println("Plugin1::Run()")
	return true
}

func (p Plugin2) Run() bool {
	fmt.Println("Plugin2::Run()")
	return true
}

func main() {
	plugins := []Plugin{
		Plugin1{},
		Plugin2{},
	}

	for _, plugin := range plugins {
		plugin.Run()
	}
}
