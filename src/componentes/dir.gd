## Dir
## SRC

# Script para los componentes de tipo DirectionalLight

extends DirectionalLight

var HUB
var yo
var intensidad
var color
var atenuacion

func inicializar(hub, yo):
	HUB = hub
	self.yo = yo
	set("params/energy", intensidad)
	set("params/attenuation", atenuacion)
	set("colors/diffuse", color)
	yo.interfaz(self, "alternar", {"lista":[]}, true)
	yo.interfaz(self, "encender", {"lista":[]}, true)
	yo.interfaz(self, "apagar", {"lista":[]}, true)
	return true

func alternar(args):
	var i = get("params/energy")
	if i==0:
		encender(args)
	else:
		apagar(args)

func encender(args):
	set("params/energy", intensidad)

func apagar(args):
	set("params/energy", 0)