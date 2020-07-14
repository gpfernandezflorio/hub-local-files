## Fonts
## SRC

extends Node

var fonts = {}
var carpeta_recursos

func inicializar(hub):
	carpeta_recursos = hub.archivos.carpeta_recursos
	return true

func fuente(nombre="FreeSerif", tamanio=20):
	var id = "%s-%s" % [nombre, tamanio]
	if id in fonts:
		return fonts[id]
	if (tamanio < 1): tamanio = 1
	var font = DynamicFont.new()
	var fontData = DynamicFontData.new()
	font.set_size(tamanio)
	fontData.font_path = carpeta_recursos.plus_file("%s.ttf") % nombre
	font.set_font_data(fontData)
	fonts[id] = font
	return font