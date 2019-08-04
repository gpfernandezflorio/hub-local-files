## Test/SRC/Terminal
## Comando

# Testea el módulo Terminal.
# Requiere:
	# -

extends Node

var HUB
var carpeta

func inicializar(hub):
	HUB = hub
	carpeta = HUB.terminal.nodo_comandos.carpeta_comandos

func comando(argumentos):
	var nodo = Node.new()
	HUB.mensaje("Testeando el módulo Terminal")
	HUB.mensaje("* Testeando ejecutar comando inexistente")
	HUB.testing.comando_fallido("hola",
		HUB.archivos.archivo_inexistente(carpeta, "hola.gd"), []
	)
	HUB.mensaje("* Testeando ejecutar un comando vacío")
	HUB.archivos.crear(carpeta, "hola.gd")
	HUB.testing.test_genera_error(
		tester_comando("hola"),
		HUB.archivos.encabezado_faltante("hola.gd"), []
	)
	HUB.mensaje("* Testeando ejecutar un comando sin encabezado 1")
	HUB.archivos.escribir(carpeta, "hola.gd", "hola")
	HUB.testing.test_genera_error(
		tester_comando("hola"),
		HUB.archivos.encabezado_faltante("hola.gd"), []
	)
	HUB.mensaje("* Testeando ejecutar un comando sin encabezado 2")
	HUB.archivos.escribir(carpeta, "hola.gd", "## hola")
	HUB.testing.test_genera_error(
		tester_comando("hola"),
		HUB.archivos.encabezado_faltante("hola.gd"), []
	)
	HUB.mensaje("* Testeando ejecutar un comando sin encabezado 3")
	HUB.archivos.sobrescribir(carpeta, "hola.gd", "## hola\nhola")
	HUB.testing.test_genera_error(
		tester_comando("hola"),
		HUB.archivos.encabezado_faltante("hola.gd"), []
	)
	HUB.mensaje("* Testeando ejecutar un comando con nombre incorrecto")
	HUB.archivos.sobrescribir(carpeta, "hola.gd", "## chau\n## chau")
	HUB.testing.test_genera_error(
		tester_comando("hola"),
		HUB.archivos.encabezado_invalido_nombre("hola.gd", "hola"), []
	)
	HUB.mensaje("* Testeando ejecutar un comando con tipo incorrecto")
	HUB.archivos.sobrescribir(carpeta, "hola.gd", "## hola\n## hola")
	HUB.testing.test_genera_error(
		tester_comando("hola"),
		HUB.archivos.encabezado_invalido_tipo("hola.gd", "Comando"), []
	)
	HUB.mensaje("* Testeando ejecutar un comando sin función de inicialización")
	nodo.set_name("hola.gd")
	HUB.archivos.sobrescribir(carpeta, "hola.gd", "## hola\n## Comando")
	HUB.testing.test_genera_error(
		tester_comando("hola"),
		HUB.errores.funcion_no_implementada(nodo, "inicializar", 1), []
	)
	HUB.archivos.borrar(carpeta, "hola.gd")
	HUB.mensaje("* Testeando ejecutar un comando con función de inicialización sin parámetros")
	nodo.set_name("hoLa.gd")
	HUB.archivos.crear(carpeta, "hoLa.gd")
	HUB.archivos.escribir(carpeta, "hoLa.gd", "## hola\n## Comando\nfunc inicializar():\n\tpass")
	HUB.testing.test_genera_error(
		tester_comando("hoLa"),
		HUB.errores.funcion_no_implementada(nodo, "inicializar", 1), []
	)
	HUB.archivos.borrar(carpeta, "hoLa.gd")
	HUB.mensaje("* Testeando ejecutar un comando con función de inicialización con 2 parámetros")
	nodo.set_name("hOla.gd")
	HUB.archivos.crear(carpeta, "hOla.gd")
	HUB.archivos.escribir(carpeta, "hOla.gd", "## hola\n## Comando\n" + \
	"func inicializar(hub, x):\n\tpass")
	HUB.testing.test_genera_error(
		tester_comando("hOla"),
		HUB.errores.funcion_no_implementada(nodo, "inicializar", 1), []
	)
	HUB.archivos.borrar(carpeta, "hOla.gd")
	HUB.mensaje("* Testeando ejecutar un comando sin función de ejecución")
	nodo.set_name("Hola.gd")
	HUB.archivos.crear(carpeta, "Hola.gd")
	HUB.archivos.escribir(carpeta, "Hola.gd", "## hola\n## Comando\nfunc inicializar(a):\n\tpass")
	HUB.testing.test_genera_error(
		tester_comando("Hola"),
		HUB.errores.funcion_no_implementada(nodo, "comando", 1), []
	)
	HUB.archivos.borrar(carpeta, "Hola.gd")
	HUB.mensaje("* Testeando ejecutar un comando con función de ejecución sin parámretros")
	nodo.set_name("holA.gd")
	HUB.archivos.crear(carpeta, "holA.gd")
	HUB.archivos.escribir(carpeta, "holA.gd", "## hola\n## Comando\nfunc inicializar(a):\n\tpass\nfunc comando():\n\tpass")
	HUB.testing.test_genera_error(
		tester_comando("holA"),
		HUB.errores.funcion_no_implementada(nodo, "comando", 1), []
	)
	HUB.archivos.borrar(carpeta, "holA.gd")
	HUB.mensaje("* Testeando ejecutar un comando con función de ejecución con 2 parámretros")
	nodo.set_name("HolA.gd")
	HUB.archivos.crear(carpeta, "HolA.gd")
	HUB.archivos.escribir(carpeta, "HolA.gd", "## hola\n## Comando\nfunc inicializar(a):\n\tpass\nfunc comando(a, b):\n\tpass")
	HUB.testing.test_genera_error(
		tester_comando("HolA"),
		HUB.errores.funcion_no_implementada(nodo, "comando", 1), []
	)
	HUB.archivos.borrar(carpeta, "HolA.gd")
	HUB.mensaje("* Testeando ejecutar un comando correcto")
	nodo.set_name("hOLa.gd")
	HUB.archivos.crear(carpeta, "hOLa.gd")
	HUB.archivos.escribir(carpeta, "hOLa.gd", "## hola\n## Comando\nfunc inicializar(a):\n\tpass\nfunc comando(a):\n\treturn 95")
	HUB.testing.test(
		tester_comando("hOLa"),
		HUB.testing.verificador_por_igualdad(95), []
	)
	HUB.archivos.borrar(carpeta, "hOLa.gd")

func tester_comando(comando):
	return TesterComando.new(HUB, comando)

class TesterComando:
	var HUB
	var comando
	func _init(hub, comando):
		HUB = hub
		self.comando = comando
	func test():
		return HUB.terminal.ejecutar(comando)

func descripcion():
	return "Test"

func man():
	var r = "[ TEST ] - " + descripcion()
	return r