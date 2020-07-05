## Kill
## Comando

# Elimina un objeto.

extends Node

var HUB

var arg_map = {
	"obligatorios":1,
	"lista":[
		{"nombre":"objeto", "codigo":"o", "path":"OBJ"}
	]
}

var modulo = "Kill"

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	var resultado = HUB.objetos.borrar(argumentos["o"])
	if HUB.errores.fallo(resultado):
		return HUB.error(HUB.errores.error("Comando fallido", resultado), modulo)
	return ""

func descripcion():
	return "Elimina un objeto"

func man():
	var r = "[ KILL ] - " + descripcion()
	r += "\nUso: kill OBJETO"
	r += "\n OBJETO : El nombre (ruta completa) del objeto que se quiere eliminar."
	return r
