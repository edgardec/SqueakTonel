Class {
	#name : #StrikeFontFixer,
	#superclass : #Object,
	#instVars : [
		'strikeFont',
		'charForms',
		'newFont'
	],
	#classVars : [
		'MappingTable',
		'NoFontTable'
	],
	#category : #'Multilingual-Display'
}

{ #category : #'class initialization' }
StrikeFontFixer class >> initialize [
"
	StrikeFontFixer initialize
"

	| d |
	self initializeNoFontTable.
	d := Array new: 256.
	0 to: 127 do: [:i | d at: i+1 put: i].
	16r80 to: 16r9F do: [:i | d at: i+1 put: nil].
	d at: 16rA0+1 put: 16r20.
	d at: 16rA1+1 put: 16rC1.
	d at: 16rA2+1 put: 16rA2.
	d at: 16rA3+1 put: 16rA3.
	d at: 16rA4+1 put: 16rA9. "CURRENCY SIGN"
	d at: 16rA5+1 put: 16rB4.
	d at: 16rA6+1 put: 16r7C. "BROKEN BAR"
	d at: 16rA7+1 put: 16rA4.
	d at: 16rA8+1 put: 16r80. "DIAERESIS"
	d at: 16rA9+1 put: 16rA9.
	d at: 16rAA+1 put: 16rBB.
	d at: 16rAB+1 put: 16rC7.
	d at: 16rAC+1 put: 16rD1. "NOT SIGN"
	d at: 16rAD+1 put: 16rD0.
	d at: 16rAE+1 put: 16rA8.
	d at: 16rAF+1 put: 16rD1. "MACRON"
	d at: 16rB0+1 put: 16rA1.
	d at: 16rB1+1 put: 16r2B. "PLUS-MINUS SIGN"
	d at: 16rB2+1 put: 16rAB. "SUPERSCRIPT TWO"
	d at: 16rB3+1 put: 16rAB. "SUPERSCRIPT THREE"
	d at: 16rB4+1 put: 16rAB.
	d at: 16rB5+1 put: 16r75. "MICRO SIGN"
	d at: 16rB6+1 put: 16rA6.
	d at: 16rB7+1 put: 16rA5.
	d at: 16rB8+1 put: 16r82. "CEDILLA"
	d at: 16rB9+1 put: 16rAB. "SUPERSCRIPT ONE"
	d at: 16rBA+1 put: 16rBC.
	d at: 16rBB+1 put: 16rC8.
	d at: 16rBC+1 put: 16r4D. "VULGAR FRACTION ONE QUARTER"
	d at: 16rBD+1 put: 16r4D. "VULGAR FRACTIOIN ONE HALF"
	d at: 16rBE+1 put: 16r4D. "VALGAR FRACTION THREE QUARTERS"
	d at: 16rBF+1 put: 16rC0.
	d at: 16rC0+1 put: 16rCB.
	d at: 16rC1+1 put: 16rCB. "CAPITAL A WITH ACUTE"
	d at: 16rC2+1 put: 16rCB. "CAPITAL A WITH CIRCUMFLEX"
	d at: 16rC3+1 put: 16rCC.
	d at: 16rC4+1 put: 16r80.
	d at: 16rC5+1 put: 16r81.
	d at: 16rC6+1 put: 16rAE.
	d at: 16rC7+1 put: 16r82.
	d at: 16rC8+1 put: 16r83. "CAPITAL E WITH GRAVE"
	d at: 16rC9+1 put: 16r83.
	d at: 16rCA+1 put: 16r83. "CAPITAL E WITH CIRCUMFLEX"
	d at: 16rCB+1 put: 16r83. "CAPITAL E WITH DIAERESIS"
	d at: 16rCC+1 put: 16r49. "CAPITAL I WITH GRAVE"
	d at: 16rCD+1 put: 16r49. "CAPITAL I WITH ACUTE"
	d at: 16rCE+1 put: 16r49. "CAPITAL I WITH CIRCUMFLEX"
	d at: 16rCF+1 put: 16r49. "CAPITAL I WITH DIAERESIS"
	d at: 16rD0+1 put: 16r44. "CAPITAL ETH"
	d at: 16rD1+1 put: 16r84.
	d at: 16rD2+1 put: 16rCD. "CAPITAL O WITH GRAVE"
	d at: 16rD3+1 put: 16rCD. "CAPITAL O WITH ACUTE"
	d at: 16rD4+1 put: 16rCD. "CAPITAL O WITH CIRCUMFLEX"
	d at: 16rD5+1 put: 16rCD.
	d at: 16rD6+1 put: 16r85.
	d at: 16rD7+1 put: 16r2B. "MULTIPLICATION SIGN"
	d at: 16rD8+1 put: 16rBF.
	d at: 16rD9+1 put: 16r86. "CAPITAL U WITH GRAVE"
	d at: 16rDA+1 put: 16r86. "CAPITAL U WITH ACUTE"
	d at: 16rDB+1 put: 16r86. "CAPITAL U WITH CIRCUMFLEX"
	d at: 16rDC+1 put: 16r86. "CAPTIAL U WITH DIAERESIS"
	d at: 16rDD+1 put: 16r59. "CAPITAL Y WITH ACUTE"
	d at: 16rDE+1 put: 16r50. "CAPITAL THORN"
	d at: 16rDF+1 put: 16rA7.
	d at: 16rE0+1 put: 16r88.
	d at: 16rE1+1 put: 16r87.
	d at: 16rE2+1 put: 16r89.
	d at: 16rE3+1 put: 16r8B.
	d at: 16rE4+1 put: 16r8A.
	d at: 16rE5+1 put: 16r8C.
	d at: 16rE6+1 put: 16rBE.
	d at: 16rE7+1 put: 16r8D.
	d at: 16rE8+1 put: 16r8F.
	d at: 16rE9+1 put: 16r8E.
	d at: 16rEA+1 put: 16r90.
	d at: 16rEB+1 put: 16r91.
	d at: 16rEC+1 put: 16r93.
	d at: 16rED+1 put: 16r92.
	d at: 16rEE+1 put: 16r94.
	d at: 16rEF+1 put: 16r95.
	d at: 16rF0+1 put: 16r64. "SMALL ETH"
	d at: 16rF1+1 put: 16r96.
	d at: 16rF2+1 put: 16r98.
	d at: 16rF3+1 put: 16r97.
	d at: 16rF4+1 put: 16r99.
	d at: 16rF5+1 put: 16r9B.
	d at: 16rF6+1 put: 16r9A.
	d at: 16rF7+1 put: 16r2D. "DIVISION SIGN"
	d at: 16rF8+1 put: 16rBF.
	d at: 16rF9+1 put: 16r9D.
	d at: 16rFA+1 put: 16r9C.
	d at: 16rFB+1 put: 16r9E.
	d at: 16rFC+1 put: 16r9F.
	d at: 16rFD+1 put: 16rD8. "SMALL Y WITH ACUTE"
	d at: 16rFE+1 put: 16r70. "SMALL THORN"
	d at: 16rFF+1 put: 16rD8.

	MappingTable := d.

]

{ #category : #'class initialization' }
StrikeFontFixer class >> initializeNoFontTable [

	| n |
	n := #(
	16rA4 "CURRENCY SIGN"
	16rA6 "BROKEN BAR"
	16rA8 "DIAERESIS"
	16rAC "NOT SIGN"
	16rAF "MACRON"
	16rB1 "PLUS-MINUS SIGN"
	16rB2 "SUPERSCRIPT TWO"
	16rB3 "SUPERSCRIPT THREE"
	16rB5 "MICRO SIGN"
	16rB8 "CEDILLA"
	16rB9 "SUPERSCRIPT ONE"
	16rBC "VULGAR FRACTION ONE QUARTER"
	16rBD "VULGAR FRACTIOIN ONE HALF"
	16rBE "VALGAR FRACTION THREE QUARTERS"
	16rC1 "CAPITAL A WITH ACUTE"
	16rC2 "CAPITAL A WITH CIRCUMFLEX"
	16rC8 "CAPITAL E WITH GRAVE"
	16rCA "CAPITAL E WITH CIRCUMFLEX"
	16rCB "CAPITAL E WITH DIAERESIS"
	16rCC "CAPITAL I WITH GRAVE"
	16rCD "CAPITAL I WITH ACUTE"
	16rCE "CAPITAL I WITH CIRCUMFLEX"
	16rCF "CAPITAL I WITH DIAERESIS"
	16rD0 "CAPITAL ETH"
	16rD2 "CAPITAL O WITH GRAVE"
	16rD3 "CAPITAL O WITH ACUTE"
	16rD4 "CAPITAL O WITH CIRCUMFLEX"
	16rD7 "MULTIPLICATION SIGN"
	16rD9 "CAPITAL U WITH GRAVE"
	16rDA "CAPITAL U WITH ACUTE"
	16rDB "CAPITAL U WITH CIRCUMFLEX"
	16rDD "CAPITAL Y WITH ACUTE"
	16rDE "CAPITAL THORN"
	16rF0 "SMALL ETH"
	16rF7 "DIVISION SIGN"
	16rFD "SMALL Y WITH ACUTE"
	16rFE "SMALL THORN"
	).
	NoFontTable := n.


]

{ #category : #'instance creation' }
StrikeFontFixer class >> newOn: aStrikeFont [ 
	^self new  font: aStrikeFont
]

{ #category : #accessing }
StrikeFontFixer >> characterFormAt: aCharacter at: aPoint [

	| f |
	f := charForms at: aCharacter asciiValue + 1.
	(f magnifyBy: 3) displayAt: aPoint.
	^ f.

]

{ #category : #displaying }
StrikeFontFixer >> displayOn: aDisplayObject at: aPoint magnifyBy: aNumber [

	| form hStep vStep bb source nextPoint |
	hStep := (strikeFont maxWidth * aNumber * 1.2) asInteger.
	vStep := (strikeFont height * aNumber *  1.2) asInteger.
	
	form := Form extent: (hStep * 16)@(vStep * 16).
	bb := BitBlt toForm: form.
	0 to: 15 do: [:i |
		1 to: 16 do: [:j |
			source := ((charForms at: (i * 16 + j)) magnifyBy: aNumber).
			nextPoint := (hStep * (j - 1)@(vStep * i)).
			bb copy: ((nextPoint+((hStep@vStep - source extent) // 2)) extent: source extent)
				from: 0@0 in: source fillColor: Color black rule: Form over.
		].
	].
	form displayOn: aDisplayObject at: aPoint.

]

{ #category : #accessing }
StrikeFontFixer >> font: aStrikeFont [

	strikeFont := aStrikeFont.
	self forms.

]

{ #category : #accessing }
StrikeFontFixer >> forms [

	1 to: 256 do: [:i |
		charForms at: i put: (strikeFont characterFormAt: (Character value: (i - 1)))
	].

]

{ #category : #'initialize-release' }
StrikeFontFixer >> initialize [

	charForms := Array new: 256.

]

{ #category : #accessing }
StrikeFontFixer >> mappingTable [

	^ MappingTable.

]

{ #category : #printing }
StrikeFontFixer >> storeEditedGlyphsOn: aStream [
	NoFontTable do: [:i |
		| n |
		n := strikeFont name.
		(n beginsWith: 'NewYork') ifTrue: [n := 'NewYork'].
		aStream nextPutAll: '((StrikeFont familyName: ''', n, ''' size: ',
			strikeFont height asString, ')'.
		aStream nextPutAll: ' characterFormAt: '.
		aStream nextPutAll: '(Character value: ', i asString, ')'.
		aStream nextPutAll: ' put: '.
		(strikeFont characterFormAt: (Character value: i)) storeOn: aStream base: 2.
		aStream nextPutAll: ')!'.
		aStream nextPut: Character cr.
		aStream nextPut: Character cr.
	].
]
