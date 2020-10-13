"
FormSetFonts are designed to capture individual images as character forms for imbedding in normal text.  While most often used to insert an isolated glyph in some text, the code is actually desinged to support an entire user-defined font.  The TextAttribute subclass TextFontReference is specifically designed for such in-line insertion of exceptional fonts in normal text.
"
Class {
	#name : #FormSetFont,
	#superclass : #StrikeFont,
	#instVars : [
		'tintable',
		'combinationRule'
	],
	#category : #'Graphics-Fonts'
}

{ #category : #examples }
FormSetFont class >> copy: charForm toClipBoardAs: char ascent: ascent [
	Clipboard clipboardText:
		(Text string: char asString
			attribute: (TextFontReference toFont: 
				(FormSetFont new
					fromFormArray: (Array with: charForm)
					asciiStart: char asciiValue
					ascent: ascent)))
"
	The S in the Squeak welcome window was installed by doing the following
	in a workspace (where the value of, eg, charForm will persist through BitEdit...
	f := TextStyle default fontAt: 4.
	oldS := f characterFormAt: $S.
	charForm := Form extent: oldS extent depth: 8.
	oldS displayOn: charForm.
	charForm bitEdit.
	...Play around with the BitEditor, then accept and close...
	FormSetFont copy: charForm toClipBoardAs: $S ascent: f ascent.
	...Then do a paste into the Welcome window
"
]

{ #category : #examples }
FormSetFont class >> example [    "FormSetFont example"
	"Lets the user select a (small) area of the screen to represent the
	character A, then copies 'A' to the clipboard with that as the letter form.
	Thereafter, a paste operation will imbed that character in any text."
	| charForm |
	charForm := Form fromUser.
	self copy: charForm toClipBoardAs: $A ascent: charForm height
]

{ #category : #accessing }
FormSetFont >> combinationRule [

	^ combinationRule
]

{ #category : #accessing }
FormSetFont >> combinationRule: anObject [

	combinationRule := anObject
]

{ #category : #displaying }
FormSetFont >> displayString: aString on: aBitBlt from: startIndex to: stopIndex at: aPoint kern: kernDelta [
	"Draw the given string from startIndex to stopIndex "

	combinationRule ifNotNil: [:r | aBitBlt combinationRule: r].
	tintable == false ifTrue: [aBitBlt colorMap: nil].
	
	^ super displayString: aString on: aBitBlt from: startIndex to: stopIndex at: aPoint kern: kernDelta
]

{ #category : #'initialize-release' }
FormSetFont >> fromFormArray: formArray asciiStart: asciiStart ascent: ascentVal [
	| height width x badChar |
	type := 2.
	name := 'aFormFont'.
	minAscii := asciiStart.
	maxAscii := minAscii + formArray size - 1.
	ascent := ascentVal.
	subscript := superscript := emphasis := 0.
	height := width := 0.
	maxWidth := 0.
	formArray do:
		[:f | width := width + f width.
		maxWidth := maxWidth max: f width.
		height := height max: f height + f offset y].
	badChar := (Form extent: 7@height) borderWidth: 1.
	width := width + badChar width.
	descent := height - ascent.
	pointSize := height.
	glyphs := Form extent: width @ height depth: formArray first depth.
	xTable := Array new: maxAscii + 3 withAll: 0.
	x := 0.
	formArray doWithIndex:
		[:f :i | f displayOn: glyphs at: x@0.
		xTable at: minAscii + i+1 put: (x := x + f width)].
	badChar displayOn: glyphs at: x@0.
	xTable at: maxAscii + 3 put: x + badChar width.
	characterToGlyphMap := nil.
]

{ #category : #'initialize-release' }
FormSetFont >> initialize [

	super initialize.
	self preserveColors.
]

{ #category : #tinting }
FormSetFont >> makeTintable [
	"Default."
	
	self tintable: true.
	self combinationRule: Form over.
]

{ #category : #tinting }
FormSetFont >> preserveColors [

	self tintable: false.
	self combinationRule: Form paint.
]

{ #category : #tinting }
FormSetFont >> preserveColorsWithAlpha [
	"Useful for rendering Emojis."
	
	self tintable: false.
	self combinationRule: Form blend.
]

{ #category : #emphasis }
FormSetFont >> reset [  "Ignored by FormSetFonts"
]

{ #category : #accessing }
FormSetFont >> tintable [

	^ tintable
]

{ #category : #accessing }
FormSetFont >> tintable: anObject [

	tintable := anObject
]
