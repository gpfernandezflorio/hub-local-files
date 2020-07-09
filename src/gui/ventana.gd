extends Panel

var HUB
var header
var footer
var cuerpo
var tamanio
var posicion

# ARGS:
#	nodo: Node
#	tamanio: Vector2 (null para fullscreen)
#	posicion: Vector2 (null para centrado)
#	textos:
#		titulo:String
#		cuerpo:String|null
#	[botones]
#		(opcional) texto:String
#		(opcional) accion:String (función del nodo)

func inicializar(hub, args):
	HUB = hub

	var nodo = args["nodo"]
	var opciones = args["botones"]
	if "tamanio" in args:
		tamanio = args["tamanio"]
	else:
		tamanio = null
	if "posicion" in args:
		posicion = args["posicion"]
	else:
		posicion = null

	header = CenterContainer.new()
	var titulo = Label.new()
	titulo.set_text(args["titulo"])
	header.add_child(titulo)
	add_child(header)

	cuerpo = Panel.new()
	add_child(cuerpo)

	footer = CenterContainer.new()
	var botones = HBoxContainer.new()
	for opt in opciones:
		var b = Button.new()
		if "texto" in opt:
			b.set_text(opt["texto"])
		if "accion" in opt:
			b.connect("button_up", nodo, opt["accion"])
		botones.add_child(b)
	footer.add_child(botones)
	add_child(footer)
	resize(null)
	HUB.eventos.registrar_ventana_escalada(self, "resize")
	return null

func cerrar():
	HUB.eventos.anular_ventana_escalada(self)
	HUB.GC.borrar_nodo(self)

func resize(nuevo_tamanio):
	var size
	if tamanio == null:
		size = HUB.pantalla.coordenadas(100,100)
	else:
		size = HUB.pantalla.coordenadas(tamanio.x,tamanio.y)
	var pos
	if posicion == null:
		pos = HUB.pantalla.centrado(size)
	else:
		pos = HUB.pantalla.coordenadas(posicion.x,posicion.y)
	set_size(size)
	set_pos(pos)
	var tamanio_header = Vector2(size.x,20)
	header.set_size(tamanio_header)
	var tamanio_footer = Vector2(size.x,30)
	footer.set_size(tamanio_footer)
	footer.set_pos(Vector2(0,size.y-tamanio_footer.y))
	var tamanio_cuerpo = Vector2(size.x,size.y-tamanio_footer.y-tamanio_header.y)
	cuerpo.set_size(tamanio_cuerpo)
	cuerpo.set_pos(Vector2(0,tamanio_header.y))