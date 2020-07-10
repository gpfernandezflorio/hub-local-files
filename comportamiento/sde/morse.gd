## SDE/Morse
## Comportamiento

# Objeto que reproduce una clave en morse
# Requiere para inicializar:
	# -

extends Spatial

var HUB

var arg_map = {
	"obligatorios":1,
	"lista":[
		{"nombre":"clave", "codigo":"c", "validar":"STR"}
	]
}

var modulo = "Morse"
var yo

var t_punto = 100
var t_raya = 300
var t_entre_puntos = 100
var t_entre_letras = 500
var t_entre_repeticiones = 2000
var activo = false
var secuencia
var luz
var sonido

var caracteres_validos = {
	"0":"-----",
	"1":".----",
	"2":"..---",
	"3":"...--",
	"4":"....-",
	"5":".....",
	"6":"-....",
	"7":"--...",
	"8":"---..",
	"9":"----."
}

func inicializar(hub, yo, args):
	HUB = hub
	self.yo = yo
	var clave = []
	for c in args["c"]:
		if c in caracteres_validos.keys():
			clave.append(caracteres_validos[c])
		else:
			return HUB.error(HUB.errores.error('Caracter inválido "'+c+'".'), modulo)
	secuencia = []
	luz = yo.sabe("apagar") and yo.sabe("encender")
	sonido = yo.sabe("sonar") and yo.sabe("silencio")
	for c in clave:
		for i in c:
			if sonido:
				secuencia.append("M|sonar|"+("punto" if i=="." else "raya"))
			if luz:
				secuencia.append("M|encender")
			secuencia.append("W|"+str((t_punto if i=="." else t_raya)))
			if luz:
				secuencia.append("M|apagar")
			secuencia.append("W|"+str(t_entre_puntos))
		secuencia.append("W|"+str(t_entre_letras))
	secuencia.append("W|"+str(t_entre_repeticiones))
	secuencia.append("R")
	yo.interfaz(self, "activar", {"lista":[]}, true)
	yo.interfaz(self, "desactivar", {"lista":[]}, true)
	if luz:
		yo.mensaje("apagar")
	if sonido:
		yo.mensaje("silencio")
	return null

func finalizar():
	if activo:
		HUB.eventos.anular_secuencia(yo, "M")

func activar(args):
	HUB.eventos.registrar_secuencia(yo, "M", secuencia)
	activo = true
func desactivar(args):
	activo = false
	HUB.eventos.anular_secuencia(yo, "M")
	if luz:
		yo.mensaje("apagar")
	if sonido:
		yo.mensaje("silencio")