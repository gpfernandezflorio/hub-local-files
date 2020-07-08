## Audio
## SRC

# Script para los componentes de tipo SpatialStreamPlayer

extends Spatial  # Este es un proxy al SpatialStreamPlayer real

var HUB
var yo
var player_real
var sonidos
var loop

func inicializar(hub, yo):
	HUB = hub
	self.yo = yo
	player_real = StreamPlayer.new() # Para que funcione en HTML5 uso este en lugar del Spatial
	add_child(player_real)
	yo.interfaz(self, "sonar", {"lista":[]}, true)
	var audios = []
	for s in sonidos:
		var audio = audios.append(HUB.archivos.abrir_recurso(s + ".ogg"))
		if HUB.errores.fallo(audio):
			return audio
		audios.append(audio)
	sonidos = audios
	if loop:
		player_real.set_stream(sonidos[0])
		player_real.set("stream/loop", true)
		player_real.set("stream/autoplay", true)
	HUB.eventos.registrar_periodico(self, "periodico")
	return true

func periodico(delta):
	var camara = get_viewport().get_camera()
	if camara == null:
		player_real.set_volume(0)
	else:
		var distancia = camara.get_global_transform().origin.distance_to(get_global_transform().origin)
		if distancia < 1:
			player_real.set_volume(3)
		else:
			var db = 3/distancia
			player_real.set_volume(db)

func finalizar():
	HUB.eventos.anular_periodico(self)

func sonar(args):
	player_real.set_stream(sonidos[0])
	player_real.play()