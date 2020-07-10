## SdE
## Programa

# Sala de Escape

extends Node

var HUB
var pid

var lib_map = [
	"HUB3DLang"
]

var modulo = "SdE"
var HUB3DLang

var jugador
var sala
var ventana
var ventana_rsa
var ventana_warn
var tip

var light_switch
var luz
var monitor
var morse
var tapa_cofre
var candado

var textos = {
	"se_warn":"Estás enviando texto plano por un canal\nsin encriptar.\nOtras personas en esta red podrían verlo.\n¿Estás seguro de que deseás continuar?",
	"no_enviar_se":"¡Muy bien! Es importante usar encriptación al\nenviar mensajes con información sensible.",
	"si_enviar_se":"El mensaje que enviaste podría haber sido\ninterceptado.\nSi no querés que esto pase, tenés que\nabrir el chat encriptado.",
}

var msgs_juan = [
	"Hola Claudia, ¿me pasás la contraseña del maletín?",
	"Qué bueno que pusiste el chat seguro, así hablamos más tranquilos. Ahora sí, pasame la contraseña que debe estar escondida por ahí.",
	"No entiendo nada de lo que pusiste. Acordate de encriptar tus mensajes con mi clave pública.",
	"Uh, no estaba lo que buscaba. Dentro sólo había un papel que decía '01011101', no sé para qué servirá.",
	"Si querés después te llamo y hablamos bien, pero ahora necesito urgente la clave de la caja de seguridad."
]

func inicializar(hub, pid, argumentos):
	HUB = hub
	self.pid = pid
	HUB3DLang = lib_map["HUB3DLang"]
	HUB.pantalla.completa()			# Pantalla completa
	HUB.terminal.cerrar()			# Ocultar terminal
	pantalla_inicio()
	return null

func pantalla_inicio():
	HUB.eventos.set_modo_mouse()	# Mostrar mouse
	var texto_intro = HUB.archivos.leer("data/sde","intro.txt")
	ventana = HUB.nodo_usuario.ventana(self,{
		"tamanio":Vector2(75,75),
		"botones":[
			{"texto":"Comenzar","accion":"crear_sala"},
			{"texto":"Salir","accion":"salir"}
		],
		"cuerpo":[
			{"clase":ScrollContainer,"tamanio":Vector2(95,98),"posicion":"center","args":{"scroll/horizontal":false},
			"hijos":[{"clase":Label,"args":{"text":texto_intro},"tamanio":Vector2(5,5)}]}
		]
	})

func crear_sala():
	if jugador != null:
		return
	if ventana != null:
		ventana.cerrar()
		ventana = null
	HUB.eventos.set_modo_mouse(2)
	jugador = HUB3DLang.crear("fps:ox-4:oz4:ry45")
	if HUB.errores.fallo(jugador):
		return jugador
	sala = HUB3DLang.crear("sde/sala:nsala")
	if HUB.errores.fallo(sala):
		return sala
	light_switch = sala.hijo_nombrado("switch")
	monitor = sala.hijo_nombrado("rsa").hijo_nombrado("monitor")
	luz = sala.hijo_nombrado("luz")
	morse = sala.hijo_nombrado("morse")
	tapa_cofre = sala.hijo_nombrado("cofre").hijo_nombrado("tapa")
	candado = sala.hijo_nombrado("cofre").hijo_nombrado("candado")

func salir():
	HUB.procesos.finalizar(self)

func finalizar():
	if ventana != null:
		ventana.cerrar()
	if ventana_rsa != null:
		ventana_rsa.cerrar()
	if tip != null:
		tip.cerrar()
	if ventana_warn != null:
		ventana_warn.cerrar()
	if jugador != null:
		HUB.objetos.borrar(jugador)
	if sala != null:
		HUB.objetos.borrar(sala)
	HUB.eventos.anular_periodico(self)
	HUB.eventos.set_modo_mouse()
	HUB.pantalla.completa(false)
	HUB.terminal.abrir()
	return null

# argumentos: [quien, target, que]
func tip(args):
	if args[2]:
		if tip != null:
			tip.cerrar()
		var texto = "Q: "
		var item = args[1]
		if item == light_switch:
			if luz.mensaje("encendida"):
				texto += "apagar"
			else:
				texto += "encender"
			texto += " la luz"
		#elif item == monitor:
		#	texto = "aa"
		else:
			texto += "inspeccionar"
		tip = HUB.nodo_usuario.ventana(self,{
			"titulo":"",
			"tamanio":Vector2(15,7),
			"posicion":["bottom-center",Vector2(0,10)],
			"cuerpo":[
				{"clase":CenterContainer,"tamanio":Vector2(100,100),
				"hijos":[{"clase":Label,"id":"tip","args":{"text":texto}}]}
			]
		})
	elif tip != null:
		tip.cerrar()
		tip = null

# argumentos: [quien, target, que]
func interruptor_luz(args):
	var encendida = luz.mensaje("alternar")
	if tip != null:
		var texto
		if luz.mensaje("encendida"):
			texto = "apagar"
		else:
			texto = "encender"
		texto += " la luz"
		var label = HUB.nodo_usuario.gui_id("tip")
		label.set_text(texto)
	if encendida:
		morse.mensaje("desactivar")
	else:
		morse.mensaje("activar")

# argumentos: [quien, target, que]
func coloreo(args):
	pass

