"
I translate the message protocol generated by PostscriptCanvas that represents the Postscript imaging model into an actual stream of ASCII-encoded Postscript Level 2.

Alternative implementations might provide binary representations, Level I or Level III or even PDF.



"
Class {
	#name : #PostscriptEncoder,
	#superclass : #PrintableEncoder,
	#classVars : [
		'MacToPSCharacterMappings'
	],
	#category : #'MorphicExtras-Postscript Canvases'
}

{ #category : #configuring }
PostscriptEncoder class >> clearCharacterMappings [

	MacToPSCharacterMappings := nil.
]

{ #category : #configuring }
PostscriptEncoder class >> filterSelector [
	^#encodePostscriptOn:.
]

{ #category : #configuring }
PostscriptEncoder class >> macToPSCharacterChart [
	"mac char code, PS char code"
	^#(
		(128 999)  "Ä"
		(129 999)  "Å"
		(130 999)  "Ç"
		(131 999)  "É"
		(132 999)  "Ñ"
		(133 999)  "Ö"
		(134 999)  "Ü"
		(135 999)  "á"
		(136 999)  "à"
		(137 999)  "â"
		(138 999)  "ä"
		(139 999)  "ã"
		(140 999)  "å"
		(141 999)  "ç"
		(142 999)  "é"
		(143 999)  "è"
		(144 999)  "ê"
		(145 999)  "ë"
		(146 999)  "í"
		(147 999)  "ì"
		(148 999)  "î"
		(149 999)  "ï"
		(150 999)  "ñ"
		(151 999)  "ó"
		(152 999)  "ò"
		(153 999)  "ô"
		(154 999)  "ö"
		(155 999)  "õ"
		(156 999)  "ú"
		(157 999)  "ù"
		(158 999)  "û"
		(159 999)  "ü"
		(160 999)  ""
		(161 202)  "°"
		(162 162)  "¢"
		(163 163)  "£"
		(164 167)  "§"
		(165 183)  "·"
		(166 182)  "¶"
		(167 251)  "ß"
		(168 999)  "®"
		(169 999)  "©"
		(170 999)  ""
		(171 999)  "´"
		(172 999)  "¨"
		(173 999)  ""
		(174 225)  "Æ"
		(175 999)  "Ø"
		(176 999)  ""
		(177 999)  "±"
		(178 999)  ""
		(179 999)  ""
		(180 165)  "¥"
		(181 999)  "µ"
		(182 999)  ""
		(183 999)  ""
		(184 999)  ""
		(185 999)  ""
		(186 999)  ""
		(187 227)  "ª"
		(188 235)  "º"
		(189 999)  ""
		(190 241)  "æ"
		(191 999)  "ø"
		(192 191)  "¿"
		(193 166)  "¡"
		(194 999)  "¬"
		(195 999)  "¦"
		(196 999)  ""
		(197 999)  "­"
		(198 999)  "²"
		(199 171)  "«"
		(200 187)  "»"
		(201 188)  ""
		(202 999)  " "
		(203 999)  "À"
		(204 999)  "Ã"
		(205 999)  "Õ"
		(206 234)  ""
		(207 250)  ""
		(208 999)  ""
		(209 999)  ""
		(210 999)  ""
		(211 999)  ""
		(212 999)  ""
		(213 999)  ""
		(214 999)  "÷"
		(215 999)  "³"
		(216 999)  "ÿ"
		(217 999)  ""
		(218 999)  "¹"
		(219 999)  "¤"
		(220 999)  ""
		(221 999)  ""
		(222 999)  "¼"
		(223 999)  "½"
		(224 999)  ""
		(225 999)  "·"
		(226 999)  ""
		(227 999)  ""
		(228 999)  ""
		(229 999)  "Â"
		(230 999)  "Ê"
		(231 999)  "Á"
		(232 999)  "Ë"
		(233 999)  "È"
		(234 999)  "Í"
		(235 999)  "Î"
		(236 999)  "Ï"
		(237 999)  "Ì"
		(238 999)  "Ó"
		(239 999)  "Ô"
		(240 999)  "¾"
		(241 999)  "Ò"
		(242 999)  "Ú"
		(243 999)  "Û"
		(244 999)  "Ù"
		(245 999)  "Ð"
		(246 999)  ""
		(247 999)  ""
		(248 999)  "¯"
		(249 999)  "×"
		(250 999)  "Ý"
		(251 999)  "Þ"
		(252 999)  "¸"
		(253 999)  "ð"
		(254 999)  "ý"
		(255 999)  "þ"
	)
]

{ #category : #configuring }
PostscriptEncoder class >> mapMacStringToPS: aString [

	| copy |
	MacToPSCharacterMappings ifNil: [
		MacToPSCharacterMappings := Array new: 256.
		self macToPSCharacterChart do: [ :pair |
			pair second = 999 ifFalse: [MacToPSCharacterMappings at: pair first put: pair second]
		].
	].
	copy := aString copy.
	copy withIndexDo: [ :ch :index |
		| val |
		(val := ch asciiValue) > 127 ifTrue: [
			| newVal |
			(newVal := MacToPSCharacterMappings at: val) ifNotNil: [
				copy at: index put: newVal asCharacter
			].
		].
	].
	^copy
]

{ #category : #'Postscript generation' }
PostscriptEncoder >> clip [
	self print: 'clip'; cr.

]

{ #category : #'Postscript generation' }
PostscriptEncoder >> closepath [
	self print:'closepath'; cr.

]

{ #category : #'Postscript generation' }
PostscriptEncoder >> comment:aString [
	self print:'%'; print:aString; cr.


]

{ #category : #'Postscript generation' }
PostscriptEncoder >> comment:aString with:anObject [
	self print:'%'; print:aString; print:' '; write:anObject; cr.


]

{ #category : #'Postscript generation' }
PostscriptEncoder >> concat:aMatrix [
	self write:aMatrix asMatrixTransform2x3; print:' concat'; cr.


]

{ #category : #'Postscript generation' }
PostscriptEncoder >> curvetoQuadratic:targetPoint from:sourcePoint via:offPoint [
	self write:(sourcePoint + offPoint) / 2; print:' ';
		 write:(offPoint + targetPoint) / 2; print:' ';
		 write:targetPoint;
		 print:' curveto'; cr.

]

{ #category : #'Postscript generation' }
PostscriptEncoder >> eofill [
	self print: 'eofill'; cr.

]

{ #category : #'Postscript generation' }
PostscriptEncoder >> fill [
	self print:'fill'; cr.

]

{ #category : #'Postscript generation' }
PostscriptEncoder >> lineto:aPoint [
	self write:aPoint; print:' lineto'; cr.

]

{ #category : #'Postscript generation' }
PostscriptEncoder >> moveto:aPoint [
	self write:aPoint; print:' moveto'; cr.

]

{ #category : #'Postscript generation' }
PostscriptEncoder >> newpath [
	self print: 'newpath'; cr.

]

{ #category : #'Postscript generation' }
PostscriptEncoder >> oval: aPoint [
	self print: 'matrix currentmatrix'; cr;
		write: (aPoint extent // 2); space;
		write: aPoint topLeft;
		print: ' newpath translate scale 1 1 1 0 360 arc setmatrix'; cr

]

{ #category : #'Postscript generation' }
PostscriptEncoder >> preserveStateDuring: aBlock [ 
	"Note that this method supplies self, an encoder, to the block"
	| retval |
	self print: 'gsave';
		 cr.
	retval := aBlock value: self.
	self print: 'grestore';
		 cr.
	^ retval
]

{ #category : #'Postscript generation' }
PostscriptEncoder >> rect: aRect [

	self newpath.
	self
		moveto:aRect topLeft;
		lineto:aRect topRight x @ aRect topRight y;
		lineto:aRect bottomRight x @ aRect bottomRight y;
		lineto:aRect bottomLeft x @ aRect bottomLeft y;
		closepath.

]

{ #category : #'Postscript generation' }
PostscriptEncoder >> rectclip:aRect [
	self write:aRect; print:' rectclip'; cr.

]

{ #category : #'Postscript generation' }
PostscriptEncoder >> rectfill:aRect [
	self write:aRect; print:' rectfill'; cr.

]

{ #category : #'Postscript generation' }
PostscriptEncoder >> remapFontForSqueak:aFontName [
	self print:'/'; print:aFontName; print:' adjustFontForSqueak'; cr.

]

{ #category : #'Postscript generation' }
PostscriptEncoder >> safeGrestore [
	self print:'{ grestore } stopped pop'; cr.

]

{ #category : #'Postscript generation' }
PostscriptEncoder >> scale:aPoint [
	self write:aPoint; print:' scale'; cr.


]

{ #category : #'Postscript generation' }
PostscriptEncoder >> selectflippedfont:fontname size:size [
	self selectflippedfont:fontname size:size ascent:size.


]

{ #category : #'Postscript generation' }
PostscriptEncoder >> selectflippedfont:fontname size:size ascent:ascent [
	self print:'/'; print:fontname; space; 
		print:'[ '; write:size; print:' 0 0 ';write:size negated; print:' 0 '; write:ascent; print:'] selectfont'; cr.


]

{ #category : #'Postscript generation' }
PostscriptEncoder >> selectfont:fontname size:size [
	self print:'/'; print:fontname; space; write:size; print:' selectfont'; cr.

]

{ #category : #'Postscript generation' }
PostscriptEncoder >> setLinewidth:width [
	self write:width; print:' setlinewidth';cr.

]

{ #category : #'Postscript generation' }
PostscriptEncoder >> setrgbcolor:aColor [
	self write:aColor red; space;
		 write:aColor green; space;
		write:aColor blue; 
		print:' setrgbcolor'; cr.

]

{ #category : #'Postscript generation' }
PostscriptEncoder >> showpage [
	self print:'showpage'; cr.

]

{ #category : #'Postscript generation' }
PostscriptEncoder >> stroke [
	self print:'stroke'; cr.

]

{ #category : #'Postscript generation' }
PostscriptEncoder >> strokepath [
	self print:'strokepath'; cr.

]

{ #category : #'Postscript generation' }
PostscriptEncoder >> translate:aPoint [
	self write:aPoint; print:' translate'; cr.


]

{ #category : #'Postscript generation' }
PostscriptEncoder >> writeMatrix:m [
	self print:'[';
		write:m a11; print:' ';
		write:m a21; print:' ';
		write:m a12; print:' ';
		write:m a22; print:' ';
		write:m a13; print:' ';
		write:m a23; print:'] '.


]

{ #category : #writing }
PostscriptEncoder >> writeNumber:aNumber [
	super writeNumber:(aNumber isInteger ifTrue:[aNumber] ifFalse:[aNumber roundTo:0.001]).

]

{ #category : #'Postscript generation' }
PostscriptEncoder >> writePoint:aPoint [
	self write:aPoint x; space; write:aPoint y.

]
