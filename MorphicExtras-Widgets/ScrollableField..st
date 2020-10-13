Class {
	#name : #ScrollableField,
	#superclass : #PluggableTextMorphWithModel,
	#category : #'MorphicExtras-Widgets'
}

{ #category : #'parts bin' }
ScrollableField class >> descriptionForPartsBin [
	"Info for build parts-bin entries."

	^ self partName:	'Scrolling Text' translatedNoop
		categories:		#(Basic)
		documentation:	'A scrollable, editable body of text' translatedNoop
]

{ #category : #'class initialization' }
ScrollableField class >> initialize [

	self registerInFlapsRegistry.	
]

{ #category : #'class initialization' }
ScrollableField class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry"
	self environment
		at: #Flaps
		ifPresent: [:cl | cl registerQuad: {#ScrollableField. #newStandAlone. 'Scrolling Text' translatedNoop. 'Holds any amount of text; has a scroll bar' translatedNoop}
						forFlapNamed: 'Stack Tools'.]
]

{ #category : #'class initialization' }
ScrollableField class >> unload [
	"Unload the receiver from global registries"

	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self] 
]

{ #category : #accessing }
ScrollableField >> adjustTextAnchor: aMorph [ 
	textMorph
		ifNotNil: [textMorph adjustTextAnchor: aMorph]
]

{ #category : #editing }
ScrollableField >> anchorMorph: aMorph at: aPoint type: anchorType [ 
	textMorph anchorMorph: aMorph at: aPoint type: anchorType 
]

{ #category : #updating }
ScrollableField >> changed [
	super changed.
	textMorph changed.
]

{ #category : #editing }
ScrollableField >> chooseEmphasisOrAlignment [
	textMorph chooseEmphasisOrAlignment
]

{ #category : #editing }
ScrollableField >> chooseFont [
	textMorph chooseFont
]

{ #category : #editing }
ScrollableField >> chooseStyle [
	textMorph chooseStyle
]

{ #category : #accessing }
ScrollableField >> contents [
	^ textMorph contents
]

{ #category : #accessing }
ScrollableField >> cursor [
	"Answer the receiver's logical cursor position"
	^ textMorph cursor
]

{ #category : #accessing }
ScrollableField >> cursorWrapped: aNumber [ 
"Set the cursor as indicated"
	textMorph cursorWrapped: aNumber
]

{ #category : #accessing }
ScrollableField >> editor [
	^ textMorph editor
]

{ #category : #accessing }
ScrollableField >> elementCount [
	"Answer how many sub-objects are within me"
	^ textMorph elementCount
]

{ #category : #accessing }
ScrollableField >> getAllButFirstCharacter [
	"Obtain all but the first character from the receiver; if that  
	would be empty, return a black dot"
	^ textMorph getAllButFirstCharacter 
]

{ #category : #accessing }
ScrollableField >> getCharacters [
"obtain a string value from the receiver"
	^ textMorph getCharacters
]

{ #category : #accessing }
ScrollableField >> getFirstCharacter [
	"obtain the first character from the receiver if it is empty, 
	return a black dot"
	^ textMorph getFirstCharacter
]

{ #category : #accessing }
ScrollableField >> getLastCharacter [
	"obtain the last character from the receiver if it is empty,  
	return a black dot"
	^ textMorph getLastCharacter 
]

{ #category : #menu }
ScrollableField >> getMenu: shiftKeyState [ 
	^ (shiftKeyState not
			or: [Preferences noviceMode])
		ifTrue: [TextEditor yellowButtonMenu]
		ifFalse: [TextEditor shiftedYellowButtonMenu]
]

{ #category : #accessing }
ScrollableField >> getNumericValue [
	"Obtain a numeric value from the receiver; if no digits, return  
	zero"
	^ textMorph getNumericValue 
]

{ #category : #'parts bin' }
ScrollableField >> initializeToStandAlone [
	super initializeToStandAlone.
	self  color: (Color r: 0.972 g: 0.972 b: 0.662).
	self retractable: false; scrollBarOnLeft: false.

	self wantsFrameAdornments: false.
]

{ #category : #accessing }
ScrollableField >> insertCharacters: aString [ 
	"Insert the characters from the given source at my current  
	cursor position"
	textMorph insertCharacters: aString 
]

{ #category : #accessing }
ScrollableField >> insertContentsOf: aPlayer [ 
	"Insert the characters from the given player at my current  
	cursor position"
	textMorph insertContentsOf: aPlayer 
]

{ #category : #classification }
ScrollableField >> isTextMorph [
	^ true
]

{ #category : #accessing }
ScrollableField >> isWrapped [
	^ textMorph isWrapped
]

{ #category : #accessing }
ScrollableField >> margins [
	^ textMorph margins
]

{ #category : #accessing }
ScrollableField >> paragraph [
	^ textMorph paragraph
]

{ #category : #private }
ScrollableField >> releaseParagraph [
	textMorph releaseParagraph 
]

{ #category : #accessing }
ScrollableField >> setCharacters: chars [ 
	"obtain a string value from the receiver"
	textMorph setCharacters: chars 
]

{ #category : #containment }
ScrollableField >> setContainer: newContainer [ 
	self changed.
	textMorph setContainer: newContainer.
self releaseParagraph
]

{ #category : #contents }
ScrollableField >> setMyText: someText [
	"Set my text, as indicated"

	| toUse |
	toUse := someText ifNil: [''].
	myContents := toUse.
	self setText: toUse.
	^ true
]

{ #category : #accessing }
ScrollableField >> setNumericValue: aValue [ 
	"Set the contents of the receiver to be a string obtained from  
	aValue"
	textMorph setNumericValue: aValue 
]

{ #category : #private }
ScrollableField >> text: aText textStyle: aTextStyle [ 
	textMorph text: aText textStyle: aTextStyle 
]

{ #category : #accessing }
ScrollableField >> textStyle [
	^ textMorph textStyle
]

{ #category : #accessing }
ScrollableField >> updateFromParagraph [
	"A change has taken place in my paragraph, as a result of  
	editing and I must be updated. If a line break causes  
	recomposition of the current paragraph, or it the selection has 
	entered a different paragraph, then the current editor will be  
	released, and must be reinstalled with the resulting new  
	paragraph, while retaining any editor state, such as selection,  
	undo state, and current typing emphasis."
	textMorph updateFromParagraph 
]

{ #category : #menu }
ScrollableField >> wantsYellowButtonMenu [
	"Answer true if the receiver wants a yellow button menu"
	^ true
]
