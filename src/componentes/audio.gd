## Audio
## SRC

# Script para los componentes de tipo SpatialStreamPlayer

extends Spatial  # Este es un proxy al SpatialStreamPlayer real

var HUB
var yo
var modulo = "Audio"

var player_real
var sonidos
var loop
var volumen

func inicializar(hub, yo):
	HUB = hub
	self.yo = yo
	player_real = StreamPlayer.new() # Para que funcione en HTML5 uso este en lugar del Spatial
	add_child(player_real)
	var audios = {}
	for s in sonidos:
		var audio
		if HUB.archivos.existe_recurso(s + ".ogg"):
			audio = HUB.archivos.abrir_recurso(s + ".ogg")
		else:
			return HUB.error(HUB.errores.error("X"), modulo)
		if HUB.errores.fallo(audio):
			return audio
		audios[s] = audio
	sonidos = audios
	var default = sonidos.keys()[0]
	if loop:
		player_real.set_stream(sonidos[default])
		player_real.set("stream/loop", true)
		player_real.set("stream/autoplay", true)
	HUB.eventos.registrar_periodico(self, "periodico")
	yo.interfaz(self, "sonar", {"lista":[{"nombre":"sonido","codigo":"s","default":default}]}, true)
	yo.interfaz(self, "silencio", {"lista":[]}, true)
	return true

func periodico(delta):
	var camara = get_viewport().get_camera()
	if camara == null:
		player_real.set_volume(0)
	else:
		var distancia = camara.get_global_transform().origin.distance_to(get_global_transform().origin)
		if distancia < 1:
			player_real.set_volume(volumen)
		else:
			var db = volumen/distancia
			player_real.set_volume(db)

func finalizar():
	HUB.eventos.anular_periodico(self)

func silencio(args):
	player_real.set("stream/loop", false)
	player_real.set("stream/autoplay", false)
	player_real.stop()

func sonar(args):
	if not args["s"] in sonidos.keys():
		return HUB.error(HUB.errores.error('No conozco el sonido "'+args["s"]+'".'))
	player_real.set_stream(sonidos[args["s"]])
	player_real.play()