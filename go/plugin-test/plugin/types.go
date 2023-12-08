package plugin

type Plugin interface {
	Name() string
	Run() bool
}

var (
	PluginList []Plugin
)

func RegisterPlugin(p Plugin) {
	PluginList = append(PluginList, p)
}
