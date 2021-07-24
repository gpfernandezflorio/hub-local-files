extends Panel

var HUB
var GUI

var header
var footer
var cuerpo
var tamanio
var posicion

# ARGS:
#	nodo: Node
#	tamanio: Vector2 (null para fullscreen)
#	posicion: String ("top","bottom-left", etc), Vector2 o ambos
#	titulo:String
#	[cuerpo]:componentes
#	[botones]
#		(opcional) texto:String
#		(opcional) accion:String (función del nodo)

func inicializar(hub, args):
	HUB = hub
	GUI = HUB.nodo_usuario

	var nodo = args["nodo"]
	var opciones = args["botones"]
	if "tamanio" in args:
		tamanio = args["tamanio"]
	else:
		tamanio = null
	posicion = args["posicion"]

	header = CenterContainer.new()
	var alura_header = 0
	if not args["titulo"].empty():
		header.add_child(GUI.texto({"texto":args["titulo"]}))
		add_child(header)
		alura_header = 5
	header = {"nodo":header,"altura":alura_header}

	cuerpo = Panel.new()
	var componentes = []
	for c in args["cuerpo"]:
		HUB.nodo_usuario.inicializar_componente(c)
		cuerpo.add_child(c["nodo"])
		componentes.append(c)
	add_child(cuerpo)
	cuerpo = {"nodo":cuerpo,"hijos":componentes}

	footer = CenterContainer.new()
	var altura_footer = 0
	if not opciones.empty():
		var botones = HBoxContainer.new()
		for opt in opciones:
			var b = GUI.boton(opt)
			if "accion" in opt:
				b.connect("button_up", nodo, opt["accion"])
			botones.add_child(b)
		footer.add_child(botones)
		add_child(footer)
		altura_footer = 7
	footer = {"nodo":footer,"altura":altura_footer}
	resize(null)
	HUB.eventos.registrar_ventana_escalada(self, "resize")
	return null

func cerrar():
	HUB.eventos.anular_ventana_escalada(self)
	HUB.GC.borrar_nodo(self)

func ocultar():
	set("visibility/visible", false)

func mostrar():
	set("visibility/visible", true)

func resize(_nuevo_tamanio):
	var size
	if tamanio == null:
		size = HUB.pantalla.coordenadas(100,100)
	else:
		size = HUB.pantalla.coordenadas(tamanio.x,tamanio.y)

	var a_y = posicion[0]
	var a_x = posicion[1]
	var offset = posicion[2]
	var marco = HUB.pantalla.resolucion
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

	set_size(size)
	set_pos(pos)
	var tamanio_header = Vector2(size.x,header["altura"]*marco.y/100)
	header["nodo"].set_size(tamanio_header)
	var tamanio_footer = Vector2(size.x,footer["altura"]*marco.y/100)
	footer["nodo"].set_size(tamanio_footer)
	footer["nodo"].set_pos(Vector2(0,size.y-tamanio_footer.y))
	var tamanio_cuerpo = Vector2(size.x,size.y-tamanio_footer.y-tamanio_header.y)
	cuerpo["nodo"].set_size(tamanio_cuerpo)
	cuerpo["nodo"].set_pos(Vector2(0,tamanio_header.y))
	for c in cuerpo["hijos"]:
		HUB.nodo_usuario.resize_componente(c,tamanio_cuerpo)
