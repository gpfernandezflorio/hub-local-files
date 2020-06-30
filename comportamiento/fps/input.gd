## FPS/Input
## Comportamiento

# Ingreso de control de jugador
# Requiere para inicializar:
	# -

extends Spatial

var HUB

var arg_map = {
	"lista":[
		{"nombre":"control", "codigo":"c", "default":"K"} # K | KM | J
	]
}

var modulo = "FPS/Input"
var yo

var teclas_presionadas = [false, false, false, false, false, false, false, false]
var input_generado = Vector3(0,0,0)
var rot_input_generado = Vector2(0,0)
var control

var controles = {
	"K":{
		"up": KEY_UP,
		"down": KEY_DOWN,
		"right": KEY_RIGHT,
		"left": KEY_LEFT,
		"rot_up": KEY_W,
		"rot_down": KEY_S,
		"rot_right": KEY_D,
		"rot_left": KEY_A,
		"action": KEY_ENTER
	},
	"KM":{
		"up": KEY_W,
		"down": KEY_S,
		"right": KEY_D,
		"left": KEY_A,
		"action": KEY_Q
	},
	"J":{}
}

func inicializar(hub, yo, args):
	HUB = hub
	self.yo = yo
	control = args["c"]
	registrar_inputs()
	return null

func registrar_inputs():
	if control == "KM":
		HUB.eventos.registrar_mouse_mov(self, "mouse")
		if HUB.os != "HTML5":
			yo.pone("input_mouse", true)
	for k in controles[control]:
		HUB.eventos.registrar_press(controles[control][k], self, "p_"+k)
		HUB.eventos.registrar_release(controles[control][k], self, "r_"+k)

func p_up(): # 0
	teclas_presionadas[0] = true
	input_generado.z = -1
	yo.pone("input_mov", input_generado)
func p_down(): # 1
	teclas_presionadas[1] = true
	input_generado.z = 1
	yo.pone("input_mov", input_generado)
func p_right(): # 2
	teclas_presionadas[2] = true
	input_generado.x = 1
	yo.pone("input_mov", input_generado)
func p_left(): # 3
	teclas_presionadas[3] = true
	input_generado.x = -1
	yo.pone("input_mov", input_generado)

func r_up(): # 0
	teclas_presionadas[0] = false
	if teclas_presionadas[1]:
		input_generado.z = 1
	else:
		input_generado.z = 0
	yo.pone("input_mov", input_generado)
func r_down(): # 1
	teclas_presionadas[1] = false
	if teclas_presionadas[0]:
		input_generado.z = -1
	else:
		input_generado.z = 0
	yo.pone("input_mov", input_generado)
func r_right(): # 2
	teclas_presionadas[2] = false
	if teclas_presionadas[3]:
		input_generado.x = -1
	else:
		input_generado.x = 0
	yo.pone("input_mov", input_generado)
func r_left(): # 3
	teclas_presionadas[3] = false
	if teclas_presionadas[2]:
		input_generado.x = 1
	else:
		input_generado.x = 0
	yo.pone("input_mov", input_generado)

func p_rot_up(): # 4
	teclas_presionadas[4] = true
	rot_input_generado.y = -1
	yo.pone("input_rot", rot_input_generado)
func p_rot_down(): # 5
	teclas_presionadas[5] = true
	rot_input_generado.y = 1
	yo.pone("input_rot", rot_input_generado)
func p_rot_right(): # 6
	teclas_presionadas[6] = true
	rot_input_generado.x = 1
	yo.pone("input_rot", rot_input_generado)
func p_rot_left(): # 7
	teclas_presionadas[7] = true
	rot_input_generado.x = -1
	yo.pone("input_rot", rot_input_generado)

func r_rot_up(): # 4
	teclas_presionadas[4] = false
	if teclas_presionadas[5]:
		rot_input_generado.y = 1
	else:
		rot_input_generado.y = 0
	yo.pone("input_rot", rot_input_generado)
func r_rot_down(): # 5
	teclas_presionadas[5] = false
	if teclas_presionadas[4]:
		rot_input_generado.y = -1
	else:
		rot_input_generado.y = 0
	yo.pone("input_rot", rot_input_generado)
func r_rot_right(): # 6
	teclas_presionadas[6] = false
	if teclas_presionadas[7]:
		rot_input_generado.x = -1
	else:
		rot_input_generado.x = 0
	yo.pone("input_rot", rot_input_generado)
func r_rot_left(): # 7
	teclas_presionadas[7] = false
	if teclas_presionadas[6]:
		rot_input_generado.x = 1
	else:
		rot_input_generado.x = 0
	yo.pone("input_rot", rot_input_generado)

func p_action():
	pass
func r_action():
	if yo.sabe("interact"):
		yo.mensaje("interact")

func mouse(mov):
	yo.pone("input_rot", mov/20.0)
