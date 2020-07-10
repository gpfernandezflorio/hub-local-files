## SPOT
## SRC

# Script para los componentes de tipo SpotLight

extends SpotLight

var HUB
var yo
var intensidad
var color
var atenuacion
var radio

func inicializar(hub, yo):
	HUB = hub
	self.yo = yo
	set("params/energy", intensidad)
	set("params/radius", radio)
	set("params/attenuation", atenuacion)
	set("colors/diffuse", color)
	yo.interfaz(self, "alternar", {"lista":[]}, true)
	yo.interfaz(self, "encender", {"lista":[]}, true)
	yo.interfaz(self, "encendida", {"lista":[]}, true)
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

func encendida(args):
	return get("params/energy")!=0