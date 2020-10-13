"
I represent a registry for icons.  You can see the icons I contain using the following script:

| dict methods |
dict := Dictionary new. 
methods := MenuIcons class selectors select: [:each | '*Icon' match: each asString].
methods do: [:each | dict at: each put: (MenuIcons perform: each)].
GraphicalDictionaryMenu openOn: dict withLabel: 'MenuIcons'
"
Class {
	#name : #MenuIcons,
	#superclass : #Object,
	#classVars : [
		'Icons',
		'TranslatedIcons',
		'TranslationLocale'
	],
	#category : #'Morphic-Menus'
}

{ #category : #'private - icons' }
MenuIcons class >> backIconContents [
	"Private - Method generated with the content of the file /home/dgd/back.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABwAAAAcCAYAAAByDd+UAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAADRElEQVRIie3WW4hVVRgH8N/e+5y56aCizpnR
jJzUCNFqLhqEWGlQDz0mGEJBCSL1Ur1YZA9BSIZGZg9dVBoo0B5D6qGwOzVaairZiJiKZ0hs
1NE5c2bm7N3DmXF2zQyO5lv+YbFZa/2/77+/y9prcxNpNFnoHi3/xUU4LtYiszX5WGC/ULsW
m69XMLgqo8UzEhtRlVpNJJb62Tc3TnCxnH7bBR65sra0nt8vkC9Ah9Ay7U5d2Z+jUrUaoRqx
Hr/qGp9gk0cFPsB0UFfFugUsybH1N7YfS7O7UTE4/u2vgDze02ijXUrRCLFmzwtswwRhwGO3
Wb55tcWNzQ75g7+KfNmZtqhEZoyXz2IKlutSIe+LNCnQ7A08NxRVuKHVywvXWG+lDXZ5SRs9
A7Qd53g3pSQlG1GboTY7PKojNh/hXBFK+s0oC85XocoOrASzJ6p9+wE7c69I8K7PfKrdgBK4
XYNWc+VMFgwGlkgU9Svo06OooOiksw7u3MPrhwySVmVAlTasAAummPzWg16oXWGdD+13fESe
ulxSZ5I7zTJHg1tNVxIr6FNQ1KlLuw7fOkJ9dTqHDwWarBJoA7lqPlqiflJO58gGuz78cJZn
fxya/ZQRutdQKZY1MKlifGJJzEA/A32UUs+4NDhispVcjtMRdmeU7BBag8iJM5yOmDmPYIwj
2pXn5MGy2LhQl3pJF0O/2CuwBXzfS0cnR7+j9/IoUSWcPnINYuhNcRN/DnXpRFUOoFFNwKYa
wgJ1s2mYS1TuLedOceLAsIMwIsoSZEhC4oCBgD70xpzB9ktcGExr4PHhvLVqFPsaM02NeC2L
XjKVTJtVdp7vKNfufB1bznO2RLE03lhj5P5ZqBZ3SHyFnFsyrM+SFEaabqrm6CjrY6Mf79tn
7cjOaDVfbA+mmRzyajUVqXpGE3g6NQ88IXZYKFISCUVioUAfetDjolOOKZbpo6HV3WK70SCL
F2uZ0V3eOzCFd64cm8/t8/C1hDr29dSqXuwT3AfuyjIvy66etPVT9tp2YwShWRZvYu0ouydd
MG8oVePFyOspjbxY3m4znMD9hm/90xJPOuzYmLZj4Oq/GENYZKqS1QKxPlsdNMqX4Sb+D/gb
LOgMCUjhiw4AAAAASUVORK5CYII='
]

{ #category : #'icons creation' }
MenuIcons class >> base64ContentsOfFileNamed: aString [ 
	"Private - convenient method"
	
	| file base64Contents |
	file := FileStream readOnlyFileNamed: aString.
	base64Contents := (Base64MimeConverter mimeEncode: file binary) contents.
	file close.
	^ base64Contents
]

{ #category : #'accessing - icons' }
MenuIcons class >> blankIcon [
	^self blankIconOfWidth: 16.

]

{ #category : #'private - icons' }
MenuIcons class >> blankIconOfWidth: aNumber [ 
	^ Icons
		at: ('blankIcon-' , aNumber asString) asSymbol
		ifAbsentPut: [Form extent: aNumber @ 1 depth:8]
]

{ #category : #'accessing - icons' }
MenuIcons class >> checkBoxOff [

	^ Icons
			at: #'checkBoxOff'
			ifAbsentPut:[ (Form
	extent: 12@12
	depth: 32
	fromArray: #( 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 0 0 0 0 0 0 0 0 0 0 4294967295 4294967295 0 0 0 0 0 0 0 0 0 0 4294967295 4294967295 0 0 0 0 0 0 0 0 0 0 4294967295 4294967295 0 0 0 0 0 0 0 0 0 0 4294967295 4294967295 0 0 0 0 0 0 0 0 0 0 4294967295 4294967295 0 0 0 0 0 0 0 0 0 0 4294967295 4294967295 0 0 0 0 0 0 0 0 0 0 4294967295 4294967295 0 0 0 0 0 0 0 0 0 0 4294967295 4294967295 0 0 0 0 0 0 0 0 0 0 4294967295 4294967295 0 0 0 0 0 0 0 0 0 0 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295)
	offset: 0@0) ].
]

{ #category : #'accessing - icons' }
MenuIcons class >> checkBoxOn [

	^ Icons
			at: #'checkBoxOn'
			ifAbsentPut:[ (Form
	extent: 12@12
	depth: 32
	fromArray: #( 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 0 0 0 0 0 0 0 0 0 0 4294967295 4294967295 0 0 0 0 0 0 0 0 0 0 4294967295 4294967295 0 0 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 0 0 4294967295 4294967295 0 0 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 0 0 4294967295 4294967295 0 0 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 0 0 4294967295 4294967295 0 0 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 0 0 4294967295 4294967295 0 0 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 0 0 4294967295 4294967295 0 0 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 0 0 4294967295 4294967295 0 0 0 0 0 0 0 0 0 0 4294967295 4294967295 0 0 0 0 0 0 0 0 0 0 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295)
	offset: 0@0) ].
]

{ #category : #'accessing - icons' }
MenuIcons class >> checkBoxPressed [

	^ Icons
			at: #'checkBoxPressed'
			ifAbsentPut:[  (Form
	extent: 12@12
	depth: 32
	fromArray: #( 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 0 0 0 0 0 0 0 0 0 0 4294967295 4294967295 0 0 0 0 0 0 0 0 0 0 4294967295 4294967295 0 0 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 0 0 4294967295 4294967295 0 0 4294967295 0 0 0 0 4294967295 0 0 4294967295 4294967295 0 0 4294967295 0 0 0 0 4294967295 0 0 4294967295 4294967295 0 0 4294967295 0 0 0 0 4294967295 0 0 4294967295 4294967295 0 0 4294967295 0 0 0 0 4294967295 0 0 4294967295 4294967295 0 0 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 0 0 4294967295 4294967295 0 0 0 0 0 0 0 0 0 0 4294967295 4294967295 0 0 0 0 0 0 0 0 0 0 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295)
	offset: 0@0) ].
]

{ #category : #'class initialization' }
MenuIcons class >> cleanUp: aggressive [

	aggressive ifTrue: [self initializeIcons].
]

{ #category : #'private - icons' }
MenuIcons class >> configurationIcon [
	"Private - Generated method"
	^ Icons
			at: #'configuration'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self configurationIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> configurationIconContents [
	"Private - Method generated with the content of the file /home/dgd/configuration.png"
	^ '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'
]

{ #category : #'private - icons' }
MenuIcons class >> confirmIcon [
	"Private - Generated method"
	^ Icons
			at: #'confirm'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self confirmIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> confirmIconContents [
	"Private - Method generated with the content of the file /home/dgd/confirm.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABwAAAAcCAYAAAByDd+UAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAACsElEQVR4nK3WvW8URxjH8c+CDxtsYg6FCJDy
IqUIWKAUiCJFWuiRIqWCKn9AynRJnS4VShEpEimSBlGkiKBAGIkUWIoUBVtC4IvBb2BsH8fd
+fD5NsWM7VO43bXPPNJoZnafme/MPL95oT8r4RCS3TbcTYNSibEynw1xusXiKyp1FvAQT5G+
LeB7H/HdCFdwcLNRStri1gK/1HiMP7G+V+ChT7hd4vwRXMB+vIxpEs+pzvB1jakIzZzp/iLa
x3w/yKWL+DECP8cpLGEULxgqcXaZ8ZR6HEtfwOQkv51h8CqGun68E6ETgoJmKadM1HkmxLWn
7cujneCDhMNfZjiOYgzlWB/mUxzO6zMXOBpjfDTHp2xbJSlN1PoGTlFJmZ3K8XmCf2O5yTRW
+gZCm2s/d3XabY9wM+YbTC5yL8N1ywpVWma8zRe/8+5BDGAef+BbVNBhvca948yfYOFZUGpP
y9uH+87yVco3+HDT+f8bLMVGHHmCOpenuY5XvTodyKKdY6jF1UFB/idj5yuCKgZwTDhQ4Q5W
6cyyJgh4d8AJmmfwPq5FWBXLoWO1MBt/xe8v0WH6dVBqT1guMDLW2nG/JzgSU7fD/TjrFOs8
iMVMYJFKmxs5P+eF9VuO9Qb/hExms1xgQrOd839T/5vAaphh/xs/pZEHnLMtpA7z9VDMXM5C
oIIZLgliaduKH3uZIZpZt2kqXAkvYr0V4rdnYCMr+nMBshW/2g4UWghMc5Z0OubLwa+6wqyg
0E7fwDyVzgkbv4X2DpezEIhGqveQl2zHb22HgikEJuGYeuMZ1hH24GSoNle3H06LewLGG/yN
Y+MJxvEaq/xQDaC/QzXf8s5SKc0ElzCIAzE1hLVb48ZT7goamimC7QT4K2Yq4VkzkjDSYThh
uEO7wk/CZfEgr59u+w8LnvWEFNR9UgAAAABJRU5ErkJggg=='
]

{ #category : #'icons creation' }
MenuIcons class >> createIconMethodsFromDirectory: directory [ 
	"
	Preferences disable: #showWorldMainDockingBar. 
	MenuIcons createIconMethodsFromDirectory: '/home/dgd/'. 
	Preferences enable: #showWorldMainDockingBar.
	"
	| iconContentsSourceTemplate iconSourceTemplate normalSize smallSize |
	iconContentsSourceTemplate := '{1}IconContents
	"Private - Method generated with the content of the file {2}"
	^ ''{3}'''.
	iconSourceTemplate := '{1}Icon
	"Private - Generated method"
	^ Icons
			at: #''{1}''
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self {1}IconContents readStream) ].'.
	""
	normalSize := #('back' 'configuration' 'confirm' 'forward' 'fullScreen' 'help' 'home' 'jump' 'objectCatalog' 'objects' 'paint' 'project' 'publish' 'squeak' 'volume' 'window' 'open' 'loadProject' ).
	smallSize := #('smallExport' 'smallAuthoringTools' 'smallDebug' 'smallBack' 'smallCancel' 'smallConfiguration' 'smallCopy' 'smallCut' 'smallDelete' 'smallDoIt' 'smallExpert' 'smallFind' 'smallForward' 'smallFullScreen' 'smallHelp' 'smallHome' 'smallInspectIt' 'smallJump' 'smallLanguage' 'smallNew' 'smallObjectCatalog' 'smallObjects' 'smallOk' 'smallOpen' 'smallPaint' 'smallPaste' 'smallPrint' 'smallProject' 'smallPublish' 'smallQuit' 'smallRedo' 'smallRemoteOpen' 'smallSave' 'smallSaveAs' 'smallSelect' 'smallSqueak' 'smallUndo' 'smallUpdate' 'smallVolume' 'smallWindow' 'smallLeftFlush' 'smallCentered' 'smallJustified' 'smallRightFlush' 'smallFonts' 'smallLoadProject' ).
	normalSize , smallSize
		do: [:each | 
			| png base64 contentsSelector selector | 
			png := directory , each , '.png'.
			base64 := self base64ContentsOfFileNamed: png.
			""
			contentsSelector := (each , 'IconContents') asSymbol.
			((self respondsTo: contentsSelector)
					and: [(self perform: contentsSelector)
							= base64])
				ifFalse: [| contentsSource | 
					contentsSource := iconContentsSourceTemplate format: {each. png. base64}.
					self class compile: contentsSource classified: 'private - icons'].
			""
			selector := (each , 'Icon') asSymbol.
			(self respondsTo: selector)
				ifFalse: [| source | 
					source := iconSourceTemplate format: {each}.
					self class compile: source classified: 'private - icons']].
	""
	self initializeIcons
]

{ #category : #'menu decoration' }
MenuIcons class >> decorateMenu: aMenu [ 
	"decorate aMenu with icons"

	| maxWidth |

	Preferences menuWithIcons ifFalse: [^ self].
	Preferences tinyDisplay ifTrue:[^ self].

	maxWidth := 0.

	aMenu items do: [:item | 
		item icon isNil ifTrue: [
			| icon | 
			icon := self iconForMenuItem: item.
			icon isNil ifFalse: [
				item icon: icon.
				maxWidth := maxWidth max: item icon width.
			]
		]
		ifFalse: [
			maxWidth := maxWidth max: item icon width
		].

		item hasSubMenu ifTrue: [
			self decorateMenu: item subMenu.
		].
	].

	maxWidth isZero ifFalse: [
		self flag: #hacky. "mt: That manual icon scaling is not optimal..."
		aMenu addBlankIconsIfNecessary: (self blankIconOfWidth: (
			"Avoid duplicate scaling because the actual menu icons are already scaled at this point."
			RealEstateAgent scaleFactor > 1.0
				ifTrue: [RealEstateAgent defaultIconExtent x]
				ifFalse: [maxWidth]))].

]

{ #category : #'import\/export' }
MenuIcons class >> exportAllIconsAsGif [
	"self exportAllIconsAsGif"

	| sels | 
	sels := self class selectors select: [:each |  '*Icon' match: each asString].
	sels do: [:each | self exportIcon: (MenuIcons perform: each) asGifNamed: each asString].

]

{ #category : #'import\/export' }
MenuIcons class >> exportAllIconsAsPNG [
	"self exportAllIconsAsPNG"

	| sels | 
	sels := self class selectors select: [:each |  '*Icon' match: each asString].
	sels do: [:each | self exportIcon: (MenuIcons perform: each) asPNGNamed: each asString].

]

{ #category : #'import\/export' }
MenuIcons class >> exportIcon: image asGifNamed: aString [
	"self exportIcon: self newIcon asGifNamed: 'newIcon'"

	| writer |
	writer := GIFReadWriter on: (FileStream newFileNamed: aString, '.gif').
	[ writer nextPutImage: image]	
		ensure: [writer close]
]

{ #category : #'import\/export' }
MenuIcons class >> exportIcon: image asPNGNamed: aString [
	"self exportIcon: self newIcon asPNGNamed: 'newIcon'"

	| writer |
	writer := PNGReadWriter on: (FileStream newFileNamed: aString, '.png').
	[ writer nextPutImage: image]	
		ensure: [writer close]
]

{ #category : #'private - icons' }
MenuIcons class >> forwardIconContents [
	"Private - Method generated with the content of the file /home/dgd/forward.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABwAAAAcCAYAAAByDd+UAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAADXUlEQVRIie3WX2iVZRwH8M97znv2f1o2Fy4r
hxMvhhCeTewmJcuEbiLLP0GECoJWEIlYUBoR3QTVhRRIXffvJupiBF4oRCZukq5Na4LhlKnT
6XE7c/P8ebs4O8fNlh3nVdEPHnif5/d8f9/3+33e53le/usRvyv0UknzzDXgQrmQ2IzJkt4V
6BT4xVJfWKa5HFgwI7J27fIOmerQmMBOnfbeGWGrChXmoVZeSlZKjzQisEyznA4s1lhFWwMd
Z4tZIh0SNjk8vc03CZO2Yzcap32R6WLLIrYt5sgl3jvOudFiZlBki6O+vxVSsKTNK9iLurLJ
4PkFLKy38YE1Wp5b7uT1P+hJEakV2KDJiAGHpipMSmAIdeoT7GwlGzGaJT2pjeUK49l8Aflw
HZtaqI57xwv22OhD33qj+2OZXYe5OFaYF/nIUTtMmB5ot0LeAbB5kSXbn9LqIRXCUksIBZOE
Dxl2RJ8T+ktjKy2x1RpN5lh7aY/Lr+6n71qR9EvjXtLjRijnyVKt+TVOOqtNiyc84kENQnGJ
Cef7XXLKgGtG9Ruc4u4B3Q7o1mKelxue9ennCYOv76fzMoENqmXxYiDpK6wD7y9ldVPZS3i7
mKPe0PAQ6w/etDfwTIjh0qx0mounuXEdAUFAECMekqgkrCCsJFFReA7+/twYMkx9guVz+W7C
+rwVIVKlWUGK/vPlSQgC5rfSuGD6fD7H6V76SvXGBPbFBJM2aCpTHhlEEQO/E+X/mhu+TO9B
jl3lxETNyG5dTsbdb1xgK+gaY3YdFdXkagiqCWuIVxFWEYbEYhMkUUFFWEntPYWimXHOdHO2
l5Fa3koVyQ5aaJteUYCYpAtoKFtdTYwd9zF/sGBtY3OBfOgcuSz5Wbw2zHgEXVilq7B0cUSa
jKEdNWURZiL6MqyMCkrTVxhNFZTnZ7MrzWgeesSt0ulKETr1GFviXjUqkJAVE8rLysnIqZKT
0SzmR1SCfXVEIzfxV+t5e4QbEZzCY7oMTKa48+sp6TNsAetn8fi1wvY4Vssnw8Vb41c8rcuZ
W+EzIVyNH0r99gT9Oc6XvtavZWx2XHo6+Mwu4DY/iTx6y2hO5E1HfXA76Ex/MTbh50n930RW
/xMZM1VYxLZZK2/MQh2+kbuLWv/Hvyj+BJaPHpqZ0oo8AAAAAElFTkSuQmCC'
]

{ #category : #'private - icons' }
MenuIcons class >> fugueBroomIcon [

	^ Icons
			at: #broom
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self fugueBroomIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> fugueBroomIconContents [
	"Fugue Icons
	(C) 2013 Yusuke Kamiyamane. All rights reserved.

	These icons are licensed under a Creative Commons
	Attribution 3.0 License.
	<http://creativecommons.org/licenses/by/3.0/>"

	^ 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9i
ZSBJbWFnZVJlYWR5ccllPAAAAoNJREFUeNqkU11Ik1EYfo6bm7WZW2r+MDNTZ9ZQcbYws0iN
piZEBF4UXWgXCXURXQQiBTYhgi4qRo0y+gEpNImauKVkhkzDNrxoCjrNZSSapnNLv+n2nc5H
GmFJgQcezuGc93nPc877vIRSivUMYqwkEFIIeQQQsnzA5rP1FEe0BKXZP894Bm6AQiKGPsjD
sLSEmpD/uCSX8e4JYOv9LJF+noNhb/ExrW8BBvE/yClmO824YbpaKUgwG6sjvy8gQVdwQNv4
qNkeCK6tQMHiz7H5kMs1fKe1Rw7/xARKTl8+Gq4hX5496bR/nkINz8MiKAhliGCIYohjRF2Y
LCJnW2ZelrM8I6mlxYzCQj1arX4cTBzC4ZMXyhYD11soD074E3KrglwJkyl3S2WbZBvCI8Oj
E1JjlDGqqCXvojjg4bB5ZwKaO0NRUFAKq/U5CpOGIRKJYG2638AuOxHCZLT5PDP+NF3Jvvhk
bSY3y8eOdA+IvV9nsFGlxLf+MZRle2E2NyI/vxQvnXGYc88hEABhgEifSdw2O521dfSmyyji
ZRFyxKSqIGK1Gu8bgTI5FgEfh3TFPBra+6BW70H5+dqGvBTUs2d8XKmCJVtDFqanHRd35GqK
hxz9EFMRtmakwDc1C8oFoUjcglO7PNCdKW9i8beZ/C7BMr+qwDY6+/rpTeO1h3ZFlAJJOWqM
D36CZ3IG0mg5Jj+48fjp3bdV+dTEwrtWeKt9YEnbTvy21y+q1ercIp59UHJWGsYcQ7B0tHUz
99WFSdH+O+EPIzElHa5RKnWN2pQVVce1gz1OvHn3vpcPolYiwavV8Ws50SKVgD4wNdUt98il
EALLX5tp3d243gQ/BBgABJ4L2+7frOgAAAAASUVORK5CYII='
]

{ #category : #'private - icons' }
MenuIcons class >> fugueDocumentClockIcon [

	^ Icons
			at: #documentClock
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self fugueDocumentClockIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> fugueDocumentClockIconContents [
	"Fugue Icons
	(C) 2013 Yusuke Kamiyamane. All rights reserved.

	These icons are licensed under a Creative Commons
	Attribution 3.0 License.
	<http://creativecommons.org/licenses/by/3.0/>"

	^ 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9i
ZSBJbWFnZVJlYWR5ccllPAAAAhNJREFUeNqMU11LG1EQPbvZfEgaSKKBtFX71BcFjT8hCb4I
Pjb1qc/9F4og9AcU6rPgk9KCb0Uw0D9gCsWAaSJBoSSp+Wg2rbp3d3vuDZtuWS0dmL3DvTNn
5szMaq7rQkppa2udx2P8W04cx/nq2Dbe7+yoC8N74cOTvc3N3Ts+WlIdBzbBvQSVSgV7x8ev
aWrUmhenTwBsW3NkkGUpvbu5wa/RCKZpYjgcqvNwe3uXfkW6Pw8A2ASQ0Dq/4VAIsXAYEcOA
oevQeNftdvF2fx+FhYV3X05PX3pxhq8CXQbrCgYKZCJCoFAoKDqJRAIfK5VeAEDICnwA94EI
UvR8AwC2EBMKI3Kv1+vo9/sqa5xZs3NzMCIRRUf6BnsghKLwk8Gf2XGX/KdiMSytrMCIRlE7
O4O4vUVoDKAHAAQv1XzOzxFlxqlkEh8ODtBh9+PpNBKpFK4uLhQt8QCA6sH3TgdxBs8yqNVq
4dnMDJ4yODk9jd71NcKcivBR+NMDy1IVWNwBnU5S2+02Xm1sIJvNYnVtTS7bmAJ9g1OQFPiY
YrYfrMLNZHB4dDQeMRtZrVZhDgZqDR+mwDOXy+Fbs4lGrSabpVTazUYDS8vLakr3UuDaKjvN
ClaLRZTLZXyiSpmdn0c+n1dvms/3L4BBrxf17AzLf1EqqR2Qv5J3Sioae+P3nQCMTPPy0eLi
G/yHEOTSs38LMADvCBAJ/QIAlQAAAABJRU5ErkJggg=='
]

{ #category : #'private - icons' }
MenuIcons class >> fugueUserSilhouetteQuestionIcon [

	^ Icons
			at: #userSilhouetteQuestion
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self fugueUserSilhouetteQuestionIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> fugueUserSilhouetteQuestionIconContents [
	"Fugue Icons
	(C) 2013 Yusuke Kamiyamane. All rights reserved.

	These icons are licensed under a Creative Commons
	Attribution 3.0 License.
	<http://creativecommons.org/licenses/by/3.0/>"

	^ 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9i
ZSBJbWFnZVJlYWR5ccllPAAAAgBJREFUeNqkk7+LGlEQx2f9rXiLvwhYHYQENaRJ4RJFsFMQ
bLQOBCRFSBGLtJciYJc21wRsUqS7v0IRlSNFjjt/d6IJaKEXFV1v853H3rHZmKTIwIfdN+87
s/PmzUqappEkSWSyJ+AFeKSvL8FH8MUoErEHEqQ8Hs/7eDz+MBwOy+yYTCaLdrvdX61Wb7Cs
GRNY6Hd7qShKLBQKBfb7vU1VVVswGAwgYYz3zGJzgjiI+ny+o+12S8xutxP4/f4j3tM1v57D
YF/x9etsNqvN5/M7arWalslkNN5jjTHWZqrgHNy3WCxUqVREb5LJJKVSKYpEItRsNiVd88cj
PG+1Wg0EqqPRiIbDIS0WC5pOpzSbzVTeY83fErCd9nq9Gb9Eo1FKp9NUrVb56+w7/VcT2c4G
g8G13W6nUqlEnU6HxuMxV8PnPzOLbQfWr4CVF+VyWfTB7XaT7nsNPgD10C0o4DPoF4tFLZ/P
axggrV6vi/dCocDCvq5RzLfwDNP3DpMXQLfl9XpNVquVcBTCNQoB+3K53INut3sPiZ9iKt/C
/el2lC8SiUQM12dxOByiZH4ul0sR7PV6xVBtNhsxVJjQm0ajcYXYx7cVHLtcLo4np9MpEvBT
lmVRJsZZVMT9YA183PxjYw9OwA34Ab6BoT5x5zoXYAS+6xrWntz9jf9jPwUYAKt/9B8pRO/y
AAAAAElFTkSuQmCC'
]

{ #category : #'private - icons' }
MenuIcons class >> fullScreenIcon [
	"Private - Generated method"
	^ Icons
			at: #'fullScreen'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self fullScreenIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> fullScreenIconContents [
	"Private - Method generated with the content of the file /home/dgd/fullScreen.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABwAAAAcCAYAAAByDd+UAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAAHT0lEQVR4nL2WW2xc1RWGv7X3OWcutmfGYzuO
7TjBSYAAgaSQEGhRQVwU2pAgFQFC6iuKhBAvCEWVKtWPBCpVquhTq6pUBURFaVrUBmQuBRWh
FJELhIRQGi42SUx8HY9n5lz2Xn3whAZIipCq/tJ6Odr7/Gv9/1rrHPg/QwAeffTRjjiOK2EY
DotIRURKqpoXEauqAnhVTY0xdWDBWnu6VqtNDwwMzO3cubPxjQl37959jYgMqepaEbFAoKoB
gIio9x5jjPPeZyLi2nc90BSRaRE5HgTBJ0NDQ5/ddddd7jxcS4SqKo888siNwJWLycJlx04e
Gwisdb1dy+qD5aHaOe54EUmApqo2gWb7WR2Ycs69H4bh+IMPPjgtIvoVwtHR0c5CoXCtiNzw
i5d+dm881Ojr7a8yO1UjPpGkF5cueXfHxjve+i9Je2BBROZVNRYRFZF559wnxpj3G43Gx6Oj
o9mZw0GxWOxUVUSkM+5Y7Or+XoH+rirbe2/jqZeeCGtvLHSpqpwr2zYMUFbVsoi0VLWmqlZE
Kt77Ffl8/pOHH374aKvVmhgdHfV269atPara49VveKPx2tW5FYEsmjrHakeodvTw8ZsnuoYr
K5NKoWKNMREQyBL8OcgDoAOoiogXESMi/UC/MaZz27ZtdeO9j1Q1yLIs1EwlmcmIT6YkpzOG
+4e5+d7vhs8cfHLTqfmTZVUtAmWgV1UHgG4RyZ2n6hFVXd2uvt8YU0qSZMCISM5amw+D0LmT
mrp5pX4gxtU9B47up2ugg0t/uDb688Fn13/B/CUUgV6gH+g821fv/SKwQlU3GGM6RMSGYRgY
wKhqBPCt5VcfKr7ZM71Fr383edU2XcPzyqEXef/Nf1LMdcTn6xoRCUSkDPS1ZeWM5+1ZVmOM
zbIsDEQkExHnnOOWy249JiKzgLtk4NLTT4z9dlO9Wu8sz/fMb99y+wdf0zyISNSWcPosUmlX
bAETiEjmvY/PyOS9t8YY19PVl+y84f53Do0fWL6sUk7+Mbb34oWFhTBpNUwaxzZzqc3li3Gx
q9LsKlUa1d7l9eGRi2a7q1WstYalcfFtBTMRSVQ1DpxzznufGGMUEGst7S3TlQ/zZsvqa6de
fO6pVdtv/0Hf+g1XUSqXKZe76SpXSOJW/sg7B8uH336LI+8c5KU//cZJWJwdXHXhB+vWX3m8
r6/PAUZEUlVNRaQVGGMyVfUiknrvRUQCIC8ickaq2uxMfscd97BqZO1XZBwcWsH1N99ClrZo
LNbs88/t6X3290/27vndYxuGRi45ccWm644PDg6qiGTW2iVC5xze+xRw3vvIGCNnv7RWm8n3
9Q9w9MPj7NULmM1gLhGqkbImDyM5ZV2UYa1h623f56Zbb+bQ/v2Fpx5/fM3zz/xqsG/4osb6
jVuOr1y5shUkSVJvF7MgIqW21h1nBjtLU2NEomKxgw/mG7yRNVAEr8J4Aw4AXkNypsymYsh1
+ZTVEVy+cSOfjo9z9z33FH6068cXnTq1qjIyMtIyu3btqgGZiEyqqvPeN9udBUCzUbd9y5YD
ME9AybQoSYuyaVK2TUrSomSaRMQcXLT8fHoZT8/3YIzBWkso4FwWJEkSdnd3N4yIaBAEc977
yXanTra7C4B8scOlSQJAqhkV02J1IeXb3cKNvYZ1nY6KbS0lYmLKJuZwK2QqCwijCO8VkCRN
08WdO3emAYCqzojIbHv5ApwClouIhmHkp6dOKyCha7CuXGKgaFCWPnvdXYLxGXNJhkeWQoXx
1BJFEUmWoiIzaZqehqWdRxRFp9pj8VG7sEkR+UhVW6qKima1+TlK1jFUAPExxrcQHyMas6YI
ZRt/HhUbY8URBJZms4W10Wwcx5OfEz7wwAOxc+6kiBwTkRpLq2FeVY+r6qedpe7Fo4cP0dmc
J/ANAhpYbbajQZdNWNMB3bZJ5Yy3JiOwAfX6AibM1SYmJv5DCLBr164jwIfe+1eNMVPttZQB
05Vq3/hf9jzNhYOriHydnG8Q0SDSBpFvEmqTauC4oGDpC5d8rlrFinDi0xNokD8+MTEx9QVC
EdGHHnrosLX2befcq8BhVa0DfsXKtSde+Oseunv6qMYtCtKgSJMiDQrSIM8ieRbpNC0GcsoF
BaFkhcZinddff33OefMeEAPYL2+OsbGxuR07dow75+aBmjGmWe1bPntg32vrioV85zVbvkNO
Hfg6VhIio0TiyIknMo7IOMoIeQIO79/P3hdePjgxOffrNE0nz0kIsHfvXjc2NvbZnXfe+a8s
y8aByeUrVr33xC8f2/jZqROl9euvoJwrk8cQkpLDEZKRQ8mrUJQ8Rw6+zcz0FH/7+74/TM0u
7gUWOXvAvw6qKvfdd19l38t/vDdNWvevv+Ly4as2b+bKzZsZWbuWIAi+cH7fKy+ze/dPpw4c
PXl3Bq8A+o0Iv4w1VYadsk1FthuRS8uVSndPb09XoVg0C7V5NzMzMz0xWfvJbIMngXP9bv5v
0N9PB+exCuDf3d6HA+fU4WgAAAAASUVORK5CYII='
]

{ #category : #'accessing - icons' }
MenuIcons class >> fullscreenWireframeIcon [
	"(c) 2016, Plainicon on www.flaticon.com
	http://www.flaticon.com/free-icon/square-frame_79288
	CC 3.0 BY http://creativecommons.org/licenses/by/3.0/"
	
	^ Icons
		at: #fullscreenWireframeIcon
		ifAbsentPut: [  (Form
	extent: 16@16
	depth: 32
	fromArray: #( 1543503871 2583691263 2583691263 2583691263 2583691263 2583691263 2583691263 2583691263 2583691263 2583691263 2583691263 2583691263 2583691263 2583691263 2583691263 1543503871 2298478591 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2298478591 2298478591 0 3254779903 2298478591 2281701375 285212671 0 0 0 0 301989887 2281701375 2298478591 3254779903 0 2298478591 2298478591 0 2298478591 0 0 0 0 0 0 0 0 0 0 2298478591 0 2298478591 2298478591 0 2298478591 0 0 0 0 0 0 0 0 0 0 2298478591 0 2298478591 2298478591 0 251658239 0 0 0 0 0 0 0 0 0 0 251658239 0 2298478591 2298478591 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2298478591 2298478591 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2298478591 2298478591 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2298478591 2298478591 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2298478591 2298478591 0 251658239 0 0 0 0 0 0 0 0 0 0 251658239 0 2298478591 2298478591 0 2298478591 0 0 0 0 0 0 0 0 0 0 2298478591 0 2298478591 2298478591 0 2298478591 0 0 0 0 0 0 0 0 0 0 2298478591 0 2298478591 2298478591 0 3288334335 2298478591 2281701375 285212671 0 0 0 0 301989887 2281701375 2298478591 3288334335 0 2298478591 2298478591 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2298478591 1476395007 2583691263 2583691263 2583691263 2583691263 2583691263 2583691263 2583691263 2583691263 2583691263 2583691263 2583691263 2583691263 2583691263 2583691263 1459617791)
	offset: 0@0) ]
]

{ #category : #'private - icons' }
MenuIcons class >> helpIconContents [
	"Private - Method generated with the content of the file /home/dgd/help.png"
	^ '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
W2tds0/6AAAAAElFTkSuQmCC'
]

{ #category : #'private - icons' }
MenuIcons class >> homeIcon [
	"Private - Generated method"
	^ Icons
			at: #'home'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self homeIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> homeIconContents [
	"Private - Method generated with the content of the file /home/dgd/home.png"
	^ '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
HrLG8KKGAAAAAElFTkSuQmCC'
]

{ #category : #'menu decoration' }
MenuIcons class >> iconForMenuItem: anItem [
	"Answer the icon (or nil) corresponding to the (translated) string."

	^TranslatedIcons at: anItem contents asString asLowercase ifAbsent: [ ]
]

{ #category : #accessing }
MenuIcons class >> icons [

	^ Icons ifNil: [Icons := Dictionary new]
]

{ #category : #'import\/export' }
MenuIcons class >> importAllIcons [
	"self importAllIcons; initialize"

	| icons |
	icons := FileDirectory default fileNames select: [:each | '*Icon.gif' match: each ].
	icons do: [:icon | self importIconNamed: (icon upTo: $.)] 
]

{ #category : #'import\/export' }
MenuIcons class >> importIconNamed: aString [
	"self importIconNamed: 'appearanceIcon'"
	"will create a method appearanceIconContents holding the string representation of the
	icon, and a method appearanceIcon to access a form built using that string"
	
	| writer image stream |
	writer := GIFReadWriter on: (FileStream fileNamed: './icons/', aString, '.gif').
	image := [ writer nextImage]	
		ensure: [writer close].
	"store string representation"
	stream := String new writeStream.
	stream nextPutAll: aString, 'Contents' ; cr.
	stream nextPutAll: (self methodStart: aString).
	image storeOn: stream.
	stream nextPutAll: self methodEnd.
	MenuIcons class compile: stream contents classified: 'private - icons' notifying: nil.
	"create accessor method"
	stream := String new writeStream.
	stream nextPutAll: aString ; cr.
	stream nextPutAll: (self methodAccessorFor: aString).
	MenuIcons class compile: stream contents classified: 'accessing - icons' notifying: nil.
	^ stream contents
]

{ #category : #'import\/export' }
MenuIcons class >> importPngIconNamed: aString [
	"self importIconNamed: 'appearanceIcon'"
	"will create a method appearanceIconContents holding the string representation of the
	icon, and a method appearanceIcon to access a form built using that string"
	
	| writer image stream |
	writer := PNGReadWriter on: (FileStream fileNamed: './icons/', aString, '.png').
	image := [ writer nextImage]	
		ensure: [writer close].
	"store string representation"
	stream := String new writeStream.
	stream nextPutAll: aString, 'Contents' ; cr.
	stream nextPutAll: (self methodStart: aString).
	image storeOn: stream.
	stream nextPutAll: self methodEnd.
	MenuIcons class compile: stream contents classified: 'private - icons' notifying: nil.
	"create accessor method"
	stream := String new writeStream.
	stream nextPutAll: aString ; cr.
	stream nextPutAll: (self methodAccessorFor: aString).
	MenuIcons class compile: stream contents classified: 'accessing - icons' notifying: nil.
	^ stream contents
]

{ #category : #'class initialization' }
MenuIcons class >> initialize [
	"self initialize"
self initializeIcons.
	Smalltalk addToStartUpList: self
]

{ #category : #'class initialization' }
MenuIcons class >> initializeIcons [
	"self initialize"
	| methods |
	Icons := IdentityDictionary new.
	methods := self class selectors
				select: [:each | '*Icon' match: each asString].
	methods
		do: [:each | Icons
				at: each
				put: (MenuIcons perform: each)].
	self initializeTranslations.

]

{ #category : #'class initialization' }
MenuIcons class >> initializeTranslations [
	"Initialize the dictionary of <translated menu string>-><icon>"

	TranslationLocale := LocaleID current.
	TranslatedIcons := Dictionary new.
	self itemsIcons do:
		[:assoc|
		assoc key do:
			[:str| TranslatedIcons at: str translated asLowercase put: assoc value]]
]

{ #category : #'menu decoration' }
MenuIcons class >> itemsIcons [
	"answer a collection of associations wordings -> icon to  
	decorate  
	the menus all over the image"
	| icons |
	icons := OrderedCollection new.

	"icons add: #('Test Runner' ) -> self smallTrafficIcon."

	" 
	world menu"
	"icons add: #('previous project' 'go to previous project') -> self smallProjectBackIcon."
	icons add: #('go to next project') -> self smallProjectNextIcon.
	icons add: #('select' ) -> self smallSelectIcon.
	icons add: #('jump to project...' ) -> self smallProjectJumpIcon.
	icons add: #('open...' ) -> self smallOpenIcon.
	icons add: #('appearance...' ) -> self smallConfigurationIcon.
	icons add: #('help...' ) -> self smallHelpIcon.
	"icons add: #('windows...' ) -> self smallWindowIcon."
	icons add: #('changes...' ) -> self smallDocumentClockIcon.
	icons add: #('print PS to file...' ) -> self smallPrintIcon.
	icons add: #('debug...' ) -> self smallDebugIcon.
	icons add: #('export...' ) -> self smallExportIcon.
	icons add: #('save' ) -> self smallSaveIcon.
	"icons add: #('save project on file...' ) -> self smallProjectSaveIcon."
	"icons add: #('save as...') -> self smallSaveAsIcon.
	icons add: #('save as new version') -> self smallSaveNewIcon.
	icons add: #('save and quit' ) -> self smallQuitIcon."
	icons add: #('quit') -> self smallQuitNoSaveIcon.
	"icons add: #('load project from file...' ) -> self smallProjectLoadIcon."
	""
	icons add: #('do it (d)' ) -> self smallDoItIcon.
	icons add: #('inspect it (i)' 'inspect world' 'explore world' 'inspect model' 'explore model' 'inspect morph' 'explore morph' 'inspect owner chain' 'explore' 'inspect' 'explore (I)' 'inspect (i)' 'basic inspect' ) -> self smallInspectItIcon.
	icons add: #('print it (p)' ) -> self smallPrintIcon.
	icons add: #('debug it (D)' ) -> self smallDebugIcon.
	icons add: #('tally it' ) -> self smallTimerIcon.
	""
	icons add: #('copy (c)' 'copy to paste buffer' 'copy text' ) -> self smallCopyIcon.
	icons add: #('paste (v)') -> self smallPasteIcon.
	icons add: #('cut (x)' ) -> self smallCutIcon.
	""
	icons add: #('accept (s)' 'yes' 'Yes' ) -> self smallOkIcon.
	icons add: #('cancel (l)' 'no' 'No' ) -> self smallCancelIcon.
	""
	icons add: #('redo (Z)' ) -> self smallRedoIcon.
	icons add: #('undo (z)' ) -> self smallUndoIcon.
	""
	icons add: #( 'find class... (f)' 'find method...' ) -> self smallSearchIcon.
	icons add: #('find...(f)') -> self smallFindIcon.
	""
	icons add: #('remove' 'remove (x)' 'remove class (x)' 'delete method from changeset (d)' 'remove method from system (x)' 'delete class from change set (d)' 'remove class from system (x)' 'destroy change set (X)' ) -> self smallDeleteIcon.
	icons add: #('add item...' 'new category...' 'new change set... (n)' ) -> self smallNewIcon.
	""
	icons add: #('objects (o)' ) -> self smallObjectCatalogIcon.
	icons add: #('authoring tools...')  -> self smallAuthoringToolsIcon.
	icons add: #('projects...')  -> self smallProjectIcon.
	""
	icons add: #('make screenshot')  -> self smallScreenshotIcon.
	
	""
	icons add: #('leftFlush' ) -> self smallLeftFlushIcon.
	icons add: #('rightFlush' ) -> self smallRightFlushIcon.
	icons add: #('centered' 'set alignment... (u)' ) -> self smallCenteredIcon.
	icons add: #('justified' ) -> self smallJustifiedIcon.
	""
	icons add: #('set font... (k)' 'list font...' 'set subtitles font' 'change font' 'system fonts...' 'change font...' 'default text font...' 'flaps font...' 'eToys font...' 'eToys title font...' 'halo label font...' 'menu font...' 'window-title font...' 'balloon-help font...' 'code font...' 'button font...') -> self smallFontsIcon.
	icons add: #('full screen on') -> self smallFullscreenOnIcon.
	icons add: #('full screen off' ) -> self smallFullscreenOffIcon.
	""
	^ icons
]

{ #category : #'private - icons' }
MenuIcons class >> jumpIcon [
	"Private - Generated method"
	^ Icons
			at: #'jump'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self jumpIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> jumpIconContents [
	"Private - Method generated with the content of the file /home/dgd/jump.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABwAAAAcCAYAAAByDd+UAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAACuElEQVRIie3WT2hcVRQG8N+dJtGkZiyiNpUs
0gZRqWhM1GihxU1BMLhx0UVFKiJqXAhuxJV0UxHcFCvuSjbqzo0LqxUXXWgFE5GAUmtTzWia
ltraZuwkk8kcFxOT+Zc0JSIU+sHl8c495/u++9479z5u4HpHuqbsfvdhQNIFwjRGjfnpvxXs
tzcl+9G7QsapCG8Z8+H6BAf0Jj7A7jUZ42jwilGnrl3wIbtSxhG0g2wr2zdxd1Z0tUu5v/ll
hvELzJarKwtR9qTvHVujSQzKpgGn04BID4vMgZ54v/hpTMR0XIx8vBEjIYYqY2pnpBdFGqgZ
pw3KNqPONA2WHESPTIo4+Ki333zXcOuQrTabVwKbbKwkb7lVvLZRPFtD0bPI0YANDZFH7BDe
gxi+Nw0//ZIDngMTpj1lv098bdb8cs3Mn2zOS5cwuRTt0+2oKblVV5gp21Px2FHs2LfdO55f
mtumyyEvN9qOyjuMPehswrWaYITHwWN3tj2TdrjFzTXzg+7Rrq22qFioXFuxrQnXaoKSLRAP
3GavJ0DO+aXpEV8qKC7nz12hkF8WqRL8l6saLQ2CS67Lsjqc8If7vWq3Pmf9Zay+xc5OIJbv
SysyriAYzki60/hFM0MFHzumZMFnRhur8xc4/1tNKE3UcdWh4ZGm5Btw/NzCifLvjjQTguIs
E6NE1equoEpwiasKDW0R3S6n8IKZUubHlpxCf6e8QuPKTh5nfq7W7GGqmyAyXq9vi8Y+nJLL
3KUHfZdGJ81tvclC72KTl+Y58zOT4yxUvazAF6SvqsQZie8cqqdvvpcOyqaSH9ADdt4u9nUS
uVqhikHpI5ysif4aLR70rctrE6SyeW/wuVhsxAy6KhbiDtKUyq5yTs1H6iqb99WPpzaHFe1a
NW8Z6zieqvG/HcCNwuv+xbiB6x//APor/zPsp+AoAAAAAElFTkSuQmCC'
]

{ #category : #'private - icons' }
MenuIcons class >> loadProjectIcon [
	"Private - Generated method"
	^ Icons
			at: #'loadProject'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self loadProjectIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> loadProjectIconContents [
	"Private - Method generated with the content of the file /home/dgd/loadProject.png"
	^ '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
AElFTkSuQmCC'
]

{ #category : #'import\/export' }
MenuIcons class >> methodAccessorFor: iconName [
	"Template method for an icon accessor method"

	^ '
	^ Icons
		at: #{1}
		ifAbsentPut: [ self {1}Contents ]' format: {iconName}
]

{ #category : #'import\/export' }
MenuIcons class >> methodEnd [

	^ ''
]

{ #category : #'import\/export' }
MenuIcons class >> methodStart: aString [

	^'^ '
]

{ #category : #'private - icons' }
MenuIcons class >> objectCatalogIcon [
	"Private - Generated method"
	^ Icons
			at: #'objectCatalog'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self objectCatalogIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> objectCatalogIconContents [
	"Private - Method generated with the content of the file /home/dgd/objectCatalog.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABwAAAAcCAYAAAByDd+UAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAAD5klEQVR4nN2VW2wUVRjH/+ecmdmd7c7e2qVb
uu1ulrZWoNUURYILSiKoBcRIN+gLUUKMifLiAzHEhHcVtInaxJQYY0g0Jo1CEBXaKBA3RhMp
0Ai10NpUbO32uu3u7GXO8QF6o7NLL5FE/8nJZL75n+/3zZn5zgH+S6r0s+cAVN4z4NqQfLE6
KLcDkBY6hy6D56oOSIVHDjjvC/hYI4BCACW3rznFlgh7oNTL3n5jr7ZuZ1i1MEYq/F62v6pc
fnV4nNfHE6J5iXnnyVnooH++/oI22P5psRBR/5yxdb21D0BFvgSLXdIxVSGHO25k9LLiuYtz
/NtEouN6+n0AXfkSzHzsNRE75ExRTienWVxq6euLGc19MeP8roND35xr8ganHrsd1AKA363i
GSDVG2pDgffKfN6kmTF68aoxDPhv317jQowCwMnzyURPvyEatqgFTo3tuTnE37ob9JZqdr7Y
9PkpMT4RNx2hp1/unm3fsFZpPxCxDwRLpEbNxp6tKpdaHQUkBsC6sDdcpG7GjJ4vziYP9Y8Y
pwAg3osvARAA4l8B9vYbu0zCeWHA8hp/SbrnwDlLeibanh4ajRtmxoSeUhaa1PMIHGlJeYJJ
dLshcHzinN42H8jR1tIa3dPSGjXPIpDIB7FvUlYTTupLKtyRVXUrHpKLJUrdDD80XrEDmAaS
hVadT1rYuu+x5+8/pvgtSExQ9FwbQurvNIrXSPijc0D/6/q4C6eRmvuGJrIBz/goi1AC5yBw
cswwPgaQvdPHCf/F7rEi2taD0Stjv/E0PyEovqMZ7ROtzuqfaNefiiP9VT6WJUDY94cs2shl
rVh0OXziQ9WdCFGpA8BKEz999HBVMniwUGhh676poD2svFnzUalw7bC1TMVMj6dyyj44qrq2
v2a121dQBg+heFhS5K2Sxfu1kdo4KvixO6aIuKJvKQ97QrFL8f50yDirlVqaJI1FhMxdkkZC
cZo6gj5kTdvCAbptt6LO26JWMxkPMjmAmT31ln+TpYnIvC4ukiAE6zVDXaf4pP361UzAVqtA
rVIsdkmpB8z7ULESknM/rCFygQRUT8M2WyrBySt6Z9YtNAHZy2pJlg/wDM+4nrRh4tcURs4k
khDEB5j/NOlRYeQ8Zi6LzGQW6Jyuzkj1Z51qrGhzQVHyRgaGLiih3GWM8HBiiG8EEQOqLX1i
+AImgRxtUUZZ87tW597dik2eHe/iWWybHPyp2zA2zI67HrcGeUbsAEU3Eakfxy5gJFfBuaSW
E/bzO6pzvNdRImLOleIzmye1irLfAQQXm2y28jU+8TD2khukQQDapOCnBzg/CkBfDvD/r38A
0MR5I7Mls/AAAAAASUVORK5CYII='
]

{ #category : #'private - icons' }
MenuIcons class >> objectsIcon [
	"Private - Generated method"
	^ Icons
			at: #'objects'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self objectsIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> objectsIconContents [
	"Private - Method generated with the content of the file /home/dgd/objects.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABwAAAAcCAYAAAByDd+UAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAADhElEQVR4nMWWW0wcVRzGv3POXHZhZdldoAud
RkzRQFsaxBpTNcUtIMZaTdoQBa+tsYRYS2mjD/riiyY2pkL6JulTaUgkaayJ8aUoohgfWlOl
GiNqTY1chr1Bmc7uzuX40E4i7A7Nsqt+yTzM+X///++cyXeSAf5n1Ycp+2gDoVcrCVUVwr4s
BXvxXyEFKO0NE5o8UxK05/zVXPdv5JO+Kr5bkBcrCZkAIBUNJgHbFcKSCX8N5+VK1nNYLtVC
oIPFYBEAqCbsq6GSwMN7RE9Ok845apdmr6vc3gxgoRAgBYA0+NZ2UXY1eQlBq+CxBKC5EJgD
FEWASjcP66o6yrwcUIoBNGxAi3J7TePXVlqjwFQxgCAE50+klnQ30xXLwPec2xsU5bZAr4Su
ynJ62Zm9WgwANM4//9k2D4Qo8TUzaYXxJ8vAXi26aFZv6tnSsr/zrsad2tWpb/9yA4Yr2ECk
WW5Sk7ag6Xx8rc2Fqwgbq6dC8nXZd+N9r998XPDEA4SqAtDumNq6+59q7e5/s6OzP5jrALU1
bMacVPj2OnEBwJbVhqykSMBWC2iWgJABfGcCFwHc+Kdn76FDJfpyaQ/n9sLYyOBZAPxWaf/B
J0o/PP1WIPjLNRN7jkdVRolOCBBdtMr0NHl17WjeRq1PH7snOj99LDE9ETRSyzt3NEieD476
KzZvFFb4/pg18eAr6rXZmL2tICAAhMrZ5P310gMfnwgyWcweZ1rAfS/Nx3741egAcClnkvJR
LGlFLk+nhx49Ek2qieyrNXR+2fhz3joN4BLgEt08lZmL2b0/zvgOtPUltNXFhlpR9HrJJue9
GEB0dr4tNbU935hOm1Fn7crvBgyTY1eTDNjY7bAE1yl5KC4lj1siTlGCl1MZjoPvJBa/uJie
ppTXtNzrkcMV9I6ZqLULwHjBsNauvp727iN3A4BSxeYb7hRioTJ6+FaZAHiopoINl/uEiLOw
QuGWF0ZlWWxyA+ipzG/qxJnHACDyXN+TDGTpwvDAOABUBdk5NW69i5t3N6eyPiljdNvUuYE6
t4bGfUcBAO3P9O+wLbvswsjAJ05NjVv73PocrSs0jzz7msKJHRkbGRzOtzd/IAdlnPYGzJmT
efeuB0gAJhH7vdHRUes/AXIC47Ozp5bWA1sXsFBlpTRjWJmuN07OuTVoeqq4wIV4rOPTb67n
/l8EAN3OFAL8G3xJPtRdAsoRAAAAAElFTkSuQmCC'
]

{ #category : #'private - icons' }
MenuIcons class >> openIconContents [
	"Private - Method generated with the content of the file /home/dgd/open.png"
	^ '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
0/8ClPo3sCGCJrEAAAAASUVORK5CYII='
]

{ #category : #'private - icons' }
MenuIcons class >> paintIcon [
	"Private - Generated method"
	^ Icons
			at: #'paint'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self paintIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> paintIconContents [
	"Private - Method generated with the content of the file /home/dgd/paint.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABwAAAAcCAYAAAByDd+UAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAAEK0lEQVR4nLXWW2xUdRoA8N85M53O2Av0Rgus
tJZCKASvUO+E3aBFN7IbWGNMdqMmPGlMdC/ZGB/U+GI0IfqiPigvGLImXtaYdReMAomu2TXB
FYGFRSUVSgstCKWdGTpzztmHKaQhiEaHLzk5+V++/M53/l9yTsqlibCHNS3kTjB8iYxKLKS1
my39c7JJX0Mm6eHFS+mF3ezYsLY7GXru2uTdh/qSK3PppJtl5zZUU5vPH3ovz65Yv34Nde2S
oMb1S2fBLVUHu+jC0w+t7aT9GtGZgiihrSUnYEnVwRRPLOnM1d7y81uJI6WxEyKhQqEMcVXB
Lhbhdw+u6WB2H2PfiGLKAvliCSarCqb4/fzZtambbr2e2kbGBsRxIBIaz5fgZNXAn5HDPf3L
ZjL3hsrkVIURJvJlAfurBmZYi8Zf9V9FXQeTp5k4WqkwCAwcGRezr2pgwAOLO3Nm9VxZmRjZ
DaKEdFA2li9FuWqB3czDL1Yvm0HTwilwVwWMA/l8Hv69h/GqgAH3Ibhz5aJKs0wMkx8Bcczg
0VMCtk7P+amv9N7u2bVauhZXRsd2nVuIksCufcclvF8V8Ao60XtTbz2N84hKjHxxbr1Yju3+
6tuxy/lXVcCQ1XDj4gZSGY7upFw4t35gaFyS2Lad8vS89I8FcUcQkCSJ/25/22XRqHmtKUFA
HLFt1yi8d4EH/dHRPP/qa3zWer+O324ycPUz/rS9x9YvSg6PTvpk38lCwuvnJ12wwn76WlmX
ITvI5q3nncNUDDe3t+vu7dXU3KwUxxb03ezz44u8smmjhDe/5tT3gneycCn/XEUqwB4eDvnN
P3jrvK3RgZ07fdLRJB1N+vqbQUE6LYoiA0fGinjhQsUEsJ7NXdz2Hx45zYcd/HUWc7NkM9Tt
5tPXWXE2qYdHc3W1G5bd2CXbkBEFjAyfduxI4tihwxNxFN31FdsuBKYRNLJ0Di37WXiKkSFe
Ha6c7ztbGOrnqrMJK0kf4vFV110hW5NRnqQcJrJtDUYPHRZH0RvfhZ0Fkw0sXUl9LS+sYktW
5QO2k+dv574t0w7/NEEYBE1zk6xykVKqApbDREdTncFD39Z9F8a0Lt3OeEDbBzz5N/5yBvdS
28Lm1dwNS6g/yfI4STaOHJ/QnE9pyodmFkKNxVAuDqH4g8DbWTHCuq08FfPnUVyGXxPW8NrN
/LHIwTDwcYqP3th7YHjGRKgtn9IydR05Oibg04uB07s03cqX/eyYw7XLpyZbsIbMOzy7sr3b
L8MOj536/OVEkJ03lnGmJlFIx947M+TgyMn/Zdl4MTCYPuhndT0vddLVgAbUIYMU/p6qiR+Z
sTxcUMgp1sSOZUt2ZE54+8SAwfzEjjQP7OfgDwbhScKPmR/SENIQVe71CTPRdpzriql0thCV
UzgcVH7lN33J3otBZ+P/SNx4XWnWkNMAAAAASUVORK5CYII='
]

{ #category : #'private - icons' }
MenuIcons class >> projectIcon [
	"Private - Generated method"
	^ Icons
			at: #'project'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self projectIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> projectIconContents [
	"Private - Method generated with the content of the file /home/dgd/project.png"
	^ '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'
]

{ #category : #'private - icons' }
MenuIcons class >> publishIcon [
	"Private - Generated method"
	^ Icons
			at: #'publish'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self publishIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> publishIconContents [
	"Private - Method generated with the content of the file /home/dgd/publish.png"
	^ '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'
]

{ #category : #'accessing - icons' }
MenuIcons class >> radioButtonOff [

	^ Icons
			at: #'radioButtonOff'
			ifAbsentPut:[ (Form
	extent: 12@12
	depth: 32
	fromArray: #( 0 0 0 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 0 0 0 0 0 4294967295 0 0 0 0 0 0 4294967295 0 0 0 4294967295 0 0 0 0 0 0 0 0 4294967295 0 4294967295 0 0 0 0 0 0 0 0 0 0 4294967295 4294967295 0 0 0 0 0 0 0 0 0 0 4294967295 4294967295 0 0 0 0 0 0 0 0 0 0 4294967295 4294967295 0 0 0 0 0 0 0 0 0 0 4294967295 4294967295 0 0 0 0 0 0 0 0 0 0 4294967295 4294967295 0 0 0 0 0 0 0 0 0 0 4294967295 0 4294967295 0 0 0 0 0 0 0 0 4294967295 0 0 0 4294967295 0 0 0 0 0 0 4294967295 0 0 0 0 0 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 0 0 0)
	offset: 0@0)].
]

{ #category : #'accessing - icons' }
MenuIcons class >> radioButtonOn [

	^ Icons
			at: #'radioButtonOn'
			ifAbsentPut:[ (Form
	extent: 12@12
	depth: 32
	fromArray: #( 0 0 0 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 0 0 0 0 0 4294967295 0 0 0 0 0 0 4294967295 0 0 0 4294967295 0 0 0 0 0 0 0 0 4294967295 0 4294967295 0 0 0 4294967295 4294967295 4294967295 4294967295 0 0 0 4294967295 4294967295 0 0 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 0 0 4294967295 4294967295 0 0 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 0 0 4294967295 4294967295 0 0 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 0 0 4294967295 4294967295 0 0 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 0 0 4294967295 4294967295 0 0 0 4294967295 4294967295 4294967295 4294967295 0 0 0 4294967295 0 4294967295 0 0 0 0 0 0 0 0 4294967295 0 0 0 4294967295 0 0 0 0 0 0 4294967295 0 0 0 0 0 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 0 0 0)
	offset: 0@0)].
]

{ #category : #'accessing - icons' }
MenuIcons class >> radioButtonPressed [

	^ Icons
			at: #'radioButtonPressed'
			ifAbsentPut:[ (Form
	extent: 12@12
	depth: 32
	fromArray: #( 0 0 0 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 0 0 0 0 0 4294967295 0 0 0 0 0 0 4294967295 0 0 0 4294967295 0 0 0 0 0 0 0 0 4294967295 0 4294967295 0 0 0 4294967295 4294967295 4294967295 4294967295 0 0 0 4294967295 4294967295 0 0 4294967295 0 0 0 0 4294967295 0 0 4294967295 4294967295 0 0 4294967295 0 0 0 0 4294967295 0 0 4294967295 4294967295 0 0 4294967295 0 0 0 0 4294967295 0 0 4294967295 4294967295 0 0 4294967295 0 0 0 0 4294967295 0 0 4294967295 4294967295 0 0 0 4294967295 4294967295 4294967295 4294967295 0 0 0 4294967295 0 4294967295 0 0 0 0 0 0 0 0 4294967295 0 0 0 4294967295 0 0 0 0 0 0 4294967295 0 0 0 0 0 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 0 0 0)
	offset: 0@0)].
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallAuthoringToolsIcon [

	^ Icons
		at: #smallAuthoringToolsIcon
		ifAbsentPut: [ self smallAuthoringToolsIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallAuthoringToolsIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 2808846277 4285241285 4285241285 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4104749094 16777215 16777215 16777215 4285241285 4288461528 3765147589 4285241285 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4156465773 4038761825 16777215 16777215 16777215 4285241285 4269385423 4287147474 4272275675 3898314177 16777215 16777215 16777215 16777215 797072384 4273576540 4294437589 4256074563 275795968 16777215 16777215 2892732357 4183986884 4286491090 4288461528 4255103704 3881930943 3064638120 3131747241 3920013734 4104492405 4293443700 4291597568 2693556224 16777215 16777215 16777215 2540345030 3580466371 4268792519 4286622160 4289118684 4270501585 4285635011 4294967295 4291342725 4292591497 4292980025 3953030672 4288257175 16777215 16777215 16777215 16777215 4083520451 3731461315 4285701320 4286227917 4289250269 4219249868 4286878622 4272851774 4292917094 4291794688 4124363449 4288257175 16777215 16777215 16777215 16777215 16777215 3951402422 4268004291 4286228432 4285636298 4272472796 4272064850 4291274851 4292526223 4071986259 4226279912 4288257175 16777215 16777215 16777215 16777215 16777215 4288257175 4259637483 4268725432 4286293452 4286030796 4273182039 4290882421 4289438090 4256807607 4260689397 4288257175 16777215 16777215 16777215 16777215 16777215 4288257175 4294901502 4259177190 4288849830 4289112743 4288981159 4288849829 4289375657 4275953373 4277795321 4288257175 16777215 16777215 16777215 16777215 16777215 4288257175 4294901502 4060020478 4294967295 4294967295 4294967295 4294967295 4294967295 3824020973 4277795321 4288257175 16777215 16777215 16777215 16777215 16777215 4288257175 4278124286 3003055870 3317805978 3874482915 4274568359 4291740331 4289906910 3102337511 3992582649 4288257175 16777215 16777215 16777215 16777215 16777215 4288257175 4278124286 3671774150 3233788567 4258252210 4292135090 4291940812 4290889933 3269254362 3791321850 4288257175 16777215 16777215 16777215 16777215 16777215 3868826775 4227726845 3923234754 2916008878 4241934256 4293847268 4290693332 4272668629 4190688481 3690790396 3868826775 16777215 16777215 16777215 16777215 16777215 3029965976 3471502058 4191934156 4192131794 4276808165 4294111470 4294177521 4292074211 4258191588 3506174971 3130694807 16777215 16777215 16777215 16777215 16777215 865835926 4070153367 3924421097 4244504061 4277926649 4294704122 4294506744 4294440951 3638484958 4019821720 1620219282 16777215 16777215 16777215 16777215 16777215 33554432 1553505174 3550059671 3952712855 4288257175 4288257175 4288257175 4288257175 3365510294 1653576333 16777215 16777215 16777215)
	offset: 0@0)
]

{ #category : #'private - icons' }
MenuIcons class >> smallBackIcon [
	"Private - Generated method"
	^ Icons
			at: #'smallBack'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self smallBackIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> smallBackIconContents [
	"Private - Method generated with the content of the file /home/dgd/smallBack.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAABqklEQVQ4jb3Sv0uUARgH8M9792bHmZRJJYIt
tghFeW8HJSGBhNDY0tAQKbRWUA1tTg5lf0AtTREaERWEEE1BDRZEtQSZS3CdyqXe+eP03rfh
BClJsKAvPNPzfL/Pry//iPQfM0edsk9GwdTWJPNa5TwUSUQqcg5sVh781rVf4pa2bLNLnQx9
4Ef1O0YQowENEnMY885YXeCkUNkdiQvh2Q7DV4ZdC++p3n7PyCRhiu1pGkN2hNQSvsxXBfoC
kSweCYO+XYMn9PedN6HgsTcahLp1yunQKCMWKykbjV+Z6h1lfuV+IHITV904pPXMEQWlDXu2
aNJuD5hQMGeB0y8oLn0O0QYOZzeSi19ZmDWzWjWzuoKEVJp0yMIq1NLavMaAWiVjf4nG5npB
ucTEWxbnWK6wsrQWy1RSPFkk8bF+xC49Up673Jx1sMzOvVRK1DI8qFKMmY6ZrrIcr0+YuL7+
xi69Up4Z2J1xbJa4xngLd2cIDIp9E9iGUGJJYFKTl7/u3KVHpOhiNvG0KXE8SEQ+bWakjchr
Fxlfc2Is59zWBOoI5HXLy/8N+f/iJ/5OkGsa/+A/AAAAAElFTkSuQmCC'
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallBroomIcon [

	^ self fugueBroomIcon
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallCancelIcon [
	"Private - Generated method"
	^ Icons
			at: #'smallCancel'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self smallCancelIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> smallCancelIconContents [
	"Private - Method generated with the content of the file /home/dgd/smallCancel.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAACC0lEQVR4nK2RX0hTYRjGf+d85882bWZMESIC
CSHOaYu6TIksRwRCXhgUOLqWsn9IlFAQ3YRSoFTQWEFGeFUXBd4FQVC3zrrJIOgiglzTOd12
tp23myY6XBfRe/XxPt/zvs/3++B/Vgx27oXdjfQ9EI5C+8aeXjs4kDhu8zVu8dmFvi2Gdx01
WThh892F85vELohctPHKvTFZfvVUxrYHSg4cqekuREe3mdnl6UnxBnrkWgDfgRiAAaCBlfOp
+Ok5U31ZYHTmiVUaTMzqK+W4D8X+sPnm6nSySfM89A/v+eWDArUpxT44fM6i6LUhK8k7svTy
sYwEVeFmi1VYev1McjMPpdyhZMTGdyBR82kbhzjQe8xmdqJFswr3pvA1DVpb0TMZAlcucDnr
+289hubhecOfcKHvko1X7VCSn7olq+PXpdSuy7BFxYVT9feN+oYG5i6FplerlMduoGmgTKhA
WYdvDTf/eUL//RAVaUN+NCPzBpJWSCaMFCLIWZN8FA40ij7wqIlqzZw2kCGDwoRNNa2QbBjJ
R5CEyVIU3PrNh1IbzPMGcsZgzYFuB05PBvDTClluQXIRZNBg8SCE1hlo0OoY6ItF+FmE21D4
WCH+Cd4BJIsErCAp8midYehU7JirEALW1lOcVKReNCODilUHurfgMzweQB4EkRjc3ZJDFHpc
iP4F8v6GEP+1fgOfrL0AYYB91QAAAABJRU5ErkJggg=='
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallCenteredIcon [

	^ Icons
		at: #smallCenteredIcon
		ifAbsentPut: [ self smallCenteredIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallCenteredIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 2862522779 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 2862522779 16777215 16777215 4288257175 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4289440683 4289440683 4289440683 4289440683 4289440683 4289440683 4289440683 4289440683 4294572537 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294440950 4294440950 4294440950 4294440950 4294440950 4294440950 4294440950 4294440950 4294572537 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294572537 4294572537 4289309097 4289309097 4289309097 4289309097 4294572537 4294572536 4294506743 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572536 4294506743 4294440950 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294572537 4294572537 4294572537 4294572537 4294572536 4294506743 4294440950 4294375157 4294309365 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294572537 4289440683 4289309097 4289309097 4289309097 4289309097 4289309097 4294309365 4294309364 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294572536 4294375157 4294309365 4294309364 4294243571 4294177778 4294111985 4294243571 4294177779 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572536 4294506743 4294440950 4294375157 4294309365 4294309365 4294243572 4294177779 4294177778 4294111985 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294440950 4294375158 4294309365 4289309097 4289309097 4289309097 4289309097 4294111985 4294046193 4294046193 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294375157 4294309365 4294309364 4294046193 4294046193 4293980400 4293914607 4294046193 4293980400 4293980399 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294901502 4294901502 4294901502 4294901502 4294901502 4294901502 4294901502 4294901502 4294901502 4294901502 4294967295 4288454554 16777215 16777215 2862522779 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 2862522780 16777215)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallChangesIcon [

	^ Icons
		at: #smallChangesIcon
		ifAbsentPut: [ self smallChangesIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallChangesIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 16777215 16777215 490044345 2671475640 3728440505 4130765241 3845814969 3157949368 1395947704 87254732 16777215 16777215 16777215 2033415863 271610031 16777215 16777215 1345746614 4130962105 4201816526 4288331486 4289908199 4289907942 4288593630 4100561352 4030167480 1479833527 16777215 1714780343 4281563063 255031227 16777215 691173044 4114250680 4288134110 4289186277 4289448678 4290631148 4291288047 4292076787 4292602100 4291288045 4115827136 3224795577 4148724669 4231297207 238518454 16777215 2604301240 4252279246 4286425299 4282351034 4281628855 4231756985 4083652551 4272736226 4292798965 4292930549 4293062134 4254381786 4291879151 4181425337 222000817 16777215 4080630456 4282745533 4265508539 4114316473 1966241975 422804152 1161066169 3443096760 4117469896 4292141808 4293324792 4293587448 4293587448 4198202553 187593913 16777215 4264916919 4214979769 2641535701 3862395320 590575030 16777215 16777215 16777215 1613920439 4281628855 4291813359 4291682544 4293390584 4198202808 171147443 16777215 4231231415 2119404740 729984219 324965577 33587328 16777215 16777215 71336127 3292101303 4204509915 4293652984 4292930549 4293587448 4214980024 154759594 16777215 222000817 16777215 16777215 16777215 16777215 16777215 16777215 2687727799 4281563063 4165830334 4149447104 4149447104 4149447360 4281563063 138444991 16777215 4180899767 4264785847 4264785847 4248008631 4231231415 4214454199 3107157943 490044345 406156725 406156725 406156725 406156725 406156725 473396918 16777215 16777215 4231231415 4293521912 4293521912 4293456120 4255630561 3761732280 271610031 16777215 16777215 16777215 16777215 445231586 964537051 4231231415 204177599 16777215 4231297207 4293587448 4291616752 4291879151 4264785847 1781757623 16777215 16777215 16777215 187593913 3912595640 2373363157 3260780998 4281563063 87254732 16777215 4248271288 4293587448 4293390584 4293456376 4291419116 4115958721 3392765112 909407928 16777215 1781757623 3980361147 4283862726 4265311417 4197940152 16777215 16777215 4248402616 4292798965 4271947742 4293258743 4293062134 4292076530 4271619037 4115892929 4214519992 4282022840 4265245624 4282417339 4283665089 2822470841 16777215 16777215 4265048504 4150630087 3560339896 4099247298 4290630890 4291879409 4291091181 4290368490 4289383143 4287871453 4287476954 4288265438 4114184888 707885494 16777215 16777215 4281563063 2469820856 16777215 1412724406 3996678584 4082995909 4287608282 4288857058 4288923108 4288002782 4235765200 4130962105 1530230966 16777215 16777215 16777215 2721216695 16777471 16777215 16777215 87254732 1395947704 3191569337 3912858808 4197742775 3829103801 2856222137 607287480 16777215 16777215 16777215)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallConfigurationIcon [

	^ Icons
		at: #smallConfigurationIcon
		ifAbsentPut: [ self smallConfigurationIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallConfigurationIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4282944717 4282944717 4282944717 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 1480812686 4282944717 4282944717 1480812686 4282944717 4291155690 4282944717 1480812686 4282944717 4282944717 16777215 16777215 16777215 16777215 16777215 16777215 4282944717 4291155690 4287805149 4282944717 4285374933 4289250531 4285374933 4282944717 4287805149 4291155690 4282944717 16777215 16777215 16777215 16777215 16777215 4282944717 4287805149 4289250531 4289250531 4289250531 4289250531 4289250531 4289250531 4289250531 4287805149 4282944717 16777215 16777215 16777215 16777215 16777215 1480812686 4282944717 4289250531 4287082715 4098460874 4284323793 4098460874 4287476956 4289250531 4282944717 1480812686 16777215 16777215 16777215 16777215 4282944717 4282944717 4285374933 4289250531 4098460874 2923986606 1497524108 2537911972 3998060491 4289250531 4285374933 4282944717 4282944717 16777215 16777215 16777215 4282944717 4291155690 4289250531 4289250531 4284323793 1497524108 16777215 1497524108 4284323793 4289250531 4289250531 4291155690 4282944717 16777215 16777215 16777215 4282944717 4282944717 4285374933 4289250531 4166095308 3445593287 1497524108 3225977527 4098460874 4289250531 4285374933 4282944717 4282944717 16777215 16777215 16777215 16777215 1480812686 4282944717 4291155690 4287082715 4166095308 4284323793 4098460874 4288330975 4289250531 4282944717 1480812686 16777215 16777215 16777215 16777215 16777215 4282944717 4287805149 4289250531 4289250531 4289250531 4289250531 4289250531 4289250531 4289250531 4287805149 4282944717 16777215 16777215 16777215 16777215 16777215 4282944717 4291155690 4287805149 4282944717 4285374933 4289250531 4285374933 4282944717 4287805149 4291155690 4282944717 16777215 16777215 16777215 16777215 16777215 16777215 4282944717 4282944717 1480812686 4282944717 4291155690 4282944717 1480812686 4282944717 4282944717 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4282944717 4282944717 4282944717 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallCopyIcon [

	^ Icons
		at: #smallCopyIcon
		ifAbsentPut: [ self smallCopyIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallCopyIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 1335796123 2140773783 2140773783 2140773783 2140773783 2140773783 2140773783 2140773783 2140773783 2140773783 2140773783 1403036570 16777215 16777215 16777215 16777215 2107219353 2147483647 2147483647 2147483647 2147483647 2147483647 2147483647 2147483647 2147483647 2147483647 2147483647 2140773783 16777215 16777215 16777215 16777215 2107219353 2147483647 2146694131 2146694129 2146694129 2146694129 2146694129 2146694129 2146694131 2146694131 2147483647 2140773783 16777215 16777215 16777215 16777215 2107219353 2147483647 2146694131 2144588753 3500845735 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 2879299995 2107219353 2147483647 2146694131 2146694131 4254834329 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4288257175 2107219353 2147483647 2146694131 2144588753 4254768536 4294967295 4294177778 4294177778 4294177778 4294177778 4294177778 4294177778 4294177778 4294177778 4294967295 4288257175 2107219353 2147483647 2146694131 2146694129 4254834329 4294967295 4294177778 4291940816 4291940816 4291940816 4291940816 4291940816 4291940816 4294177778 4294967295 4288257175 2107219353 2147483647 2146694129 2144457169 4254768536 4294967295 4294177778 4294177778 4294177778 4294177778 4294177778 4294177778 4294177778 4294177778 4294967295 4288257175 2107219353 2147483647 2146562545 2146562545 4254834329 4294967295 4294177778 4291940816 4291940816 4291940816 4291940816 4291940816 4294177778 4294177778 4294967295 4288257175 2107219353 2147483647 2146562545 2144325583 4254768536 4294967295 4294177778 4294177778 4294177778 4294177778 4294177778 4294177778 4294177778 4294704123 4294309365 4288257175 2107219353 2147220475 2146430959 2146430959 4254834329 4294967295 4294177778 4291940816 4291940816 4291940816 4291940816 4291940816 4294046193 4294572536 4291743694 4288257175 2107219353 2146825717 2146957301 2146825717 4254834329 4294967295 4294177778 4294177778 4294177778 4294177778 4294177778 4288520347 4288520347 4288520347 4288520347 4288257175 1352639388 2140904857 2140904857 2140904857 4254768536 4294901501 4294177778 4294177778 4294177778 4294177778 4294704123 4289243814 4294704123 4294572537 4293454312 4288257175 16777215 16777215 16777215 16777215 4221214104 4294704122 4294177778 4294177778 4294177778 4294704123 4294704123 4289243814 4294704123 4293519848 4288257175 3432619159 16777215 16777215 16777215 16777215 4221214104 4294375158 4294572536 4294506743 4294835708 4294769916 4292664540 4289243814 4293454312 4288257175 2140773783 16777215 16777215 16777215 16777215 16777215 2744950939 4288322968 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 3214580887 2140773783 16777215 16777215)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallCutIcon [

	^ Icons
		at: #smallCutIcon
		ifAbsentPut: [ self smallCutIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallCutIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 16777215 16777215 2086296920 4270888083 4169895821 16777215 16777215 16777215 16777215 3580785006 4271151255 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4288060314 4294440951 3950673018 3178000237 16777215 16777215 16777215 4254110610 4292401881 4018045312 16777215 16777215 16777215 16777215 16777215 16777215 4288257693 4292467931 4293980656 3833232506 16777215 16777215 1851284056 4290165433 4291744465 4288060571 16777215 16777215 16777215 16777215 16777215 16777215 4271217305 4290626241 4294441207 4186343815 3178000237 16777215 4288257693 4292073430 4290297019 4169435271 16777215 16777215 16777215 16777215 16777215 16777215 1700288598 4288323486 4292928482 4294046449 4001268610 3597693552 4290823620 4292204502 4288257693 3177671015 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4220227726 4290757570 4294572537 4271151254 4289441710 4290823106 4290823363 3900144248 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 1549162838 4288257693 4293257190 4294309621 4289178795 4290033847 4287994521 1549162838 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 3698554484 4290954692 4293651948 4290165433 4288389279 3580785006 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 2539610207 4288060314 4291744208 4290625727 4283997890 1549162838 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 2134145207 4266566084 4283212999 4287417300 4292537599 4292537599 4266631363 2134145207 16777215 16777215 16777215 16777215 16777215 16777215 2134145207 4288667371 4292537599 4292537599 4283213770 3744684890 4285454303 4292537599 4292537599 4292537599 4283212999 2134145207 16777215 16777215 16777215 2134145207 4288667371 4292537599 3945492591 4287941348 4279934652 16777215 458557696 4292537599 4283279307 4118390190 4292537599 4283212999 2134145207 16777215 16777215 4268539848 4292537599 3125100092 16777215 4287941605 4280000187 16777215 16777215 4283212743 4272087534 16777215 3057990715 4292537599 4281899979 16777215 16777215 4280130745 4288734706 16777215 3477099345 4292537599 4281899979 16777215 16777215 4281899979 4290041584 3544143702 16777215 4292537599 4281899979 16777215 16777215 4281899979 4292537599 4288734706 4292537599 4245856928 1549473302 16777215 16777215 1549473302 4269132498 4292537599 4292537599 4292537599 4245727654 16777215 16777215 16777215 4281899979 4280195254 4280130488 1549473302 16777215 16777215 16777215 16777215 2538548780 4281899979 4281899979 4281899979 16777215 16777215)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallDebugIcon [

	^ Icons
		at: #smallDebugIcon
		ifAbsentPut: [ self smallDebugIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallDebugIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 2134145207 16777215 16777215 4231297207 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 2134145207 16777215 16777215 4231297207 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 2134145207 16777215 16777215 4231297207 4231297207 16777215 2134145207 4231297207 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 2134145207 4231297207 4290304767 4290304767 4231297207 4231297207 4231297207 16777215 4231297207 4231297207 4231297207 16777215 16777215 16777215 16777215 16777215 16777215 4231297207 4290304767 4231297207 4290304767 4290304767 4290304767 4231297207 2134145207 16777215 16777215 16777215 16777215 16777215 4231297207 16777215 16777215 16777215 4231297207 4290304767 4290304767 4290304767 4290304767 4290304767 4231297207 16777215 16777215 16777215 16777215 16777215 16777215 4231297207 2134145207 2134145207 4231297207 4290304767 4290304767 4281694904 4290304767 4290304767 4290304767 4231297207 16777215 16777215 16777215 16777215 16777215 16777215 4231297207 4231297207 4231297207 4290304767 4290304767 4290304767 4281694904 4290304767 4290304767 4231297207 4231297207 4231297207 4281628855 16777215 16777215 16777215 16777215 16777215 16777215 4231297207 4290304767 4290304767 4290304767 4281694904 4290304767 4231297207 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4231297207 2134145207 4231297207 4290304767 4290304767 4290304767 4285966811 4231297207 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4231297207 16777215 16777215 4231297207 4231297207 4231297207 4231297207 2134145207 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4231297207 16777215 16777215 16777215 4231297207 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4231297207 16777215 16777215 16777215 4231297207 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4231297207 16777215 16777215 16777215 16777215 16777215 16777215)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallDeleteIcon [

	^ Icons
		at: #smallDeleteIcon
		ifAbsentPut: [ self smallDeleteIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallDeleteIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 1382511397 4284837928 4284837928 4284837928 4284837928 4284837928 4284837928 4284837928 4284837928 4284837928 4284837928 4284837928 4284837928 1986424869 16777215 1449488679 4287666543 4292994782 4292994782 4292994782 4292994782 4292994782 4292994782 4292994782 4292994782 4292994782 4292994782 4292994782 4292994782 4288192890 1147498793 4284837928 4292994782 4287139466 4285493612 4285625199 4285822577 4285954164 4286151542 4286283129 4286480507 4286612094 4286809472 4286941059 4290691515 4292994782 4284837928 4284837928 4292994782 4284112991 4285888370 4286019958 4286283128 4286414715 4286612094 4286809473 4287006852 4287072902 4287270280 4287336074 4289243813 4292994782 4284837928 4284837928 4290955444 4292994782 4292994782 4292994782 4292994782 4292994782 4292994782 4292994782 4292994782 4292994782 4292994782 4292994782 4292994782 4290231460 4284837928 2590339368 4284837928 4288851047 4287338045 4287206716 4287075131 4286877754 4286614585 4286416951 4286022196 4285693233 4285495344 4285363760 4285035308 4284837928 2590207782 16777215 4284837928 4291812235 4290760282 4290760282 4290694233 4289904210 4289970017 4290232690 4289115217 4288325447 4287733059 4287272512 4288324968 4284837928 16777215 16777215 4284837928 4291812235 4290760282 4290760282 4290628441 4291022450 4292731857 4292731857 4292074155 4289575523 4288983124 4288391252 4288324716 4284837928 16777215 16777215 4284837928 4291943566 4290760282 4290760282 4292140202 4291088506 4290627953 4292139948 4292205742 4289509987 4289246047 4288917339 4289574266 4284837928 16777215 16777215 4284837928 4292009105 4290957409 4291220332 4292600262 4292731857 4290365032 4290101861 4290101613 4290956176 4289114972 4288719960 4289903745 4284837928 16777215 16777215 4284837928 4292337822 4291286129 4291286127 4292534726 4291285891 4290430569 4291942578 4290232689 4292468932 4288983643 4288390740 4290100612 4284837928 16777215 16777215 4284837928 4292403360 4291220334 4291154541 4291154294 4292205742 4291614119 4292600263 4292534470 4290035573 4288786006 4288259408 4289772418 4284837928 16777215 16777215 4284837928 4292206493 4291154538 4291022952 4290693989 4290365026 4290036063 4291679916 4289378136 4288983381 4288654161 4288127821 4289705854 4284837928 16777215 117440512 4284837928 4206542989 4292140187 4291943322 4291876761 4291614359 4291416725 4291284884 4291021715 4290890129 4290692752 4290363789 4204569458 4284837928 100663296 16777216 2103470115 4284837928 4284837928 4284837928 4284837928 4284837928 4284837928 4284837928 4284837928 4284837928 4284837928 4284837928 4284837928 2120049952 33554432)
	offset: 0@0)
]

{ #category : #'private - icons' }
MenuIcons class >> smallDoItIcon [
	"Private - Generated method"
	^ Icons
			at: #'smallDoIt'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self smallDoItIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> smallDoItIconContents [
	"Private - Method generated with the content of the file /home/dgd/smallDoIt.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAABl0
RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAMRSURBVDiNfVNbaFRXFF3n3DNz
r3cm10nsaJxYMU5joon4QvGZYjUGtLZEBWkiRWwj+iEq4odIW6S0P/VXEIvFDzP4iB/6IRLR
ZDCjVpsJksekKsaQaXwlmceN9c6duWf7EQ0y2O6/zVqstdl7bUZE+L+qXzW3GEAFgM5QJJbK
x1m+wJ7ayl+IaCdj7HZ6TB4wvPyvJVWqO9qTyaRMuTYUif39IZ/nuW0JzhT7ThzzB5YtcG90
CYS/WqcXNW43iuo26MWJ11ZD/gQir896dEVyIdBQV6gvX2QHPyt1QzKG+AuZ0VVl457aygYC
Os0xWR+KxGzxznmmz+BnfAbH44GsJK5AuIHyOeP6BGDrJp82I+BetGKJh5+7nAy03jX3A/hN
AMBkQzn7XcMnqwt9ghV4OIgLXLgyaoXvmHYuR1hfbajbvixUv6hWOQAESzW15XZyHWPsuAAA
KVFaXu5h6jiOe1FTXmtLDjWFHx5kDP1ZZ86Piotvrts0RQ1HUnbTpZGRtq6hZgCCA4Ak+uHw
TwOJyL3XNnGBrphldT9NnJdE4Zwju3I2+/npgG0SF7BsBoDxpbOnDRNRlgPA7y09ZzIZ+qPj
wViGuILi6ZrqNyZNJ6IUAGgaX6npwkVcQU2N3/3rsbJpJVP104wxJgDg28/nba+c593d2Dir
gDjHmmq/cr8jvW13bVWh28Wl1yvW7tjx6WTiCgDAY3DQ+AXH1+w4pAZKJgmX5kIqnUVBgQtH
jlZ4e7rTX3s8AoESDZqm4OLFuNXaOpzjnLEnz9LNABwBAEQ4394+eijamSodTdjO0mVF7l3f
B/WqhVMmAkIA0mMSj4eSJyN9z05LIg7gCQeAUCSWMc3c4pY/48sfDiaPMs6zxBUMxi3s29vx
prk5niGuIFhmqH6fXuZI2UdEvUQkJ5IYisQcAL31q+Y6fb3pXGc0hZvX/3nT3T9yim5gQ9eD
ZMnwK8tq7xm6yhhTiMj56DO9S+ZCEnTk+ei/Zlv3YNM3KytuPXqemB/tf+mRRI+I6MV77kcF
JkDGBBHl/pMA4C2oHVtvUbiwmAAAAABJRU5ErkJggg=='
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallDocumentClockIcon [

	^ self fugueDocumentClockIcon
]

{ #category : #'private - icons' }
MenuIcons class >> smallExpertIcon [
	"Private - Generated method"
	^ Icons
			at: #'smallExpert'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self smallExpertIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> smallExpertIconContents [
	"Private - Method generated with the content of the file /home/dgd/smallExpert.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAACS0lEQVR4nJWRu09TcRTHP+1tL33QVkjB0lqN
QABRiiE6SDCEElJcYWbV4GRSw9zBP8BFSRwk6mCiI4Mp0dCQaHwwgQllACqlPEIfVOhte3vb
n4M0ImICZzq/c36f73lJnMHehJDfRiiLGW44nGRGfMj6swjU1qObfoSHNWJ2lcZ7z1B0p4W/
PsEraTR61yg7BWHFwsRKM3On5X0+Jx/uXiM3NYRYGuPTx4c0AvyvAxm4CnQDWeAxsNpgZrLX
w/eZH9ieB1GlFRZOgseQSNY214pWf6twd7oFIID3wOXDP9dDIfQCdMc7eMo5xj13PPR099Du
biefyBOdjyLbZcIvw0qlXLkFfyobjsCjyIxzG1wXXTTVNdFyvoWOng7Mo2ZiuzEKhYJl9vXs
K+AmoAIcPeMEV8BoNVJjrMEsm7Fb7HjqPbS526iz1jEwMoCl3uIDAlWoKmAAfDRAqVyiWCqS
V/NklSzxVJxoIkrqIIWiKji8DoDe4yNYARPy70fyZ5LN9CY2k428mscoGUntp4in4miSBuA8
LpAFVsjQghXWU+uYZBOlcomtvS0kvcR+fp+N9AaZRAbg80lLnGaVB1wAIQTLm8vs5fZwWBzo
9XqUosJ2bBttV8sB4Sp09IxmYJ4uOungXysAc0CW+8BkNSxVnVAopDcYDEs7iztdpa1SE4bD
7AEQB90XnXrJeWkqGAy+6+/vVyORSO4vgUAgYHe5XA19fX0LxXRxmzjFynJFsiVtCa/R+214
aPjF4ODgohBC1jRN8fv96UgkIn4BMVjYCuwVUJAAAAAASUVORK5CYII='
]

{ #category : #'private - icons' }
MenuIcons class >> smallExportIcon [
	"Private - Generated method"
	^ Icons
			at: #'smallExport'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self smallExportIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> smallExportIconContents [
	"Private - Method generated with the content of the file /home/dgd/smallExport.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAABl0
RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAJTSURBVDiNlZPNTxNhEMaf2d2y
29IWW6rAoiEhVRP5sBIlcqgHL0YTrScvePDEyZuJqf+BB2/ExHjxwFUTKtFEkyZgoySgpGCU
AEK4uKLUVtvdbbfd3fEgEChN0Oc4mfc3z8w7Q8yMRgrGFRnATQA5ADPFTOVbozxqBAjGlSE1
1vY0erpbbfepmExPlX4s564WM5WpAwGBC/K18EXfuO9UE9UKNkgU0NPVh6X0mvX17cYVAOsA
1ouZigsAQj1RbpdGPapA5moVuefmRz1b0RcWs1DOsexpE9NSRFglkR9t5+8BpNRwgLVatjhj
FQsvy7d/vSj3G/O1QfNzzdF/m4je6kTizmUIihjYfiPtKc/87MlqcxevUSSh6bVgXPGKIZpQ
opLoaRGhiAp0S4djuF/2OUip4WGJecBnO4cB3N0KH1KOSRFRITCAUq2E7EIWANJ7hphSw61g
XurN637ZdeUPkaAJolhCy68E48rxJlWY9g/IrXKnB/lX5uzmmD5Y7+BByLKNUNWWfbaLTsMy
wPwYAIqZykpVc0/8nLBGN8asudJy/yjFks07DsY7QlEAK5LjFgTABkAAxKoohABcSmj513Tm
3kMwj+yamUNE48x8Y7uFHgCeuh9lAIvXj4wMAZiMnT2P9o6jICLkNr9jdvoNAxiWACCh5T/V
78OOYskQAHRHT0IU/xrwB4KYm3nnOI7dsm+R/lf/AnABwND1nUC5bMJ1HQGA2/CYdotiSZlI
eM/s9nq9PgtEKJtGExFpzNx3IGAL4gcQBzCw5XoeQIaz9wt/AFR4+5g8QPOiAAAAAElFTkSu
QmCC'
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallFindIcon [

	^ Icons
		at: #smallFindIcon
		ifAbsentPut: [ self smallFindIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallFindIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 3500845735 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 2879299995 16777215 16777215 16777215 16777215 4254834329 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4288257175 16777215 16777215 16777215 16777215 4254768536 4294967295 4294177778 4294177778 4294177778 4294177778 4294177778 4294177778 4294177778 4294177778 4294967295 4288257175 16777215 16777215 16777215 16777215 4254834329 4294967295 4294177778 4291940816 4291940816 4291940816 4291940816 4291940816 4291940816 4294177778 4294967295 4288257175 16777215 16777215 16777215 16777215 4254768536 4294967295 4294177778 4294177778 4294177778 4294177778 4292796125 4287862162 4287862162 4287862162 4287862162 4287927954 16777215 16777215 16777215 16777215 4254834329 4294967295 4294177778 4291940816 4291940816 4290164917 4287862162 4290430675 4289841372 4289578718 4290037208 4287862162 1552255106 16777215 16777215 16777215 4254768536 4294967295 4294177778 4294177778 4292796381 4287862162 4290036947 4288002781 4291288045 4291682288 4289119970 4288461783 4287862162 830636669 16777215 16777215 4254834329 4294967295 4294177778 4291940816 4287862162 4289772744 4287674587 4292996085 4293718521 4293456120 4291944945 4288200674 4255366615 4287862162 16777215 16777215 4254834329 4294967295 4294177778 4294177778 4287862162 4289578459 4289711079 4292864501 4293193462 4293061877 4291419375 4289383143 4270634460 4287862162 16777215 16777215 4254768536 4294901501 4294177778 4294177778 4287862162 4290038751 4289711336 4292338931 4292864758 4292142066 4291813617 4291156462 4253726428 4287862162 16777215 16777215 4221214104 4294704122 4294177778 4294177778 4287862162 4289970895 4287936987 4290565356 4291551216 4291419376 4292273395 4289645027 4221615577 4287862162 16777215 16777215 4221214104 4294967295 4294967295 4294967295 4292401366 4287862162 4289381852 4288463072 4290367719 4290499818 4289447648 4288856541 4287862162 3800664454 16777215 16777215 2744950939 4288322968 4288257175 4288257175 4288257175 4287665037 4287862162 4290630372 4288068314 4287281116 4289052891 4287862162 4289901490 4289901490 3632300413 16777215 16777215 16777215 16777215 16777215 16777215 16777215 2306834557 4287862162 4287862162 4287862162 4287862162 4288585629 4291151300 4289901490 4289901490 4288059028 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4288585629 4291151300 4289901490 4288059028 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 33554432 4288585629 4288585629 4288059028)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallFontsIcon [
	"Private - Generated method"
	^ Icons
			at: #'smallFonts'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self smallFontsIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> smallFontsIconContents [
	"Private - Method generated with the content of the file /home/dgd/smallFonts.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAABw0lEQVR4nNWRP0xTURTGv3vP+8Pro9CqQ1Pw
34tplIGYgIZASZogFWpinEy0mGCJiX+Cg4uM3R1MHNwMMwMrcRAGFhwaEjVRQTSS1DQMbaWN
0tf77r0OakUWWDnJGb58J79zvhzg0BftFuPj03an5/XHI6erpdK6OAiA7xYVXZ8KtXW+Vu3W
44Ne8B+AOM8BgON2TOz10ulbbipzP7YX0IqQzNxJCOEnORlHiYx4JBpb3Sp+WgOAgbHJR4Lo
2U6j1nPy3MUnXV7vZScRn69sbMjWFqnFvWr52wspmrMA4IQjd/96vt94U1xfzRaW5nIqCOYs
27kSqltT/yLk85wxlmqPHiuRZS0C0Kbjjnh9yRMAEA5HKt2J/pnBzO1lTubV33HJawGGCsUx
KcR3JnFzp1YdFU3/LQOzouHYNABIKWY58esfVhYegOnnAKC15gBgAIBSavLr58LDrS8f3wHA
hdHsiAn7le123AAwo5TcNsgwvd7hs8ToGgAwzttSqbxBA+mJrNbqkuse6S5tvl8AgONnzueC
ps8CIcqxUz3Jxo/6U61UFyPq+1krvwyk8Bnnoer22iYAMADmn97v5fY+M4exfgFP/5Zri/7V
SwAAAABJRU5ErkJggg=='
]

{ #category : #'private - icons' }
MenuIcons class >> smallForwardIcon [
	"Private - Generated method"
	^ Icons
			at: #'smallForward'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self smallForwardIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> smallForwardIconContents [
	"Private - Method generated with the content of the file /home/dgd/smallForward.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAABr0lEQVQ4jb3ST0uUcRTF8c/jPDPqlKORiqSt
JqSNRfM0LlqElkRtItAIa9HWF9DKXkCbIAQhIohoURQFtQ2iYDYZkpAEUS1CamOBjppmOvNr
MZRUi/5And2F+z33cO/ln6tXt6KBv4N365SYkwgKbivq+LElAnv1YUjQLrIkWEAdBrVkthnt
YfwFMx/nRM6YdGXDomifxIrBzcFwLjiaDQ5mgr500J8OxvIhE46FsfV7IR7vDopRkLjsuFQt
QeKiVDTSUhpyMtOvS6u02IJlT7z0yLRVaw7YZacu1x/eND9aYq161ycnIokJjalepSPqpW3X
ql7arLL3yj+tpV2z2TvPODcN52ORipUKryasVta9DlWiOuI0cYaGJjry3wxmlcnHtSJoigVv
wbs1mpdRJVQIYWNsNkeujdVl3jzn0nzNK3Y2kjiNq9/lbEixNaYjxUgjqSWyLSx+oJTl2mJZ
1YApk7UzJgqCHeo0qKqIfBZ0ilxwagv750ilub+JW/OLgkOeevzrR0pM6Y2CG7lguD5IzEgU
fg1+VcFhiRWJIPHAHm2/D2+kyEv0/Dn4v/QF8kyGaRoL4uEAAAAASUVORK5CYII='
]

{ #category : #'private - icons' }
MenuIcons class >> smallFullScreenIcon [
	"Private - Generated method"
	^ Icons
			at: #'smallFullScreen'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self smallFullScreenIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> smallFullScreenIconContents [
	"Private - Method generated with the content of the file /home/dgd/smallFullScreen.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAADIklEQVR4nH2TTWhcVRzFz//e++7Me+1MxkxS
0jR0nJZSbI0am07c2OomI7HrilB0GVy5kJDtZJNVEHQTcONKF2otlGmUEhoQSUtClTAWalJp
Pmtik/l47828efM+/m6yiFA8cDaHw1n84BAAMDNNTU2ZWutjWmsrCALDNE3HNM3q+Ph4gP8R
TU9P90oprwHIARBHHBJRi5nrQog9rfVap9N5OjEx0fzPwMzMTG6nuvVp+dmPH/fnTiad9ebO
Bxc++uVIJwbgMbMNYJ+INpj5t8nJyS0iYjk6OnpybXf12vbQ6mU+7xvVf+rd/UFuP22mIyIC
AAagiShFRD1E1EtEpxcXF7PFYrEq4ji2rIRFkR3B3nBx7t08/dS4ddULvB4AJwD0AegCoABI
Zu6N4/jNOI4vM/NZRURGvuesnX80uOqppvXEezLgd1hpqWMAICIJ4DgzHwNgA3CJKH2YaUVE
YcJIBO+9+v5TIQQeri+5sd9OLMz9MAgiYZkWeW2/menudc9deH03ne5yD9n4YRiGKgzDkIg6
RGQws3Xp5YKz8uDeqTvz91PKMAAAraaLysoy5m5/f/Hu7Tsbr7w2sjmQO+MqpTxFRB0hhB/H
sRRCSAAwrWRi6VkVXzeycCKB00kTQ6cK+OSzM+LDG5v57779Jr8wd9MYLFwtKwCNKIr2AdSZ
uYuIglS6S246LsJAISUktpvAhkO4K9O4nu7D8PAw7IbTr5RqKc/zqpZl7QA4OKSuojDg4ypE
MRWhS0vUgwjL+y10AFTaBoa0xt+7e3YGmQNRKpXazLzGzAfM/JiZ9xzb9nuojazyICMbL8kW
BlM+BgwbGdmElBLr61vPZ2dn6woAMpnMSq1WSwohiswc1WqNR1lCIYyqiEmCmZBLCJyQIZIc
od1qot5w/wDAEgDK5XI8Pz+/OTY29lgI4Wid6Cz9eq9QvPK2UtyAZBeafJjko08aqCwt88KD
Sqlet/+iFz2sVCqpPysPz9vV7a9G3iqMvDF8SXZnMxBSI/Da+PLzL36/+fP9dwDYLxw4qouA
drK4EofIsYBBgPLauHXgYQcA/gWOnHIlydMKjQAAAABJRU5ErkJggg=='
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallFullscreenOffIcon [

	^ Icons
		at: #smallFullscreenOffIcon
		ifAbsentPut: [ self smallFullscreenOffIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallFullscreenOffIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 3597627500 4288322713 4288322713 4288322713 4288322713 4288322713 4288322713 4288322713 4288322713 4288322713 4288322713 4288322713 4288322713 4288322713 4288322713 3597627500 4288322713 4294966267 4294966267 4294966267 4294966267 4294966267 4294966267 4294966267 4294966267 4294966267 4294966267 4294966267 4294966267 4294966267 4294966267 4288322713 4288322713 4294966267 4290033079 4290033079 4290033079 4290033079 4294045933 4294045933 4294111726 4294111726 4290033079 4290033079 4290033079 4290033079 4294966267 4288322713 4288322713 4294966267 4290033079 4290033079 4290098872 4294045933 4294045933 4294111470 4294177519 4294177519 4294177519 4290098872 4290033079 4290033079 4294966267 4288322713 4288322713 4294966267 4290033079 4290098872 4290362044 4290822852 4294111726 4294111726 4294243312 4294243312 4290559423 4290296251 4290033079 4290033079 4294966267 4288322713 4288322713 4294966267 4290033079 4294111726 4290757059 4291612368 4292270298 4294177519 4294178289 4292072919 4291480782 4290691266 4294309105 4290098872 4294966267 4288322713 4288322713 4294966267 4294177519 4294177519 4294243312 4292270298 4292730849 4293125607 4293191400 4292928228 4292270298 4294374898 4294113010 4294374898 4294966267 4288322713 4288322713 4294966267 4294243312 4294243312 4294308849 4294178289 4293059814 4294309105 4294374130 4293191400 4294440435 4294440435 4294440691 4294178803 4294966267 4288322713 4288322713 4294966267 4294440691 4294440691 4294440691 4294506228 4293257193 4294505716 4294572277 4293651951 4294571509 4294376182 4294638070 4294637302 4294966267 4288322713 4288322713 4294966267 4294506484 4294506484 4294571509 4292007126 4292862435 4293454316 4293651951 4293322986 4292533470 4294638070 4294703863 4294637302 4294966267 4288322713 4288322713 4294966267 4290033079 4294572277 4290559423 4291086024 4291941333 4294571509 4294637302 4292401884 4291349196 4290559423 4294703863 4290033079 4294966267 4288322713 4288322713 4294966267 4290033079 4290033079 4290164665 4290427837 4294376182 4294638070 4294703095 4294768888 4290362044 4290098872 4290033079 4290033079 4294966267 4288322713 4288322713 4294966267 4290033079 4290033079 4290033079 4294703863 4294637302 4294441975 4294768888 4294834681 4294834681 4290033079 4290033079 4290033079 4294966267 4288322713 4288322713 4294966267 4290033079 4290033079 4290033079 4290033079 4294769656 4294769656 4294900474 4294834681 4290033079 4290033079 4290033079 4290033079 4294966267 4288322713 4288322713 4294966267 4294966267 4294966267 4294966267 4294966267 4294966267 4294966267 4294966267 4294966267 4294966267 4294966267 4294966267 4294966267 4294966267 4288322713 3647762028 4288322713 4288322713 4288322713 4288322713 4288322713 4288322713 4288322713 4288322713 4288322713 4288322713 4288322713 4288322713 4288322713 4288322713 3698093161)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallFullscreenOnIcon [

	^ Icons
		at: #smallFullscreenOnIcon
		ifAbsentPut: [ self smallFullscreenOnIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallFullscreenOnIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 2576981400 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 2576981400 4288257175 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4288257175 4288257175 4294967295 4281563063 4281563063 4281563063 4281563063 4294046192 4294046192 4294111985 4294111985 4281563063 4281563063 4281563063 4281563063 4294967295 4288257175 4288257175 4294967295 4281563063 4281563063 4281760184 4294046192 4294046192 4294111728 4294177777 4294177777 4294177777 4281760184 4281563063 4281563063 4294967295 4288257175 4288257175 4294967295 4281563063 4281760184 4282942140 4285175492 4294111985 4294111985 4294243571 4294243571 4283861695 4282679483 4281957047 4281563063 4294967295 4288257175 4288257175 4294967295 4281628855 4294111985 4284912835 4287672272 4289643482 4294177777 4294243827 4289052375 4287080654 4284584386 4294309364 4281825720 4294967295 4288257175 4288257175 4294967295 4294177778 4294177778 4294243570 4289511898 4291023329 4291943399 4292206568 4291286500 4289446362 4294375157 4294309621 4294375157 4294967295 4288257175 4288257175 4294967295 4294243570 4294243571 4294309107 4294243827 4291877862 4294309363 4294374901 4292272104 4294440693 4294440693 4294440949 4294375414 4294967295 4288257175 4288257175 4294967295 4294440949 4294440949 4294440950 4294506486 4292141033 4294506487 4294572536 4292863983 4294572537 4294572793 4294638329 4294638073 4294967295 4288257175 4288257175 4294967295 4294506743 4294506742 4294572280 4288461014 4290892259 4292535020 4292995311 4292009706 4289840862 4294638329 4294704122 4294638330 4294967295 4288257175 4288257175 4294967295 4281628855 4294572536 4283664831 4285701320 4288198101 4294572537 4294638330 4289381084 4286292684 4283599039 4294704122 4281563063 4294967295 4288257175 4288257175 4294967295 4281563063 4281759927 4282219705 4283204797 4294572793 4294638329 4294704123 4294769659 4282942140 4281825720 4281563063 4281563063 4294967295 4288257175 4288257175 4294967295 4281563063 4281563063 4281563063 4294704122 4294638330 4294638586 4294769916 4294835452 4294835452 4281563063 4281563063 4281563063 4294967295 4288257175 4288257175 4294967295 4281563063 4281563063 4281563063 4281563063 4294769915 4294769915 4294901245 4294835709 4281563063 4281563063 4281563063 4281563063 4294967295 4288257175 4288257175 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4288257175 2643827092 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 2694091921)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallHelpIcon [

	^ Icons
		at: #smallHelpIcon
		ifAbsentPut: [ self smallHelpIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallHelpIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 16777215 16777215 16777215 672815513 2232900251 3306642333 4061617052 4061617052 3306642333 2232900251 672815513 16777215 16777215 16777215 16777215 16777215 16777215 33587328 2031573916 4113327778 4254773454 4291285987 4293849847 4293849847 4291285987 4254708174 4130104994 2014796699 33587328 16777215 16777215 16777215 33587328 3289865116 4133981369 4293455348 4290102746 4285699261 4282479274 4282479274 4285699261 4290168539 4293520883 4134047161 3289865116 33587328 16777215 16777215 2031573916 4134441147 4293652469 4284844728 4283530415 4291549157 4294178297 4293586676 4289971418 4283925171 4285633726 4293718518 4150890169 2031573916 16777215 672815513 4113459107 4293521140 4284779191 4279720860 4286159552 4294835710 4292732142 4294112760 4294967295 4291286244 4282151596 4286094019 4293586933 4130236322 672815513 2232900251 4271748304 4290102746 4279720860 4279720860 4283793842 4283925171 4281626024 4284845241 4294967295 4294770173 4283334836 4283071922 4290892002 4255234002 2232900251 3306642333 4291417573 4285699261 4279720860 4280574624 4281165988 4281822889 4282348973 4288065743 4294967295 4293718262 4283729335 4283860408 4287869136 4291812328 3307101598 4061617052 4293981175 4282085031 4280311967 4281165988 4281823145 4282414509 4286225605 4294638845 4294901502 4287606223 4284386493 4284518078 4286095046 4294112761 4061748381 4061617052 4293981175 4282216616 4280903075 4281757096 4282348973 4283006130 4293718518 4294967295 4289512155 4284846529 4285109698 4285241284 4286752203 4294178298 4061944989 3306642333 4291417573 4286027967 4281363109 4282151595 4282874544 4284188857 4291878122 4292009707 4285372612 4285438406 4285701320 4285898697 4289183708 4292141036 3307167391 2232900251 4254971088 4290365661 4281757352 4282480557 4283269044 4284254907 4288460756 4288723928 4285569735 4285964490 4286358733 4286555855 4291944429 4255957466 2233031837 672815513 4130236323 4293586933 4285962689 4282874544 4283597493 4285437634 4294967295 4294967295 4286292940 4286424783 4286884818 4289250528 4293981433 4130433443 672815513 16777215 2014796699 4134572988 4293784054 4286554310 4283794871 4285635011 4294967295 4294967295 4286621647 4286884818 4289447393 4294178811 4151876034 2015125149 16777215 16777215 33587328 3289865116 4151415997 4293784054 4291089381 4288197844 4286423754 4286949839 4289381599 4292141550 4294112762 4152270533 3290652832 33587328 16777215 16777215 16777215 33587328 2031573916 4130367396 4272471510 4292075243 4294178554 4294244347 4292403949 4256351709 4130630309 2015256221 33587328 16777215 16777215 16777215 16777215 16777215 16777215 672815513 2232900251 3306970782 4061879709 4061879709 3307233441 2233031837 672815513 16777215 16777215 16777215 16777215)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallHomeIcon [

	^ Icons
		at: #smallHomeIcon
		ifAbsentPut: [ self smallHomeIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallHomeIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 16777215 16777215 16777215 16777215 16777215 1291782669 4290904064 4290904064 2180975120 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 1291782669 4290904064 4294904335 4294904335 4290904064 1291782669 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 1291782669 4290904064 4294904335 4287978586 4288768873 4294904335 4290904064 1291782669 16777215 16777215 16777215 16777215 16777215 16777215 16777215 1291782669 4290904064 4294904335 4289883499 4288059284 4289440682 4292057497 4294904335 4290904064 1291782669 16777215 16777215 16777215 16777215 16777215 1291782669 4290904064 4294904335 4289955460 4288717214 4291085765 4291677644 4291217093 4292128687 4294904335 4290904064 1291782669 16777215 16777215 16777215 1291782669 4290904064 4294904335 4290158236 4289704110 4291546058 4293190884 4293190884 4293190884 4292861919 4292264385 4294904335 4290904064 1291782669 16777215 1291782669 4290904064 4294904335 4290228141 4289901233 4292993505 4293848814 4293848814 4293848814 4293783021 4293783021 4293717228 4293253336 4294904335 4290904064 1291782669 4290904064 4294904335 4290822334 4289835696 4292927712 4293651435 4293717228 4293717228 4293717228 4293651435 4293519849 4293519849 4293519849 4293716457 4294904335 4290904064 1740701696 4294904335 4293388776 4284967526 4284967526 4284967526 4284967526 4293717228 4287269773 4287138960 4287137928 4287138960 4287138185 4294440951 4294904335 1455489024 16777215 4284967526 4294243572 4284967526 4287665037 4287730830 4287796367 4293717228 4287138959 4286949841 4287137928 4286818512 4287073167 4294375158 4284967526 16777215 16777215 4284967526 4294177779 4284967526 4288059539 4288059539 4288059539 4293717228 4287073166 4285110471 4287137928 4283533503 4286941325 4294309365 4284967526 16777215 16777215 4284967526 4294111986 4284967526 4288191125 4288191125 4288453494 4293717228 4286811028 4281563063 4287137928 4281563063 4286613908 4294309365 4284967526 16777215 16777215 4284967526 4294111986 4284967526 4288191382 4288191382 4288322448 4293717228 4290691267 4291086541 4291217352 4291152333 4289967027 4294309365 4284967526 16777215 16777215 4284967526 4294046193 4284967526 4288257175 4288257175 4288257175 4293717228 4289835441 4289901234 4289901234 4289901234 4289901234 4294309365 4284967526 16777215 16777215 4284967526 4294440951 4286085750 4289178277 4289243814 4289309350 4294309365 4294440951 4294440951 4294440951 4294440951 4294440951 4294769916 4284967526 16777215 16777215 2892392806 4284967526 4284967526 4284967526 4284967526 4284967526 4284967526 4284967526 4284967526 4284967526 4284967526 4284967526 4284967526 2540137061 16777215)
	offset: 0@0)
]

{ #category : #'private - icons' }
MenuIcons class >> smallInspectItIcon [
	"Private - Generated method"
	^ Icons
			at: #'smallInspectIt'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self smallInspectItIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> smallInspectItIconContents [
	"Private - Method generated with the content of the file /home/dgd/smallInspectIt.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAACX0lEQVR4nKWST08TURTFT2f6nyntlJbWAq2h
BYxUSAoblBg0rsTECiEkfgANSgyuXejaj2CMicaFhhhdINGYKAYQYjUYTG1EBIZph1JaSodO
W9uZqSvISAYT41299847v3fuzQP+szQHD3wNtf2+o9Yhu03frNUSBp6vrJZF6cnUNPtCDaBV
rG2dQef9sZFQX9/p5oLB6lmRqwa+xDMdk5OxS5IoR1bZ7eF4vJhQS0C1+unx188H+yr0ufdr
5LBBeYkqzZXq+YehkbFX62+mmB4A4p5GAgBNG++8fBo+L3kGp1lywHww5qZA10wu6G03wnnv
x4VkY3JTmNjTCADobHd2N3rdCY64YFHrsyLJBJu1GCVrx/LxFnuvUiMAWNpa6LqCxsuqmQFA
KPzSAcDiRqPJ5TI7AeiUAKfnCAVJY5IOA2R3BCMAVGQ9HLRZC8CqBKzMRzi+prrmUDOn0rwp
9oN1AUDAniww8VwKQPqPGURjmSW5lAlZq9Hd/b5FiYgtJ+xvZ7/6RVEm9ZDELvMXOs7ll5QP
kACQ48vR+chGz/WBYluy4E7PLPJNc5+WfCyXpiVJJkx6qXzv2ShVM/7ZzpxsIKKxbEQoivF9
AICdrUwpOheJnxnqSXV1eLitOqpYDjhyhXDw2+5F7yxtybnNuHqC6KV4K6MznF1niu+EUjl1
8CvbAs22260BOuRxU26djtRv7xQTCS4fJQnNsYkHV05RmTRZZRYrg4/XuZ+s0H7Y4PfSEYq9
sdVPP/o+c3NXmr8s3r3VnQoG611/A6iW02kaDff7P/iaaq/9s1mtfgOeOPMUwSrvxgAAAABJ
RU5ErkJggg=='
]

{ #category : #'private - icons' }
MenuIcons class >> smallJumpIcon [
	"Private - Generated method"
	^ Icons
			at: #'smallJump'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self smallJumpIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> smallJumpIconContents [
	"Private - Method generated with the content of the file /home/dgd/smallJump.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAABdklEQVQ4jcWSPUuCcRTFf/d51LSIgmfphSBo
iobCBx16oSUaApemgqCGQGhq6wNEn6ChrakIWlskiKgpqCdqqKkXSlJCibA3M/U2aFZaEDR4
xv8593DP/R+oNuRXxqYDxS6qHBzO/2Zg4xeXLJPV7jLlgSphHA6/Pptlw8MCO572RmtsYda0
Jnq49L8h6UclmmkVmKaFPeI/bRPEkiC3xlzT82p+W1/1TRd1Q306qjwNKEuo2KjYxAhifYwZ
JYMsIbxm3dT8nG9cBsmRZ41dXsiAYUIA6BWAZrKEKgwMIUBn/dOke4gkKby4aaC2QD4kAdBu
/dQW4fp+KDG8eOhiBh81XJMAVbiLFXitTF7aIK/sc5KqW8lskSBVHM7DxQE83hX8nS/ail9o
Iyo5wufRM/dzX6NJ+h6ujiGVKPC7IBEA4riY5YYXKO+BzbAIESwR7VdoAe5BjgROFSCnMILD
Zil1RSgbv9TLOg/a8f0+Pxfp31WuPt4BdGiFIfxoncEAAAAASUVORK5CYII='
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallJustifiedIcon [

	^ Icons
		at: #smallJustifiedIcon
		ifAbsentPut: [ self smallJustifiedIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallJustifiedIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 2862522779 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 2862522779 16777215 16777215 4288257175 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4289440683 4289440683 4289440683 4289440683 4289440683 4289440683 4289440683 4289440683 4294572537 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294440950 4294440950 4294440950 4294440950 4294440950 4294440950 4294440950 4294440950 4294572537 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4289309097 4289309097 4289309097 4289309097 4289309097 4289309097 4289309097 4289309097 4294506743 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572536 4294506743 4294440950 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294572537 4294572537 4294572537 4294572537 4294572536 4294506743 4294440950 4294375157 4294309365 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4289309097 4289309097 4289309097 4289309097 4289309097 4289309097 4289309097 4289309097 4294309364 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294375157 4294375157 4294309365 4294309364 4294243571 4294177778 4294111985 4294046193 4294177779 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572536 4294506743 4294440950 4294375157 4294309365 4294309365 4294243572 4294177779 4294177778 4294111985 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294440950 4289309097 4289309097 4289309097 4289309097 4289309097 4289309097 4289309097 4289309097 4294046193 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294375157 4294177778 4294111985 4294046193 4294046193 4293980400 4293914607 4293848814 4293783021 4293980399 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294901502 4294901502 4294901502 4294901502 4294901502 4294901502 4294901502 4294901502 4294901502 4294901502 4294967295 4288454554 16777215 16777215 2862522779 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 2862522780 16777215)
	offset: 0@0)
]

{ #category : #'private - icons' }
MenuIcons class >> smallLanguageIcon [
	"Private - Generated method"
	^ Icons
			at: #'smallLanguage'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self smallLanguageIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> smallLanguageIconContents [
	"Private - Method generated with the content of the file /home/dgd/smallLanguage.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAABlElEQVR4nMWRv0sbARTHP+bulOCQwaQnauoF
rYGiDpa2Wtupg7q5Fsng/+CmODqUigouDuLg4L/goCBxiFkEtRXj0CVNuWhE6cn9MOZeB1NI
S07qlC+84T34fHnf96DRaqozawE+Aa8ikchLTdOaS6XSN+AY2ASsxwxTuq7/XFz8LPn8d/F9
V0Q8Mc28rK+vSSJh3AAzgXBvb49/eVkQEa9u2faNDA+/FWCu3tr24WE2EP5TppkXTdMEeA6g
Vg3eGUZ3uF9R+PVlCTXehZowqBQvENtG6ezAy2RRYlHaPrxndHSEvb30R2AjVDVwXNflLneO
1vcCpV2n+c1rymc5lK5OvEwWymWaWlupFAo4jgvg1EZQAHN3Z1tEPPHvbh9Wrjh/974r52cn
EgqFHKDt3zsM6fqz61zua2D+YvGHJJN9LjAe9AkjHA5nVleXxbKuxPddsawrOTjYl/n52fto
NLoF9AfBAKiqmj09PZJ0elcGBwcqwA4wCUQeBauKT0yM+anUlAesAPH/gWo1DSwAsaeCjdNv
pz0BrfQjq7kAAAAASUVORK5CYII='
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallLeftFlushIcon [

	^ Icons
		at: #smallLeftFlushIcon
		ifAbsentPut: [ self smallLeftFlushIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallLeftFlushIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 2862522779 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 2862522779 16777215 16777215 4288257175 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4289309097 4289309097 4289309097 4289309097 4289309097 4289309097 4289309097 4294572537 4294572537 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4289309097 4289309097 4289309097 4289309097 4289309097 4294572537 4294572537 4294572536 4294506743 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572536 4294506743 4294440950 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294440950 4294440950 4294440950 4294440950 4294375157 4294309365 4294309364 4294375157 4294309365 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4289440683 4289309097 4289309097 4289309097 4289309097 4289309097 4289309097 4294309365 4294309364 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294572536 4294572536 4294506743 4294440950 4294375157 4294309365 4294309364 4294243571 4294177779 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572536 4294309365 4294309364 4294243571 4294177778 4294309365 4294243572 4294177779 4294177778 4294111985 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294440950 4289309097 4289309097 4289309097 4289309097 4294243571 4294177778 4294111985 4294046193 4294046193 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294375157 4294309365 4294309364 4294243571 4294177779 4294111986 4294046193 4294046193 4293980400 4293980399 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294901502 4294901502 4294901502 4294901502 4294901502 4294901502 4294901502 4294901502 4294901502 4294901502 4294967295 4288454554 16777215 16777215 2862522779 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 2862522780 16777215)
	offset: 0@0)
]

{ #category : #'private - icons' }
MenuIcons class >> smallLoadProjectIcon [
	"Private - Generated method"
	^ Icons
			at: #'smallLoadProject'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self smallLoadProjectIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> smallLoadProjectIconContents [
	"Private - Method generated with the content of the file /home/dgd/smallLoadProject.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAADA0lEQVQ4jY2SW0zbZRjGf9+/358eKIUW6AE7
SlvcxiImc8PIlnmKkmAyt5ktWaYx8cAu1At3ockWZ2I27iDemHjjMTEsgnE6ncQsJrhMM2RM
kQnLQKRoS4GW0lJKD/T/eWe8EOJ7++b3vHne5xH8j2l56MjjhmF6QkBIYYwZQl2YunpxEsC0
JXnsmOke966+XU3Os/aO4w3r7SeahMvrZ+7O87X+7So5Nzm8pcBO1843nzpQ9/K7r3jNDTua
Xc/UjFf9WH/QW7r/iKN889vttf7wLW0LXjjsFafOnqgXCUuA8nKaVtsM+8wR0M0m/fgZuzC0
V+Wm1x8+HPDVWUV8zU2hsooLyd2YSgYRw0l7dYxFm9t7S4jWTQVM6InpeDH1UzbgOOoaw+w8
wBvZw/zQ8g5kkqTWFB0Wrbiphd+GBrLlYjFyfvKu+cvxe/l51c16WZIvCC7F7+N0v1peXS/1
b/UDBMaLhc96ymfGGmMFw0RX7QhmY5We79KR769P/1m2r3eLrr10un3B3lp/yOkNNEtzZaWm
61JomgCBSC8l1ODlQUatj2Y8TmtFKbfmmM1MDUdDE/VMr+2XUuqd574cbREqDarAYux3ZkY+
wtCqaXvkKLl8lmvRiJqc/XRgWtpkydZxkj23r9IVaOXQRKes99/dmFqJk1gpgTKwCI1CbgV7
jRldK/LYh29x4+mUoDF4snRlKc9zA130VgU0iwsDhHR5/N50ZpmNsg9QFFWUBw+dQlAklVnC
7HWit4cpsQHNixY+dxYIaTL8l5cpjT9kPpvJBX02ssk73P7gEpVtYYQnxLMfv41UGsFcgbkF
Mw2eMCPBLL7dbumPVDHR/fV17PwqkwuRGIZivG+QB3q+YnjvNrb1v8R8fIk2TxNWn5XZ3pny
L/tmTcb54aEo9EcVCzj4hiHyMp2Yj61mNmh74SA33DUE9+xAaE6uvNYNqgBaNXXj76Wvnbt4
GsEnjJL7d9RSCfpef3J/SJXLJqXUPwtNSqHrZk1WWEQuu/IFN3n/v7ryN/fUMc5/02mQAAAA
AElFTkSuQmCC'
]

{ #category : #'private - icons' }
MenuIcons class >> smallNewIcon [
	"Private - Generated method"
	^ Icons
			at: #'smallNew'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self smallNewIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> smallNewIconContents [
	"Private - Method generated with the content of the file /home/dgd/smallNew.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAACb0lEQVR4nI2RzWsUaRCHn3r7ne6e7p5MPjTu
mMRE8bIOe9iFsKwiePAgQcGFBW+aYy7e/APyXwQPe9uL5CJIbnszgrCw7IQISr7Nl05kY9Rm
ZpJ53/LQKIgfWJeqQz1Vv1+V8I24dH2y98iVhowJhsXrsBcdBjmuav569GDmMYAtGqfGvNM/
EH6Kk2j05OCxU0kS1yppEvdkKZVKRpYlVLKUl81X3Lv/98/ABQD57erUkBVduHljov/X8XHS
ai/tQ8g7nrztyDuOI6c4p3Q9XK5H/H7rTuvhL7WM6WlvrLizfb2V/omJK7hSD/u5J+84nPNY
K1TigJ5yQDW1VJOAUlSmr1opn/9v53RhQSQ7MTiAKqRxgPeKU3Be8b7IH+quV7pOGRup8Xox
rwMrRpUDAZLQUA4N5ciQhIY0MiRRkbM4II0NQ/0hWRwwOlJD8fVCgdVm3moTlQxOQb3iFbwW
W70qcWioJpbQCgBjIzWAc8WAQ7uX5y1KgRBZQVUKWAVrhCQy2EA+ee/o8A8AdQAzPzfz+s3b
vCOilKxQskJoTXG8JPgMBhg7VQP4kelpYwA96naf/79/gDWCDYQ4NJTs5+CHGOirkibl+NK/
zTMGQGF9e7dJYArZ5uvsJyqcuroBEJWN7Rd7iIB8BwwwUhsEtBighvXt3VffR1J85uBtjogJ
LYBR1nde7H2xud3usLKxw/LaJkurmyyvbbG6sU27c9gQCf60AD5w/yw+W+0uPl2x7/IWK+tb
LK1usby2ydZOs6WqT0AXvNAQrw31dmF+7u4+wEfHF69NTSJ6G9hFpCHogvHaOB7vL83Ozrqv
2XkPgdkFGpcRD6AAAAAASUVORK5CYII='
]

{ #category : #'private - icons' }
MenuIcons class >> smallObjectCatalogIcon [
	"Private - Generated method"
	^ Icons
			at: #'smallObjectCatalog'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self smallObjectCatalogIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> smallObjectCatalogIconContents [
	"Private - Method generated with the content of the file /home/dgd/smallObjectCatalog.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAAB9UlEQVR4nGNgIAxYGBgYuIlQhx2YqrNFR7hx
bcAlz4xHL6OiDKuZkQZbUUMynyM/N6MTEyNj0IMXf1cQZbOICINkuAvXpR+HpP//Py7z/9Q8
sY9OJuye6OpYGBgYGMzDC90EBHidYIJ//zIw7Tl7unvlnu1mJhqs5xJ9uDXff/7HdPvx/8dY
DZCWFvVZ0JSbCxO8dOshw57YS8sYGBgu7D714+/eUz/KmJmZ5MSF/hs+fslwBcMAfGDXqZ82
DAwMH3HJMxEyAJ9muAvevvt0o3ry0o0wwU9ffrAzMP9F1RjKwMz7gtPCwFk2+8e/X/qnDz3Q
ZzjA8IcRh8EcDAwMP5AFzBtVXnOKcIs8f/jxJ6vQX+an+94Gvt/1bQuKF5zZ2ELS2LhOVLDz
XvZg5VjAwMAAt+A/4//Hl3bf2nfz1AOeL/e+bWNXZS5kYEBNSMzBrFwLJ3EKmrqwcgipM7No
nfj748ar//+vCbow8P/48t+XRZxRk+kDM9M/1n9ZXCpssh/Yvnchu0BGg4lZHsbRY2ZlE2Fg
cWRgYGD4+4PN6zfLHxdGDiZJxn9/bzFzMj3+cu7nKr4PaHkkio1r2zt+qf9/BWT+t3HyvRVn
YFBiYGBgYDBmYOWz5YjhteO0YgjFm/wZ+GxZ2Ds9WdhXq7CyWuBTSDUAANeVnXOvNaMbAAAA
AElFTkSuQmCC'
]

{ #category : #'private - icons' }
MenuIcons class >> smallObjectsIcon [
	"Private - Generated method"
	^ Icons
			at: #'smallObjects'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self smallObjectsIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> smallObjectsIconContents [
	"Private - Method generated with the content of the file /home/dgd/smallObjects.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAAB/0lEQVR4nJWQXUgUURTH/zN3ZnMGbXcM+9AN
spaelETtQyLbsiWofAjspYwegggfpJ6KoqjH6KEEeyjDoBfFCvbBqChZiGJD7EMa66koQzPX
zf1o292ZuXN6aWSM2KYDl8s55///nXsuw+/wAfW1jO3LEsEGZvA/sVGSe64qgXm9YgXdVLTM
dubr92xeDmnrdTWQokCQnBNVl+VCjLV78YvVIsJ7JMXvLu6Uy1RNEHd5AiQEGn/LDcNdfG+b
dpZs/S96bUOtvGkRYIrz4cvFH09GedEiADo37bP5THzVga7pyMETDW5xS53v+Pq18i0AFU5N
cO56Ue5SBWzOEY3rttUDwAp3ngxJHI0kGyMjt69Rxw5lqO+M1tZ5YX6MCZT8PGu/8bImGuuq
hi8e0+bmHlYTxYNE8SDdOK1NhWqkFk8AAFq4SYl9uLfScgC7tyy5CwDMI6CwdF2EKoVPrYwJ
wkzSpi/frMLoO7NPWpA0tavgzLfIZso/MXHHiBzqbnv5YGhsIJc3++/nz3/PcL3KLx4GUOZ8
Iho6uqN7tzU3O3kqm2OPnr++tKay/IXAjcnHg70Jvx+r02l8dM9YeIHmL8epo/trnHzyawLP
XulBblM2Ntg7DQB/mgFALLW4ZSMfG7gyUUpTEkBE6VJ9wLXCbDIVbT1yLuVuZgrFp/8C/AKq
oMu3BdqijAAAAABJRU5ErkJggg=='
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallOkIcon [

	^ Icons
		at: #smallOkIcon
		ifAbsentPut: [ self smallOkIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallOkIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 248039624 79675327 33554431 33554431 33554431 33554431 33554431 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 16777215 16777215 16777215 16777215 2438055777 2135606620 16777215 16777215 33554431 33554431 33554431 33554431 33554431 33554431 50331647 50331647 50331647 50331647 61516458 2471741027 4285252467 4284989551 2034219344 16777215 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 2437793121 4285186674 4287618449 4286961290 4284332135 2066328132 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 2437923681 4285055344 4287487120 4287356046 4284397928 4281637445 134225920 33554431 33554431 1147794552 1718086006 33554431 33554431 33554431 33554431 2437792609 4284989551 4287290254 4287159181 4284332135 4231042883 134225920 16777215 196721081 1047000951 3865102958 4286107261 1885067371 33554431 33554431 2437792091 4284923758 4287224460 4287027851 4284266341 4230977347 152844572 61516458 93952409 1198060663 3831679084 4287027080 4287552399 4233345377 1884605796 2336866654 4284857964 4286962059 4286896264 4284069475 4230911554 152844572 33554431 33554431 33554431 169502259 4284334440 4285910139 4287684243 4286961546 4284990064 4285252723 4286764935 4286634375 4284003682 4247426367 152844572 33554431 33554431 33554431 33554431 33554431 186080558 4283676768 4285252979 4287159181 4287027594 4286568581 4286568325 4283806817 4264203071 171134259 50331647 33554431 33554431 33554431 33554431 33554431 33554431 186080535 4283018583 4284595563 4286634118 4286371460 4283741024 4264071742 152844572 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 186074647 4282229325 4284003683 4283544158 4263940413 152844572 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 186074647 4281243715 4213674302 136331296 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 186074647 136331296 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 33554431 16777215)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallOpenIcon [

	^ Icons
		at: #smallOpenIcon
		ifAbsentPut: [ self smallOpenIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallOpenIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 16777215 16777215 16777215 4167658343 4218055784 4234767207 4234833000 4234833000 4251741802 4251807595 3597825392 359492973 16777215 16777215 16777215 2676854157 3968633996 3968633996 3968633996 4285098855 4294572537 4294638330 4294704123 4294769916 4294769916 4294835709 4289835697 3782111083 242052461 16777215 16777215 4035677067 4292072403 4291940817 4291809231 4284967526 4292993505 4292598747 4292598747 4292598747 4292401368 4292269782 4294901502 4272202915 3563942253 158429553 16777215 4018570886 4291875024 4290690750 4290427578 4284967526 4293125091 4289506732 4289506732 4289506732 4289506732 4292730332 4294901502 4294835709 4272335015 2590863724 16777215 4001464705 4291611851 4290427578 4290295992 4285098855 4293454056 4293256677 4293190884 4293190884 4293190884 4293322470 4293783021 4293585642 4292467161 4050678382 16777215 3967647101 4291414473 4290295992 4290032820 4285098855 4293651435 4289704110 4289506731 4289506731 4289506731 4293190884 4293519849 4293519849 4292467417 4084101228 16777215 3950540920 4291085508 4290098613 4289835441 4285164648 4293914607 4293848814 4293848814 4293783021 4293783021 4293783021 4293783021 4293717228 4292927712 4050546540 16777215 3916591730 4290822336 4282744759 4281957047 4281957047 4281826232 4281759928 4281759928 4281628856 4281628855 4281628855 4281628855 4281563063 4281563063 4281563063 3828906425 3916394351 4290559164 4281628856 4291354096 4291354096 4291354096 4291354096 4291354096 4291354096 4291419632 4291419888 4291419888 4291419888 4291419888 4291025902 4264785848 3882445161 4290295992 4281628855 4291550960 4288463588 4288463588 4288463588 4288463588 4288463588 4288463588 4288463588 4288463588 4288463588 4288660965 4290894317 4247943351 3848561764 4290032819 4281759927 4291682288 4288857574 4288857574 4288857574 4288857574 4288857574 4288857574 4288857574 4288857574 4288857574 4288660709 4290893805 4214519992 3831389790 4289835441 4281825720 4291288047 4289054438 4288988902 4288988902 4288988902 4288988902 4288988902 4288988902 4288726245 4288331748 4288003810 4290434027 4197742776 3797572186 4289440683 4281957047 4289711337 4288200675 4287938018 4287609569 4287477985 4287346912 4287149791 4286821086 4286689758 4286689758 4286952670 4288725988 4164188600 3764083547 4289309097 4282088119 4288660196 4287412448 4287083999 4287083999 4287083999 4287083999 4287083999 4287083999 4287083999 4287083999 4287215583 4287609312 4147542200 3764017754 4287601320 4282088119 4284193486 4284259279 4284259279 4284259279 4284259279 4284259279 4284259279 4284259279 4284259279 4284259279 4284259279 4283404487 3644225976 2656459876 4281563063 4281563063 4281563063 4281563063 4281563063 4281563063 4281563063 4281563063 4281563063 4281563063 4281563063 4281563063 4281563063 3996481463 1194293175)
	offset: 0@0)
]

{ #category : #'private - icons' }
MenuIcons class >> smallPaintIcon [
	"Private - Generated method"
	^ Icons
			at: #'smallPaint'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self smallPaintIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> smallPaintIconContents [
	"Private - Method generated with the content of the file /home/dgd/smallPaint.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAAB60lEQVR4nJXQT0iTcRzH8ffze/5srT0zNvqr
KM42JTskoRJISVARCf0RCTp4KCMhELpJx4gQomNBl+jgtX8QnQorqIyg/5atpZmOlk62PXPP
9uCz5+kQ7bAObd/rh8+LD1+o8cJwIgzDgKi1S0Qw/Gi0wx0f3O62wAi1KG0Q6tu1/nLnnr3o
uh8JumoCXFmMjZze56eYxgYcyFQNNENTT7v/VKi1B4w5Vl0AFqoGBAwdP9IlIWuQX8SyS4hq
gV5QhMTJju6dsPwJcFk2TFyYrAr4AQd2tKzd4tkQhdQUpVVIpsylbxCvCpBgf19vM5hLkEtQ
tFzeTqfu/M2V/wKStNsQIV6+eMNWbN7FinxdyI3/AwyAvAbOBED9CFcfgw2gB4NqtP88iqZx
/d5dpiZuGrPwvAwcgnA9DM7Bg04YC4DPgM3AaBgiqrAablw6h+INkU1bzvRs9ixQKgNe8Ot/
kGPfYTIGFySYAVCFGDrYHq4reSQsJcur1x+exaE8H0Dcgvef4WIaMl7YdhSeKnA4At224yS0
lE1jRqHekPFpmlT5IwXAgTYVGppgXStIebjWHNy0uNGr1+krwowWPL77TpKcaV2pBGSAOHxp
hPwvMGMQL8D8z8KKFdACqt+W1du5+YmHyUT/DDypBH4Dwguh75kYJgEAAAAASUVORK5CYII='
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallPasteIcon [

	^ Icons
		at: #smallPasteIcon
		ifAbsentPut: [ self smallPasteIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallPasteIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 16777215 16777215 16777215 33554432 3983042920 4286743170 4286743170 4286743170 4286743170 3983042920 33554432 16777215 16777215 16777215 16777215 16777215 1278376377 4281628855 4281628855 4281628855 4286677633 4289377716 4289378230 4289378230 4289377716 4286677633 4281628855 4281628855 4281628855 1278376377 16777215 138420224 4281628855 4289252074 4292537599 4287207318 4286874756 4288652194 4288717730 4288717730 4288586401 4286874756 4287206547 4292537599 4289252074 4281628855 71319552 524958216 4281628855 4292537599 4287207061 4294375158 4293651435 4291940817 4291940817 4291940817 4291940817 4293651435 4294440951 4287206290 4292537599 4281628855 273694720 524958216 4281628855 4292537599 4287270541 4294967295 4294309365 4294309365 4294309365 4294309365 4294309365 4294309365 4294967295 4287270798 4292537599 4281628855 273694720 524958216 4281628855 4292537599 4287270541 4294967295 4294309365 4291546572 4291546572 4291546572 4291546572 4294243828 4294967295 4287270798 4292537599 4281628855 273694720 524958216 4281628855 4292537599 4287270541 4294967295 4294309365 4294309365 4294309365 4294309365 4294243828 4294112499 4294967295 4287270798 4292537599 4281628855 273694720 524958216 4281628855 4292537599 4287270541 4294967295 4294309365 4291546572 4291546572 4291480779 4291480522 4293980656 4294967295 4287270798 4292537599 4281628855 273694720 524958216 4281628855 4292537599 4287270541 4294967295 4294309365 4294243828 4294178035 4294046449 4293980656 4293322983 4294967295 4287270798 4292537599 4281628855 273694720 524958216 4281628855 4292537599 4287270541 4294967295 4294243572 4294112242 4294046449 4293980656 4293257190 4292665053 4294967295 4287270798 4292537599 4281628855 273694720 524958216 4281628855 4292537599 4287270541 4294967295 4294046706 4293980656 4293915120 4292730846 4291744208 4291678672 4294967295 4287270798 4292537599 4281628855 273694720 524958216 4281628855 4292537599 4287270541 4294967295 4293980656 4293849327 4293191397 4291743951 4294967295 4294967295 4294967295 4287270798 4292537599 4281628855 273694720 524958216 4281628855 4292537599 4287270541 4294967295 4293783791 4293125861 4292138709 4291612622 4294967295 4294967295 4287270798 4292537599 4292537599 4281628855 273694720 524958216 4281628855 4292537599 4287076246 4294178035 4294901502 4294901502 4294901502 4294243828 4294835965 4287270798 4292537599 4292537599 4292537599 4281628855 273694720 138420224 4281628855 4289252074 4292537599 4287142553 4287468177 4287468177 4287468177 4287468177 4287468177 4292537599 4292537599 4292537599 4289252074 4281628855 71319552 16777215 1278376377 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 1278376377 16777215)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallPinIcon [

	^ Icons
		at: #smallPinIcon
		ifAbsentPut: [ self smallPinIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallPinIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 1560237654 2550092884 872371541 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 1560237654 4294923605 4294923605 4294923605 1560237654 16777215 16777215 16777215 16777215 4294923605 16777215 16777215 16777215 16777215 16777215 1560237654 4294923605 4294923605 4294936712 4294936712 4294923605 1560237654 16777215 16777215 16777215 4294923605 4294923605 16777215 16777215 16777215 1560237654 4294923605 4294923605 4294936712 4294936712 4294923605 4294923605 4294923605 872371541 16777215 16777215 1560237654 4294923605 4294923605 1560226346 2113885782 4294923605 4294923605 4294936712 4294936712 4294923605 4294923605 4294923605 4293283149 2550092884 16777215 16777215 16777215 2113885782 4294923605 4294923605 4294923605 4294923605 4294936712 4294936712 4294923605 4294923605 4294923605 4293283149 4291576900 2107979575 16777215 16777215 16777215 16777215 2902410822 4294923605 4294923605 4294936712 4294936712 4294923605 4294923605 4294923605 4293283149 4291576900 2107979575 16777215 16777215 16777215 16777215 16777215 872371541 3187614499 4294923605 4294923605 4294923605 4294923605 4294923605 4293283149 4291576900 2107979575 16777215 16777215 16777215 16777215 16777215 16777215 16777215 1560237654 3405717793 4294923605 4294923605 4294923605 4293283149 4291576900 2107979575 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 3212409209 4286151033 3405717793 4294923605 4294923605 4291773765 2545302845 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 3212409209 4286151033 3212409209 1560237654 3187614499 4294923605 4294923605 1560226346 16777215 16777215 16777215 16777215 16777215 16777215 16777215 3212409209 4286151033 3212409209 16777215 16777215 872371541 2902410822 4294923605 4294923605 16777215 16777215 16777215 16777215 16777215 16777215 2675472504 4286151033 3212409209 16777215 16777215 16777215 16777215 16777215 2113885782 4294923605 4294923605 16777215 16777215 16777215 16777215 2138601592 4286151033 2675472504 16777215 16777215 16777215 16777215 16777215 16777215 16777215 1560237654 4294923605 4294923605 16777215 16777215 16777215 4286151033 2138601592 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallPrintIcon [

	^ Icons
		at: #smallPrintIcon
		ifAbsentPut: [ self smallPrintIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallPrintIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 2176367288 4290296247 4290296247 4290296247 4290296247 4290296247 4290296247 4290296247 4290296247 4290296247 2176367288 16777215 16777215 16777215 16777215 16777215 4290296247 4294638330 4294638330 4294638330 4294638330 4294638330 4294638330 4294638330 4294638330 4294572537 4290296247 16777215 16777215 16777215 16777215 16777215 4290296247 4294638330 4291809231 4291809231 4291809231 4291809231 4291809231 4291809231 4291809231 4294572537 4290296247 16777215 16777215 16777215 16777215 16777215 4290296247 4294638330 4294243572 4294243572 4294243572 4294309365 4294309365 4294309365 4294309365 4294572537 4290296247 16777215 16777215 16777215 16777215 16777215 4290296247 4294572537 4291809231 4291809231 4291875024 4291875024 4291875024 4291940817 4291940817 4294572537 4290296247 16777215 16777215 16777215 16777215 16777215 4290296247 4294572537 4293322470 4293454056 4293519849 4293519849 4293585642 4293651435 4293717228 4294572537 4290296247 16777215 16777215 16777215 16777215 16777215 4290296247 4294506744 4289835441 4289835441 4289835441 4289967027 4293388263 4293388263 4293388263 4294572537 4290296247 16777215 16777215 16777215 2173603982 4287598991 4288125078 4290361785 4290295992 4290361785 4290361785 4290361785 4290361785 4290361785 4290295992 4290295992 4288125078 4287598991 2173603982 16777215 4287598991 4294835709 4294638330 4294375158 4294375158 4294375158 4294375158 4294375158 4294375158 4294375158 4294375158 4294375158 4293651435 4293783021 4287598991 16777215 4287598991 4294835709 4292664540 4294046193 4290559164 4294309365 4293256677 4293519849 4293388263 4293454056 4293322470 4293125091 4289703855 4292335317 4287598991 16777215 4287598991 4294177779 4292269525 4293190884 4293190884 4293190884 4293190884 4293190884 4293125091 4293190884 4293190884 4292927712 4288585116 4291875024 4287598991 16777215 4287598991 4294309365 4291480266 4288190358 4287466635 4287466635 4287203463 4287334792 4287203205 4286940290 4287071877 4287334792 4290756543 4291875024 4287598991 16777215 4287598991 4294309365 4291282887 4291151301 4291151301 4291151301 4291151301 4291151300 4291019715 4290822336 4290953922 4291085508 4291151301 4291940817 4287598991 16777215 4287598991 4293980400 4292861919 4292927712 4292927712 4292861919 4292861919 4292861919 4292861919 4292861919 4292730333 4292861919 4292796126 4292664540 4287598991 16777215 2811269520 4287598991 4287598991 4287598991 4287598991 4287598991 4287598991 4287598991 4287598991 4287598991 4287598991 4287598991 4287598991 4287598991 2811269520)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallProjectBackIcon [

	^ Icons
		at: #smallProjectBackIcon
		ifAbsentPut: [ self smallProjectBackIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallProjectBackIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 2083747767 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 2083747767 16777215 16777215 4281628855 4292537599 4292537599 4292537599 4292537599 4292537599 4293176763 4293176763 4292537599 4292537599 4292537599 4292537599 4292537599 4281628855 16777215 16777215 4281628855 4292537599 4292537599 4292537599 4292537599 4292985039 4293751676 4293751676 4292985039 4292537599 4292537599 4292537599 4292537599 4281628855 16777215 16777215 4281628855 4292537599 4292537599 4292537599 4292793830 4293496216 4294901760 4294901760 4293496216 4292793830 4292537599 4292537599 4292537599 4281628855 16777215 16777215 4281628855 4292537599 4292537599 4292537599 4292985039 4294901760 4294901760 4294901760 4294901760 4292985039 4292537599 4292537599 4292537599 4281628855 16777215 16777215 4281628855 4292537599 4292537599 4292537599 4292537599 4292537599 4292537599 4292537599 4292537599 4292537599 4292537599 4292537599 4292537599 4281628855 16777215 16777215 4281628855 4292537599 4278239744 4278239744 4278239744 4278239744 4292537599 4292537599 4290694609 4287727293 4287727293 4290694609 4292537599 4281628855 16777215 16777215 4281628855 4292537599 4278239744 4278239744 4278239744 4278239744 4292537599 4292537599 4287595701 4281014002 4281014002 4287661239 4292537599 4281628855 16777215 16777215 4281628855 4292537599 4278239744 4278239744 4278239744 4278239744 4292537599 4292537599 4287463852 4280948465 4280948465 4287464110 4292537599 4281628855 16777215 16777215 4281628855 4292537599 4278239744 4278239744 4278239744 4278239744 4292537599 4292537599 4290628297 4287595700 4287595700 4290628298 4292537599 4281628855 16777215 16777215 2083747767 4291090666 4284271650 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 2083747767 16777215 16777215 3169845236 4278231040 4278231040 3053453311 3053453311 3053453311 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 3053453311 4284271650 4289589680 4278231040 4278231040 4278231040 4278231040 3053453311 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4281118976 4283491340 4278248192 4278247936 4278246144 4278244352 4278231040 3053453311 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 3053453311 4281118976 4285526614 4278231040 4278231040 4278231040 4278231040 3053453311 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 3169910772 4278231040 4278231040 3053453311 3053453311 3053453311 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallProjectIcon [

	^ Icons
		at: #smallProjectIcon
		ifAbsentPut: [ self smallProjectIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallProjectIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 2083747767 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 2083747767 16777215 16777215 4281628855 4292537599 4292537599 4292537599 4292537599 4292537599 4293176763 4293176763 4292537599 4292537599 4292537599 4292537599 4292537599 4281628855 16777215 16777215 4281628855 4292537599 4292537599 4292537599 4292537599 4292985039 4293751676 4293751676 4292985039 4292537599 4292537599 4292537599 4292537599 4281628855 16777215 16777215 4281628855 4292537599 4292537599 4292537599 4292793830 4293496216 4294901760 4294901760 4293496216 4292793830 4292537599 4292537599 4292537599 4281628855 16777215 16777215 4281628855 4292537599 4292537599 4292537599 4292985039 4294901760 4294901760 4294901760 4294901760 4292985039 4292537599 4292537599 4292537599 4281628855 16777215 16777215 4281628855 4292537599 4292537599 4292537599 4292537599 4292537599 4292537599 4292537599 4292537599 4292537599 4292537599 4292537599 4292537599 4281628855 16777215 16777215 4281628855 4292537599 4278239744 4278239744 4278239744 4278239744 4292537599 4292537599 4290694609 4287727293 4287727293 4290694609 4292537599 4281628855 16777215 16777215 4281628855 4292537599 4278239744 4278239744 4278239744 4278239744 4292537599 4292537599 4287595701 4281014002 4281014002 4287661239 4292537599 4281628855 16777215 16777215 4281628855 4292537599 4278239744 4278239744 4278239744 4278239744 4292537599 4292537599 4287463852 4280948465 4280948465 4287464110 4292537599 4281628855 16777215 16777215 4281628855 4292537599 4278239744 4278239744 4278239744 4278239744 4292537599 4292537599 4290628297 4287595700 4287595700 4290628298 4292537599 4281628855 16777215 16777215 2083747767 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 2083747767 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallProjectJumpIcon [

	^ Icons
		at: #smallProjectJumpIcon
		ifAbsentPut: [ self smallProjectJumpIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallProjectJumpIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 2083747767 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 2083747767 16777215 16777215 4281628855 4292537599 4292537599 4292537599 4292537599 4292537599 4293176763 4293176763 4292537599 4292537599 4292537599 4292537599 4292537599 4281628855 16777215 16777215 4281628855 4292537599 4292537599 4292537599 4292537599 4292985039 4293751676 4293751676 4292985039 4292537599 4292537599 4292537599 4292537599 4281628855 16777215 16777215 4281628855 4292537599 4292537599 4292537599 4292793830 4293496216 4294901760 4294901760 4293496216 4292793830 4292537599 4292537599 4292537599 4281628855 16777215 16777215 4281628855 4292537599 4292537599 4292537599 4292985039 4294901760 4294901760 4294901760 4294901760 4292985039 4292537599 4292537599 4292537599 4281628855 16777215 16777215 4281628855 4292537599 4292537599 4292537599 4292537599 4292537599 4292537599 4292537599 4292537599 4292537599 4292537599 4292537599 4292537599 4281628855 16777215 16777215 4281628855 4292537599 4278239744 4278239744 4278239744 4278239744 4292537599 4292537599 4290694609 4287727293 4287727293 4290694609 4292537599 4281628855 16777215 16777215 4281628855 4292537599 4278239744 4278239744 4278239744 4278239744 4292537599 4292537599 4287595701 4281014002 4281014002 4287661239 4292537599 4281628855 16777215 16777215 4281628855 4292537599 4278239744 4278239744 4278239744 4278239744 4292537599 4292537599 4287463852 4280948465 4280948465 4287464110 4292537599 4281628855 16777215 16777215 4281628855 4292537599 4278239744 4278239744 4278239744 4278239744 4292537599 4292537599 4290628297 4287595700 4287595700 4290628298 4292537599 4281628855 16777215 16777215 2083747767 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4284271650 4291090666 2083747767 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 3053453311 3053453311 3053453311 4278231040 4278231040 3500729258 16777215 16777215 1275109632 4278231040 1275109632 4278231040 1275109632 4278231040 1275109632 3053453311 4278231040 4278231040 4278231040 4278231040 4278241792 4278231040 3417498546 16777215 4278231040 4278246144 4278231040 4278246144 4278231040 4278246144 4278231040 3053453311 4278231040 4278246144 4278246144 4278246144 4278246144 4278241792 4278231040 16777215 1275109632 4278231040 1275109632 4278231040 1275109632 4278231040 1275109632 3053453311 4278231040 4278231040 4278231040 4278231040 4278241792 4278231040 3417498546 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 3053453311 3053453311 3053453311 4278231040 4278231040 3500729258 16777215)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallProjectLoadIcon [

	^ Icons
		at: #smallProjectLoadIcon
		ifAbsentPut: [ self smallProjectLoadIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallProjectLoadIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 16777215 16777215 16777215 16777215 16777215 1278376377 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 1278376377 16777215 16777215 16777215 16777215 16777215 16777215 4281628855 4292537599 4292537599 4292537599 4294928966 4294928966 4292537599 4292537599 4292537599 4281628855 16777215 16777215 16777215 16777215 4281628855 4281628855 4281628855 4292537599 4292537599 4294949256 4294901760 4294901760 4294949256 4292537599 4292537599 4281628855 16777215 16777215 1412725174 4281628855 4281628855 4287412967 4281628855 4288923367 4292537599 4294933841 4294901760 4294901760 4294933841 4292537599 4292537599 4281628855 16777215 1412725174 4281628855 4290304767 4290304767 4290304767 4287412967 4281628855 4278247936 4278247936 4292537599 4292537599 4290947299 4290947299 4292537599 4281628855 16777215 4281628855 4290304767 4287412967 4281628855 4287412967 4281628855 4279353404 4278247936 4278247936 4292537599 4290947299 4282515711 4282515711 4290947299 4281628855 16777215 4281628855 4290304767 4281628855 4281628855 4281628855 4281628855 4278247936 4278247936 4278247936 4292537599 4290947299 4282515711 4282515711 4290947299 4281628855 16777215 4281628855 4281628855 4281628855 16777215 16777215 1278376377 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 1278376377 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4286151288 4286151288 4286151288 4286151288 4286151288 4286151288 4286151288 4286151288 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4286151288 4294770683 4294770683 4294770683 4294770683 4294770683 4294770683 4286151288 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4286151288 4294770683 4294770683 4294770683 4294770683 4294770683 4294770683 4286151288 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4286151288 4294770683 4294770683 4294770683 4294770683 4294770683 4294770683 4286151288 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4286151288 4286151288 4286151288 4286151288 4286151288 4286151288 4286151288 4286151288 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4286151288 4294770683 4294770683 4294770683 4294770683 4294770683 4294770683 4286151288 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4286151288 4286151288 4286151288 4286151288 4286151288 4286151288 4286151288 4286151288 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallProjectNextIcon [

	^ Icons
		at: #smallProjectNextIcon
		ifAbsentPut: [ self smallProjectNextIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallProjectNextIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 3178078063 4282619024 4282619024 4282619024 4282619024 4282619024 4282619024 4282619024 4282619024 4282619024 4282619024 4282619024 4282619024 3178078063 16777215 16777215 4282619024 4292666586 4292666586 4292666586 4292666586 4292666586 4294159759 4294159503 4292666586 4292666586 4292666586 4292666586 4292600791 4282619024 16777215 16777215 4282619024 4292666587 4292337348 4292337348 4292337348 4293637757 4294139970 4294139970 4293571966 4292271812 4292271812 4292337350 4292600791 4282619024 16777215 16777215 4282619025 4292666589 4292337349 4292337349 4292337349 4294079056 4294901760 4294901760 4294079056 4292337349 4292337349 4292271812 4292600790 4282619024 16777215 16777215 4282619025 4292732381 4292337608 4292337608 4292337608 4294901760 4294901760 4294901760 4294901760 4292337350 4292271810 4292271553 4292600791 4282619024 16777215 16777215 4282619025 4292666586 4292337609 4285977428 4285977170 4285911632 4285911631 4292271554 4291084195 4287727293 4287727293 4291084196 4292534996 4282619024 16777215 16777215 4282619025 4292469200 4292140219 4278239744 4278239744 4278239744 4285713988 4292074168 4287595701 4281014002 4281014002 4287661239 4292337610 4282619024 16777215 16777215 4282619025 4292140221 4291942577 4278239744 4278239744 4278239744 4285582397 4291942577 4287463852 4280948465 4280948465 4287464110 4292140221 4282619024 16777215 16777215 4282619026 4292074170 4292074167 4278239744 4278239744 4278239744 4285713987 4292074167 4290886292 4287595700 4287595700 4290886293 4292073912 4282619024 16777215 16777215 4282619026 4291415968 4291415968 4291415968 4291415968 4291415968 4291415968 4291415968 4291415968 4291415968 4284271650 4293915107 4291153049 4282619024 16777215 16777215 3178078063 4282619024 4282619024 4282619024 4282619024 4282619024 4282619024 4291354847 4291354847 4291354847 4278231040 4278231040 4290962394 3178078063 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 3053453311 4278231040 4278231040 4278231040 4278231040 4289589680 4284271650 3053453311 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 3053453311 4278231040 4278244352 4278246144 4278247936 4278248192 4283491340 4281118976 3053453311 16777215 16777215 16777215 16777215 16777215 16777215 16777215 3053453311 4278231040 4278231040 4278231040 4278231040 4285526614 4281118976 3053453311 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 3053453311 3053453311 3053453311 4278231040 4278231040 3169910772 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4281118976 3053453311 16777215 16777215 16777215)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallProjectSaveIcon [

	^ Icons
		at: #smallProjectSaveIcon
		ifAbsentPut: [ self smallProjectSaveIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallProjectSaveIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 1278376377 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 1278376377 16777215 16777215 16777215 16777215 16777215 16777215 4281628855 4292537599 4292537599 4292537599 4294928966 4294928966 4292537599 4292537599 4292537599 4281628855 16777215 16777215 16777215 16777215 16777215 16777215 4281628855 4292537599 4292537599 4294949256 4294901760 4294901760 4294949256 4292537599 4292537599 4281628855 16777215 16777215 16777215 16777215 16777215 16777215 4281628855 4292537599 4292537599 4294933841 4294901760 4294901760 4294933841 4292537599 4292537599 4281628855 16777215 16777215 16777215 16777215 16777215 16777215 4281628855 4278247936 4278247936 4278247936 4292537599 4292537599 4290947299 4290947299 4292537599 4281628855 16777215 4281628855 4281628855 1412725174 16777215 16777215 4281628855 4278247936 4278247936 4278247936 4292537599 4290947299 4282515711 4282515711 4290947299 4281628855 16777215 4281628855 4290304767 4281628855 1412725174 16777215 4281628855 4278247936 4278247936 4278247936 4292537599 4290947299 4282515711 4282515711 4290947299 4281628855 16777215 4281628855 4287412967 4290304767 4281628855 16777215 1278376377 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 4281628855 1278376377 16777215 16777215 4281628855 4290304767 4281628855 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4281628855 4281628855 4290304767 4281628855 4281628855 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4286151288 4286151288 4286151288 4281628855 4287412967 4290304767 4287412967 4281628855 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4286151288 4294770683 4294770683 4290434020 4281628855 4287412967 4281628855 4284643980 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4286151288 4294770683 4294770683 4294770683 4290434020 4281628855 4290434020 4286151288 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4286151288 4294770683 4294770683 4294770683 4294770683 4294770683 4294770683 4286151288 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4286151288 4286151288 4286151288 4286151288 4286151288 4286151288 4286151288 4286151288 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4286151288 4294770683 4294770683 4294770683 4294770683 4294770683 4294770683 4286151288 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4286151288 4286151288 4286151288 4286151288 4286151288 4286151288 4286151288 4286151288)
	offset: 0@0)
]

{ #category : #'private - icons' }
MenuIcons class >> smallPublishIcon [
	"Private - Generated method"
	^ Icons
			at: #'smallPublish'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self smallPublishIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> smallPublishIconContents [
	"Private - Method generated with the content of the file /home/dgd/smallPublish.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAADG0lEQVQ4jY2Sb2jUdQDGP9/fn7vN29+7tv2c
t5tenulsUd1miWlEFCjZzRdRVPiiEnohBBaLIiRIg9heDAuiFwVJONgcWrBilajlKlKU5cEa
zrlluzvnbfd/9/f3/fYiKgoOel4/z4cHnkfwP7Tl4X2PSanvEeBXyCkp1PC1705NA4h/Obfi
oMU8R6fLQzi5H/9Tl+6+rT7b3Nn4RK63Lxap73LZ878sVc6NNqhycWjmwtgx/e9wkG4cvM2T
vr5nB171zPiSL3gmbgeeeyjwzIcHLWf7XRvdzzddrf+hZa9V3ravwb48scnjvTOsE8R0Pej5
eus7oYH0675guUcn7IzTGLDE8tpE99D6dmFaXUTjgu1101wvdjAj12rC11WSV852GMChbe89
/ehZbRy+SkuUlCrkMlYSNxC/RVh0P0Kdqmd4+T70smRBNrO9McLSmlYrLES3galtDnsXYSxt
M5TowGsexrr8MhP2zc7JHkfh8M62QGUKZ/NO3sr2MbnlA0gvk8gpHq/RShoV+X08lgS30pFU
iJf7eS3h52jaVyM9M0em10XHY/dwJdNK3jYoFAVfxO7njRG1ksmXRzTyjKjha1FWAEEjk2T4
mRt/TiRfKp4ctN+c8kWKUueA5yJOmWHwTGrh/E+zN+26/FFxoIfdjpaOY7hb3Tu6g9Lpcmmm
oQtNEyCEmJu/pY5fiIqcozXV1lzrKK/mGlK50qlVQxyc+3Y0ZRiGufv98amNQiVAFliKzDJ3
8ThSr6d3VwhTt7HuOK8Ojcbay6vZ9tl15jzjJ+2/1jdavAFfIrlEPFkCVaFGGBTzaeoaHZh6
BWSB2lpd/f7jaB64/t+XGu42r5XKJKnYLYCipBbZFXoFoQokUnFqTYXDIWS1mxuFbHp1g+Ui
uzLHrx+fxtXrR7StZ/+nQxhK0NHkYgf3qmoAbfnWQgTg6okvCQ5+TnRgDGkXiMbiWKzBUIpS
SaveIBWPRjKpEr0vhrjU2syG4CaE3sQ3/e+CLIDWwEdHPslVBSjBif69D/iVbetK/dNUMwxh
mk7NcNSI1WzydDXAH4NwUmsvAPcyAAAAAElFTkSuQmCC'
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallQuitIcon [

	^ Icons
		at: #smallQuitIcon
		ifAbsentPut: [ self smallQuitIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallQuitIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 4284901482 4290098613 4288124823 4287401100 4286677377 4286085240 4285558896 4285295724 4294046194 4294112244 4294309366 4294440952 4294440952 4293980658 4287598995 679904902 4284901482 4290493371 4288585374 4287730065 4287137928 4286545791 4286019447 4285756275 4294046194 4294309365 4294572537 4294704124 4294769916 4294638330 4289243563 1066044042 4284901482 4291217094 4289111718 4288387995 4287664272 4287137928 4286677377 4286282619 4294046194 4294309366 4294638330 4288727272 4282685399 4294704123 4289769906 1183484554 4284901482 4291282887 4289572269 4289045925 4288387995 4287730065 4287203721 4286808963 4294046451 4294112502 4285771742 4284261853 4278219466 4292536564 4288260277 1736008038 4284901482 4291414473 4289769648 4289243304 4288716960 4288190616 4287664272 4287203721 4293324017 4282553556 4285444580 4289977081 4281306583 4280321491 4279467214 4278544569 4284901482 4291480266 4289835441 4289374890 4288848546 4288322202 4287795858 4286351764 4279335885 4285707496 4288007672 4288401400 4288861177 4288926713 4289189626 4278348735 4284901482 4291480266 4289967027 4289506476 4288980132 4288519581 4285894306 4278218436 4285182955 4285906421 4283345650 4283542770 4283674098 4283805170 4288335864 4278348992 4284901482 4291480266 4290164406 4289638062 4289177511 4288585374 4278217663 4281832927 4284527603 4280522222 4278946541 4278224107 4278224106 4278224364 4286300406 4278348992 4284901482 4291480266 4290295992 4289835441 4289243304 4288716960 4286944417 4278217920 4280782815 4281638640 4278223849 4278223849 4278223849 4278224106 4284133619 4278348735 4284901482 4291480266 4290295992 4289901234 4289374890 4288914339 4288387995 4287337370 4280057289 4279600088 4281835503 4282689009 4282097645 4282294251 4282425579 4278348735 4284901482 4291480266 4290295992 4290032820 4289572269 4289111718 4288716960 4287927444 4285625720 4283604181 4278220498 4281572332 4278218436 4278482381 4278218435 4079241345 4284901482 4291480266 4290295992 4290295992 4289835441 4289309097 4286743170 4288322460 4292467419 4293454314 4286230746 4278219466 4278218951 4293520107 4288190874 814056837 4284901482 4291480266 4290361785 4290624957 4288124824 4288454561 4291875283 4292533470 4292730592 4292796385 4292862178 4288002776 4283209424 4292665056 4286875272 495223940 4284901482 4291743438 4289177769 4288783012 4291283661 4291612369 4291743954 4291743955 4291809747 4291809747 4291809747 4291809747 4291809747 4291612626 4285690998 176193664 3309849418 4286282878 4284967275 4285033068 4285098861 4285098861 4285098861 4285098861 4285164654 4285164654 4285164654 4285164654 4285164654 4285098861 3326889805 41975936 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallQuitNoSaveIcon [

	^ Icons
		at: #smallQuitNoSaveIcon
		ifAbsentPut: [ self smallQuitNoSaveIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallQuitNoSaveIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 4284967526 4290098613 4288124823 4287401100 4286677377 4286085240 4285558896 4285295724 4294111985 4294243570 4294375157 4294506743 4294506743 4293980912 4287730575 369098751 4284967526 4290493371 4288585374 4287730065 4287137928 4286545791 4286019447 4285756275 4294111985 4294309365 4294572537 4294769915 4294769916 4294638330 4289375144 587202559 4284967526 4291217094 4289111718 4288387995 4287664272 4287137928 4286677377 4286282619 4294111985 4294375157 4294638330 4293435552 4292297797 4294704123 4289835696 654311423 4284967526 4291282887 4289572269 4289045925 4288387995 4287730065 4287203721 4286808963 4294177777 4294374642 4292768627 4292697180 4291428352 4294237146 4290091673 988390307 4284967526 4291414473 4289769648 4289243304 4288716960 4288190616 4287664272 4287203721 4294043878 4292100674 4293160558 4294554547 4292292400 4292026402 4291695379 4173529088 4284967526 4291480266 4289835441 4289374890 4288848546 4288322202 4287795858 4287921276 4291629331 4293423730 4294481302 4294482843 4294550178 4294550435 4294616999 4240637952 4284967526 4291480266 4289967027 4289506476 4288980132 4288519581 4288836982 4291035136 4293618282 4294276470 4294069839 4294070609 4294071124 4294071637 4294482586 4240703488 4284967526 4291480266 4290164406 4289638062 4289177511 4288585374 4290707456 4292818744 4294140000 4293796644 4293724943 4293591040 4293525504 4293656576 4294343547 4240703488 4284967526 4291480266 4290295992 4289835441 4289243304 4288716960 4288775557 4290772992 4292814633 4293932085 4293459968 4293459968 4293459968 4293525504 4294138458 4240637952 4284967526 4291480266 4290295992 4289901234 4289374890 4288914339 4288387995 4288318347 4291370268 4292351255 4293867320 4294001733 4293737276 4293606975 4293607489 4257415168 4284967526 4291480266 4290295992 4290032820 4289572269 4289111718 4288716960 4287927444 4286083697 4292170578 4291952640 4293669684 4291035136 4291625991 4290969600 3368550400 4284967526 4291480266 4290295992 4290295992 4289835441 4289309097 4286743170 4288388250 4292467673 4293520104 4292508538 4291428352 4291231744 4293585897 4288256664 436207615 4284967526 4291480266 4290361785 4290624957 4288125079 4288586140 4291941328 4292665050 4292796637 4292862430 4292928223 4292384661 4291841612 4292731100 4287006852 268435455 4284967526 4291743438 4289243559 4288914593 4291415495 4291678668 4291875534 4291875790 4291875791 4291875791 4291875791 4291875791 4291875791 4291809996 4285822578 100663295 2238541675 4286348923 4285098855 4285164648 4285230441 4285230441 4285230441 4285230441 4285296234 4285296234 4285296234 4285296234 4285296234 4285230441 2255647856 33554431 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallRedoIcon [

	^ Icons
		at: #smallRedoIcon
		ifAbsentPut: [ self smallRedoIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallRedoIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4282691328 860270336 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4282691328 4282691328 1128640256 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4282691328 4289526392 4282691328 1094955264 16777215 16777215 16777215 16777215 16777215 16777215 16777215 122271232 1178971904 2655301120 3477384960 4282691328 4282691328 4289526392 4289526392 4282691328 1094955264 16777215 16777215 16777215 16777215 16777215 910339840 2974068224 3298668032 3719096654 4289591414 4289591671 4289919871 4289001324 4285128704 4289526392 4282691328 1094955264 16777215 16777215 16777215 1246081024 3359944448 4256228425 4289722227 4288737880 4288866048 4288866048 4288866048 4288866048 4285128704 4285128704 4289526392 4282691328 998676224 16777215 725725696 3125128960 4289586251 4289853296 4289128704 4288080156 4288866048 4288866048 4290044672 4285128704 4285128704 4285128704 4285260032 4289526392 4282691328 16777215 2655301120 3936735531 4289852778 4289194502 4290044672 4290044672 4291877888 4285586944 4285128704 4285128704 4285128704 4285128704 4286901554 4282691328 1094955264 16777215 3662721792 4289917550 4290701860 4292009728 4288537088 4288931328 4288931328 4288931328 4288931328 4292864000 4285128704 4286901554 4282691328 1094955264 16777215 16777215 4048204032 4289983599 4292141312 4272009984 4282691328 4282691328 4282691328 4282691328 4282691328 4292075264 4286901554 4282691328 1094955264 16777215 16777215 16777215 4282691328 4290964552 4289116160 4047810304 1933946624 809873152 16777215 16777215 4282691328 4286901554 4282691328 1094955264 16777215 16777215 16777215 16777215 4282691328 4256752690 4282691328 1212395008 16777215 16777215 16777215 16777215 4282691328 4282691328 860270336 16777215 16777215 16777215 16777215 16777215 4282691328 4122863670 4265914112 16777215 16777215 16777215 16777215 16777215 4282691328 860270336 16777215 16777215 16777215 16777215 16777215 16777215 3242438144 3333936384 3466506240 1212395008 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 1581559808 2253699584 2529681430 2359929600 205564416 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 541634304 1782820864 1531162112 491171840 79675136 61516288 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215)
	offset: 0@0)
]

{ #category : #'private - icons' }
MenuIcons class >> smallRemoteOpenIcon [
	"Private - Generated method"
	^ Icons
			at: #'smallRemoteOpen'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self smallRemoteOpenIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> smallRemoteOpenIconContents [
	"Private - Method generated with the content of the file /home/dgd/smallRemoteOpen.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAAD2klEQVQ4ja3T+0/VdRzH8efn+/18OTcOnJtc
zhFCg+EVD56BiYU4qQw1XdocttSt6VrL1fyh1vpBN7dq9mPZlv1Wm1OsDRZqU/DSkKkFelKS
wEsonANM1AOHw/d7Lt/TD9lWW2219f4DHnu/fnjC/3RidzkWIx+r1MkkLcxVBDcO9ZD6r5A0
8jiTY7XWyTzNrG9aq4TPnU/sDEXbEHwjspw81EPiX320K0T7gfbWtWORcc61tFBSWUnZwoX0
dnTQ09k5E4/FjitZvlYNjn/WR/yfIDUUYGFDrfpMyawEoRe3YySh5cAH7HpvG2t2vq2VLapa
kM2am8fHRvYsKcjU1BQjQ36GeqIYf4GWFuGrCC56uTjvEUz0UlBRzVRCYWqgk1JLmCJvhlBD
Hat3vCGL5lTMM/SZlx5Eo3uW+rO1NX76f4wwCqAuC5B2eArfXFw1G0QOZE0cpTV8d/QEoWXl
qGYCpm4jH1yixC956oXnWbl1l2pzuipvhsM7gn6zpXeECXVdhIfj7vQ79WtWaD/fy9AVjhET
RXiLA5w6doaxsQROtxun2w3pBEzexDJ1lYrqJVh88+T17ou23ijfyn1gNg/Hr2zeN1SXVG3k
BOZgvznKSH+E5cGNNK4OcPnCKUZb+ygpyadpQxCRTYE+wRPz5xM3RDnkeuXip7e6b9mM4Meb
illWW8prt5p5zjXBkChjuO0TPj38Awf3b0M4Z3O96zxHDrfSvH0lCAuqlAAapOcraWVm/871
flv9AgsXp5/kfVcb613XyAhJcMtb9EcFHae7IdLFouXLyS9dwODtSVCsKFKigAbZHMVplWub
an1i2l7EsbtzqbRH0UhimJCjKpStWMWFn6ZAOiA+QsOWV+i5fAe0PKQqEAIVMGU6K9xfjDey
t+AsxZ4Mtbfe5dlZD9jt78KuqkzmjjE0LDBMK5Z0EnuuxO4pQk/noKgqQkGCMJT4tNF3YsKj
p5IKm51XMYXCptyL+Geu4IqdJXZviEKvHc2WD5oD9Bh1GzYS7hlAVSWCx1AmlTo62XZwbN2d
1/loaAUAg7qLG/dtNHc3cvpKjODiEhRL7u/zEPgKvDg8hSjyD0hJqg8jg5dcroIN8TsD6fvl
q1xznLrY62sl/MtE9qtD7Y/kve5f49c6s+N3hx0zehprngdHfh4Ojw9D1+k40vIoPCq+FI9T
sZZWNXxoc3k3qtKSa5OmLZVMDURu931+/27/CWCkrkyr8lozTXY1Wx8I+JZWVi+ZZZom506e
/f7odeur4k/dCSCgaZovlUpJIAZE4e+Kz3dXFU5Xq6oouzGuDupp/fJvhgd0/Din8aMAAAAA
SUVORK5CYII='
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallRightFlushIcon [

	^ Icons
		at: #smallRightFlushIcon
		ifAbsentPut: [ self smallRightFlushIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallRightFlushIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 2862522779 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 4288257175 2862522779 16777215 16777215 4288257175 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294572537 4289638062 4289440683 4289440683 4289440683 4289440683 4289440683 4289440683 4294440950 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294572537 4294440950 4294440950 4294440950 4294440950 4294440950 4294440950 4294440950 4294572537 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294572537 4294572537 4294572537 4289638062 4289440683 4289440683 4289440683 4289440683 4294309365 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294572537 4294572537 4294572537 4294440950 4294440950 4294440950 4294375157 4294309365 4294440950 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294572537 4294572537 4294572537 4294572537 4294572536 4294506743 4294440950 4294375157 4294309365 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294572537 4289440683 4289309097 4289309097 4289309097 4289309097 4289309097 4289309097 4294309364 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572537 4294572536 4294375157 4294309365 4294309364 4294243571 4294177778 4294111985 4294046193 4294177779 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294572536 4294506743 4294440950 4294375157 4294309365 4294309365 4294243572 4294177779 4294177778 4294111985 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294440950 4294375158 4294309365 4294309365 4294309364 4289440683 4289309097 4289309097 4289309097 4293848814 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294375157 4294309365 4294309364 4294243571 4294177779 4293980400 4293914607 4293848814 4293783021 4293980399 4294901502 4288454554 16777215 16777215 4288257175 4294967295 4294901502 4294901502 4294901502 4294901502 4294901502 4294901502 4294901502 4294901502 4294901502 4294901502 4294967295 4288454554 16777215 16777215 2862522779 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 4288454554 2862522780 16777215)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallSaveAsIcon [

	^ Icons
		at: #smallSaveAsIcon
		ifAbsentPut: [ self smallSaveAsIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallSaveAsIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 2088343690 2119535780 1866038431 2352512158 3560536991 4281957279 4165041566 3847390612 2237959310 16777215 16777215 16777215 16777215 16777215 16777215 16777215 1581744805 2120722634 1569307355 3451508718 4292273651 4291617521 4288990696 4252212658 4249387676 461084520 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4287143846 4285694857 4283662745 4282615725 4282813362 4289252322 4291355120 4283799744 4284120721 4286677886 4286677886 4286677886 4286677886 4287796623 16777215 16777215 4287534739 4294967295 4293126109 4291944164 4286032581 4281957279 4289975786 4288464094 4284256430 4292601323 4294967295 4294967295 4294967295 4287862160 16777215 16777215 4287994512 4294046193 4294046193 4293257444 4286818752 4281957279 4286756567 4288266713 4282416802 4290234575 4294046193 4293980657 4293980657 4287862160 16777215 16777215 4287862160 4293914864 4281957279 4281957279 4281957279 4281957279 4286756567 4284195788 4281957279 4281957279 4281957279 4281957279 4293980400 4287862160 16777215 16777215 4287862160 4293783022 4292073678 4281957279 4288793573 4286230477 4286230477 4286230477 4286361550 4288661474 4281957279 4288854206 4293848558 4287862160 16777215 16777215 4287862160 4294704123 4293519849 4291810762 4281957279 4288793573 4286361550 4286361550 4290040551 4281957279 4288656827 4293519849 4294375158 4287862160 16777215 16777215 4287862160 4294046193 4294704123 4293519849 4291810762 4281957279 4290106858 4288793573 4282154659 4288656827 4293519849 4294704123 4294046193 4287862160 16777215 16777215 4287862160 4293519849 4294046193 4294704123 4294704123 4292271570 4282613922 4281957279 4289182914 4294704123 4294835709 4294046193 4293519849 4287862160 16777215 2158208927 4289901488 4289835952 4289901488 4289901488 4289901488 4289901488 4289901488 4289901488 4289901488 4289901488 4289901488 4289901488 4289901488 4289901488 2158208927 4286677886 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4278190080 4294967295 4294967295 4286677886 4286677886 4294967295 4290625211 4294967295 4290625212 4294967295 4290625211 4294967295 4290625211 4294967295 4291085763 4294967295 4278190080 4294967295 4294967295 4286677886 4286677886 4294967295 4291085763 4294967295 4291085763 4294967295 4291085763 4294967295 4291085763 4294967295 4291085763 4294967295 4278190080 4294967295 4294967295 4286677886 4286677886 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4278190080 4294967295 4294967295 4286677886 2155971454 4286677886 4286677886 4286677886 4286677886 4286677886 4286677886 4286677886 4286677886 4286677886 4286677886 4286677886 4286677886 4286677886 4286677886 2155971454)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallSaveIcon [

	^ Icons
		at: #smallSaveIcon
		ifAbsentPut: [ self smallSaveIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallSaveIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 2089200540 2119802550 1865322161 2351730865 3559886514 4281306802 4164849841 3847723431 2238554017 16777215 16777215 16777215 16777215 16777215 16777215 16777215 1581749686 2120857815 1569835238 3451969523 4292602614 4292012277 4289452015 4252872386 4249392559 461679227 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4287999926 4286748316 4284126380 4282227390 4282424771 4289779178 4291749876 4283738575 4284780964 4287862160 4287862160 4287862160 4287862160 4288849568 16777215 16777215 4288587684 4294967295 4293455075 4292404714 4286495186 4281306802 4290436848 4288991207 4284654271 4292930288 4294967295 4294967295 4294967295 4288980641 16777215 16777215 4289047457 4294243572 4294243572 4293586409 4287477965 4281306802 4287218657 4288859618 4282159540 4290892761 4294243572 4294178036 4294178036 4288980641 16777215 16777215 4288980641 4294112243 4281306802 4281306802 4281306802 4281306802 4287218657 4284068825 4281306802 4281306802 4281306802 4281306802 4294177779 4288980641 16777215 16777215 4288980641 4294046193 4292534487 4281306802 4289254892 4286693081 4286693081 4286693081 4286823898 4289188586 4281306802 4289578443 4294111729 4288980641 16777215 16777215 4288980641 4294769916 4293783021 4292337107 4281306802 4289254892 4286823898 4286823898 4290567150 4281306802 4289446856 4293783021 4294506744 4288980641 16777215 16777215 4288980641 4294243572 4294769916 4293783021 4292337107 4281306802 4290567664 4289254892 4281635253 4289446856 4293783021 4294769916 4294243572 4288980641 16777215 16777215 4288980641 4293783021 4294243572 4294769916 4294769916 4292732122 4282422196 4281306802 4289907150 4294769916 4294835709 4294243572 4293783021 4288980641 16777215 16777215 4288980641 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294506744 4294506744 4294111986 4294111986 4293783021 4288980641 16777215 16777215 4288980641 4288980641 4288980641 4288980641 4288980641 4288980641 4288980641 4288980641 4288980641 4288980641 4288980641 4288980641 4288980641 4288980641 16777215 16777215 4288980641 4291085252 4291085252 4291085252 4291085252 4291085252 4291085252 4291085252 4291085252 4291085252 4291085252 4291085252 4291085252 4288980641 16777215 16777215 4288980641 4291085252 4291085252 4291085252 4291085252 4291085252 4291085252 4291085252 4291085252 4291085252 4291085252 4291085252 4291085252 4288980641 16777215 16777215 4288980641 4291151301 4291151301 4291151301 4291151301 4291151301 4291151301 4291151301 4291151301 4291151301 4291151301 4291151301 4291151301 4288980641 16777215 16777215 4288849568 4287862160 4287862160 4287862160 4287862160 4287862160 4287862160 4287862160 4287862160 4287862160 4287862160 4287862160 4287862160 4288849568 16777215)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallSaveNewIcon [

	^ Icons
		at: #smallSaveNewIcon
		ifAbsentPut: [ self smallSaveNewIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallSaveNewIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 2089200540 2119802550 1865322161 2351730865 3559886514 4281306802 4164849841 3847723431 2238554017 16777215 16777215 16777215 16777215 16777215 16777215 16777215 1581749686 2120857815 1569835238 3451969523 4292602614 4292012277 4289452015 4252872386 4249392559 461679227 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4287999926 4286748316 4284126380 4282227390 4282424771 4289779178 4291749876 4283738575 4284780964 4287862160 4287862160 4287862160 4287862160 4288849568 16777215 16777215 4288587684 4294967295 4293455075 4292404714 4286495186 4281306802 4290436848 4288991207 4284654271 4292930288 4294967295 4294967295 4294967295 4288980641 16777215 16777215 4289047457 4294243572 4294243572 4293586409 4287477965 4281306802 4287218657 4288859618 4282159540 4290892761 4294243572 4294178036 4294178036 4288980641 16777215 16777215 4288980641 4294112243 4281306802 4281306802 4281306802 4281306802 4287218657 4284068825 4281306802 4281306802 4281306802 4281306802 4294177779 4288980641 16777215 16777215 4288980641 4294046193 4292534487 4281306802 4289254892 4286693081 4286693081 4286693081 4286823898 4289188586 4281306802 4289578443 4294111729 4288980641 16777215 16777215 4288980641 4294769916 4293783021 4292337107 4281306802 4289254892 4286823898 4286823898 4290567150 4281306802 4289446856 4293783021 4294506744 4288980641 16777215 16777215 4288980641 4294243572 4294769916 4293783021 4292337107 4281306802 4290567664 4289254892 4281635253 4289446856 4293717228 4294704123 4294177779 4288980641 16777215 16777215 4288980641 4293783021 4294243572 4294769916 4294769916 4292732122 4282422196 4281306802 4289907150 4294769916 4294901502 4285890304 4294638330 4288980641 16777215 16777215 4288980641 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294440951 4294835709 4285890304 4294508288 4285890304 4293190883 16777216 16777215 4288980641 4292598747 4292598747 4292598747 4292598747 4292467161 4292598747 4292598747 4294243572 4285890304 4289311744 4294508288 4289311744 4285890304 3003121663 16777215 4288980641 4291085252 4291085252 4291085252 4291085252 4291085252 4291085252 4291085252 4285890304 4294508288 4294508288 4294508288 4294508288 4294508288 4285890304 16777215 4288980641 4291085252 4291085252 4291085252 4291085252 4291085252 4291085252 4291085252 4293783021 4285890304 4289311744 4294508288 4289311744 4285890304 3003121663 16777215 4288980641 4291151301 4291151301 4291151301 4291151301 4291151301 4291151301 4291151301 4291151301 4293783021 4285890304 4294508288 4285890304 4293190883 16777215 16777215 4288849568 4287862160 4287862160 4287862160 4287862160 4287862160 4287862160 4287862160 4287862160 4287862160 4292796381 4285890304 4292796381 4288849568 16777215)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallScreenshotIcon [

	^ Icons
		at: #smallScreenshotIcon
		ifAbsentPut: [ self smallScreenshotIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallScreenshotIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 16777215 16777215 16777215 16777215 1982540587 4283392626 4284446346 4284446346 4284446346 4265561434 1462117926 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4282009685 4294967295 4294967295 4294967295 4294967295 4278190079 4282075478 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4282010199 4292209663 4294967295 4294967295 4294967295 4289649663 4282075478 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4281483596 4285105307 4288332514 4288859118 4289649151 4285237151 4282207836 16777215 16777215 16777215 16777215 2738567995 4283524727 4283129455 4282339422 4282471266 4282997611 4287410126 16777215 16777215 16777215 4288595688 4281088066 4282207836 4282339422 4283393141 2738567995 4284315017 4291028223 4290371327 4294967295 4294967295 4289649663 4287871704 4288793068 4289123060 4289583358 4289649151 4291553535 4289649151 4291028223 4291815679 4262992929 4284907927 4289649663 4284578703 4289386490 4289649663 4288595688 4291422207 4292472319 4291815679 4289649663 4288464102 4288464102 4287673812 4285500581 4290633983 4262992929 4284512397 4289452028 4284578703 4285830059 4288661482 4291028223 4290043391 4288661482 4288201184 4288201184 4287805142 4289386490 4285895853 4283524727 4289649663 4262992929 4284248967 4289188854 4284578703 4286093489 4289452028 4288135134 4288595688 4284512397 4281351496 4283656571 4287673812 4286159027 4288398052 4284117381 4289649663 4262992929 4284248967 4289188854 4284578703 4286093489 4288595688 4285500581 4281614926 4280429620 4279440147 4279440147 4281483596 4285105307 4285500581 4285171101 4289452028 4262992929 4284248967 4289188854 4284578703 4286685886 4285632423 4282997611 4282405472 4294967295 4289649663 4283393141 4281219910 4284973977 4285171101 4286356407 4289452028 4262795547 4284248967 4289188854 4284578703 4287476176 4285171101 4281746770 4283393141 4289649663 4294047999 4291422207 4284248967 4286159027 4285237151 4285830059 4289386490 4262795547 4284248967 4289188854 4284644497 4286685372 4285171101 4283063661 4279440147 4285961903 4292997631 4292866559 4286817728 4287673812 4285237151 4285961903 4288661482 4262269971 4283854207 4287937498 4288332771 4288003291 4288332514 4284842133 4280693050 4283524727 4284248967 4287410126 4290239999 4288201184 4288464102 4287015107 4286357176 4198056779 2738567995 4283854207 4283392626 4283392626 4262335254 4285171101 4285434531 4283393141 4284315017 4286093489 4284512397 4284051331 4283524727 4283392626 4283392369 2738567995 16777215 16777215 16777215 16777215 1261844022 2218408506 3578481483 4250166386 4283985793 4250166386 3595324751 1849178168 858927666 16777215 16777215 16777215)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallSearchIcon [

	^ Icons
		at: #smallSearchIcon
		ifAbsentPut: [ self smallSearchIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallSearchIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 16777215 16777215 16777215 2844298120 4118971263 4270032000 4286677886 4102062717 2542571658 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 1049398408 4169171584 4275361492 4292993763 4275887841 4292468193 4292796385 4275360979 4152328574 982356365 16777215 16777215 16777215 16777215 16777215 898667920 4269966464 4292993762 4188256462 4051150803 4202607067 4286296026 4050822352 4188584911 4293190884 4253123454 832018322 16777215 16777215 16777215 16777215 4118774141 4292993505 4204180946 4269518811 3989823728 3957780472 4242861558 3736589034 4252741594 4187666386 4293059298 4085153916 16777215 16777215 16777215 1989120396 4206278581 4188782032 4269518810 3890014453 3958108664 4042257914 4243058680 3705071349 3265316323 4269453018 4189701845 4155683760 1871811470 16777215 16777215 4286348921 4292993504 4285571534 4189508073 4225821173 4226149879 4209504247 4293258742 4040549618 3616191967 3850022619 4287476438 4292927711 4286348921 16777215 16777215 4269900670 4292862434 4286230234 3418150637 3453149937 3336103923 3235703028 3856394484 1854058716 2054926555 2340269274 4286230234 4293454056 4269900670 16777215 16777215 4202725756 4293256677 4269846745 3013262819 3049314029 2999902193 2580077294 2762853096 1517990106 1820176348 2189209564 4235700950 4293059298 4185883004 16777215 16777215 3348469650 4224700367 4237407702 3312690387 2340269274 1970974426 1585098972 1920839387 1333702363 1702801116 3211500488 4254447831 4174631890 3231094675 16777215 16777215 1654103191 3801388691 4292403431 4286296026 2558111192 2004528861 1652207325 2172366553 1434169051 2071374035 4286296026 4292468967 3933895800 2122877572 16777215 16777215 16777215 3883761531 3971463351 4291024100 4286296026 3496384451 1987685334 2742594518 3445920446 4286361562 4291811035 4272203427 4120418711 4068179065 426141286 16777215 16777215 781949846 4152328572 3819086754 4292995310 4288790749 4269977817 4286296026 4288856541 4292666346 4252860027 4291151300 4288125334 4253518213 3917052791 813727872 16777215 16777215 781949846 3833430139 3700527759 3802177952 4073573837 4293256677 3634076827 3782703477 1668247407 4286611838 4291085506 4288322970 4258386385 4286546045 16777215 16777215 16777215 16777215 1637391254 3063520407 4118774140 4286546300 3063520407 1637391254 16777215 2256436862 4286546045 4292203988 4292796126 4286546045 16777215 16777215 16777215 16777215 33554432 67108864 83886080 100663296 100663296 117440512 100663296 100663296 1685419381 4269834365 4286546045 1451262077 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215)
	offset: 0@0)
]

{ #category : #'private - icons' }
MenuIcons class >> smallSelectIcon [
	"Private - Generated method"
	^ Icons
			at: #'smallSelect'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self smallSelectIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> smallSelectIconContents [
	"Private - Method generated with the content of the file /home/dgd/smallSelect.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAABK0lEQVR4nKXOO0oEQRAG4L+6q2cfjojgBmJi
YmroEQwNBBPxFF7AzBt4DMHcyFwUE2MRPIDruuxMd9VvsKCbrOJOQVNNPT5KcHK7gTjdA2UH
MQzgnoCQIJ6AEAE3QFqQBSFk0DMcBaot1uxOobPjm/ODy/WhxrqvWvei1r35v1+FUIzM5mwz
PZt7a2Qx98eX9/Hp1cOFJpV0uD8aYUmkKJJixLBCXKxv1qmCSz/0VKtly79FEJlnjdBVgG+o
CljpgoVLJP499guQVFInIDtKJ6DJ3nQCPps86wTkgoYAVwYAycXYARAW8/8DKQZBgCgczdPr
x3h3azBwEtmc5qQZWZx0gsXJUpzFOe85+fw2mQCIgrPrbVg6AtFAQgHpAOznyTzTHRCDLNRt
ev8FfDedurn+q90AAAAASUVORK5CYII='
]

{ #category : #'private - icons' }
MenuIcons class >> smallSqueakIcon [
	"Private - Generated method"
	^ Icons
			at: #'smallSqueak'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self smallSqueakIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> smallSqueakIconContents [
	"Private - Method generated with the content of the file /home/dgd/smallSqueak.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAACWklEQVQ4jcWSW0hTARzGv52zeXY25ub0eEFd
BBsztbYcC8PWhZEsctm6jFlEWkQRBT4U0ioiirSHMAgzijDqLeqlop60jGhGiEoaydKtXXWX
pmdubpN5eukhTKM3v8f/x//38v2A1Q75j05UpVNfy5NLbdFwzANgCgCZV5h3qLiMaZ2JsjSA
sZUA5Jb62uFae3Mju1FZM+cLH6eynENdvfbe4dPWMw1NJj3KGWPSG6KXBejqNHeNF47uejo1
zWP7R5AqZ0hJcr7x7PlmlUgioi6fuA6/qpQWpRfy+csBKtUbjoiHEqj7HoCsQIVMGYEhZ0Cq
3WNAgUCAm/YupL66QcokxQQAHgkcLAH/EgAZAFRVa4TvevvQcqAJ2dgcnHMp7LfVo292Ft1+
PwiSACWikQzFUoQExK1OMHceg7m6GULHTsv2jkg0QnBiGi6XC8FgEJkgiwabCYowi8EbT+Af
/wG5VsnFIzND/CoI1+8DU7QIHixEVilpaWwrUinw6dE0KIqCx+MBXVOCjJdEca4YW5UK8E9a
4B33JOIT/nYiBzn5I+AjCAoDQoLU1WkgpQRob7XhQ+Ab1pmNsO7ehp+RBE7Z7CHn6EQ0PDYZ
i/YPdwIY4FMQHOuAp4uleSrVOaucTWfIZDyB9HwabRetWOA4OD5OYtTnRTKZvvK858XD3/6k
AID3pziMVvlerKuoUGyqFNDy3Jzc0kL0vv3M7fAtcu5w8OXgs9d7ly7GW3owm82v9Hq9UV6Q
H7/dc/+Ly+3uzoZn3wBIrCDd3xYaDAa7yWR6AGDN/z6tXn4B2ljYZPClNw8AAAAASUVORK5C
YII='
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallTimerIcon [

	^ Icons
		at: #smallTimerIcon
		ifAbsentPut: [ self smallTimerIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallTimerIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 16777215 16777215 16777215 16777215 16777215 4288526525 4116212343 4116212343 4288526525 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4284515726 4284515726 4284515726 4284515726 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4284515726 4284515726 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 2639020888 4116212343 4284449675 4284515726 4284909712 3377418592 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 1414084431 4149767289 4288526525 4291550689 4292208362 4292274155 4291419360 4288525497 4284515981 1414084431 16777215 16777215 16777215 16777215 16777215 1414084431 4267474568 4291090909 4291286488 4291875796 4284534498 4284534498 4293322728 4291877082 4291090909 4284450703 1414084431 16777215 16777215 16777215 16777215 4099434870 4291090909 4290693837 4292798956 4284534498 4284534498 4284534498 4294046451 4293849072 4290693837 4291090909 4099434870 16777215 16777215 16777215 2639020888 4288526525 4291089366 4292730334 4278190080 4284534498 4284534498 4284534498 4294178037 4293914865 4292730334 4291089366 4288526525 2639020888 16777215 16777215 3931463791 4291550689 4290561222 4294046451 4293522164 4278190080 4285054413 4284534498 4294178037 4293980401 4294046451 4290561222 4291550689 4285369491 75530240 16777215 4284450446 4292208362 4291415245 4293980401 4294243573 4294310137 4278190080 4280778896 4293190885 4293914865 4293914608 4294440951 4292076519 4284582032 16777215 16777215 3931463791 4291550689 4290363586 4294243573 4293717229 4293783279 4284966759 4278190080 4293651693 4293454314 4294506745 4294046194 4291550689 4284842635 16777215 16777215 2639020888 4288526525 4290497486 4293651436 4294046193 4293717229 4294506745 4293585900 4293454057 4294111987 4294506744 4292272611 4288526525 4066077045 16777215 16777215 16777215 4116146551 4291090909 4289838785 4293980401 4294309365 4293717229 4293191142 4293783279 4294309366 4293323499 4291090909 4284712333 890442520 16777215 16777215 16777215 1731932739 4284251783 4291090909 4290562765 4291678674 4294309366 4294177780 4294375159 4292600805 4291090909 4284581518 3493280325 1325400064 67108864 16777215 16777215 385875968 2385323570 4216680057 4288526525 4291550689 4292208362 4292274155 4291550689 4288526525 4284514697 3593219383 2147483648 1090519040 16777215 16777215 16777215 16777215 520093696 1509949440 3493476934 4233325429 4284383883 4284450703 4284185988 4064366169 2650800128 2097152000 939524096 33554432 16777215)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallTrafficIcon [

	^ Icons
		at: #smallTrafficIcon
		ifAbsentPut: [ self smallTrafficIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallTrafficIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 422804152 4281694648 4281694648 4281694648 4281694648 4281694648 4281694648 422804152 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4281694648 4289448421 4292255918 4293546071 4293546071 4292255918 4289448421 4281694648 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4281694648 4291288047 4293546071 4294836738 4294836738 4293546071 4291288047 4281694648 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4281694648 4291288047 4293546071 4294836738 4294836738 4293546071 4291288047 4281694648 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4281694648 4291288047 4292255918 4293546071 4293546071 4292255918 4291288047 4281694648 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4281694648 4291288047 4292265390 4293569111 4293569111 4292265390 4291288047 4281694648 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4281694648 4291288047 4293569111 4294872578 4294872578 4293569111 4291288047 4281694648 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4281694648 4291288047 4293569111 4294872578 4294872578 4293569111 4291288047 4281694648 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4281694648 4291288047 4292265390 4293569111 4293569111 4292265390 4291288047 4281694648 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4281694648 4291288047 4287747246 4282960727 4282960727 4287747246 4291288047 4281694648 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4281694648 4291288047 4282960727 4278370818 4278370818 4282960727 4291288047 4281694648 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4281694648 4291288047 4282960727 4278370818 4278370818 4282960727 4291288047 4281694648 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4281694648 4289448421 4287747246 4282960727 4282960727 4287747246 4289448421 4281694648 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 808811194 4281694648 4281694648 4281694648 4281694648 4281694648 4281694648 808811194 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215)
	offset: 0@0)
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallUndoIcon [

	^ Icons
		at: #smallUndoIcon
		ifAbsentPut: [ self smallUndoIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallUndoIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 16777215 16777215 16777215 16777215 16777215 16777215 4292129024 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 348959488 4292129024 4292129024 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 295077632 4292129024 4294834103 4292129024 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 295077632 4292129024 4294834103 4294962176 4292129024 4292129024 3889082880 3486232576 2764878080 193694464 16777215 16777215 16777215 16777215 16777215 295077632 4292129024 4294834103 4294633738 4294896384 4294832763 4294832503 4294635126 4177194867 3570184704 3587224576 479367680 16777215 16777215 16777215 177838336 4292129024 4294834103 4294633472 4294699535 4294370304 4294633472 4294370304 4293646336 4294107683 4294635120 4276869437 3838882816 848269056 16777215 16777215 4292129024 4294834103 4294633472 4294765071 4294699535 4294699535 4294633472 4294370304 4293909760 4293909760 4293909760 4294107683 4293515323 3402478080 177838336 16777215 295077632 4292129024 4294832770 4294765071 4294567680 4292988160 4292988160 4292988160 4293909760 4293909760 4293909760 4293448704 4294438002 4174625536 3419123968 16777215 16777215 295077632 4292129024 4294832766 4293185536 4294832766 4294766704 4294766704 4294766704 4294766704 4294764032 4293448704 4293054208 4294042744 4107187200 16777215 16777215 16777215 295077632 4292129024 4294832766 4294832766 4292129024 4292129024 4292129024 4292129024 4292000000 4294175095 4293448960 4294372208 4174361600 16777215 16777215 16777215 16777215 295077632 4292129024 4294832766 4292129024 16777215 16777215 819310336 1355393280 3386159616 4294569333 4294240640 4291867648 16777215 16777215 16777215 16777215 16777215 16777215 4292129024 4292129024 16777215 16777215 16777215 16777215 449753344 4292262912 4277595539 4291932928 16777215 16777215 16777215 16777215 16777215 16777215 16777215 4292129024 16777215 16777215 16777215 16777215 16777215 4275681792 4277134179 4023367168 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 584233984 4242919490 4276277570 2144319232 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 1574154752 3002197102 2933044736 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 1775351296 1775482368 416658688 16777215 16777215)
	offset: 0@0)
]

{ #category : #'private - icons' }
MenuIcons class >> smallUpdateIcon [
	"Private - Generated method"
	^ Icons
			at: #'smallUpdate'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self smallUpdateIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> smallUpdateIconContents [
	"Private - Method generated with the content of the file /home/dgd/smallUpdate.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAACz0lEQVR4nI3SW2hTBwDG8f85iSdpEnIxR+01
0TlmbawOWy8PdXZYFRXLVHwYLt5ARMUXH0Rh0DxIq1jQl3irw6KCSMecKDiYVZEZ6+jEFsrs
apektsY2tWnNSU/S0+T45IMgxO/5+35Pn8CXRyqysRmROoOIVReJSDl+MeZbOcx85XaYL2/Z
tnV1bd16saKyGovVgZJ8z/ZNNQvzAYt27tja/dOe3UJfLEXwfhjloQqiAX+1i5JS75J8gDh/
/jzhbqifJxNejHIFVWUzmcxo9IR7sNrs5nzAlDqp6mFVEYQCAZ9nJovnyuR0nbe9r3n+Ovom
HzCazkzp5aUOwW1zM8tupvvvByhDL1lTs5Shwcg1sbzUsq92xcK++rqVI99VL+gvdnLLbWHZ
R6C9/VFkTbWXRF+IcPtF0rF/WVtTyc0r5yfC72gRdmypGzjbcrPsRU8vnuLZSKLGrbartN24
8bb/VeRoMsd/P9av+8vhchlNZhMDkQGms9ncLM/immAw+FS0O53uI40XOPnnMAdau/Cf/oNh
oZizF84VHjy0r1VVGej8p6szq88gqYgsqKhiND7aVVRUdALAKCLqU7qRVb5isjmdjl4DnUkd
57OX2O02Ach0vxpe2xe97isw4RlTuAcotRtzjwHEWGww7il0kZvWMBkNfF3oACClTDIxkcwC
aUBRNZ6NKbQBSiAQcEqSpAIYX3SGWv0HjwXu3G7BOnseGYsXr7uQ5XPLaAn+PgJMAjQ1NS0T
BEFOp9OqLMtHotHoJQABkDasXvLcv3evr6M7yrSWwfNNJb45Art37W86fDTwsyzLv42Pj49o
mpaSJMmUSCTuNTc33/kIUAUW/6njqY5QCKvNSmwwRkpNx1d+X7+npKTkQCKRaG9oaDjzuaMY
AGKgxYf+r9hU/0O5JBWIY2PvctGheOjbquWueDz+a2NjY2uew30SJ2D70vIHGPAd/9jj14AA
AAAASUVORK5CYII='
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallUserQuestionIcon [

	^ self fugueUserSilhouetteQuestionIcon
]

{ #category : #'private - icons' }
MenuIcons class >> smallVolumeIcon [
	"Private - Generated method"
	^ Icons
			at: #'smallVolume'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self smallVolumeIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> smallVolumeIconContents [
	"Private - Method generated with the content of the file /home/dgd/smallVolume.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAAAmJLR0QA/4ePzL8AAAE3SURB
VHjajdE/SJRxHMfxF/f8Hp/n7vLhlAKhyKRCOpccA6EbFEW0BsciyKWphiBoCRuiQXEJnIyG
ampyEppydy8wBOFEyPzHA0X1wNGggV0Ivbbv8h3eH44rKWkT/XUNqdhxgrjz5kBTA90SiVlD
h0+PdI6PvZhKwDmPVL13G4KaOqcuTL+6k3z8iis+Sd0175pxy0H91ss066g+SKo+Q68uq4Zd
9M5DyyUdE6dHzg7XIrmdM7XHPriq8NoNaxJdgRypA7/Ezo8e9NjDpgzfhMC+kp92FXZb++u+
KKPbd5S1Ak2xVJ+WH3nzqQE5Jq3IpPJgY2GOrDe+NxhCYUvZkkGXvHHfkuJPhkr/4pNiZlsD
dbPq+ryVHS9Zqc1c39JAJhF5Zqw9dsXzw7yIXBb/u0fUNt7/+A0ZzEdfNHX2/wAAAABJRU5E
rkJggg=='
]

{ #category : #'accessing - icons' }
MenuIcons class >> smallWindowIcon [

	^ Icons
		at: #smallWindowIcon
		ifAbsentPut: [ self smallWindowIconContents ]
]

{ #category : #'private - icons' }
MenuIcons class >> smallWindowIconContents [
^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 1556466370 4291217859 4291217859 4291217859 4291217859 4291217859 4291217859 4291217859 4291217859 4291217859 4291217859 1556466370 16777215 16777215 16777215 16777215 4291217859 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4291217859 16777215 16777215 16777215 16777215 4291217859 4294901502 4279720860 4279720860 4279720860 4279720860 4279720860 4279720860 4279720860 4279720860 4294835709 4291217859 16777215 16777215 16777215 16777215 4291217859 4294835708 4281563063 4281563063 4281563063 4281563063 4281563063 4281563063 4281563063 4281563063 4294769916 4291217859 16777215 16777215 16777215 16777215 4291217859 4294704379 4294638330 4294638330 4293388774 4291217859 4291217859 4291217859 4291217859 4291217859 4291217859 4291217859 4291217859 4291217859 4291217859 1556466370 4291217859 4294572537 4294506744 4294441208 4291217859 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4291217859 4291217859 4294572537 4294374901 4294309365 4291217859 4294901502 4279720860 4279720860 4279720860 4279720860 4279720860 4279720860 4279720860 4279720860 4294835709 4291217859 4291217859 4294309365 4294046193 4294111986 4291217859 4294835708 4281563063 4281563063 4281563063 4281563063 4281563063 4281563063 4281563063 4281563063 4294769916 4291217859 4291217859 4294111987 4293914350 4293848814 4291217859 4294704379 4294638330 4294638330 4294638330 4294572793 4294572537 4294572537 4294572537 4294572537 4294572793 4291217859 4291217859 4294046449 4293585643 4293585642 4291217859 4294572537 4294506744 4294441208 4294506488 4294506744 4294506487 4294440951 4294506487 4294506487 4294572537 4291217859 4291217859 4294374901 4294112242 4294177522 4291217859 4294572537 4294374901 4294309365 4294309365 4294309365 4294243829 4294309365 4294309365 4294374901 4294506744 4291217859 1589888702 4291217859 4291217859 4291217859 4291217859 4294309365 4294046193 4294111986 4294111986 4294111986 4294111986 4294111986 4294111986 4294046193 4294243828 4291217859 16777215 16777215 16777215 16777215 4291217859 4294111987 4293914350 4293848814 4293848814 4293848814 4293783021 4293848814 4293848557 4293848558 4294111986 4291217859 16777215 16777215 16777215 16777215 4291217859 4294046449 4293585643 4293585642 4293585898 4293585642 4293585642 4293585642 4293585642 4293585642 4294046193 4291217859 16777215 16777215 16777215 16777215 4291217859 4294374901 4294112242 4294177522 4294111986 4294112243 4294111986 4294111986 4294177522 4294111986 4294111986 4291217859 16777215 16777215 16777215 16777215 1589888702 4291217859 4291217859 4291217859 4291217859 4291217859 4291217859 4291217859 4291217859 4291217859 4291217859 1556466370)
	offset: 0@0)
]

{ #category : #'private - icons' }
MenuIcons class >> squeakIcon [
	"Private - Generated method"
	^ Icons
			at: #'squeak'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self squeakIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> squeakIconContents [
	"Private - Method generated with the content of the file /home/dgd/squeak.png"
	^ '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'
]

{ #category : #'accessing - icons' }
MenuIcons class >> squeakLogoIcon [
^ Icons
		at: #squeakLogoIcon ifAbsentPut: [(Form
	extent: 24@16
	depth: 32
	fromArray: #( 0 0 67108865 2063597569 1778384897 889192449 0 0 0 0 0 0 0 0 0 0 0 0 1610612737 1811939329 1610612737 0 0 0 0 0 905969665 889192449 0 1442840577 788529153 0 0 0 0 0 0 0 0 0 0 1711276033 469762049 0 1728053249 0 0 0 0 0 1006632961 704643073 0 0 1895825409 234881025 0 0 0 0 0 0 0 0 1207959553 838860801 0 0 1728053249 0 0 0 0 0 738197505 989855745 0 0 167772161 1862270977 0 0 0 0 0 0 0 83886081 1879048193 0 0 0 1744830465 0 0 0 0 0 469762049 1258291201 0 0 0 1543503873 520093697 0 0 0 0 0 0 1543503873 335544321 0 0 0 1761607681 0 0 0 0 0 16777217 1644167169 0 0 0 33554433 67108865 0 0 0 0 0 0 33554433 0 0 0 0 1795162113 0 0 0 0 0 0 1711276033 0 0 0 0 0 117440513 0 0 0 0 0 0 0 0 0 100663297 1677721601 0 0 0 0 0 0 1744830465 0 0 0 0 3019898881 4009754625 1056964609 0 0 1090519041 3204448257 1325400065 0 0 0 889192449 889192449 0 0 0 0 0 0 1392508929 352321537 0 0 637534209 4278190081 4278190081 2650800129 0 0 3372220417 4278190081 3758096385 0 0 0 1560281089 117440513 0 0 0 0 0 0 0 0 0 0 134217729 4060086273 4278190081 1929379841 0 0 3187671041 4278190081 3590324225 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 704643073 1577058305 83886081 0 0 771751937 2667577345 956301313 0 0 0 0 0 0 0 0 0 0 369098753 973078529 1577058305 1728053249 1711276033 1325400065 805306369 218103809 0 855638017 922746881 16777217 0 268435457 788529153 1308622849 1593835521 1056964609 436207617 16777217 0 0 1442840577 1761607681 1409286145 788529153 301989889 872415233 1124073473 1627389953 1929379841 973078529 2030043137 4278190081 4278190081 2164260865 1040187393 1946157057 1577058305 939524097 452984833 687865857 1325400065 1778384897 1795162113 1392508929 0 0 855638017 1795162113 1677721601 855638017 620756993 436207617 486539265 285212673 2030043137 4278190081 4278190081 2164260865 486539265 1023410177 922746881 1157627905 1392508929 1845493761 1744830465 486539265 0 0 201326593 2013265921 1006632961 0 553648129 1694498817 1778384897 1694498817 1728053249 738197505 0 855638017 922746881 16777217 738197505 1728053249 1744830465 1778384897 1476395009 251658241 117440513 1476395009 1879048193 150994945 0 16777217 0 486539265 1426063361 16777217 0 0 0 0 0 0 0 0 0 0 0 0 234881025 1728053249 486539265 0 167772161 50331649)
	offset: 0@0)]
]

{ #category : #'class initialization' }
MenuIcons class >> startUp: resuming [ 
	resuming ifFalse: [^self].
	TranslationLocale = LocaleID current ifTrue:
		[^self].
	self initializeTranslations
]

{ #category : #'accessing - icons' }
MenuIcons class >> subMenuMarker [

	^ Icons
			at: #'subMenuMarker'
			ifAbsentPut:[ (Form
	extent: 5@9
	depth: 32
	fromArray: #( 4294967295 0 0 0 0 4294967295 4294967295 0 0 0 4294967295 4294967295 4294967295 0 0 4294967295 4294967295 4294967295 4294967295 0 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 0 4294967295 4294967295 4294967295 0 0 4294967295 4294967295 0 0 0 4294967295 0 0 0 0)
	offset: 0@0)].
]

{ #category : #'private - icons' }
MenuIcons class >> volumeIcon [
	"Private - Generated method"
	^ Icons
			at: #'volume'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self volumeIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> volumeIconContents [
	"Private - Method generated with the content of the file /home/dgd/volume.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAQAAABKfvVzAAAABGdBTUEAALGOfPtRkwAAACBj
SFJNAAB6JQAAgIMAAPn/AACA6QAAdTAAAOpgAAA6mAAAF2+SX8VGAAAAAmJLR0QA/4ePzL8A
AAAJcEhZcwAACxMAAAsTAQCanBgAAAHrSURBVDjLldTLahRBFMbx/xu02hEvm1mZIC4qovaA
LhoE142+QIMvILoRgjASdKEilSBxO5CFIhKbmUAQNWmD6KCQxCAMEi+JGGKISuETfC665uIM
DqRqd6hfn9Nd5zRidxsBV/jOH5rc5QhjJBDwnyUQ43xmix9ssMo8GRiygaBBg0dMM887FsCE
jvyfUwEZaRdY5CrDnOUyt8GE7pbaIKEEgEGYNnjpowmYIXdfeQfErJMAUCliArFMAJwEM+Sm
9V5r6iopIC+eXdDiK1lycux+90Qb2tavAlQxFxgBwwoAl8haIH+sTKN6oZ/6rW1ttjJYzEMO
QZUEKPnTgnxHmzqjHW3pm77ooxApEFC9QwoxVV+U8eCTmirrq9bU1KqWVNZBEewDe55JwGfM
iT1Y0hud0gct661ea1HndEzEQOUiUxzoBwt6quNq6JVyPdOcTuuwCE6AtUywpx/Mqq5RPdec
ZlVTTTjSBxBgp7gGCRYA136HG7qpYU2qrppqqou8VtxAcI8RyDBACddzD6GzbTAOFYIxjkLs
C6pQbYHWMqGbUF11kcNeH2OdEhDgiHsBmNBZzXRaI2XFN4YtWr4LREREYEJ3vQNKfpRSXNGh
PaBMBIb+ebA+Tz/wZPDE0ZMjgiAaBHb919jd/gvLk2YJrn7DBgAAAABJRU5ErkJggg=='
]

{ #category : #'private - icons' }
MenuIcons class >> windowIcon [
	"Private - Generated method"
	^ Icons
			at: #'window'
			ifAbsentPut:[ Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: self windowIconContents readStream) ].
]

{ #category : #'private - icons' }
MenuIcons class >> windowIconContents [
	"Private - Method generated with the content of the file /home/dgd/window.png"
	^ 'iVBORw0KGgoAAAANSUhEUgAAABwAAAAcCAYAAAByDd+UAAAABHNCSVQICAgIfAhkiAAAABF0
RVh0U29mdHdhcmUAU29kaXBvZGmU4xfQAAAB5UlEQVR4nO2WP2gTURzHP/fuEqMpZ1vUKBqq
FHFTB/+0XVSKRSxCBUVHQXHoUHeh4thFVwcnFwWdNFBErWgVVBIXBRGs1pZEjamtucvl7nKX
O4fkoPXPkHqCw32m977vz4f3ePB7EBEyUtDoGzrbLRDpMDeX63XjceZqDvCDTAHoP3HuwsHd
uy5uVNukuXQXruSR8ORlSaqyS6IuYwqX79MFfKG8mLx9pWeJcNv2HSOnx69Lq18+Z+zRJHmj
xNEt+5Al0ZJs3tZ4kM/SrW7ivZant7+Xzx9n9n79NHDkbfbeXcBRAN69eq3cHzzJ+sPHWGsn
SMopSvlCy6fz8NmqpOiwYgglxdybaWanpjArCzuBBeCpAmCZVZ4Uiwzs30NXpdRcXm5ZCLAO
AJ2U6/Iwl8N1nGCoA5pXGospjI0Oo7YllyX5E4cO9HD8zHlmF2UCYE1nuwhbBhCPx9ic3rAk
a+1VhEAkjISR8D8RGlXT9zzvnwjKuvGrsKxXStdujmPZtdBEtZrDrTsTfJgpUDMqepBLAH2D
p4aFiF+WJGlFaMYGvmVoz7ITNy4BDpAJvhirVibVoaTaqYZps23L1ue/BHXOATJKs2OahvbN
NDQrTOFPFGHRJwqQaRRJ6bfT/w6XRsWPCJ8feQeiSATBXJcAAAAASUVORK5CYII='
]
