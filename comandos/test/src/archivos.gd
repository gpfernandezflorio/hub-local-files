## Test/SRC/Archivos
## Comando

# Testea el módulo Archivos.
# Requiere:
	# -

extends Node

var HUB

func inicializar(hub):
	HUB = hub

func comando(argumentos):
	HUB.mensaje("Testeando el módulo Archivos")
	HUB.mensaje("* Testeando abrir archivo inexistente")
	HUB.testing.test_genera_error(
		tester_abrir("", "hola.gd"),
		HUB.archivos.archivo_inexistente("","hola.gd"), []
	)
	HUB.mensaje("* Testeando leer archivo inexistente")
	HUB.testing.test_genera_error(
		tester_leer("", "hola.gd"),
		HUB.archivos.archivo_inexistente("","hola.gd"), []
	)
	HUB.mensaje("* Testeando escribir archivo inexistente")
	HUB.testing.test_genera_error(
		tester_escribir("", "hola.gd", "hola"),
		HUB.archivos.archivo_inexistente("","hola.gd"), []
	)
	HUB.mensaje("* Testeando archivo no existe")
	HUB.testing.asegurar(not HUB.archivos.existe("","hola.gd"))
	HUB.mensaje("* Testeando crear un archivo nuevo")
	HUB.testing.test(
		tester_crear("", "hola.gd"),
		verificador_archivo_existe("","hola.gd"), []
	)
	HUB.mensaje("* Testeando archivo existe")
	HUB.testing.asegurar(HUB.archivos.existe("","hola.gd"))
	HUB.mensaje("* Testeando listar un archivo")
	HUB.testing.test_genera_error(
		tester_listar("", "hola.gd"),
		HUB.archivos.no_es_un_directorio("","hola.gd"), []
	)
	HUB.mensaje("* Testeando leer un archivo vacío")
	HUB.testing.test(
		tester_leer("", "hola.gd"),
		HUB.testing.verificador_por_igualdad(""), []
	)
	HUB.mensaje("* Testeando escribir en un archivo vacío")
	HUB.testing.test(
		tester_escribir("", "hola.gd", "hola"),
		verificador_contenido_archivo("", "hola.gd", "hola"), []
	)
	HUB.mensaje("* Testeando escribir en un archivo existente")
	HUB.testing.test(
		tester_escribir("", "hola.gd", "hola"),
		verificador_contenido_archivo("", "hola.gd", "hola\nhola"), []
	)
	HUB.mensaje("* Testeando leer un archivo no vacío")
	HUB.testing.test(
		tester_leer("", "hola.gd"),
		HUB.testing.verificador_por_igualdad("hola\nhola"), []
	)
	HUB.mensaje("* Testeando sobrescribir un archivo")
	HUB.testing.test(
		tester_sobrescribir("", "hola.gd", "hola"),
		verificador_contenido_archivo("", "hola.gd", "hola"), []
	)
	HUB.mensaje("* Testeando crear un archivo que ya existe")
	HUB.testing.test_genera_error(
		tester_crear("", "hola.gd"),
		HUB.archivos.archivo_ya_existe("","hola.gd"), []
	)
	HUB.mensaje("* Testeando borrar un archivo")
	HUB.testing.test(
		tester_borrar("", "hola.gd"),
		verificador_archivo_no_existe("","hola.gd"), []
	)
	HUB.mensaje("* Testeando sobrescribir un archivo que no existe")
	HUB.testing.test_genera_error(
		tester_sobrescribir("", "hola.gd", "hola"),
		HUB.archivos.archivo_inexistente("","hola.gd"), []
	)
	HUB.mensaje("* Testeando borrar un archivo que no existe")
	HUB.testing.test_genera_error(
		tester_borrar("", "hola.gd"),
		HUB.archivos.archivo_inexistente("","hola.gd"), []
	)
	HUB.mensaje("* Testeando crear una carpeta nueva")
	HUB.testing.test(
		tester_crear_carpeta("", "hola"),
		verificador_archivo_existe("","hola"), []
	)
	HUB.mensaje("* Testeando listar una carpeta vacía")
	HUB.testing.test(
		tester_listar("", "hola"),
		HUB.testing.verificador_por_igualdad(["..","."]), []
	)
	HUB.mensaje("* Testeando listar una carpeta con un archivo")
	HUB.archivos.crear("hola/","hola")
	HUB.testing.test(
		tester_listar("", "hola"),
		HUB.testing.verificador_por_igualdad(["hola","..","."]), []
	)
	HUB.mensaje("* Testeando borrar una carpeta")
	HUB.testing.test(
		tester_borrar("", "hola"),
		verificador_archivo_no_existe("","hola"), []
	)

func tester_abrir(carpeta, archivo):
	return TesterAbrir.new(HUB, carpeta, archivo)
func tester_leer(carpeta, archivo):
	return TesterLeer.new(HUB, carpeta, archivo)
func tester_escribir(carpeta, archivo, contenido):
	return TesterEscribir.new(HUB, carpeta, archivo, contenido)
func tester_sobrescribir(carpeta, archivo, contenido):
	return TesterSobrescribir.new(HUB, carpeta, archivo, contenido)
