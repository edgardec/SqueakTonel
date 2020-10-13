"
A scripting tile consisting of a function-name and an argument pad, and representing a call to a numeric function of a single argument.
"
Class {
	#name : #FunctionTile,
	#superclass : #TileMorph,
	#instVars : [
		'functionNameTile',
		'argumentPad'
	],
	#category : #'Etoys-Scripting Tiles'
}

{ #category : #scripting }
FunctionTile class >> defaultNameStemForInstances [
	"Answer a good default name stem to use for names of instances"

	^ 'Function' translatedNoop
]

{ #category : #scripting }
FunctionTile class >> randomNumberTile [
	"Answer a newly conjured-up random-number tile, suitable for handing to the user."

	| functionPhrase argTile aPad |
	functionPhrase := FunctionTile new.
	argTile := (Vocabulary vocabularyNamed: 'Number') defaultArgumentTile.
	aPad := TilePadMorph new setType: #Number.
	aPad addMorphBack: argTile.
	functionPhrase operator: #random pad: aPad.
	^ functionPhrase


"
FunctionTile randomNumberTile openInHand
"
]

{ #category : #menu }
FunctionTile >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	"Add custom menu items to the menu"

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	self topEditor ifNotNil:
		[aCustomMenu add: 'remove function' translated action: #removeFunctionWrapper]
]

{ #category : #'code generation' }
FunctionTile >> basicParseNodeWith: encoder [
	"Answer a message node for the receiver."

	| sel rec ret |
	sel := submorphs first operatorOrExpression.
	rec := submorphs third parseNodeWith: encoder.
	ret := MessageNode new
				receiver: rec
				selector: sel
				arguments: #()
				precedence: (sel precedence)
				from: encoder
				sourceRange: nil.
	^ self convertPrecedenceInParseNode: ret with: encoder.

]

{ #category : #'dropping\/grabbing' }
FunctionTile >> booleanComparatorPhrase [
	"Answer a boolean-valued phrase derived from a retriever (e.g. 'car's heading'); this is in order to assure that tiles laid down in a TEST area will indeed produce a boolean result"

	| outerPhrase rel  |

	rel := Vocabulary numberVocabulary comparatorForSampleBoolean.
	outerPhrase := PhraseTileMorph new setOperator: rel type: #Boolean rcvrType: #Number argType: #Number.
	outerPhrase firstSubmorph addMorph: self.
	outerPhrase submorphs last addMorph: (ScriptingSystem tileForArgType: #Number).

	outerPhrase submorphs second submorphs last setBalloonText: (ScriptingSystem helpStringForOperator: rel).    
	^ outerPhrase
]

{ #category : #'code generation' }
FunctionTile >> convertPrecedenceInParseNode: message with: encoder [

	| e r w list |
	w := WriteStream on: (Array new: 3).
	message receiver eToysExpFlattenOn: w.
	list := w contents.
	e := EToyExpressionTransformer2 new newNodeFromList: list encoder: encoder.
	r := e transform.
	message receiver: r.
	^ message.

]

{ #category : #'code generation' }
FunctionTile >> convertPrecedenceOfArgsInParseNode: message with: encoder [

	| e r w list |
	message arguments size > 0 ifTrue: [
		w := WriteStream on: (Array new: 3).
		message arguments first  eToysExpFlattenOn: w.
		list := w contents.
		e := EToyExpressionTransformer2 new newNodeFromList: list encoder: encoder.
		r := e transform.
		message arguments at: 1 put: r.
		^ message.
	] ifFalse: [
		^ message.
	].

]

{ #category : #initialization }
FunctionTile >> initialize [
	"initialize the state of the receiver"

	super initialize.
	type := #function.
	self minHeight: 30; vResizing: #spaceFill; borderWidth: 0
]

{ #category : #'code generation' }
FunctionTile >> kedamaParseNodeWith: encoder actualObject: obj [

	| ret arg |
	arg := submorphs third parseNodeWith: encoder.
	ret := MessageNode new
				receiver: (encoder encodePlayer: obj)
				selector: #random:
				arguments: (Array with: arg)
				precedence: (#random: precedence)
				from: encoder
				sourceRange: nil.
	^  self convertPrecedenceOfArgsInParseNode: ret with: encoder.

]

{ #category : #initialization }
FunctionTile >> operator: opSymbol pad: aTilePadMorph [
	"Set the operator and pad.  Builds and adds the four submorphs of the receiver
		function-name, left-paren, argument-pad, right-paren."

	| functionTriplet |
	functionTriplet := ScriptingSystem tableOfNumericFunctions  detect: [:triplet | triplet second = opSymbol].  "If none, error..."
	self operator: opSymbol wording: functionTriplet first  translated helpString: functionTriplet third translated pad: aTilePadMorph
]

{ #category : #initialization }
FunctionTile >> operator: opSymbol wording: aWording  helpString: aHelpString pad: aTilePadMorph [
	"Set the operator and pad.  Builds and adds the four submorphs of the receiver -- function-name, left-paren, argument-pad, right-paren."

	argumentPad := aTilePadMorph.
	self removeAllMorphs.
	self vResizing: #shrinkWrap.
	functionNameTile := FunctionNameTile new.
	functionNameTile operator: opSymbol wording: aWording helpString: aHelpString.
	self addMorphFront: functionNameTile.
	self addMorphBack: (ImageMorph new image: (ScriptingSystem formAtKey: #LeftParenthesis)).
	self addMorphBack: aTilePadMorph.
	self addMorphBack: (ImageMorph new image: (ScriptingSystem formAtKey: #RightParenthesis))
]

{ #category : #'code generation' }
FunctionTile >> parseNodeWith: encoder [

	| phrase player costume sel |
	sel := submorphs first operatorOrExpression.
	sel == #random ifFalse: [^ self basicParseNodeWith: encoder].
	phrase := self outermostMorphThat: [:m| m isKindOf: PhraseTileMorph].
	phrase ifNil: [^ self basicParseNodeWith: encoder].

	player := phrase associatedPlayer.
	player ifNil: [^ self basicParseNodeWith: encoder].

	costume := player costume.
	costume ifNil: [^ self basicParseNodeWith: encoder].

	(player isKindOf: KedamaExamplerPlayer) ifTrue: [
		^ self kedamaParseNodeWith: encoder actualObject: player costume renderedMorph kedamaWorld player].

	(costume renderedMorph isMemberOf: KedamaMorph) ifTrue: [
		^ self kedamaParseNodeWith: encoder actualObject: self].

	^ self basicParseNodeWith: encoder.

]

{ #category : #menu }
FunctionTile >> removeFunction [
	"Unwrap the receiver from its contents."

	self removeFunctionWrapper

	
]

{ #category : #menu }
FunctionTile >> removeFunctionWrapper [
	"Remove the function wrapper"
	
	| myPad |
	(owner isNil or: [owner owner isNil]) ifTrue: [^ Beeper beep].  "Not in a line of script"
	myPad := submorphs third.
	owner owner replaceSubmorph: owner by: myPad.
	myPad scriptEdited
]

{ #category : #initialization }
FunctionTile >> replaceSubmorph: existingMorph by: newMorph [
	"Replace a submorph by a different morph.  If it's my pad, fix up my argumentPad inst var."

	super replaceSubmorph: existingMorph by: newMorph.
	(newMorph isKindOf: TilePadMorph) ifTrue: [argumentPad := newMorph].

]

{ #category : #'dropping\/grabbing' }
FunctionTile >> rowOfRightTypeFor: aLayoutMorph forActor: aPlayer [
	"Answer a phrase of the right type for the putative container"

	| aTemporaryViewer aPhrase |
	aLayoutMorph demandsBoolean ifTrue:
		[aTemporaryViewer := CategoryViewer new invisiblySetPlayer: aPlayer.
		aPhrase := aTemporaryViewer booleanPhraseFromPhrase: self.
		aPhrase justGrabbedFromViewer: false.
		^ aPhrase].
	^ self
]

{ #category : #'code generation' }
FunctionTile >> storeCodeOn: aStream indent: tabCount [ 
	"Store the receiver's code on the stream, honoring indentation."

	aStream nextPut: $(.
	aStream space.
	argumentPad storeCodeOn: aStream indent: tabCount.
	aStream nextPut: $).
	aStream space.
	functionNameTile storeCodeOn: aStream indent: tabCount
]

{ #category : #'dropping\/grabbing' }
FunctionTile >> tileRows [
	"Answer a list of tile rows -- in this case exactly one row -- representing the receiver."

	^ Array with: (Array with: self)
]
