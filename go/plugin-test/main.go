package main

import (
	"fmt"
	"main/plugin"
)

func main() {
	for _, plugin := range plugin.PluginList {
		fmt.Printf("%s returned %v\n", plugin.Name(), plugin.Run())
	}
}
