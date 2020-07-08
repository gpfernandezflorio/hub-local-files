## Audio
## SRC

# Script para los componentes de tipo SpatialStreamPlayer

extends SpatialStreamPlayer

var HUB
var yo
var sonidos
var loop

func inicializar(hub, yo):
	HUB = hub
	self.yo = yo
	yo.interfaz(self, "sonar", {"lista":[]}, true)
	var audios = []
	for s in sonidos:
		var audio = audios.append(HUB.archivos.abrir(HUB.archivos.carpeta_recursos, s + ".ogg"))
		if HUB.errores.fallo(audio):
			return audio
		audios.append(audio)
	sonidos = audios
	if loop:
		set_stream(sonidos[0])
		set("stream/loop", true)
		set("stream/autoplay", true)
	set("params/attenuation/max_distance",20)
	set("params/attenuation/distance_exp",5)
	return true

func sonar(args):
	set_stream(sonidos[0])
	play(0)