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
var script_gui = "gui.gd"

func inicializar(hub):
	HUB = hub
	gui.set_name("GUI")
	add_child(gui)
	mundo = HUB.objetos.crear(null)
	mundo.set_name("Mundo")
	add_child(mundo)
	script_ventana = HUB.archivos.abrir(HUB.hub_src.plus_file(carpeta_gui), script_ventana)
	script_gui = HUB.archivos.abrir(HUB.hub_src.plus_file(carpeta_gui), script_gui)
	return true

func gui(nodo, args):
	args["nodo"] = nodo
	if "componentes" in args:
		for c in args["componentes"]:
			if "posicion" in c:
				var p = c["posicion"]
				if typeof(p) == TYPE_STRING:
					var ps = p.split("-")
					var a = ["c","c"]
					if ps.size()==1:
						a = parse_a(a,p)
					elif ps.size()==2:
						a = parse_a_y(a,ps[0])
						a = parse_a_x(a,ps[1])
					c["posicion"] = [a[0],a[1],Vector2(0,0)]
				elif typeof(p) == TYPE_VECTOR2:
					c["posicion"] = ["t","l",p]
			else:
				c["posicion"] = ["t","l",Vector2(0,0)]
			if not "clase" in c:
				c["clase"] = Panel
			if not "hijos" in c:
				c["hijos"] = []
	else:
		args["componentes"] = []

	var control = HUB.GC.crear_nodo(Control)
	control.set_script(script_gui)
	gui.add_child(control)
	control.inicializar(HUB, args)
	return control

func ventana(nodo, args):
	args["nodo"] = nodo
	if not "titulo" in args:
		args["titulo"] = "mensaje de " + nodo.get_name()
	if "botones" in args:
		#for b in args["botones"]:
		pass
	else:
		args["botones"] = []

	var panel = HUB.GC.crear_nodo(Panel)
	panel.set_script(script_ventana)
	gui.add_child(panel)
	panel.inicializar(HUB, args)
	return panel

func parse_a_y(a,p):
	var res = a
	if p == "top":
		res[0]="t"
	elif p == "bottom":
		res[0]="b"
	return res

func parse_a_x(a,p):
	var res = a
	if p == "right":
		res[1]="r"
	elif p == "left":
		res[1]="l"
	return res

func parse_a(a,p):
	var res = a
	res = parse_a_y(res,p)
	res = parse_a_x(res,p)
	return res