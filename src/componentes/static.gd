## STATIC
## SRC

# Script para los componentes de tipo StaticBody

extends StaticBody

var HUB
var yo

func inicializar(hub, yo_recibido):
	HUB = hub
	self.yo = yo_recibido
	return true

#func add_shape(shape, transform=Transform()):#@3
#	var s_owner = create_shape_owner(null)#@3
#	shape_owner_add_shape(s_owner, shape)#@3
#	shape_owner_set_transform(s_owner, transform)#@3
