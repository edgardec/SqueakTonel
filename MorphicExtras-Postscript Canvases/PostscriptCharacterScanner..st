"
I am a simple character scanner that forwards text-drawing commands to my canvas.  Despite the name, it should also work with other Canvases that actually implement the text-drawing commands (which the basic FormCanvas does not).

Style text support currently includes color, centering, fonts and emphasis.  Not yet supported are embedded objects, full justification and probably some others as well.

Tabs aren't supported properly, but rather hacked in the Postscript Header provided by PostscriptCanvas to be equivalent to 4 space.

mpw.

"
Class {
	#name : #PostscriptCharacterScanner,
	#superclass : #Object,
	#instVars : [
		'canvas',
		'paragraph',
		'bounds',
		'curPos',
		'font',
		'foregroundColor',
		'emphasis'
	],
	#pools : [
		'TextConstants'
	],
	#category : #'MorphicExtras-Postscript Canvases'
}

{ #category : #'instance creation' }
PostscriptCharacterScanner class >> scannerWithCanvas:aCanvas paragraph:aParagraph bounds:newBounds [
    ^self new canvas:aCanvas; paragraph:aParagraph; bounds:newBounds.
 
]

{ #category : #'textstyle support' }
PostscriptCharacterScanner >> addEmphasis: emphasisCode [

	emphasis := emphasis bitOr: emphasisCode.
]

{ #category : #'textstyle support' }
PostscriptCharacterScanner >> addKern: kern [
	" canvas comment:'kern now: ',kern printString. "

]

{ #category : #accessing }
PostscriptCharacterScanner >> bounds:newBounds [
    bounds:=newBounds.
    curPos:=newBounds origin.

	
]

{ #category : #accessing }
PostscriptCharacterScanner >> canvas [
	^canvas.

	
]

{ #category : #accessing }
PostscriptCharacterScanner >> canvas:newCanvas [
    canvas:=newCanvas.

	
]

{ #category : #accessing }
PostscriptCharacterScanner >> defaultFont [
	^ TextStyle defaultFont
]

{ #category : #displaying }
PostscriptCharacterScanner >> displayLine: line offset: baseOffset leftInRun: leftInRun [
	| offset aText string doJustified |

	self setTextStylesForOffset: ((line first) + 1).	" sets up various instance vars from text styles "
	offset := baseOffset.
	offset := offset + (line left @ (line top + line baseline - self font ascent )). 
	offset := offset + ((self textStyle alignment caseOf:{
		[Centered] -> [ line paddingWidth /2 ].
		[RightFlush] -> [ line paddingWidth ] } otherwise:[0]) @ 0).

	canvas moveto: offset.

	aText := paragraph text copyFrom: line first to: line last.
	doJustified := (paragraph textStyle alignment = Justified)
						and: [ (paragraph text at:line last) ~= Character cr
						and: [aText runs runs size = 1]].
	string := aText string.
	aText runs withStartStopAndValueDo: [:start :stop :attributes | | s drawFont |
		self setTextStylesForOffset: (start + line first - 1).	" sets up inst vars from text styles "
		s := string copyFrom: start to: stop.
		drawFont := self font.
		canvas setFont: drawFont.
		canvas 
			textStyled: s
			at: offset 		"<--now ignored"
			font: drawFont 		"<--now ignored"
			color: foregroundColor
			justified: doJustified		"<-can't do this now for multi-styles" 
			parwidth: line right - line left.
	].

]

{ #category : #accessing }
PostscriptCharacterScanner >> font [
	^ font ifNil:[self defaultFont].
]

{ #category : #'textstyle support' }
PostscriptCharacterScanner >> indentationLevel: amount [
	" canvas comment:'indentation level ',amount printString. "

]

{ #category : #accessing }
PostscriptCharacterScanner >> paragraph [
	^paragraph.

	
]

{ #category : #accessing }
PostscriptCharacterScanner >> paragraph:newPara [
    paragraph:=newPara.

	
]

{ #category : #'textstyle support' }
PostscriptCharacterScanner >> setActualFont: newFont [
	font := newFont.
]

{ #category : #'textstyle support' }
PostscriptCharacterScanner >> setAlignment: alignment [
	self paragraph textStyle alignment: alignment.
]

{ #category : #accessing }
PostscriptCharacterScanner >> setDestForm:destForm [
	"dummy"

]

{ #category : #'textstyle support' }
PostscriptCharacterScanner >> setFont: fontNumber [
	self setActualFont:(self textStyle fontAt:fontNumber).

]

{ #category : #'textstyle support' }
PostscriptCharacterScanner >> setTextStylesForOffset:offset [
	" default text style "
	font := self textStyle defaultFont.
	emphasis := 0.
	foregroundColor := Color black.

	" set text styles defined at this point, these methods will set instance vars of myself "
	(paragraph text attributesAt: offset forStyle: paragraph textStyle) do: 
		[:att | att emphasizeScanner: self].

	" post-processing of 'emphasis' "
	self setActualFont: (font emphasized: emphasis)
]

{ #category : #'textstyle support' }
PostscriptCharacterScanner >> textColor: aColor [
	foregroundColor := aColor.

]

{ #category : #accessing }
PostscriptCharacterScanner >> textStyle [
	^paragraph textStyle.

]
