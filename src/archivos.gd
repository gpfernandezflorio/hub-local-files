## Archivos
## SRC

# Maneja el acceso a archivos.
# Requiere para inicializar:
	# -

extends Node

var HUB
# Interfaz para acceder al sistema de archivos del SO
var file_system = File.new()

func inicializar(hub):
	HUB = hub
	return true

# Carga el contenido de un archivo
func abrir(ruta, nombre):
	if existe(ruta, nombre):
		return load(HUB.ruta_raiz + ruta + nombre)
	return null

# Carga el contenido de un archivo como texto
func leer(ruta, nombre):
	if existe(ruta, nombre):
		file_system.open(HUB.ruta_raiz + ruta + nombre, File.READ)
		var contenido = file_system.get_as_text()
		file_system.close()
		return contenido
	return null

# Determina si un archivo existe
func existe(ruta, nombre):
	return file_system.file_exists(HUB.ruta_raiz + ruta + nombre)