## SDE/Sala
## Objeto
## HUB3DLang

$pared=face(!10,3,-z)&body(static):cbox(!10,3,1)

(face(!10,!10)&body(static):cplane):nPiso
pared:oz-5:ry180:nFondo
pared:oz5:nFrente
pared:ox-5:ry90:nDerecha
pared:ox5:ry-90:nIzquierda
(face(!10,!10,-y)&body(static):cbox(!10,1,!10)):nTecho:oy3
switch:oz-5:oy1.8:ox3:nswitch
luz(r=10,i=0.5,c=ba5):nluz:oy2.6