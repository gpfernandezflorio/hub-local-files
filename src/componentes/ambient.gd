## AMBIENT
## SRC

# Script para los componentes de tipo WorldEnvironment

extends WorldEnvironment

var HUB
var yo
var env

var intensidad
var color

func inicializar(hub, yo_recibido):
	HUB = hub
	self.yo = yo_recibido
	env = Environment.new()
	env.set("ambient_light/enabled",true)
	env.set("ambient_light/color",color)
	env.set("ambient_light/energy",intensidad)
	set_environment(env)
	yo.interfaz(self, "alternar", {"lista":[]}, true)
	yo.interfaz(self, "encender", {"lista":[]}, true)
	yo.interfaz(self, "encendida", {"lista":[]}, true)
	yo.interfaz(self, "apagar", {"lista":[]}, true)
	
	return true

func alternar(args):
	var i = env.get("ambient_light/energy")
	if i==0:
		encender(args)
	else:
		apagar(args)
	return i==0

func encender(_args):
	env.set("ambient_light/energy",intensidad)

func apagar(_args):
	env.set("ambient_light/energy",0)

func encendida(_args):
	return get("ambient_light/energy")!=0
