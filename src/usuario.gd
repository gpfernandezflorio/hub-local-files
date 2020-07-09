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
			completar_componente(c)
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
	if "cuerpo" in args:
		for c in args["cuerpo"]:
			completar_componente(c)
	else:
		args["cuerpo"] = []

	var panel = HUB.GC.crear_nodo(Panel)
	panel.set_script(script_ventana)
	gui.add_child(panel)
	panel.inicializar(HUB, args)
	return panel

func inicializar_componente(c, dict_ids=null):
	var nodo = HUB.GC.crear_nodo(c["clase"])
	c["nodo"] = nodo
	if "id" in c and dict_ids != null:
		dict_ids[c["id"]] = nodo
	if "args" in c:
		for a in c["args"].keys():
			nodo.set(a,c["args"][a])
	for h in c["hijos"]:
		inicializar_componente(h)
		nodo.add_child(h["nodo"])

func completar_componente(c):
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
	if "hijos" in c:
		for h in c["hijos"]:
			completar_componente(h)
	else:
		c["hijos"] = []

func resize_componente(c, marco=HUB.pantalla.resolucion):
	var nodo = c["nodo"]
	var size
	if "tamanio" in c:
		size = Vector2(marco.x*c["tamanio"].x/100,marco.y*c["tamanio"].y/100)
		nodo.set_size(size)
	else:
		size = nodo.get_size()
	var a_y = c["posicion"][0]
	var a_x = c["posicion"][1]
	var offset = c["posicion"][2]
	offset = Vector2(marco.x*offset.x/100,marco.y*offset.y/100)
	var pos = offset
	if a_x == "r":
		pos.x = marco.x-size.x-offset.x
	elif a_x == "c":
		pos.x = (marco.x-size.x)/2+offset.x
	if a_y == "b":
		pos.y = marco.y-size.y-offset.y
	elif a_y == "c":
		pos.y = (marco.y-size.y)/2+offset.y
	nodo.set_size(size)
	nodo.set_pos(pos)
	for h in c["hijos"]:
		resize_componente(h, size)

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