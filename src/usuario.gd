## Nodo Usuario
## SRC

# Nodo raíz del usuario.
# Requiere para inicializar:
	# HUB.objetos
		# crear

extends Node

var HUB
var modulo = "USUARIO"

# Nodo raíz para la interfaz gráfica
var gui = Control.new()
# Objeto raíz de la jerarquía de objetos
var mundo

var carpeta_gui = "gui"
var script_ventana = "ventana.gd"

func inicializar(hub):
	HUB = hub
	gui.set_name("GUI")
	add_child(gui)
	mundo = HUB.objetos.crear(null)
	mundo.set_name("Mundo")
	add_child(mundo)
	script_ventana = HUB.archivos.abrir(HUB.hub_src.plus_file(carpeta_gui), script_ventana)
	#aviso({},[{"texto":"si"},{"texto":"no"}])
	return true

var textos_default = {
	"titulo":"mensaje",
	"cuerpo":""
}

func aviso(textos={}, opciones=[]):
	for t in textos_default.keys():
		if not t in textos.keys():
			textos[t] = textos_default[t]
	var panel = HUB.GC.crear_nodo(Panel)
	panel.set_script(script_ventana)
	gui.add_child(panel)
	panel.inicializar(HUB, textos, opciones)