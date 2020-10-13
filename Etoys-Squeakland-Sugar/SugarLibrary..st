"
THIS CLASS HAS NO COMMENT!

Sugar button no haikei shoku ga okashii.
"
Class {
	#name : #SugarLibrary,
	#superclass : #Object,
	#instVars : [
		'iconDictionary'
	],
	#classVars : [
		'Default'
	],
	#category : #'Etoys-Squeakland-Sugar'
}

{ #category : #icons }
SugarLibrary class >> chooseIcon [

	^ Form extent: 50@50 depth: 32 bits: (Base64MimeConverter mimeDecodeToBytes: '6cTjfv8AAAAT/wsLC/+4uLn/7+/v/4+Pj7r/AAAAB/9oaGkJ/wv/+fn5/xQUFLb/AAAAB/9+
f38N/wf/Li4vtv8AAAAH/35/fw3/B/8uLi+2/wAAAAf/fn9/Df8H/y4uL7b/AAAAB/9+f38N
/wf/Li4vtv8AAAAH/35/fw3/B/8uLi+2/wAAAAf/fn9/Df8H/y4uL7b/AAAAB/9+f38N/wf/
Li4vtv8AAAAH/35/fw3/B/8uLi+2/wAAAAf/fn9/Df8H/y4uL7b/AAAAB/9+f38N/wf/Li4v
ev8AAAAH/4aHiDr/ury+B//GyMkN/wf/vb3AOv+6vL4H/1dYWT7/AAAAB/+PkJI6/8bIygf/
y8zODf8H/8XHyjr/xsjKB/9dXl8+/wAAAAf/j5CSOv/GyMoH/8vMzg3/B//Fx8o6/8bIygf/
XV5fPv8AAAAH/4+Qkjr/xsjKB//LzM4N/wf/xcfKOv/GyMoH/11eXz7/AAAAB/+PkJIi/8bI
ygv/xcfK/8XHyRL/xsjKB//LzM4N/wf/xcfKEv/GyMoL/8bHyf/Fx8ki/8bIygf/XV5fPv8A
AAAH/4+Qkh7/xsjKE//X2Nj//////+7u7v/Fx8oO/8bIygf/y8zODf8H/8XHyg7/xsjKE//K
y8z/+/v7///////Jyswe/8bIygf/XV5fPv8AAAAH/4+Qkhr/xsjKC//Hycv/+vr6Cf8L//Dw
8P/Fx8kK/8bIygf/y8zODf8H/8XHygr/xsjKC//Hycr//Pz8Cf8H/+Dh4h7/xsjKB/9dXl8+
/wAAAAf/j5CSHv/GyMoH/+Hh4g3/E//l5eb/xcfJ/8bIyv/LzM4N/xP/xcfK/8bIyv/Fx8r/
9fX1Df8H/87P0B7/xsjKB/9dXl8+/wAAAAf/j5CSHv/GyMoL/8XHyf/w8PAN/w//2tvb/8bI
yv/LzM4N/w//xcfK/8XHyf/r7OwN/wv/3t/g/8XHyR7/xsjKB/9dXl8+/wAAAAf/j5CSIv/G
yMoL/8XHyv/4+PgN/wv/0NHS/8vMzg3/C//GyMv/4OHiDf8L/+rq6v/GyMki/8bIygf/XV5f
Pv8AAAAH/4+Qkib/xsjKC//Iycv//v7+Df8H/9bX2A3/B//Z2dsN/wv/8/P0/8XHySb/xsjK
B/9dXl8+/wAAAAf/j5CSKv/GyMoH/83Ozw3/B//8/PwZ/wv/+/v7/8fIySr/xsjKB/9dXl8+
/wAAAAf/j5CSLv/GyMoH/9bX2CX/B//Kyswu/8bIygf/XV5fPv8AAAAH/4+Qki7/xsjKC//H
ycv/4eLiHf8H/9DR0jL/xsjKB/9dXl8+/wAAAAf/j5CSMv/GyMoL/8XHyf/s7O0V/wf/2tvc
Nv/GyMoH/11eXz7/AAAAB/+PkJI2/8bIygv/xsfJ//j4+Q3/C//o6On/x8nKNv/GyMoH/11e
Xz7/AAAAB/+PkJI6/8bIygf/yMjKCf8L//r6+v/GyMk6/8bIygf/XV5fPv8AAAAH/4+Qkj7/
xsjKD//Fx8j/0NHS/8fJyz7/xsjKB/9dXl8+/wAAAAf/j5CShv/GyMoH/11eXz7/AAAAB/+P
kJKG/8bIygf/XV5fPv8AAAAH/4+Qkob/xsjKB/9dXl8+/wAAAAf/j5CShv/GyMoH/11eXz7/
AAAAB/+PkJKG/8bIygf/XV5fPv8AAAAH/4+Qkob/xsjKB/9dXl8+/wAAAAf/j5CShv/GyMoH
/11eXz7/AAAAB/8kJCSG/zIyMwf/FxgY5l7/AAAA' readStream) contents
]

{ #category : #'singleton management' }
SugarLibrary class >> clearDefault [
"
	SugarLibrary clearDefault
"
	Default := nil.

]

{ #category : #icons }
SugarLibrary class >> closeIcon [
	^Form extent: 50@50 depth: 32 bits: (Base64MimeConverter mimeDecodeToBytes: '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' readStream) contents
]

{ #category : #'singleton management' }
SugarLibrary class >> default [
	"Answer the default instance of the receiver, which is held as a class variable.  If the Default is not yet set up, set it up at this time."

	^ Default ifNil: [Default := self newDefault].

"
Default := nil.
"

]

{ #category : #'singleton management' }
SugarLibrary class >> defaultIconHeight [

	^ 75.

]

{ #category : #icons }
SugarLibrary class >> helpIcon [
	"self helpIcon asMorph openInHand"
	^  (PNGReadWriter on: (Base64MimeConverter mimeDecodeToBytes: 'iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAABHNCSVQICAgIfAhkiAAAAAlw
SFlzAAANrAAADawB7wbGRwAAACV0RVh0U29mdHdhcmUATWFjcm9tZWRpYSBGaXJld29ya3Mg
TVggMjAwNId2rM8AAAI/SURBVHic7Zq7iupQFIZ/x1NoEUmRwkQb8QaKplAsxM7OvINP4WP4
CtaChU1qn0E0rRAt4pWIFzSCJHMqhRwzhzCz9xhCvvLfsv/1s9byHgLwCR/w8e4CSPHHSex2
u79dh2s6nY6j7puOBEG8huOO/EupVEIikaBdywuapkFRFFePdRUkkUigWCz+qKjv4jaIb0Yr
COI1qAcxTZO2BQCXy+6Ww+EAVVWxWCyg6zrO5zNM00Q0GkUsFkMymUSlUgHDMCRtARAMcjqd
0Ov1HM8Mw4BhGNhsNhiPx2g2myiXy6SsAbxhRyzLwmg0wmq1Inov0dF6wLIseJ4Hx3HQdR2q
qsIwjOe5ZVmYTqfgeZ6YJ9EgHMehXq8jm83a9OVyiX6/b9N2ux1Ja3JBGIZBu91GKBR6ORME
AZFIBLfb7alZlkXKGgDBIE4BHqzXa1sIAETHCviFZb9er5Bl+UXPZDJEfags+4PL5YLBYIDT
6WTTa7UaUqkUUS9qHbnf7xgOh9jv9zY9nU6j0WgQ96PWEVmWsd1ubVoul4MkSf/dp+9CpSPH
4xGqqto0nufRarXw8UFnCKjc6vSqXSgUEA6HadgBoDRa8XgckiTZNEEQaFg9ofYWhWVZGld/
CZUg8/kck8nEplWrVapfYFAJcjweMZvNbFo+n6dh9ST4qOs1fBOEyo6IoghRFGlc/SW+6UgQ
xGsEQbyGb4K4evrVNI12HT/2dRVEURTXP7i8C9+MVhDEawRBvIZvgoQQ/M3JW/gmyF+WjKG7
Y8WsvAAAAABJRU5ErkJggg==' readStream) readStream) nextImage.
]

{ #category : #icons }
SugarLibrary class >> hideNavBarIcon [
	"Answer a form with the hideNavBar picture"

	^ Form extent: 50@50 depth: 32 bits: (Base64MimeConverter mimeDecodeToBytes: 

'6cThmQC5/xEAuf8RALn/EQC5/xEAuf8RALn/EQC5/xEAuf8RAGn/MQAh/xEAaf8xACH/EQBp
/zEAIf8RAIH/GQAh/xEAff8dACH/EQB5/yEAIf8RAHX/FQAF/w0AIf8RAHH/FQAJ/w0AIf8R
AG3/FQAN/w0AIf8RAGn/FQAR/w0AIf8RAGX/FQAV/w0AIf8RAGX/EQAZ/w0AIf8RAGX/DQBJ
/xEAuf8RALn/EQC5/xEAuf8RACH/DQAd/w0AZf8RACH/DQAZ/xEAZf8RACH/DQAV/xUAZf8R
ACH/DQAR/xUAaf8RACH/DQAN/xUAbf8RACH/DQAJ/xUAcf8RACH/DQAF/xUAdf8RACH/IQB5
/xEAIf8dAH3/EQAh/xkAgf8RACH/NQBl/xEAIf81AGX/EQAh/zUAZf8RALn/EQC5/xEAuf8R
ALn/EQC5/xEAuf8RALn/EQC5/+GZAA=='

readStream) contents.


]

{ #category : #icons }
SugarLibrary class >> keepIcon [

	^ Form extent: 50@50 depth: 32 bits: (Base64MimeConverter mimeDecodeToBytes: '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
mpqa/4qKiv/AwMAJ/xP/4ODg/3x8fP+0tLT//Pz8If8T/7Gxsf+Dg4P/jY2N/8rKyg3/F//C
wsL/gYGB/46Ojv9OTk7/AgICUv8AAAAr/0pKSv+ZmZn/ioqK/76+vv/9/f3//////+Dg4P98
fHz/tLS0//z8/CH/E/+xsbH/g4OD/42Njf/KysoN/xf/wsLC/4GBgf+Ojo7/Tk5O/wICAlL/
AAAAK/9KSkr/mZmZ/4qKiv++vr7//f39///////g4OD/fHx8/7S0tP/8/Pwh/xP/sbGx/4OD
g/+NjY3/ysrKDf8X/8LCwv+BgYH/jo6O/05OTv8CAgJS/wAAACv/SkpK/5mZmf+Kior/vr6+
//39/f//////4ODg/3x8fP+0tLT//Pz8If8T/7Kysv+Dg4P/jY2N/8rKyg3/F//CwsL/gYGB
/46Ojv9OTk7/AgICUv8AAAAr/0hISP+ZmZn/ioqK/7+/v//+/v7//////+Dg4P98fHz/tLS0
//z8/B3/F//7+/v/p6en/4SEhP+MjIz/yMjIDf8X/8LCwv+BgYH/jo6O/05OTv8CAgJS/wAA
ABP/TU1N/5mZmf+Kior/vb29Cf8T/+Dg4P98fHz/tLS0//z8/Bn/G//n5+f/uLi4/46Ojv+K
ior/jIyM/9zc3A3/F//CwsL/gYGB/46Ojv9OTk7/AgICSv8AAAAz/xUVFf9GRkb/eHh4/5GR
kf+Li4v/nZ2d/8PDw//09PT/4eHh/3x8fP+0tLT//Pz8Df8n//f39//Z2dn/vb29/5qamv+F
hYX/i4uL/4aGhv+urq7//f39Df8X/8LCwv+BgYH/jo6O/05OTv8CAgJK/wAAAC//PDw8/6en
p/+VlZX/ioqK/4yMjP+Dg4P/goKC/9vb2//i4uL/fHx8/7W1tQn/K//j4+P/wsLC/6ioqP+R
kZH/hISE/4iIiP+Li4v/g4OD/6mpqf/v7+8R/xf/wsLC/4GBgf+Ojo7/Tk5O/wICAkr/AAAA
W/8XFxf/NjY2/2VlZf+Tk5P/i4uL/6urq//Nzc3/9fX1/+Li4v9+fn7/q6ur/8/Pz/+vr6//
l5eX/4iIiP+EhIT/iYmJ/4qKiv+Ghob/mJiY/8jIyP/09PQV/xf/wsLC/4GBgf+Ojo7/Tk5O
/wICAlL/AAAAE/9JSUn/mZmZ/4qKiv/BwcEJ/xP/0dHR/4SEhP+Pj4//kJCQCv+Hh4cb/4mJ
if+Li4v/j4+P/6mpqf/U1NT/8fHxHf8X/8LCwv+BgYH/jo6O/05OTv8CAgJS/wAAAEP/SUlJ
/5mZmf+Li4v/tra2/83Nzf+np6f/kZGR/4yMjP+Li4v/ioqK/4yMjP+Pj4//mpqa/8LCwv/o
6Oj/+fn5Jf8X/7a2tv+EhIT/j4+P/0dHR/8BAQFS/wAAABf/SkpK/5mZmf+MjIz/jY2N/4yM
jAr/ioqKDv+MjIwT/4+Pj/+rq6v/0dHR/9fX1wr/2dnZB//X19ca/9bW1hv/2tra/8fHx/+X
l5f/iYmJ/5KSkv8uLi5W/wAAAAv/S0tL/5qamgr/jIyMB/+Li4sa/4yMjAr/i4uLMv+KiooT
/4yMjP+UlJT/fHx8/w4ODlb/AAAAC/9KSkr/n5+fVv+WlpYX/5WVlf+Xl5f/lpaW/39/f/8q
Kipa/wAAAA//Hh4e/1hYWP9gYGBW/15eXg//X19f/09PT/8gICBm/wAAAAf/BQUFUv8EBAQL
/wUFBf8EBATirv8AAAA=' readStream) contents
]

{ #category : #icons }
SugarLibrary class >> languageIcon [

	^ Form extent: 50@50 depth: 32 bits: (Base64MimeConverter mimeDecodeToBytes: '6cTjPv8AAAAT/wgICP8rKyv/RkZG/1dXVxb/aWlpE/9gYGD/RkZG/ysrK/8RERGO/wAAAAv/
CAgI/2lpaTb/jIyME/96enr/V1dX/zQ0NP8ICAhG/wAAABP/CAgI/2lpaf+Dg4P/PT09Kv8A
AAAH/z09PUr/jIyMD/9gYGD/NDQ0/wgICDb/AAAAC/8rKyv/g4ODDv+MjIwq/wAAAAf/Tk5O
Ev+MjIwH/5OTkxb/qKioB/+Tk5Mq/4yMjA//YGBg/z09Pf8REREi/wAAAAv/ERER/2BgYBb/
jIyMKv8AAAAH/2lpaQr/jIyMC/+hoaH/8PDwHf8T//f39//i4uL/xcXF/6GhoSb/jIyMD/96
enr/V1dX/0ZGRgr/IyMjD/8rKyv/RkZG/3FxcRr/jIyMB/9xcXEq/wAAAAf/g4ODCv+MjIwH
/6+vrzH/D//39/f/09PT/6+vr1L/jIyMB/9gYGAm/wAAAAf/CAgIDv+MjIwH/8XFxT3/D//3
9/f/09PT/6+vrzb/jIyMB/+Tk5MO/4yMjAf/RkZGJv8AAAAH/yMjIw7/jIyMB//b29sJ/xP/
6enp/8zMzP+vr6//qKioGv+MjIwT/6ioqP+vr6//xcXF/+Li4gn/E//39/f/29vb/76+vv+o
qKga/4yMjBP/mpqa/7e3t//b29v/4uLiDv+MjIwH/ysrKwr/AAAAC/8aGhr/CAgIFv8AAAAH
/z09PQ7/jIyMD//p6en//////7e3tz7/jIyMD/+vr6//zMzM//Dw8A3/B//39/cO/+Li4hH/
B//MzMwO/4yMjBv/Ghoa/wgICP9gYGD/jIyM/4ODg/8aGhoS/wAAAAf/Tk5ODv+MjIwJ/07/
jIyMD/+hoaH/zMzM//Dw8CH/B/++vr4O/4yMjAv/IyMj/3p6eg7/jIyMB/9GRkYS/wAAAAf/
aWlpCv+MjIwP/6Ghof//////6enpEv+MjIwL/6ioqP++vr4S/8XFxQ//t7e3/6ioqP+Tk5Mm
/4yMjA//oaGh/8XFxf/i4uIV/wf/qKioIv+MjIwH/z09PRL/AAAAB/+Dg4MK/4yMjA//r6+v
///////b29sO/4yMjAf/4uLiJf8P/+np6f/MzMz/r6+vKv+MjIwL/6ioqP+3t7cK/8XFxQf/
k5OTIv+MjIwH/yMjIw7/AAAAB/8ICAgO/4yMjA//xcXF///////FxcUO/4yMjAf/9/f3Nf8P
/9vb2/+3t7f/k5OTTv+MjIwH/wgICA7/AAAAB/8jIyMO/4yMjA//29vb//////+vr68K/4yM
jAf/k5OTMf8j//f39//i4uL/29vb/8zMzP/i4uL/xcXF/7e3t/+Tk5Mu/4yMjAr/mpqaCv+M
jIwH/4ODgxL/AAAAB/89PT0O/4yMjA//6enp//////+hoaEK/4yMjAf/qKioKf8L/9PT0/+h
oaEa/4yMjB//mpqa/8XFxf/i4uL/zMzM/6+vr/+oqKj/k5OTCv+MjIwb/5qamv+oqKj/xcXF
/+np6f//////oaGhCv+MjIwH/2lpaRL/AAAAB/9OTk4O/4yMjAn/Dv+MjIwH/76+viH/C//b
29v/mpqaKv+MjIwL/5OTk//b29sp/w7/jIyMB/9OTk4S/wAAAAf/aWlpCv+MjIwP/6Ghof//
////6enpDv+MjIwH/8zMzB3/B/++vr4K/4yMjAv/mpqa/6ioqB7/jIyMB/+ampoK/4yMjAf/
09PTIf8H/+np6Q7/jIyMB/89PT0S/wAAAAf/g4ODCv+MjIwP/6+vr///////29vbDv+MjIwH
/+Li4hn/B/+3t7cK/4yMjAv/vr6+/8zMzAr/jIyMI/+3t7f/xcXF/4yMjP+vr6//k5OT/4yM
jP/FxcX/t7e3Cv+MjIwH/9vb2x3/B//b29sO/4yMjAf/IyMjDv8AAAAH/wgICA7/jIyMD//F
xcX//////8XFxQ7/jIyMB//39/cV/wf/09PTCv+MjIxH/9PT0//w8PD/k5OT/4yMjP+3t7f/
/////6+vr/+MjIz/zMzM/9vb2/+MjIz/k5OT//f39/+3t7f/jIyM/5OTk//39/cZ/wf/xcXF
Dv+MjIwH/wgICA7/AAAAB/8jIyMO/4yMjA//29vb//////+vr68K/4yMjAf/k5OTFf8j//f3
9/+Tk5P/jIyM/8XFxf//////t7e3/4yMjP+oqKgJ/y//oaGh/4yMjP/i4uL//////5qamv+M
jIz/09PT//////+ampr/jIyM/8zMzBn/B/+vr68K/4yMjAf/g4ODEv8AAAAH/z09PQ7/jIyM
D//p6en//////6GhoQr/jIyMB/+oqKgV/xf/t7e3/4yMjP+oqKj///////Dw8Ar/jIyMB//w
8PAJ/wr/jIyMJ//39/f//////8XFxf+MjIz/t7e3///////T09P/jIyM/5qamhn/B/+hoaEK
/4yMjAf/aWlpEv8AAAAH/05OTg7/jIyMCf8O/4yMjAf/vr6+Ef8j//f39/+Tk5P/jIyM/+Li
4v//////zMzM/4yMjP+vr68J/w//6enp/4yMjP+ampoJ/xf/4uLi/4yMjP+oqKj///////f3
9wr/jIyMB//39/cV/w7/jIyMB/9OTk4S/wAAAAf/aWlpCv+MjIwP/6Ghof//////6enpDv+M
jIwH/8zMzBH/B//b29sa/4yMjBv/qKio/+np6f//////09PT/4yMjP+oqKgJ/w//4uLi/4yM
jP+oqKgJ/w//qKio/4yMjP/i4uIR/wf/6enpDv+MjIwH/z09PRL/AAAAB/+Dg4MK/4yMjA//
r6+v///////b29sO/4yMjAf/4uLiEf8H/8XFxSL/jIyME/+ampr/oaGh/4yMjP/FxcUJ/w//
4uLi/4yMjP+oqKgJ/w//qKio/4yMjP/i4uIR/wf/29vbDv+MjIwH/yMjIw7/AAAAB/8ICAgO
/4yMjA//xcXF///////FxcUO/4yMjAf/9/f3Ef8P/6+vr/+MjIz/09PTCf8K/4yMjAv/t7e3
/5OTkw7/jIyMI/+hoaH/zMzM/+np6f/T09P/jIyM/6Ghof/T09P/t7e3Cv+MjIwH/+Li4hH/
B//FxcUO/4yMjAf/CAgIDv8AAAAH/yMjIw7/jIyMD//b29v//////6+vrwr/jIyMB/+Tk5MV
/w//qKio/4yMjP/i4uIJ/wr/jIyMCf8H/9PT0zL/jIyMB//p6ekR/wf/r6+vCv+MjIwH/4OD
gxL/AAAAB/89PT0O/4yMjA//6enp//////+hoaEK/4yMjAf/qKioFf8P/6+vr/+MjIz/zMzM
Cf8K/4yMjAn/B//39/cK/4yMjA//zMzM/6ioqP+Tk5MO/4yMjBP/qKio/6+vr/+MjIz/k5OT
Ff8H/6GhoQr/jIyMB/9paWkS/wAAAAf/Tk5ODv+MjIwL/8XFxf+oqKgO/4yMjAf/vr6+Ff8P
/8XFxf+MjIz/t7e3Cf8K/4yMjAn/D//i4uL/jIyM/6GhoQn/B//39/cK/4yMjBf/8PDw////
//++vr7/jIyM/7e3txX/Dv+MjIwH/05OThL/AAAAB/9paWki/4yMjAf/zMzMFf8P/+Li4v+M
jIz/k5OTCf8K/4yMjBf/8PDw///////MzMz/jIyM/6+vrwn/I//FxcX/jIyM/6ioqP//////
8PDw/5OTk/+MjIz/4uLiEf8H/+np6Q7/jIyMB/89PT0S/wAAAAf/g4ODIv+MjIwH/+Li4hn/
N/+ampr/jIyM/8zMzP//////r6+v/4yMjP/MzMz//////76+vv+MjIz/xcXF///////p6ekK
/4yMjBf/4uLi//////+oqKj/jIyM/6ioqBX/B//b29sO/4yMjAf/IyMjEv8AAAAH/3p6ehL/
jIyMB/+Dg4MO/4yMjAf/9/f3Gf9T/9PT0/+MjIz/k5OT/+np6f/T09P/jIyM/5qamv//////
qKio/4yMjP/b29v/9/f3/5OTk/+MjIz/r6+v//////+3t7f/jIyM/5OTk//w8PAV/wf/xcXF
Dv+MjIwH/wgICBL/AAAAG/8RERH/RkZG/z09Pf8jIyP/AAAA/2BgYAr/jIyMB/+Tk5Mh/z//
qKio/4yMjP+Tk5P/6enp/5qamv+MjIz/vr6+/5OTk/+MjIz/29vb/5qamv+MjIz/oaGh//Dw
8P+vr68K/4yMjAf/09PTGf8H/6+vrwr/jIyMB/+Dg4Mq/wAAAAf/cXFxCv+MjIwH/6ioqCH/
F//39/f/oaGh/4yMjP+Tk5P/oaGhEv+MjIwj/5OTk/+MjIz/mpqa/76+vv+Tk5P/jIyM/5OT
k//T09Md/wf/oaGhCv+MjIwH/2lpaSr/AAAADv+MjIwH/76+viX/C//39/f/qKioLv+MjIwL
/6Ghof/p6ekh/w7/jIyMB/9OTk4m/wAAAAf/GhoaDv+MjIwK/5qamhb/jIyMH/+ampr/qKio
/76+vv/T09P/8PDw/9PT0/+hoaEe/4yMjAv/oaGh/9PT0yX/B//p6ekO/4yMjAf/PT09Jv8A
AAAH/ysrKz7/jIyME/+ampr/vr6+/8zMzP/T09MO/8XFxQv/29vb//Dw8C3/B//MzMwO/4yM
jAf/IyMjJv8AAAAH/0ZGRkr/jIyMD/+Tk5P/t7e3/9vb2zH/C//39/f/vr6+Ev+MjIwH/wgI
CCb/AAAAB/8jIyMO/4yMjAv/enp6/2BgYBb/RkZGC/9paWn/cXFxJv+MjIwT/5OTk/+3t7f/
09PT//Dw8Bn/D//39/f/zMzM/5qamhL/jIyMB/9paWku/wAAAA//Ghoa/yMjI/8ICAgm/wAA
ABP/CAgI/ysrK/9OTk7/enp6Jv+MjIwL/5qamv+oqKgK/8XFxQv/vr6+/6ioqBr/jIyMC/9p
aWn/CAgIbv8AAAAP/xEREf89PT3/cXFxQv+MjIwL/4ODg/9GRkaC/wAAAA//ERER/z09Pf9x
cXEy/4yMjAv/V1dX/xEREZL/AAAAF/8ICAj/Kysr/05OTv9paWn/cXFxDv+MjIwT/2lpaf9X
V1f/NDQ0/wgICONK/wAAAA==' readStream) contents
]

{ #category : #'singleton management' }
SugarLibrary class >> mimeStringFor: aForm [

	aForm hibernate.
	^ (Base64MimeConverter mimeEncode: aForm bits readStream) contents.

]

{ #category : #icons }
SugarLibrary class >> miniPrivateIcon [

	^ Form extent: 36@36 depth: 32 bits: (Base64MimeConverter mimeDecodeToBytes: '5RA6/wAAAQv/ExMT/x4eHg7/ICAgC/8eHh7/ExMTav8AAAE3/x4eHv8gICD/MzMz/4mJif/K
ysr/3d3d/9/f3//d3d3/ysrK/4mJif8zMzP/ICAg/x0dHVb/AAABH/8eHh7/PT09/7a2tv/d
3d3/39/f//Ly8v/9/f0N/x///f39//Ly8v/f39//3d3d/7a2tv89PT3/Hh4eRv8AAAEX/wgI
CP8+Pj7/ubm5/97e3v/9/f0t/xf//f39/97e3v+5ubn/Pj4+/wgICDr/AAABE/8eHh7/YGBg
/8fHx//9/f09/xP//f39/8fHx/9gYGD/Hh4eMv8AAAEP/ysrK/+Xl5f/3d3dTf8P/93d3f+X
l5f/LCwsKv8AAAEP/x4eHv+Xl5f/6+vrVf8P/+vr6/+YmJj/Hh4eIv8AAAEP/wgICP9gYGD/
3d3dXf8P/93d3f9gYGD/CAgIHv8AAAEL/z4+Pv/Hx8dl/wv/x8fH/z4+Phr/AAABD/8eHh7/
ubm5//39/WX/D//9/f3/ubm5/x4eHhb/AAABC/89PT3/3t7ebf8L/93d3f89PT0S/wAAAQ//
HR0d/7a2tv/9/f1t/w///f39/7a2tv8eHh4O/wAAAQv/ICAg/93d3XX/C//d3d3/ICAgDv8A
AAEL/zMzM//f398x/wf//f39Dv/p6ekH//39/TH/C//f39//MzMzCv8AAAEP/xMTE/+JiYn/
8vLyLf8f//Dw8P+Pj4//MTEx/x0dHf8xMTH/j4+P//Dw8C3/H//y8vL/iYmJ/xMTE/8AAAH/
Hh4e/8rKyv/9/f0p/w///f39/4+Pj/8iIiIO/wAAAQ//IiIi/4+Pj//9/f0p/xv//f39/8rK
yv8eHh7/AAAB/yAgIP/d3d0t/wv/6enp/zExMRb/AAABC/8xMTH/6enpLf8X/93d3f8gICD/
AAAB/yAgIP/f398t/wv/6enp/x0dHRb/AAABC/8dHR3/6enpLf8X/9/f3/8gICD/AAAB/yAg
IP/d3d0t/wv/6enp/zIyMhb/AAABC/8yMjL/6enpLf8b/93d3f8gICD/AAAB/x4eHv/Kysr/
/f39Lf8L/5iYmP8kJCQO/wAAAQv/JCQk/5iYmC3/H//9/f3/ysrK/x4eHv8AAAH/ExMT/4qK
iv/y8vIt/x//8vLy/4+Pj/8xMTH/HR0d/zExMf+Pj4//8vLyLf8P//Ly8v+JiYn/ExMTCv8A
AAEL/zMzM//f398x/wf//f39Dv/p6ekH//39/TH/C//f39//MzMzDv8AAAEL/yAgIP/d3d11
/wv/3d3d/yAgIA7/AAABD/8dHR3/tra2//39/W3/D//9/f3/tra2/x4eHhL/AAABC/89PT3/
3t7ebf8L/97e3v89PT0W/wAAAQ//Hh4e/7m5uf/9/f1l/w///f39/7m5uf8eHh4a/wAAAQv/
Pj4+/8fHx2X/C//Hx8f/Pj4+Hv8AAAEP/wgICP9gYGD/3d3dXf8P/93d3f9gYGD/CAgIIv8A
AAEP/x4eHv+Xl5f/6+vrVf8P/+vr6/+Xl5f/Hh4eKv8AAAEP/ysrK/+Xl5f/3d3dTf8P/93d
3f+Xl5f/KysrMv8AAAET/x4eHv9gYGD/x8fH//39/T3/E//9/f3/x8fH/2BgYP8eHh46/wAA
ARf/CAgI/z4+Pv+5ubn/3t7e//39/S3/F//9/f3/3t7e/7m5uf8+Pj7/CAgIRv8AAAEf/x4e
Hv89PT3/tra2/93d3f/f39//8vLy//39/Q3/H//9/f3/8vLy/9/f3//d3d3/tra2/z09Pf8e
Hh5W/wAAATf/Hh4e/yAgIP8zMzP/iYmJ/8rKyv/d3d3/39/f/93d3f/Kysr/iYmJ/zMzM/8g
ICD/Hh4eav8AAAEL/xMTE/8eHh4O/yAgIAv/Hh4e/xMTE87/AAAB' readStream) contents
]

{ #category : #icons }
SugarLibrary class >> miniShareIcon [

	^ Form extent: 36@36 depth: 32 bits: (Base64MimeConverter mimeDecodeToBytes: '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
ExPO/wAAAQ==' readStream) contents
]

{ #category : #'singleton management' }
SugarLibrary class >> newDefault [
	"Answer a new instance of SugarLibrary."

	| i |
	i := SugarLibrary new.
	i iconAt: 'new' put: self newIcon.
	i iconAt: 'prev' put: self prevIcon.
	i iconAt: 'next' put: self nextIcon.
	i iconAt: 'save' put: self saveIcon.
	i iconAt: 'open' put: self openIcon.
	i iconAt: 'keep' put: self keepIcon.
	i iconAt: 'choose' put: self chooseIcon.
	i iconAt: 'paint' put: self paintIcon.
	i iconAt: 'language' put: self languageIcon.
	i iconAt: 'undo' put: self undoIcon.
	i iconAt: 'close' put: self closeIcon.
	i iconAt: 'share' put: self shareIcon.
	i iconAt: 'miniShare' put: self miniShareIcon.
	i iconAt: 'supplies' put: self suppliesIcon.
	i iconAt: 'stop' put: self stopIcon.
	i iconAt: 'zoom' put: self zoomIcon.
	i iconAt: 'help' put: self helpIcon.
	i iconAt: 'miniPrivate' put: self miniPrivateIcon.
	i iconAt: 'private' put: self privateIcon.
	i iconAt: 'hideNavBar' put: self hideNavBarIcon.
	i iconAt: 'showNavBar' put: self showNavBarIcon.

	i iconAt: 'newProject' put: (i iconAt: 'new').
	i iconAt: 'previousProject' put: (i iconAt: 'prev').
	i iconAt: 'nextProject' put: (i iconAt: 'next').
	i iconAt: 'publishProject' put: (i iconAt: 'save').
	i iconAt: 'publishSexp' put: (i iconAt: 'save').
	i iconAt: 'findAProjectSimple' put: (i iconAt: 'open').
	i iconAt: 'loadASexp' put: (i iconAt: 'open').
	i iconAt: 'publishProject' put: (i iconAt: 'save').
	i iconAt: 'keepProject' put: (i iconAt: 'keep').
	i iconAt: 'chooseObject' put: (i iconAt: 'choose').
	i iconAt: 'doNewPainting' put: (i iconAt: 'paint').
	i iconAt: 'chooseLanguage' put: (i iconAt: 'language').
	i iconAt: 'undoOrRedoLastCommand' put: (i iconAt: 'undo').
	i iconAt: 'toggleSupplies' put: (i iconAt: 'supplies').
	i iconAt: 'quitSqueak' put: (i iconAt: 'close').
	i iconAt: 'shareThisWorld' put: (i iconAt: 'share').
	i iconAt: 'shareMenu' put: (i iconAt: 'private').
	i iconAt: 'chooseScreenSetting' put: (i iconAt: 'zoom').
	i iconAt: 'stopSqueak' put: (i iconAt: 'stop').
	i iconAt: 'toggleHelp' put: (i iconAt: 'help'). 
	i iconAt: 'gotoAnother' put: (i iconAt: 'choose').

	i iconAt: 'missingIcon' put: (i iconAt: 'private'). 

	^  i

]

{ #category : #icons }
SugarLibrary class >> newIcon [

	^ Form extent: 50@50 depth: 32 bits: (Base64MimeConverter mimeDecodeToBytes: '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' readStream) contents
]

{ #category : #icons }
SugarLibrary class >> nextIcon [

	^ Form extent: 50@50 depth: 32 bits: (Base64MimeConverter mimeDecodeToBytes: '6cTiXv8AAAAH/z8/P2n/E/+/v7//n5+f/19fX/8PDw9O/wAAAAf/Pz8/ef8L/6+vr/9fX19G
/wAAAAf/Pz8/gf8L/9/f3/9fX18+/wAAAAf/Pz8/if8L/7+/v/8vLy82/wAAAAf/Pz8/jf8L
/+/v7/9fX18y/wAAAAf/Pz8/lf8H/5+fny7/AAAAB/8/Pz+Z/wf/n5+fKv8AAAAH/z8/P53/
B/+fn58m/wAAAAf/Pz8/of8H/19fXyL/AAAAB/8/Pz+h/wv/7+/v/y8vLx7/AAAAB/8/Pz+l
/wf/z8/PHv8AAAAH/z8/P6n/B/9fX18a/wAAAAf/Pz8/Pf8L/7y8vP/d3d1l/wf/39/fGv8A
AAAH/z8/Pz3/D/+mpqb/TU1N/6ampmX/B/9fX18W/wAAAAf/Pz8/Pf8H/6ampgr/TU1NC/9u
bm7/3d3dXf8H/8/Pzxb/AAAAB/8/Pz89/wf/pqamEv9NTU0H/7GxsV3/B/8fHx8S/wAAAAf/
Pz8/Pf8H/6amphb/TU1NC/95eXn/6OjoVf8H/29vbxL/AAAAB/8/Pz89/wf/pqamGv9NTU0L
/1hYWP+8vLxR/wf/r6+vEv8AAAAH/z8/Pz3/B/+mpqYi/01NTQv/hISE//Pz80n/B//f398S
/wAAAAf/Pz8/Pf8H/6ampib/TU1NC/9YWFj/x8fHSf8S/wAAAAf/Pz8/Pf8H/6ampi7/TU1N
C/+Pj4//8/PzQf8H/w8PDw7/AAAAB/8/Pz89/wf/pqamMv9NTU0L/2NjY//S0tI9/wf/Pz8/
Dv8AAAAH/z8/Pz3/B/+mpqY6/01NTQf/mpqaOf8H/z8/Pw7/AAAAB/8/Pz89/wf/pqamNv9N
TU0L/1hYWP/S0tI5/wf/Pz8/Dv8AAAAH/z8/Pz3/B/+mpqYy/01NTQv/hISE//Pz8z3/B/8P
Dw8O/wAAAAf/Pz8/Pf8H/6ampir/TU1NC/9YWFj/x8fHRf8S/wAAAAf/Pz8/Pf8H/6ampib/
TU1NC/95eXn/6OjoRf8H/9/f3xL/AAAAB/8/Pz89/wf/pqamHv9NTU0L/1hYWP+xsbFN/wf/
r6+vEv8AAAAH/z8/Pz3/B/+mpqYa/01NTQv/bm5u/+jo6FH/B/9vb28S/wAAAAf/Pz8/Pf8H
/6amphb/TU1NB/+mpqZZ/wf/Hx8fEv8AAAAH/z8/Pz3/B/+mpqYO/01NTQv/bm5u/93d3Vn/
B//Pz88W/wAAAAf/Pz8/Pf8H/6ampgr/TU1NC/+ampr/8/PzXf8H/19fXxb/AAAAB/8/Pz89
/w//pqam/2NjY//S0tJh/wf/39/fGv8AAAAH/z8/Pz3/C//S0tL/8/PzZf8H/19fXxr/AAAA
B/8/Pz+l/wf/z8/PHv8AAAAH/z8/P6H/C//v7+//Ly8vHv8AAAAH/z8/P6H/B/9fX18i/wAA
AAf/Pz8/nf8H/5+fnyb/AAAAB/8/Pz+Z/wf/n5+fKv8AAAAH/z8/P5X/B/+fn58u/wAAAAf/
Pz8/jf8L/+/v7/9fX18y/wAAAAf/Pz8/if8L/7+/v/8vLy82/wAAAAf/Pz8/gf8L/9/f3/9f
X18+/wAAAAf/Pz8/ef8L/6+vr/9fX19G/wAAAAf/Pz8/af8T/7+/v/+fn5//X19f/w8PD+Ha
/wAAAA==' readStream) contents
]

{ #category : #icons }
SugarLibrary class >> openIcon [

	^ Form extent: 50@50 depth: 32 bits: (Base64MimeConverter mimeDecodeToBytes: '6cThZv8AAAAv/xISEv8zMzP/SUlJ/19fX/91dXX/ioqK/6CgoP+2trb/zMzM/66urv8aGhqa
/wAAAAv/UFBQ//X19SX/B/94eHia/wAAAAf/jo6OKf8H/35+fpr/AAAAG/8SEhL/oKCg/6Gh
of+MjIz/d3d3/7m5uRX/B/9oaGiq/wAAAAf/fHx8Gf8H/1JSUqL/AAAAC/8BAQH/ampqCf8P
//7+/v//////8fHxCf8H/zw8PKL/AAAAK/9aWlr//v7+///////+/v7//////+Tk5P+6urr/
//////7+/v8nJyee/wAAAAv/SkpK//39/Q3/D//r6+v/DAwM/83NzQn/B/8RERGa/wAAAAv/
Ojo6//z8/A3/G//x8fH/FBQU/wAAAP/i4uL///////r6+pr/AAAAC/8fHx//+vr6Df8L//b2
9v8dHR0K/wAAAA//9/f3///////m5uaa/wAAAAv/oqKi//7+/gn/C//5+fn/KCgoDv8AAAAP
/8PDw///////qampgv8AAAAH/wEBARb/AAAAB/+Ojo4J/wv/+/v7/zc3NxL/AAAAD/8RERH/
TExM/wQEBDr/AAAAB/8BAQEy/wAAAAf/AQEBLv8AAAAP/5iYmP++vr7/MTEx0v8AAAAH/wEB
ATr/AAAAD/8gICD/bm5u/5SUlBr/qKioE/+kpKT/hISE/1NTU/8JCQmS/wAAAAv/QEBA/6qq
qg7/ra2tB/+srKwW/62trRP/rKys/66urv+QkJD/EBAQNv8AAAAH/wEBAVL/AAAAE/8YGBj/
qamp/62trf+urq4K/62trQf/rq6uIv+tra0H/3l5eTL/AAAAB/8BAQEO/wAAAAf/AQEBRv8A
AAAH/25ubg7/ra2tC/+/v7//0tLSFv/T09Mb/83Nzf+zs7P/rq6u/62trf+urq7/GxsbKv8A
AAAH/wEBAVL/AAAAD/8BAQH/AAAA/5mZmQr/ra2tB/+/v78h/wf/7OzsDv+tra0P/6qqqv+o
qKj/qampFv+oqKgO/6mpqRf/qKio/6Ojo/+CgoL/SEhI/wEBAUb/AAAAB/8HBwcO/62trQf/
2NjYIf8H//7+/kr/ra2tC/+CgoL/CQkJQv8AAAAH/wsLCw7/ra2tB//c3Nwl/w//y8vL/62t
rf+srKxC/62trQf/c3NzQv8AAAAH/wsLCw7/ra2tB//b29sl/wv/+vr6/9vb2w7/09PTC//S
0tL/1NTUIv/T09Mb/8zMzP+vr6//ra2t/66urv+tra3/IyMjIv8AAAAH/wEBARr/AAAAB/8L
CwsO/62trQf/29vbMf8H//7+/in/D//+/v7//////+rq6g7/ra2tB/9TU1M+/wAAAAf/CwsL
Dv+tra0H/9zc3Gn/B/+0tLQK/62trQf/ZmZmEv8AAAAH/wEBASr/AAAAB/8KCgoO/62trQf/
29vbUf8H//7+/hX/B/+1tbUK/62trQf/ZmZmPv8AAAAH/wsLCw7/ra2tB//b29sN/xf/+Pj4
/9bW1v/FxcX/v7+//76+vgr/v7+/D/++vr7/v7+//8DAwBb/v7+/B/++vr4e/7+/vwf/sLCw
Cv+tra0b/5mZmf+IiIj/h4eH/3R0dP9JSUn/BQUFKv8AAAAH/wsLCw7/ra2tB//b29sJ/wv/
5eXl/7Kysgr/ra2tB/+urq4K/62trQf/rKysLv+tra0H/66urg7/ra2tB/+urq4i/62trQv/
kpKS/xISEib/AAAAB/8LCwsO/62trRP/29vb///////y8vL/sLCwev+tra0X/6ysrP+tra3/
e3t7/wAAAP8BAQEe/wAAAAf/CwsLDv+tra0f/9ra2v/+/v7/vr6+/62trf+urq7/ra2t/7e3
t1b/xMTEB//Dw8MO/8TExAv/w8PD/7Ozsw7/ra2tB/8SEhIi/wAAAAf/CwsLDv+tra0L/9vb
2//c3NwO/62trQv/wsLC//7+/mn/B//j4+MO/62trQf/ISEhHv8AAAAP/wEBAf8LCwv/rKys
Cv+tra0L/9vb2/+9vb0K/62trQv/sbGx//X19W3/B//U1NQO/62trQf/GhoaIv8AAAAH/wsL
Cw7/ra2tB//X19cK/62trQv/rKys/9HR0W3/C//8/Pz/s7OzCv+tra0L/5SUlP8BAQEi/wAA
AAf/CwsLDv+tra0H/8nJyQ7/ra2tB//q6upt/wf/3d3dDv+tra0H/0dHRyb/AAAAB/8LCwsO
/62trQf/u7u7Cv+tra0L/7Gxsf/9/f1Z/wf//v7+Df8L//7+/v+5ubkK/62trQv/oKCg/wcH
Byb/AAAAB/8LCwsO/62trQf/r6+vCv+tra0H/8nJyRn/B//+/v5R/wf/5ubmDv+tra0H/1pa
Wir/AAAAB/8LCwsa/62trQf/4eHhbf8H/8DAwAr/ra2tE/+oqKj/EBAQ/wAAAP8BAQEi/wAA
AAf/CwsLFv+tra0L/66urv/6+vpp/wf/7u7uDv+tra0H/2pqai7/AAAAB/8LCwsS/62trQv/
rq6u/8DAwA3/B//+/v5d/xf/ycnJ/66urv+tra3/rq6u/x4eHi7/AAAAB/8LCwsW/62trQf/
2NjYaf8L//X19f+urq4K/62trQf/fX19Mv8AAAAH/wsLCwr/ra2tB/+srKwK/62trQf/8fHx
af8H/9HR0Q7/ra2tB/8vLy8y/wAAAAf/CwsLEv+tra0H/7e3t2n/C//6+vr/sbGxCv+tra0H
/46Ojjb/AAAAC/8LCwv/rq6uDv+tra0H/8/Pz2n/B//a2toK/62trQv/rq6u/0BAQBr/AAAA
B/8BAQEa/wAAAAf/CwsLEv+tra0H/+jo6Gn/B/+2trYK/62trQv/nJyc/wQEBDb/AAAAB/8L
CwsS/62trQf/x8fHZv/JyckH/8TExA7/ra2tB/9TU1M6/wAAAAf/CwsLev+tra0H/66urgr/
ra2tC/+mpqb/DAwMOv8AAAAL/wEBAf+qqqp2/62trQf/rKysCv+tra0H/2RkZD7/AAAAE/8B
AQH/S0tL/6CgoP+fn59y/5OTkw//kZGR/11dXf8LCwvhuv8AAAA=' readStream) contents
]

{ #category : #icons }
SugarLibrary class >> paintIcon [

	^ Form extent: 50@50 depth: 32 bits: (Base64MimeConverter mimeDecodeToBytes: '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
aWkP/2BgYP80NDT/CAgI4ar/AAAA' readStream) contents
]

{ #category : #icons }
SugarLibrary class >> prevIcon [

	^ Form extent: 50@50 depth: 32 bits: (Base64MimeConverter mimeDecodeToBytes: '6cTiov8AAAAT/w8PD/9fX1//n5+f/7+/v2n/B/8/Pz9G/wAAAAv/X19f/6+vr3n/B/8/Pz8+
/wAAAAv/X19f/9/f34H/B/8/Pz82/wAAAAv/Ly8v/7+/v4n/B/8/Pz8y/wAAAAv/X19f/+/v
743/B/8/Pz8u/wAAAAf/n5+flf8H/z8/Pyr/AAAAB/+fn5+Z/wf/Pz8/Jv8AAAAH/5+fn53/
B/8/Pz8i/wAAAAf/X19fof8H/z8/Px7/AAAAC/8vLy//7+/vof8H/z8/Px7/AAAAB//Pz8+l
/wf/Pz8/Gv8AAAAH/19fX6n/B/8/Pz8a/wAAAAf/39/fZf8L/93d3f+8vLw9/wf/Pz8/Fv8A
AAAH/19fX2X/D/+mpqb/TU1N/6ampj3/B/8/Pz8W/wAAAAf/z8/PXf8L/93d3f9ubm4K/01N
TQf/pqamPf8H/z8/PxL/AAAAB/8fHx9d/wf/sbGxEv9NTU0H/6ampj3/B/8/Pz8S/wAAAAf/
b29vVf8L/+jo6P95eXkW/01NTQf/pqamPf8H/z8/PxL/AAAAB/+vr69R/wv/vLy8/1hYWBr/
TU1NB/+mpqY9/wf/Pz8/Ev8AAAAH/9/f30n/C//z8/P/hISEIv9NTU0H/6ampj3/B/8/Pz8S
/wAAAEn/C//Hx8f/WFhYJv9NTU0H/6ampj3/B/8/Pz8O/wAAAAf/Dw8PQf8L//Pz8/+Pj48u
/01NTQf/pqamPf8H/z8/Pw7/AAAAB/8/Pz89/wv/0tLS/2NjYzL/TU1NB/+mpqY9/wf/Pz8/
Dv8AAAAH/z8/Pzn/B/+ampo6/01NTQf/pqamPf8H/z8/Pw7/AAAAB/8/Pz85/wv/0tLS/1hY
WDb/TU1NB/+mpqY9/wf/Pz8/Dv8AAAAH/w8PDz3/C//z8/P/hISEMv9NTU0H/6ampj3/B/8/
Pz8S/wAAAEX/C//Hx8f/WFhYKv9NTU0H/6ampj3/B/8/Pz8S/wAAAAf/39/fRf8L/+jo6P95
eXkm/01NTQf/pqamPf8H/z8/PxL/AAAAB/+vr69N/wv/sbGx/1hYWB7/TU1NB/+mpqY9/wf/
Pz8/Ev8AAAAH/29vb1H/C//o6Oj/bm5uGv9NTU0H/6ampj3/B/8/Pz8S/wAAAAf/Hx8fWf8H
/6amphb/TU1NB/+mpqY9/wf/Pz8/Fv8AAAAH/8/Pz1n/C//d3d3/bm5uDv9NTU0H/6ampj3/
B/8/Pz8W/wAAAAf/X19fXf8L//Pz8/+ampoK/01NTQf/pqamPf8H/z8/Pxr/AAAAB//f399h
/w//0tLS/2NjY/+mpqY9/wf/Pz8/Gv8AAAAH/19fX2X/C//z8/P/0tLSPf8H/z8/Px7/AAAA
B//Pz8+l/wf/Pz8/Hv8AAAAL/y8vL//v7++h/wf/Pz8/Iv8AAAAH/19fX6H/B/8/Pz8m/wAA
AAf/n5+fnf8H/z8/Pyr/AAAAB/+fn5+Z/wf/Pz8/Lv8AAAAH/5+fn5X/B/8/Pz8y/wAAAAv/
X19f/+/v743/B/8/Pz82/wAAAAv/Ly8v/7+/v4n/B/8/Pz8+/wAAAAv/X19f/9/f34H/B/8/
Pz9G/wAAAAv/X19f/6+vr3n/B/8/Pz9O/wAAABP/Dw8P/19fX/+fn5//v7+/af8H/z8/P+GW
/wAAAA==' readStream) contents
]

{ #category : #icons }
SugarLibrary class >> privateIcon [

	^ Form extent: 50@50 depth: 32 bits: (Base64MimeConverter mimeDecodeToBytes: '6cTiov8AAAET/w8PD/9fX1//j4+P/7+/vx3/E/+/v7//j4+P/19fX/8PDw+G/wAAAQv/T09P
/6+vrz3/C/+vr6//T09Pdv8AAAEL/09PT//f399N/wv/39/f/09PT2b/AAABC/8fHx//v7+/
Xf8L/7+/v/8fHx9a/wAAAQv/X19f/+/v72X/C//v7+//X19fUv8AAAEH/39/f3X/B/9/f39K
/wAAAQf/n5+fff8H/5+fn0L/AAABB/9/f39R/wf//v7+Mf8H/39/fzr/AAABB/9fX1+N/wf/
X19fMv8AAAEL/x8fH//v7+91/wf//f39Ff8L/+/v7/8fHx8u/wAAAQf/v7+/lf8H/7+/vyr/
AAABB/9PT0+d/wf/T09PJv8AAAEH/9/f353/B//f398i/wAAAQf/T09Ppf8H/09PTx7/AAAB
B/+vr6+l/wf/r6+vGv8AAAEH/w8PD63/B/8PDw8W/wAAAQf/X19frf8H/19fXxb/AAABB/+f
n59J/x///f39/+vr6//Y2Nj/0tLS/9vb2//v7+///v7+Sf8H/4+Pjxb/AAABB/+/v79J/yP/
1dXV/4aGhv9LS0v/Nzc3/0lJSf+IiIj/2tra//7+/kX/B/+/v78W/wAAAUX/L//7+/v/09PT
/3p6ev8mJib/BgYG/wICAv8FBQX/IiIi/3d3d//b29v//v7+Rf8W/wAAAUX/E//r6+v/hYWF
/ycnJ/8DAwMO/wAAARP/AQEB/yMjI/+Dg4P/7e3tRf8W/wAAAUX/D//a2tr/TU1N/wYGBhb/
AAABD/8CAgL/PDw8/8rKykX/Ev8AAAEH/x8fH0X/D//T09P/NDQ0/wEBARr/AAABC/8eHh7/
tra2Rf8W/wAAAUX/C//V1dX/PT09Hv8AAAEL/yoqKv++vr5F/xb/AAABRf8P/+fn5/9xcXH/
FhYWFv8AAAEP/xQUFP9paWn/29vbRf8W/wAAAUX/E//7+/v/w8PD/2FhYf8ZGRkO/wAAARP/
FBQU/15eXv/AwMD/+fn5Rf8W/wAAAQf/v7+/Rf8n//n5+f/CwsL/aWlp/y0tLf8ZGRn/Kioq
/2lpaf/BwcH/9/f3Rf8H/7+/vxb/AAABB/+Pj49J/x///Pz8/97e3v+9vb3/srKy/7y8vP/a
2tr/+fn5Sf8H/4+Pjxb/AAABB/9fX1+t/wf/X19fFv8AAAEH/w8PD63/B/8PDw8a/wAAAQf/
r6+vpf8H/6+vrx7/AAABB/9PT0+l/wf/T09PIv8AAAEH/9/f353/B//f398m/wAAAQf/T09P
nf8H/09PTyr/AAABB/+/v7+V/wf/v7+/Lv8AAAEL/x8fH//v7+91/wf/9PT0Ff8L/+/v7/8f
Hx8y/wAAAQf/X19fdf8H//39/RX/B/9fX186/wAAAQf/f39/hf8H/39/f0L/AAABB/+fn599
/wf/n5+fSv8AAAEH/39/f3X/B/9/f39S/wAAAQv/X19f/+/v7y3/Dv/7+/st/wv/7+/v/19f
X1r/AAABC/8fHx//v7+/Xf8L/7+/v/8fHx9m/wAAAQv/T09P/9/f303/C//f39//T09Pdv8A
AAEL/09PT/+vr689/wv/r6+v/09PT4b/AAABH/8PDw//X19f/4+Pj/+/v7////////n5+f/9
/f0R/xP/v7+//4+Pj/9fX1//Dw8P4db/AAAB' readStream) contents
]

{ #category : #icons }
SugarLibrary class >> saveIcon [

	^ Form extent: 50@50 depth: 32 bits: (Base64MimeConverter mimeDecodeToBytes: '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
AQEBIv8AAAAH/wsLCxb/ra2tC/+urq7/+vr6af8H/+7u7g7/ra2tB/9qamou/wAAAAf/CwsL
Ev+tra0L/66urv/AwMAN/wf//v7+Xf8X/8nJyf+urq7/ra2t/66urv8eHh4u/wAAAAf/CwsL
Fv+tra0H/9jY2Gn/C//19fX/rq6uCv+tra0H/319fTL/AAAAB/8LCwsK/62trQf/rKysCv+t
ra0H//Hx8Wn/B//R0dEO/62trQf/Ly8vMv8AAAAH/wsLCxL/ra2tB/+3t7dp/wv/+vr6/7Gx
sQr/ra2tB/+Ojo42/wAAAAv/CwsL/66urg7/ra2tB//Pz89p/wf/2traCv+tra0L/66urv9A
QEAa/wAAAAf/AQEBGv8AAAAH/wsLCxL/ra2tB//o6Ohp/wf/tra2Cv+tra0L/5ycnP8EBAQ2
/wAAAAf/CwsLEv+tra0H/8fHx2b/ycnJB//ExMQO/62trQf/U1NTOv8AAAAH/wsLC3r/ra2t
B/+urq4K/62trQv/pqam/wwMDDr/AAAAC/8BAQH/qqqqdv+tra0H/6ysrAr/ra2tB/9kZGQ+
/wAAABP/AQEB/0tLS/+goKD/n5+fcv+Tk5MP/5GRkf9dXV3/CwsL4br/AAAA' readStream) contents
]

{ #category : #icons }
SugarLibrary class >> shareIcon [

	^ Form extent: 50@50 depth: 32 bits: (Base64MimeConverter mimeDecodeToBytes: '6cTiov8AAAAT/w8PD/9fX1//j4+P/7+/vx3/E/+/v7//j4+P/19fX/8PDw+G/wAAAAv/T09P
/6+vrz3/C/+vr6//T09Pdv8AAAAL/09PT//f399N/wv/39/f/09PT2b/AAAAC/8fHx//v7+/
Xf8L/7+/v/8fHx9a/wAAAAv/X19f/+/v7y3/Dv/7+/st/wv/7+/v/19fX1L/AAAAB/9/f38x
/xf/mZmZ/zU1Nf8gICD/NTU1/5mZmTH/B/9/f39K/wAAAAf/n5+fMf8L/5mZmf8nJycO/wAA
AAv/Jycn/5mZmTH/B/+fn59C/wAAAAf/f39/Mf8L//v7+/81NTUW/wAAAAv/NTU1//v7+zH/
B/9/f386/wAAAAf/X19fHf8K//v7+xH/C//7+/v/IyMjFv8AAAAL/yMjI//7+/sV/wf//f39
Hf8H/19fXzL/AAAAC/8fHx//7+/vFf8b/6mpqf9FRUX/IyMj/ywsLP91dXX/8fHxDf8H/0dH
Rxb/AAAAB/9HR0cR/xf/5OTk/4CAgP85OTn/ZWVl/9LS0hX/C//v7+//Hx8fLv8AAAAH/7+/
vxX/C//S0tL/NTU1Dv8AAAAL/xUVFf91dXUN/wv/tLS0/zIyMg7/AAAAC/8yMjL/tLS0Df8f
/9/f3/9FRUX/CgoK/wAAAP8FBQX/NTU1/6mpqRX/B/+/v78q/wAAAAf/T09PGf8L/2VlZf8F
BQUS/wAAAAv/LCws//v7+w3/F/+0tLT/R0dH/ycnJ/9HR0f/tLS0Ef8L/2lpaf8FBQUS/wAA
AAf/RUVFGf8H/09PTyb/AAAAB//f398V/wv//f39/zU1NRb/AAAAC/8gICD/+/v7Ff8H//39
/RX/C//9/f3/LCwsFv8AAAAL/yMjI//7+/sV/wf/39/fIv8AAAAH/09PTx3/C/91dXX/CQkJ
Ev8AAAAL/zQ0NP/7+/sx/wf/RUVFFv8AAAAL/ywsLP/7+/sZ/wf/T09PHv8AAAAH/6+vrx3/
D//i4uL/RUVF/wUFBQr/AAAAC/8nJyf/jo6ONf8L/6mpqf8nJycO/wAAAAv/FRUV/3V1dR3/
B/+vr68a/wAAAAf/Dw8PJf8X/9/f3/9paWn/LCws/0VFRf+pqak9/xv/jo6O/zQ0NP8gICD/
LCws/3V1df/x8fEh/wf/Dw8PFv8AAAAH/19fXy3/B//9/f1J/w7/+/v7Kf8H/19fXxb/AAAA
B/+fn5+t/wf/j4+PFv8AAAAH/7+/vxn/Cv/7+/tt/wr//f39Gf8H/7+/vxb/AAAAGf8X/5mZ
mf81NTX/IyMj/0dHR/+0tLRd/xf/tLS0/0dHR/8jIyP/NTU1/5mZmRn/Fv8AAAAV/wv/mZmZ
/ycnJw7/AAAAC/8yMjL/tLS0Vf8L/7S0tP8yMjIO/wAAAAv/Jycn/5mZmRX/Fv8AAAAR/wv/
+/v7/zU1NRb/AAAAB/9HR0dV/wf/R0dHFv8AAAAL/zU1Nf/7+/sR/xL/AAAAB/8fHx8R/wv/
+/v7/yAgIBb/AAAAC/8nJyf//f39Tf8L//39/f8nJycW/wAAAAv/ICAg//v7+xH/Fv8AAAAR
/wv/+/v7/zU1NRb/AAAAB/9HR0dV/wf/R0dHFv8AAAAL/zU1Nf/7+/sR/xb/AAAAFf8L/5mZ
mf8nJycO/wAAAAv/MjIy/7S0tFX/C/+0tLT/MjIyDv8AAAAL/ycnJ/+ZmZkV/xb/AAAAGf8X
/5mZmf81NTX/IyMj/0dHR/+0tLRd/xf/tLS0/0dHR/8jIyP/NTU1/5mZmRn/Fv8AAAAH/7+/
vxn/Cv/9/f1t/wr/+/v7Gf8H/7+/vxb/AAAAB/+Pj4+t/wf/j4+PFv8AAAAH/19fXyn/Dv/7
+/tJ/wf//f39Lf8H/19fXxb/AAAAB/8PDw8h/xv/8fHx/3V1df8sLCz/ICAg/zQ0NP+Ojo49
/xf/qamp/0VFRf8sLCz/aWlp/9/f3yX/B/8PDw8a/wAAAAf/r6+vHf8L/3V1df8VFRUO/wAA
AAv/Jycn/6mpqTX/C/+Ojo7/JycnCv8AAAAP/wUFBf9FRUX/5OTkHf8H/6+vrx7/AAAAB/9P
T08Z/wv/+/v7/ywsLBb/AAAAB/9FRUUx/wv/+/v7/zQ0NBL/AAAAC/8KCgr/gICAHf8H/09P
TyL/AAAAB//f398V/wv/+/v7/yAgIBb/AAAAC/8sLCz//f39Ff8H//39/RX/C//7+/v/ICAg
Fv8AAAAL/zk5Of/9/f0V/wf/39/fJv8AAAAH/09PTxX/C//7+/v/OTk5Ev8AAAAL/wUFBf9p
aWkR/xf/tLS0/0dHR/8nJyf/R0dH/7S0tA3/C//7+/v/LCwsEv8AAAAL/wUFBf9lZWUZ/wf/
T09PKv8AAAAH/7+/vxX/H/+mpqb/NTU1/wUFBf8AAAD/CgoK/0VFRf/f398N/wv/qamp/zAw
MA7/AAAAC/8yMjL/tLS0Df8L/3V1df8VFRUO/wAAAAv/NTU1/9LS0hX/B/+/v78u/wAAAAv/
Hx8f/+/v7xX/F//S0tL/ZWVl/zk5Of+AgID/5OTkEf8H/0VFRRb/AAAAB/9HR0cN/xv/8fHx
/3V1df8sLCz/IyMj/0VFRf+pqakV/wv/7+/v/x8fHzL/AAAAB/9fX18d/wf//f39Ff8L//v7
+/8jIyMW/wAAAAv/IyMj//39/RH/Cv/7+/sF/wf//f39Ff8H/19fXzr/AAAAB/9/f38x/wv/
+/v7/zU1NRb/AAAAC/81NTX//f39Mf8H/39/f0L/AAAAB/+fn58x/wv/mZmZ/ycnJw7/AAAA
C/8nJyf/mZmZMf8H/5+fn0r/AAAAB/9/f38x/xf/mZmZ/zU1Nf8gICD/NTU1/5mZmTH/B/9/
f39S/wAAAAv/X19f/+/v7y3/Dv/7+/st/wv/7+/v/19fX1r/AAAAC/8fHx//v7+/Xf8L/7+/
v/8fHx9m/wAAAAv/T09P/9/f303/C//f39//T09Pdv8AAAAL/09PT/+vr689/wv/r6+v/09P
T4b/AAAAH/8PDw//X19f/4+Pj/+/v7////////n5+f/9/f0R/xP/v7+//4+Pj/9fX1//Dw8P
4db/AAAA' readStream) contents
]

{ #category : #icons }
SugarLibrary class >> showNavBarIcon [
	"Answer a form with the showNavBar picture"

	^ Form extent: 50@50 depth: 32 bits: (Base64MimeConverter mimeDecodeToBytes: 

'6cThmQC1/xUAtf8VALX/FQC1/xUAtf8VALX/FQC1/xUAtf8VAI3/DQAd/xUAYf8NAB3/EQAd
/xUAYf8NABn/FQAd/xUAYf8NABX/FQAh/xUAYf8NABH/FQAl/xUAYf8NAA3/FQAp/xUAYf8N
AAn/FQAt/xUAYf8NAAX/FQAx/xUAYf8hADX/FQBh/x0AOf8VAGH/GQA9/xUAYf81ACH/FQBh
/zUAIf8VAGH/NQAh/xUAtf8VALX/FQC1/xUAIf81AGH/FQAh/zUAYf8VACH/NQBh/xUAPf8Z
AGH/FQA5/x0AYf8VADX/IQBh/xUAMf8VAAX/DQBh/xUALf8VAAn/DQBh/xUAKf8VAA3/DQBh
/xUAJf8VABH/DQBh/xUAIf8VABX/DQBh/xUAIf8RABn/DQBh/xUAIf8FAAsE////AAAAAB3/
DQBh/xUAtf8VALX/FQC1/xUAtf8VALX/FQC1/xUAtf8VALX/4Z0A'

readStream) contents
]

{ #category : #icons }
SugarLibrary class >> stopIcon [

	^ Form extent: 50@50 depth: 32 bits: (Base64MimeConverter mimeDecodeToBytes: '6cThzv8AAAAH/2BgYEr/v7+/B/+QkJB2/wAAAAf/YGBgUf8H/5+fn27/AAAAB/9gYGBZ/wf/
n5+fZv8AAAAH/2BgYGH/B/+fn59e/wAAAAf/YGBgaf8H/5+fn1b/AAAAB/9gYGBx/wf/n5+f
Tv8AAAAH/2BgYHn/B/+fn59G/wAAAAf/YGBggf8H/5+fnz7/AAAAB/9gYGCJ/wf/n5+fNv8A
AAAH/2BgYJH/B/+fn58u/wAAAAf/YGBgmf8H/5+fnyb/AAAAB/9gYGCh/wf/n5+fHv8AAAAH
/2BgYKn/B/+fn58W/wAAAAf/Ly8vsf8H/5CQkBL/AAAAB/9AQECx/wf/v7+/Ev8AAAAH/0BA
QD3/Pv+AgIAH/9/f3zX/B/+/v78S/wAAAAf/QEBAPf8+/wAAAAf/v7+/Nf8H/7+/vxL/AAAA
B/9AQEA9/z7/AAAAB/+/v781/wf/v7+/Ev8AAAAH/0BAQD3/Pv8AAAAH/7+/vzX/B/+/v78S
/wAAAAf/QEBAPf8+/wAAAAf/v7+/Nf8H/7+/vxL/AAAAB/9AQEA9/z7/AAAAB/+/v781/wf/
v7+/Ev8AAAAH/0BAQD3/Pv8AAAAH/7+/vzX/B/+/v78S/wAAAAf/QEBAPf8+/wAAAAf/v7+/
Nf8H/7+/vxL/AAAAB/9AQEA9/z7/AAAAB/+/v781/wf/v7+/Ev8AAAAH/0BAQD3/Pv8AAAAH
/7+/vzX/B/+/v78S/wAAAAf/QEBAPf8+/wAAAAf/v7+/Nf8H/7+/vxL/AAAAB/9AQEA9/z7/
AAAAB/+/v781/wf/v7+/Ev8AAAAH/0BAQD3/Pv8AAAAH/7+/vzX/B/+/v78S/wAAAAf/QEBA
Pf8+/wAAAAf/v7+/Nf8H/7+/vxL/AAAAB/9AQEA9/z7/AAAAB/+/v781/wf/v7+/Ev8AAAAH
/0BAQD3/Pv9AQEAH/9DQ0DX/B/+/v78S/wAAAAf/QEBAsf8H/7+/vxL/AAAAB/8vLy+x/wf/
kJCQFv8AAAAH/2BgYKn/B/+fn58e/wAAAAf/YGBgof8H/5+fnyb/AAAAB/9gYGCZ/wf/n5+f
Lv8AAAAH/2BgYJH/B/+fn582/wAAAAf/YGBgif8H/5+fnz7/AAAAB/9gYGCB/wf/n5+fRv8A
AAAH/2BgYHn/B/+fn59O/wAAAAf/YGBgcf8H/5+fn1b/AAAAB/9gYGBp/wf/n5+fXv8AAAAH
/2BgYGH/B/+fn59m/wAAAAf/YGBgWf8H/5+fn27/AAAAB/9gYGBR/wf/n5+fdv8AAAAH/09P
T0r/gICAB/9vb2/hzv8AAAA=' readStream) contents
]

{ #category : #icons }
SugarLibrary class >> suppliesIcon [

	^ Form extent: 50@50 depth: 32 bits: (Base64MimeConverter mimeDecodeToBytes: '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
/wAAAA==' readStream) contents
]

{ #category : #icons }
SugarLibrary class >> undoIcon [

	^ Form extent: 50@50 depth: 32 bits: (Base64MimeConverter mimeDecodeToBytes: '6cTnTv8AAAAH/1JSUgr/zs7OB/9ERES2/wAAABf/a2tr/97e3v/f39//3t7e/6Kioq7/AAAA
C/8VFRX/lJSUEv/e3t4H/4eHh6r/AAAAC/8hISH/sbGxEv/e3t4L/4aGhv8WFham/wAAAA//
LCws/8/Pz//f398K/97e3gv/4ODg/2tra6r/AAAAB/9RUVEK/97e3hP/39/f/97e3v/Ozs7/
UlJSqv8AAAAL/3h4eP/f398K/97e3g//39/f/8/Pz/8sLCym/wAAAAv/FRUV/5OTkxL/3t7e
D//Pz8//RUVF/zg4OBL/OTk5D/84ODj/OTk5/zg4OAr/OTk5Ev84ODgP/zk5Of84ODj/Hx8f
Zv8AAAAT/6Kiov/f39//3t7e/+Dg4Bb/3t7eD//f39//3t7e/9/f3xb/3t7eB//g4OAK/97e
3gf/39/fEv/e3t4P/8DAwP94eHj/ICAgWv8AAAAy/97e3hL/39/fB//e3t4K/9/f3xL/3t7e
H//f39//3t7e/9/f3//e3t7/39/f/3h4eP8UFBRS/wAAAAf/hoaGCv/e3t4H/9/f3w7/3t7e
Dv/f398S/97e3gf/39/fHv/e3t4H/9/f3wr/3t7eB//f398O/97e3gv/sbGx/yAgIFL/AAAA
B/94eHgW/97e3gf/X19fCv85OTkH/zg4OA7/OTk5Dv84ODga/zk5ORf/ODg4/2tra//AwMD/
3t7e/9/f3wr/3t7eC//Ozs7/ISEhUv8AAAAP/1FRUf/Ozs7/39/fCv/e3t4L/8/Pz/9SUlJG
/wAAAA//X19f/87Ozv/f398K/97e3gf/sbGxVv8AAAAL/ywsLP/Ozs4S/97e3gf/bGxsRv8A
AAAL/ywsLP/Pz88K/97e3gv/39/f/2xsbFb/AAAAE/8VFRX/sLCw/97e3v/f398K/97e3gv/
hYWF/xUVFUL/AAAAC/8sLCz/3t7eCv/f398L/8/Pz/8WFhZW/wAAAAv/FRUV/4aGhhL/3t7e
C/+xsbH/FBQUQv8AAAAH/2xsbAr/3t7eC//f39//UlJSXv8AAAAP/2xsbP/e3t7/39/fCv/e
3t4H/5WVlUL/AAAAF/8VFRX/39/f/+Dg4P/e3t7/lJSUYv8AAAAX/1JSUv/Pz8//3t7e/9/f
3/+VlZVG/wAAAAf/oqKiCv/e3t4H/87Ozmb/AAAAE/8sLCz/lJSU/6Kiov8sLCxG/wAAAAf/
a2trCv/f398H/97e3rr/AAAAB/9sbGwO/97e3rr/AAAAB/94eHgO/97e3rr/AAAAE/+xsbH/
39/f/97e3v+wsLC2/wAAAAf/LCwsDv/e3t4H/4eHh7b/AAAAB/+ioqIO/97e3gf/RUVFsv8A
AAAH/2BgYA7/3t7eB/+/v7+y/wAAAA//Xl5e/97e3v/f398K/97e3gf/OTk5qv8AAAAT/zg4
OP+hoaH/3t7e/9/f3wr/3t7eB/94eHhS/wAAAAf/FRUVDv9ra2sO/2xsbAr/ampqB/9ra2sK
/2xsbAr/ampqDv9sbGwH/2trawr/bGxsE/9ra2v/eHh4/7Gxsf/g4OAK/97e3g//39/f/97e
3v+Hh4dW/wAAAAf/sbGxEv/e3t4H/9/f3xr/3t7eB//f398e/97e3gf/39/fDv/e3t4H/9/f
3wr/3t7eB/94eHha/wAAAAv/3t7e/9/f3xb/3t7eB//f398i/97e3gf/39/fGv/e3t4T/9/f
3//e3t7/oaGh/zg4OF7/AAAAC/9sbGz/39/fHv/e3t4H/9/f3x7/3t7eB//f398S/97e3g//
oqKi/3d3d/8rKyvoDv8AAAA=' readStream) contents
]

{ #category : #icons }
SugarLibrary class >> zoomIcon [

	^ Form extent: 50@50 depth: 32 bits: (Base64MimeConverter mimeDecodeToBytes: '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' readStream) contents
]

{ #category : #'icon images' }
SugarLibrary >> iconAt: aName [

	^ iconDictionary at: aName.

]

{ #category : #'icon images' }
SugarLibrary >> iconAt: aName ifAbsent: aBlock [
	"If the IconDictionary has entry filed under the first argument, answer that entry; if not (e.g. during development) then answer the result of evaluating the block provided"

	^ iconDictionary at: aName ifAbsent: [aBlock value]
]

{ #category : #'icon images' }
SugarLibrary >> iconAt: aName put: aForm [

	^ iconDictionary at: aName put: aForm.

]

{ #category : #'icon images' }
SugarLibrary >> imageFor: aString color: aColor [

	^ self imageFor: aString color: aColor grayOutColor: nil.

]

{ #category : #'icon images' }
SugarLibrary >> imageFor: aString color: aColor grayOutColor: grayOutColor [
	"Answer an image corresponding to the given string, using the specified color scheme."

	| icon g h orig w height ret f |
	icon := self iconAt: aString ifAbsent: [self iconAt: #missingIcon].
	icon unhibernate.
	grayOutColor ifNotNil: [
		f := Form extent: icon extent depth: 32.
		f fillColor: grayOutColor.
		icon displayOn: f at: 0@0 rule: 37.
		icon := f.
	].

	orig := Form new hackBits: icon bits.
	height := icon width * icon height.

	g := Form extent: icon extent depth: 32.
	h := Form new hackBits: g bits.

	w := WarpBlt current toForm: h.
	w sourceForm: orig.
	w cellSize: 1.
	w combinationRule: Form over.
	w copyQuad: {1@0. 1@height. 2@height. 2@0} toRect: (0@0 corner: 4@(height + 1)).
	ret := (Form extent: icon extent depth: 32) fillColor: aColor.
	g displayOn: ret at: 0 rule: 34.
	^ ret asFormOfDepth: 16
]

{ #category : #'icon images' }
SugarLibrary >> initialize [

	super initialize.
	iconDictionary := Dictionary new.

]

{ #category : #'icon images' }
SugarLibrary >> loadFrom: aFileDirectory [

	aFileDirectory fileNames do: [:fName |
		(fName endsWith: 'White.png') ifTrue: [
			iconDictionary at: (fName copyFrom: 1 to: fName size - 9) put: ((PNGReadWriter on: (aFileDirectory readOnlyFileNamed: fName)) nextImage asFormOfDepth: 32).
		]
	].

]

{ #category : #'icon images' }
SugarLibrary >> makeButton: aString balloonText: anotherString for: aSymbol target: target baseColor: baseColor highLightColor: highLightColor [
	"Answer a SugarButton constructed from the arguments."

	| s keyString img |
	keyString := aSymbol asString.
	s := SugarButton new.
	img := self iconAt: aString ifAbsent: [self iconAt: #missingIcon].
	self recolorButton: s for: keyString baseColor: baseColor highLightColor: highLightColor.
	s extent: img extent + (25@25).
	s target: target.
	s actionSelector: aSymbol.
	s setBalloonText: anotherString.
	^ s
]

{ #category : #'icon images' }
SugarLibrary >> recolorButton: aSugarButton for: aSymbol baseColor: baseColor highLightColor: highLightColor [

	| keyString |
	keyString := aSymbol asString.
	aSugarButton color: baseColor.
	aSugarButton onImage: (self imageFor: keyString color: highLightColor).
	aSugarButton offImage: (self imageFor: keyString color: baseColor).
	aSugarButton disabledImage: (self imageFor: keyString color: baseColor grayOutColor: Color gray).
	aSugarButton highLightColor: highLightColor.
	^ aSugarButton.

]
