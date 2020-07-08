## SDE/Sala
## Objeto
## HUB3DLang

$pared=face(!10,3,-z)&body(static):cbox(!10,3,1)

(face(!10,!10)&body(static):cplane):nPiso:mfixed(c=333)
pared:oz-5:ry180:nFondo:mfixed(c=223)
pared:oz5:nFrente:mfixed(c=866)
pared:ox-5:ry90:nDerecha:mfixed(c=223)
pared:ox5:ry-90:nIzquierda:mfixed(c=866)
(face(!10,!10,-y)&body(static):cbox(!10,1,!10)):nTecho:oy3:mfixed(c=443)
switch:oz-5:oy1.8:ox3:nswitch
(cube(!.2,.1,!.2)&(luz(r=10,i=0.5,c=ba5):oy-.1)):oy2.9:nluz
estacion/rsa:ox4:ry90