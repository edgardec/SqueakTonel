Class {
	#name : #LinedTTCFont,
	#superclass : #TTCFont,
	#instVars : [
		'emphasis',
		'lineGlyph',
		'contourWidth'
	],
	#category : #'TrueType-Fonts'
}

{ #category : #'instance creation' }
LinedTTCFont class >> fromTTCFont: aTTCFont emphasis: code [

	| inst |
	inst := self new.
	inst ttcDescription: aTTCFont ttcDescription.
	inst pointSize: aTTCFont pointSize.
	inst emphasis: (aTTCFont emphasis bitOr: code).
	inst lineGlyph: (aTTCFont ttcDescription at: $_).

	^ inst.

]

{ #category : #private }
LinedTTCFont >> computeForm: char [

	| ttGlyph scale |

	char = Character tab ifTrue: [^ super computeForm: char].

	"char = $U ifTrue: [self doOnlyOnce: [self halt]]."
	scale := self pixelSize asFloat / (ttcDescription ascender - ttcDescription descender).
	ttGlyph := ttcDescription at: char.
	^ ttGlyph asFormWithScale: scale ascender: ttcDescription ascender descender: ttcDescription descender fgColor: foregroundColor bgColor: Color transparent depth: self depth replaceColor: false lineGlyph: lineGlyph lingGlyphWidth: contourWidth emphasis: emphasis
]

{ #category : #accessing }
LinedTTCFont >> emphasis [

	^ emphasis.

]

{ #category : #accessing }
LinedTTCFont >> emphasis: code [

	emphasis := code.

]

{ #category : #initialize }
LinedTTCFont >> lineGlyph: aGlyph [

	lineGlyph := aGlyph.
	contourWidth := aGlyph calculateWidth.

]
