## EX
## Objeto
## Funcion

extends Node

var HUB

var lib_map = [
	"HUB3DLang",
	"tipos"
]
var arg_map = {
	"lista":[
		{"nombre":"ancho", "codigo":"w", "default":"x"},
		{"nombre":"alto", "codigo":"h", "default":"y"},
		{"nombre":"profundidad", "codigo":"p", "default":[]},
		{"nombre":"invertir", "codigo":"i", "validar":"BOOL", "default":false}
	]
}

var h3 # Biblioteca HUB3DLang
var tipos # Biblioteca tipos
var xyz_regex

# Para saber cómo generar las caras y los mapas UV
var direcciones = [] # lista de hasta 3 diccionarios que indican para cada eje si es positivo o no
var invertir_caras = false

func inicializar(hub):
	HUB = hub
	h3 = lib_map.HUB3DLang
	tipos = lib_map.tipos
	xyz_regex = RegEx.new()
	xyz_regex.compile("(-)?(x|y|z)")
	return null

func gen(argumentos):
	var w = argumentos["w"]
	var h = argumentos["h"]
	var p = argumentos["p"]
	direcciones = []
	if not tipos.es_una_lista(w):
		w = [w]
	if not tipos.es_una_lista(h):
		h = [h]
	if not tipos.es_una_lista(p):
		p = [p]
	w = offsets(w)
	if HUB.errores.fallo(w):
		return w
	h = offsets(h)
	if HUB.errores.fallo(h):
		return h
	p = offsets(p)
	if HUB.errores.fallo(p):
		return p
	invertir_caras = hay_que_invertir(argumentos["i"])
	var ultimo_vertice = Vector3(0,0,0)
	var vertices1 = [ultimo_vertice]
	var vertices2 = [ultimo_vertice]
	var borde = {"bot":[0],"lef":[0]}
	var vertexes = [ultimo_vertice]
	var faces = []
	for x in w:
		var nuevo_vertice = ultimo_vertice + x
		vertices1.append(nuevo_vertice)
		vertices2.append(nuevo_vertice)
		borde["bot"].append(vertexes.size())
		vertexes.append(nuevo_vertice)
		ultimo_vertice = nuevo_vertice
	var vs = vertices1.size()
	borde["rig"] = [vs-1]
	var current = 0
	for x in h:
		for v in range(vs):
			vertices1[v] += x
		borde["lef"].append(vertexes.size())
		for v in vertices1:
			vertices2.append(v)
			vertexes.append(v)
		borde["rig"].append(vertexes.size()-1)
		for i in range(vs-1):
			faces.append(cara([current+i,current+vs+i,current+vs+i+1,current+i+1]))
		current += vs
	if not p.empty():
		borde["top"] = []
		for v in range(vs):
			borde["top"].push_front(vertexes.size()-v-1)
		var ultima_capa = p.back()
		p.pop_back()
		for x in p:
			var nuevo_borde = {"bot":[]}
			nuevo_borde["lef"] = [vertexes.size()]
			for b in borde["bot"]:
				var v = vertexes[b] + x
				nuevo_borde["bot"].append(vertexes.size())
				vertexes.append(v)
			nuevo_borde["rig"] = [vertexes.size()-1]
			for i in range(1, borde["lef"].size()):
				var b = borde["lef"][i]
				var v = vertexes[b] + x
				nuevo_borde["lef"].append(vertexes.size())
				vertexes.append(v)
			nuevo_borde["top"] = [vertexes.size()-1]
			for i in range(1, borde["rig"].size()):
				var b = borde["rig"][i]
				var v = vertexes[b] + x
				nuevo_borde["rig"].append(vertexes.size())
				vertexes.append(v)
			var last_v = vertexes.size()-1
			for i in range(1, borde["top"].size()-1):
				var b = borde["top"][i]
				var v = vertexes[b] + x
				nuevo_borde["top"].append(vertexes.size())
				vertexes.append(v)
			nuevo_borde["top"].append(last_v)
			for i in range(nuevo_borde["bot"].size()-1):
				faces.append(cara([
					borde["bot"][i],borde["bot"][i+1],nuevo_borde["bot"][i+1],nuevo_borde["bot"][i]
				]))
			for i in range(nuevo_borde["lef"].size()-1):
				faces.append(cara([
					borde["lef"][i],nuevo_borde["lef"][i],nuevo_borde["lef"][i+1],borde["lef"][i+1]
				]))
			for i in range(nuevo_borde["rig"].size()-1):
				faces.append(cara([
					borde["rig"][i],borde["rig"][i+1],nuevo_borde["rig"][i+1],nuevo_borde["rig"][i],
				]))
			for i in range(nuevo_borde["top"].size()-1):
				faces.append(cara([
					borde["top"][i],nuevo_borde["top"][i],nuevo_borde["top"][i+1],borde["top"][i+1]
				]))
			borde = nuevo_borde
			for i in range(vertices2.size()):
				vertices2[i] += x
		# Última capa:
		var hs = h.size()
		var current = vertexes.size()
		for i in range(vertices2.size()):
			vertexes.append(vertices2[i] + ultima_capa)
		for i in range(borde["bot"].size()-1):
			faces.append(cara([
				borde["bot"][i],borde["bot"][i+1],current+i+1,current+i
			]))
		for i in range(borde["lef"].size()-1):
			faces.append(cara([
				borde["lef"][i],current+(vs*i),current+(vs*(i+1)),borde["lef"][i+1]
			]))
		var current_rig = current + vs -1
		for i in range(borde["rig"].size()-1):
			faces.append(cara([
				borde["rig"][i],borde["rig"][i+1],current_rig+(vs*(i+1)),current_rig+(vs*i),
			]))
		var current_top = current + vs*(hs)
		for i in range(borde["top"].size()-1):
			faces.append(cara([
				borde["top"][i],current_top+i,current_top+i+1,borde["top"][i+1]
			]))
		for j in range(hs):
			for i in range(vs-1):
				faces.append(cara([current+i,current+i+1,current+vs+i+1,current+vs+i]))
			current += vs
	return h3.nuevo_mesh_rep(vertexes, faces)