func tester_crear(carpeta, archivo):
	return TesterCrear.new(HUB, carpeta, archivo)
func tester_crear_carpeta(carpeta, archivo):
	return TesterCrearCarpeta.new(HUB, carpeta, archivo)
func tester_borrar(carpeta, archivo):
	return TesterBorrar.new(HUB, carpeta, archivo)
func tester_listar(carpeta, archivo):
	return TesterListar.new(HUB, carpeta, archivo)

class TesterAbrir:
	var HUB
	var carpeta
	var archivo
	func _init(hub, carpeta, archivo):
		HUB = hub
		self.carpeta = carpeta
		self.archivo = archivo
	func test():
		return HUB.archivos.abrir(carpeta, archivo)

class TesterLeer:
	var HUB
	var carpeta
	var archivo
	func _init(hub, carpeta, archivo):
		HUB = hub
		self.carpeta = carpeta
		self.archivo = archivo
	func test():
		return HUB.archivos.leer(carpeta, archivo)

class TesterEscribir:
	var HUB
	var carpeta
	var archivo
	var contenido
	func _init(hub, carpeta, archivo, contenido):
		HUB = hub
		self.carpeta = carpeta
		self.archivo = archivo
		self.contenido = contenido
	func test():
		return HUB.archivos.escribir(carpeta, archivo, contenido)

class TesterSobrescribir:
	var HUB
	var carpeta
	var archivo
	var contenido
	func _init(hub, carpeta, archivo, contenido):
		HUB = hub
		self.carpeta = carpeta
		self.archivo = archivo
		self.contenido = contenido
	func test():
		return HUB.archivos.sobrescribir(carpeta, archivo, contenido)

class TesterCrear:
	var HUB
	var carpeta
	var archivo
	func _init(hub, carpeta, archivo):
		HUB = hub
		self.carpeta = carpeta
		self.archivo = archivo
	func test():
		return HUB.archivos.crear(carpeta, archivo)

class TesterCrearCarpeta:
	var HUB
	var carpeta
	var archivo
	func _init(hub, carpeta, archivo):
		HUB = hub
		self.carpeta = carpeta
		self.archivo = archivo
	func test():
		return HUB.archivos.crear_carpeta(carpeta, archivo)

class TesterBorrar:
	var HUB
	var carpeta
	var archivo
	func _init(hub, carpeta, archivo):
		HUB = hub
		self.carpeta = carpeta
		self.archivo = archivo
	func test():
		return HUB.archivos.borrar(carpeta, archivo)

class TesterListar:
	var HUB
	var carpeta
	var archivo
	func _init(hub, carpeta, archivo):
		HUB = hub
		self.carpeta = carpeta
		self.archivo = archivo
	func test():
		return HUB.archivos.listar(carpeta, archivo)

func verificador_archivo_existe(carpeta, archivo):
	return VerificadorArchivoExiste.new(HUB, carpeta, archivo)
func verificador_archivo_no_existe(carpeta, archivo):
	return VerificadorArchivoNoExiste.new(HUB, carpeta, archivo)
func verificador_contenido_archivo(carpeta, archivo, contenido):
	return VerificadorContenidoArchivo.new(HUB, carpeta, archivo, contenido)

class VerificadorArchivoExiste:
	var HUB
	var carpeta
	var archivo
	func _init(hub, carpeta, archivo):
		HUB = hub
		self.carpeta = carpeta
		self.archivo = archivo
	func verificar(resultado):
		if HUB.errores.fallo(resultado):
			return "El resultado generó un error inesperado."
		if HUB.archivos.existe(carpeta, archivo):
			return ""
		return 'Se esperaba que el archivo "' + archivo + \
		'" exista en la carpeta "' + carpeta + '" pero no es así.'

class VerificadorArchivoNoExiste:
	var HUB
	var carpeta
	var archivo
	func _init(hub, carpeta, archivo):
		HUB = hub
		self.carpeta = carpeta
		self.archivo = archivo
	func verificar(resultado):
		if HUB.errores.fallo(resultado):
			return "El resultado generó un error inesperado."
		if HUB.archivos.existe(carpeta, archivo):
			return 'Se esperaba que el archivo "' + archivo + \
			'" no exista en la carpeta "' + carpeta + '" pero existe.'
		return ""

class VerificadorContenidoArchivo:
	var HUB
	var carpeta
	var archivo
	var contenido_esperado
	func _init(hub, carpeta, archivo, contenido):
		HUB = hub
		self.carpeta = carpeta
		self.archivo = archivo
		contenido_esperado = contenido
	func verificar(resultado):
		if HUB.errores.fallo(resultado):
			return "El resultado generó un error inesperado."
		var contenido_recibido = HUB.archivos.leer(carpeta, archivo)
		if HUB.errores.fallo(contenido_recibido):
			return 'Hubo un error al leer el archivo "' + archivo + '".'
		if contenido_recibido == contenido_esperado:
			return ""
		return 'Se esperaba que el archivo "' + archivo + \
		'" contenga\n\t' + contenido_esperado.replace("\n","\n\t") + \
		'\nPero contiene\n\t' + contenido_recibido.replace("\n","\n\t")

func descripcion():
	return "Test"

func man():
	var r = "[ TEST ] - " + descripcion()
	return r