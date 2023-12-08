package plugin

import "fmt"

type Plugin1 struct{}

func (p Plugin1) Run() bool {
	fmt.Println("Plugin1::Run()")
	return false
}

func (p Plugin1) Name() string {
	return "Plugin1"
}

func init() {
	RegisterPlugin(Plugin1{})
}
