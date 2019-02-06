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

func inicializar(hub):
	HUB = hub
	gui.set_name("GUI")
	add_child(gui)
	mundo = HUB.objetos.crear(null)
	mundo.set_name("Mundo")
	add_child(mundo)
	return true