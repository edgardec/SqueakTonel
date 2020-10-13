"
I allow the display of a string in a TrueType font as a stand-alone morph.

Morph's color changes the inside of the characters.
Morph's borderColor changes the outline.

Many free fonts are stored at www.FontGuy.com.  
Use a normal web browser (not our Scamper) and go there.  
Choose 'categories' and browse to a font you like.  
Hold the mouse down on the example text in that font.  
When the menu comes up, choose ""Copy this link location"".  
Come back into Squeak, choose ""load font from web...""
from my menu, and paste in the url.
"
Class {
	#name : #TTSampleStringMorph,
	#superclass : #TTSampleFontMorph,
	#instVars : [
		'string',
		'ttBounds'
	],
	#category : #'Morphic-TrueType'
}

{ #category : #'parts bin' }
TTSampleStringMorph class >> descriptionForPartsBin [
	^ self partName:	'TrueType banner' translatedNoop
		categories:		#()
		documentation:	'A short text in a beautiful font.  Use the resize handle to change size.' translatedNoop
]

{ #category : #menus }
TTSampleStringMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu add: 'edit contents...' translated action: #edit.
	aCustomMenu add: 'how to find more fonts...' translated action: #howTo.
	aCustomMenu add: 'load font from web...' translated action: #loadFromURL.
]

{ #category : #'halos and balloon help' }
TTSampleStringMorph >> addOptionalHandlesTo: aHalo box: box [
]

{ #category : #private }
TTSampleStringMorph >> computeTransform [
	| cy |
	cy := bounds origin y + bounds corner y * 0.5.
	transform := MatrixTransform2x3 
			transformFromLocal: (ttBounds insetBy: self borderWidth negated)
			toGlobal: bounds.
	transform := transform composedWithGlobal:(MatrixTransform2x3 withOffset: 0 @ cy negated).
	transform := transform composedWithGlobal:(MatrixTransform2x3 withScale: 1.0 @ -1.0).
	transform := transform composedWithGlobal:(MatrixTransform2x3 withOffset: 0 @ cy).
	^transform
]

{ #category : #'geometry testing' }
TTSampleStringMorph >> containsPoint: aPoint [ 
	"^ super containsPoint: aPoint"

	"so much faster..."

	| picker |
	(self bounds containsPoint: aPoint) ifFalse: [^false].
	picker := BalloonCanvas on: (Form extent: 1 @ 1 depth: 32).
	picker transformBy: (MatrixTransform2x3 withOffset: aPoint negated).
	self drawOn: picker.
	^(picker form bits first) ~= 0
]

{ #category : #initialization }
TTSampleStringMorph >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 0
]

{ #category : #initialization }
TTSampleStringMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ {Color magenta. Color yellow. Color orange. Color lightGray} atRandom
]

{ #category : #drawing }
TTSampleStringMorph >> drawOn: aCanvas [
	| xStart |
	(font isNil or:[string isNil or:[string isEmpty]]) 
		ifTrue:[^aCanvas frameRectangle: self bounds color: Color black].
	xStart := 0.
	aCanvas asBalloonCanvas preserveStateDuring:[:balloonCanvas|
		balloonCanvas transformBy: self transform.
		balloonCanvas aaLevel: self smoothing.
		string do:[:char| | glyph |
			glyph := font at: char.
			balloonCanvas preserveStateDuring:[:subCanvas|
				subCanvas transformBy: (MatrixTransform2x3 withOffset: xStart@0).
				subCanvas 
					drawGeneralBezierShape: glyph contours
					color: self color 
					borderWidth: self borderWidth 
					borderColor: self borderColor].
			xStart := xStart + glyph advanceWidth.
		].
	].
]

{ #category : #menus }
TTSampleStringMorph >> edit [
	"Allow the user to change the text in a crude way"

	| str |
	str := FillInTheBlankMorph request: 'Type in new text for this TrueType displayer.'
				 initialAnswer: 'some text'.
	str isEmpty ifTrue: [^ self].
	self string: str.

]

{ #category : #accessing }
TTSampleStringMorph >> font: aTTFontDescription [
	font := aTTFontDescription.
	string ifNil: [self string: aTTFontDescription fullName]
		ifNotNil: [self initializeString].
]

{ #category : #menus }
TTSampleStringMorph >> howTo [

	self inform: 'Many free fonts are stored at www.FontGuy.com.  
Use a normal web browser (not our Scamper) and go there.  
Choose ''categories'' and browse to a font you like.  
Hold the mouse down on the example text in that font.  
When the menu comes up, choose "Copy this link location".  
Come back into Squeak, choose "load font from web..."
from this menu, and paste in the url.'
]

{ #category : #initialize }
TTSampleStringMorph >> initializeString [
	| xStart char glyph |
	(font isNil or: [string isNil]) ifTrue: [^ self].
	xStart := 0.
	ttBounds := 0@0 corner: 0@0.
	1 to: string size do:
		[:i |
		char := string at: i.
		glyph := font at: char.
		ttBounds := ttBounds quickMerge: (glyph bounds translateBy: xStart@0).
		xStart := xStart + glyph advanceWidth.
	].
	self extent: ttBounds extent // 40.
	self borderWidth: ttBounds height // 40
]

{ #category : #'parts bin' }
TTSampleStringMorph >> initializeToStandAlone [
	"Make me into an example"

	| dd |
	dd := TTFontDescription default.
	dd ifNil: [^ RectangleMorph initializeToStandAlone].	"not available"

	super initializeToStandAlone.
	self font: dd; color: (TranslucentColor r: 1.0 g: 0.097 b: 1.0 alpha: 0.6).
	self string: 'TrueType fonts are beautiful'.

]

{ #category : #menus }
TTSampleStringMorph >> loadFromURL [
	"Allow the user to change the text in a crude way"

	| url |
	url := FillInTheBlankMorph request: ' Type in the url for a TrueType font on the web. '
				 initialAnswer: 'http://www.fontguy.com/download.asp?fontid=1494'.
	url isEmpty ifTrue: [^ self].
	self loadFromURL: url.

]

{ #category : #menus }
TTSampleStringMorph >> loadFromURL: urlString [
	"Fetch the file, unarchive, unzip, and use as my font."

	| rawStrm |
	rawStrm := HTTPSocket httpGet: urlString. 	"Later use an HttpURL?"
	self font: (TTFontReader readFrom: rawStrm asUnZippedStream).

]

{ #category : #printing }
TTSampleStringMorph >> printOn: aStream [
	aStream nextPutAll: 'TTSampleString(';
		nextPutAll: font familyName;
		nextPut: $)
]

{ #category : #accessing }
TTSampleStringMorph >> string [
	^ string
]

{ #category : #accessing }
TTSampleStringMorph >> string: aString [
	string := aString.
	self initializeString.
]
