## OMNI
## SRC

# Script para los componentes de tipo OmniLight

extends OmniLight

var HUB
var yo
var intensidad
var color
var atenuacion
var radio

func inicializar(hub, yo_recibido):
	HUB = hub
	self.yo = yo_recibido
	set("params/energy", intensidad)
	set("params/radius", radio)
	set("params/attenuation", atenuacion)
	set("colors/diffuse", color)
	if HUB.os != "HTML5":
		set("shadow/shadow", true)
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
	return i==0

func encender(_args):
	set("params/energy", intensidad)

func apagar(_args):
	set("params/energy", 0)

func encendida(_args):
	return get("params/energy")!=0
