extends Panel

var HUB
var header
var footer
var cuerpo

func inicializar(hub, textos={}, opciones=[]):
	HUB = hub

	header = CenterContainer.new()
	var titulo = Label.new()
	titulo.set_text(textos["titulo"])
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
		botones.add_child(b)
	footer.add_child(botones)
	add_child(footer)
	resize(null)
	HUB.eventos.registrar_ventana_escalada(self, "resize")
	return null

func resize(nuevo_tamanio):
	var tamanio = HUB.pantalla.coordenadas(80,80)
	var posicion = HUB.pantalla.centrado(tamanio)
	set_size(tamanio)
	set_pos(posicion)
	var tamanio_header = Vector2(tamanio.x,20)
	header.set_size(tamanio_header)
	var tamanio_footer = Vector2(tamanio.x,30)
	footer.set_size(tamanio_footer)
	footer.set_pos(Vector2(0,tamanio.y-tamanio_footer.y))
	var tamanio_cuerpo = Vector2(tamanio.x,tamanio.y-tamanio_footer.y-tamanio_header.y)
	cuerpo.set_size(tamanio_cuerpo)
	cuerpo.set_pos(Vector2(0,tamanio_header.y))