func cara(vertices):
	if invertir_caras:
		vertices.invert()
	return h3.nueva_cara(vertices)

func offsets(lista):
	var resultado = []
	var nueva_direccion = {}
	for x in lista:
		var nuevo_offset = Vector3(0,0,0)
		if tipos.es_un_string(x):
			while not x.empty():
				var start = 1
				if x[0] == "-":
					start += 1
				var sep = xyz_regex.find(x,start)
				var n
				if sep == -1:
					n = HUB.varios.str_desde(x,start)
				else:
					n = x.substr(start,sep-start)
				if n.empty():
					n = 1
				elif n.is_valid_float():
					n = float(n)
				elif h3.esta_definido(n):
					n = h3.obtener(n)
				else:
					return HUB.error(HUB.errores.error('eX n inválido: '+n), h3.modulo)
				if not tipos.es_un_numero(n):
					return HUB.error(HUB.errores.error('eX n no es un número: '+n), h3.modulo)
				var axis = x[0]
				if x[0]=="-":
					n*=-1
					axis = x[1]
				if axis == "x":
					nuevo_offset.x = n
					if not "x" in nueva_direccion.keys():
						nueva_direccion["x"] = (n>0)
				elif axis == "y":
					nuevo_offset.y = n
					if not "y" in nueva_direccion.keys():
						nueva_direccion["y"] = (n>0)
				elif axis == "z":
					nuevo_offset.z = n
					if not "z" in nueva_direccion.keys():
						nueva_direccion["z"] = (n>0)
				else:
					return HUB.error(HUB.errores.error('eX eje inválido en "'+x), h3.modulo)
				x = HUB.varios.str_desde(x,sep)
		else:
			return HUB.error(HUB.errores.error("eX no es un string: "+x), h3.modulo)
		resultado.append(nuevo_offset)
	if not resultado.empty():
		direcciones.append(nueva_direccion)
	return resultado

func hay_que_invertir(i):
	var resultado = false
	if direcciones.size() == 3:
		# 3d
		pass
	elif direcciones.size() == 2:
		# 2d
		pass
	else:
		return false
	if i:
		resultado = not resultado
	return resultado