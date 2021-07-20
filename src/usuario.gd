## Nodo Usuario
## SRC

# Nodo raíz del usuario.
# Requiere para inicializar:
	# HUB.archivos
		# carpeta_recursos
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
var ids = {}
var fonts

func inicializar(hub):
	HUB = hub
	gui.set_name("GUI")
	add_child(gui)
	mundo = HUB.objetos.crear(null)
	mundo.set_name("Mundo")
	add_child(mundo)
	script_ventana = HUB.archivos.abrir(HUB.hub_src.plus_file(carpeta_gui), script_ventana)
	script_gui = HUB.archivos.abrir(HUB.hub_src.plus_file(carpeta_gui), script_gui)
	fonts = Node.new()
	fonts.set_script(HUB.archivos.abrir(HUB.hub_src.plus_file(carpeta_gui), "fonts.gd"))
	fonts.inicializar(HUB)
	return true

func gui_id(id):
	if id in ids.keys():
		var res = ids[id]
		if HUB.GC.es_valido(res):
			return res
		ids.erase(id)
		return null

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
	if "posicion" in args:
		args["posicion"] = parse_pos(args["posicion"])
	else:
		args["posicion"] = ["c","c",Vector2(0,0)]

	var panel = HUB.GC.crear_nodo(Panel)
	panel.set_script(script_ventana)
	gui.add_child(panel)
	panel.inicializar(HUB, args)
	return panel

func inicializar_componente(c):
	var clase = c["clase"]
	var nodo
	if typeof(clase) == TYPE_STRING:
		if not "args" in c:
			c["args"] = {}
		nodo = componente(clase, c["args"])
	else:
		nodo = HUB.GC.crear_nodo(clase)
		if "args" in c:
			for a in c["args"].keys():
				nodo.set(a,c["args"][a])
	c["nodo"] = nodo
	if "id" in c:
		ids[c["id"]] = nodo
	for h in c["hijos"]:
		inicializar_componente(h)
		nodo.add_child(h["nodo"])

func completar_componente(c):
	if "posicion" in c:
		c["posicion"] = parse_pos(c["posicion"])
	else:
		c["posicion"] = ["t","l",Vector2(0,0)]
	if not "clase" in c:
		c["clase"] = Panel
	if "hijos" in c:
		for h in c["hijos"]:
			completar_componente(h)
	else:
		c["hijos"] = []

func componente(clase, args):
	if clase == "texto":
		return texto(args)
	if clase == "texto_entrada":
		return texto_entrada(args)
	if clase == "boton":
		return boton(args)
	if clase == "opcion":
		return opcion(args)

var halign = {
	"center":Label.ALIGN_CENTER,
	"left":Label.ALIGN_LEFT,
	"right":Label.ALIGN_RIGHT
}

func texto(args):
	if not "font" in args:
		args["font"] = "FreeSerif"
	if not "size" in args:
		args["size"] = 20
	if not "color" in args:
		args["color"] = Color(1,1,1)
	if not "texto" in args:
		args["texto"] = ""
	if not "align" in args:
		args["align"] = "left"
	var res = HUB.GC.crear_nodo(Label)
	var s = args["size"]*HUB.pantalla.resolucion.y/850
	var font = fonts.fuente(args["font"], s)
	res.set("custom_fonts/font",font)
	res.set("custom_colors/font_color",args["color"])
	res.set_text(args["texto"])
	res.set_align(halign[args["align"]])
	return res

func texto_entrada(args):
	if not "font" in args:
		args["font"] = "FreeSerif"
	if not "size" in args:
		args["size"] = 20
	if not "color" in args:
		args["color"] = Color(1,1,1)
	if not "texto" in args:
		args["texto"] = ""
	if not "edit" in args:
		args["edit"] = true
	var res = HUB.GC.crear_nodo(LineEdit)
	var s = args["size"]*HUB.pantalla.resolucion.y/850
	var font = fonts.fuente(args["font"], s)
	res.set("custom_fonts/font",font)
	res.set("custom_colors/font_color",args["color"])
	res.set("size_flags/horizontal", Container.SIZE_EXPAND_FILL)
	res.set_text(args["texto"])
	res.set("editable",args["edit"])
	return res

func boton(args):
	if not "font" in args:
		args["font"] = "FreeSerif"
	if not "size" in args:
		args["size"] = 20
	if not "color" in args:
		args["color"] = Color(1,1,1)
	if not "texto" in args:
		args["texto"] = ""
	var res = HUB.GC.crear_nodo(Button)
	var s = args["size"]*HUB.pantalla.resolucion.y/850
	var font = fonts.fuente(args["font"], s)
	res.set("custom_fonts/font",font)
	res.set("custom_colors/font_color",args["color"])
	res.set_text(args["texto"])
	return res

func opcion(args):
	if not "opciones" in args:
		args["opciones"] = []
	var res = HUB.GC.crear_nodo(OptionButton)
	for opt in args["opciones"]:
		res.add_item(opt)
	return res

func resize(c):
	if c["clase"] in ["texto","texto_entrada","boton"]:
		var s = c["args"]["size"]*HUB.pantalla.resolucion.y/850
		var font = fonts.fuente(c["args"]["font"], s)
		c["nodo"].set("custom_fonts/font",font)

func resize_componente(c, marco=HUB.pantalla.resolucion):
	if typeof(c["clase"]) == TYPE_STRING:
		resize(c)
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
	nodo.set_position(pos)
	for h in c["hijos"]:
		resize_componente(h, size)

func parse_pos(p):
	if typeof(p) == TYPE_STRING:
		var ps = p.split("-")
		var a = ["c","c"]
		if ps.size()==1:
			a = parse_a(a,p)
		elif ps.size()==2:
			a = parse_a_y(a,ps[0])
			a = parse_a_x(a,ps[1])
		return [a[0],a[1],Vector2(0,0)]
	elif typeof(p) == TYPE_VECTOR2:
		return ["t","l",p]
	else: # Es un par string-vector2
		var rec = parse_pos(p[0])
		return [rec[0],rec[1],p[1]]

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