# argumentos: [quien, target, que]
func rsa(args):
	HUB.eventos.set_modo_mouse()
	jugador.pausa()
	monitor.mensaje("silencio")
	if ventana_rsa == null:
		ventana_rsa = HUB.nodo_usuario.ventana(self,{
			"tamanio":Vector2(50,40),
			"titulo":"Chat sin encriptar",
			"cuerpo":[{"clase":Container,"tamanio":Vector2(96,50),
				"hijos":[{"clase":Button,"id":"boton_rsa","posicion":"top-right",
				"args":{"text":"Modo Encriptado"}},{"clase":VBoxContainer,
				"posicion":["top-left",Vector2(3,0)],"hijos":[
				{"clase":Label,"id":"rsa_msg_h","args":{"text":"Recibiendo mensaje..."}},
				{"clase":Label,"id":"rsa_msg_r"}]},
				{"clase":VBoxContainer,"tamanio":Vector2(96,10),
				"posicion":["bottom-left",Vector2(3,0)],
				"hijos":[{"clase":Label,"args":{"text":"Responder:"}},
				{"clase":LineEdit,"id":"rsa_msg_s"},
				{"clase":Button,"id":"boton_enviar","args":{"text":"Enviar"}}]}]}],
			"botones":[{"texto":"Cerrar","accion":"cerrar_rsa"}]
		})
		HUB.eventos.registrar_secuencia(self, "RSA", ["W|1500","F|recibir_mensaje_rsa"])
		HUB.nodo_usuario.gui_id("boton_enviar").connect("button_up", self, "rsa_enviar")
		HUB.nodo_usuario.gui_id("boton_rsa").connect("button_up", self, "rsa_modo")
	else:
		ventana_rsa.mostrar()

# argumentos: [quien, target, que]
func candado(args):
	HUB.eventos.set_modo_mouse()
	jugador.pausa()
	if ventana != null:
		ventana.cerrar()
	var botones = []
	for i in range(9):
		botones.append({"clase":Button,"args":{"text":str(i+1)},"id":"btn_"+str(i+1)})
	ventana = HUB.nodo_usuario.ventana(self,{
		"titulo":"",
		"tamanio":Vector2(30,30),
		"botones":[
			{"texto":"Cerrar","accion":"cerrar_ventana"}
		],
		"cuerpo":[{"clase":CenterContainer,"tamanio":Vector2(95,98),"hijos":[
			{"clase":GridContainer,"tamanio":Vector2(95,98),"posicion":"center",
			"args":{"columns":3},"hijos":botones}]}
		]
	})
	for i in range(9):
		var btn = HUB.nodo_usuario.gui_id("btn_"+str(i+1))
		btn.connect("button_up", self, "boton_candado", [i+1])

func boton_candado(x):
	print(x)
	candado.mensaje("sonar")

func abrir_cofre():
	HUB.eventos.registrar_periodico(self, "abrir_cofre_step")

func abrir_cofre_step(delta):
	if tapa_cofre.get_rotation_deg().x > -60:
		tapa_cofre.rotate_x(delta/3.0)
	else:
		HUB.eventos.anular_periodico(self)

func rsa_enviar():
	if ventana_rsa != null:
		ventana_rsa.ocultar()
	ventana_warn = HUB.nodo_usuario.ventana(self, {"titulo":"Advertencia",
	"tamanio":Vector2(30,30),"cuerpo":[{"clase":Label,
	"posicion":"center","args":{"text":textos["se_warn"]}}],
	"botones":[{"texto":"Sí","accion":"rsa_warn_si"},{"texto":"No","accion":"rsa_warn_no"}]})

func rsa_warn_si():
	if ventana_warn != null:
		ventana_warn.cerrar()
	ventana_warn = HUB.nodo_usuario.ventana(self, {"titulo":"Notificación",
	"tamanio":Vector2(30,30),"cuerpo":[{"clase":Label,
	"posicion":"center","args":{"text":textos["si_enviar_se"]}}],
	"botones":[{"texto":"Aceptar","accion":"rsa_warn_ok"}]})

func rsa_warn_no():
	if ventana_warn != null:
		ventana_warn.cerrar()
	ventana_warn = HUB.nodo_usuario.ventana(self, {"titulo":"Notificación",
	"tamanio":Vector2(30,30),"cuerpo":[{"clase":Label,
	"posicion":"center","args":{"text":textos["no_enviar_se"]}}],
	"botones":[{"texto":"Aceptar","accion":"rsa_warn_ok"}]})

func rsa_warn_ok():
	if ventana_warn != null:
		ventana_warn.cerrar()
	if ventana_rsa != null:
		ventana_rsa.mostrar()

func rsa_modo():
	if ventana_rsa != null:
		ventana_rsa.cerrar()
	ventana_rsa = HUB.nodo_usuario.ventana(self,{
		"tamanio":Vector2(50,40),
		"titulo":"Chat [MODO ENCRIPTADO]",
		"botones":[{"texto":"Cerrar","accion":"cerrar_rsa"}]
	})

func recibir_mensaje_rsa(args):
	monitor.mensaje("sonar", ["whatsapp"])
	if ventana_rsa != null:
		HUB.nodo_usuario.gui_id("rsa_msg_h").set_text("Mensaje de juanchi:")
		HUB.nodo_usuario.gui_id("rsa_msg_r").set_text(msgs_juan[0])

func cerrar_ventana():
	if ventana != null:
		ventana.cerrar()
	jugador.pausa(false)
	HUB.eventos.set_modo_mouse(2)

func cerrar_rsa():
	if ventana_rsa != null:
		ventana_rsa.ocultar()
	jugador.pausa(false)
	HUB.eventos.set_modo_mouse(2)