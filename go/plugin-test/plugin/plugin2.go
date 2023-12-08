package plugin

import "fmt"

type Plugin2 struct{}

func (p Plugin2) Run() bool {
	fmt.Println("Plugin2::Run()")
	return true
}

func (p Plugin2) Name() string {
	return "Plugin2"
}

func init() {
	RegisterPlugin(Plugin2{})
}
