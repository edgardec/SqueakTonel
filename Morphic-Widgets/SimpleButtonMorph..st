"
I am labeled, rectangular morph which allows the user to click me. I can be configured to send my ""target"" the message ""actionSelector"" with ""arguments"" when I am clicked. I may have a label, implemented as a StringMorph.

Example:

	SimpleButtonMorph new
		target: Beeper;
		label: 'Beep!';
		actionSelector: #beep; 
		openInWorld

Structure:
instance var 	Type		Description 
target 			Object 		The Object to notify upon a click 
actionSelector 	Symbol 		The message to send to Target (#messageName) 
arguments 		Array 		Arguments to send with #actionSelection (optional) 
actWhen 		Symbol 		When to take action: may be #buttonUp (default), #buttonDown,
								#whilePressed, or #startDrag 
oldColor 		Color 		Used to restore color after click 

Another example: a button which quits the image without saving it.

	SimpleButtonMorph new
		target: Smalltalk;
		label: 'quit';
		actionSelector: #snapshot:andQuit:;
		arguments: (Array with: false with: true); 
		openInWorld


"
Class {
	#name : #SimpleButtonMorph,
	#superclass : #RectangleMorph,
	#instVars : [
		'target',
		'actionSelector',
		'arguments',
		'actWhen',
		'oldColor',
		'mouseDownTime'
	],
	#category : #'Morphic-Widgets'
}

{ #category : #scripting }
SimpleButtonMorph class >> authoringPrototype [
	^ super authoringPrototype label: 'Button'
]

{ #category : #printing }
SimpleButtonMorph class >> defaultNameStemForInstances [
	^ self = SimpleButtonMorph
		ifTrue: ['Button' translatedNoop]
		ifFalse: [^ super defaultNameStemForInstances]
]

{ #category : #'as yet unclassified' }
SimpleButtonMorph class >> newWithLabel: labelString [

	^ self basicNew initializeWithLabel: labelString

]

{ #category : #'submorphs-add\/remove' }
SimpleButtonMorph >> actWhen [
	"acceptable symbols:  #buttonDown, #buttonUp, and #whilePressed"

	^ actWhen
]

{ #category : #'submorphs-add\/remove' }
SimpleButtonMorph >> actWhen: condition [
	"Accepts symbols:  #buttonDown, #buttonUp, and #whilePressed, #startDrag"
	actWhen := condition.
	actWhen == #startDrag
		ifFalse: [self on: #startDrag send: nil to: nil ]
		ifTrue:[self on: #startDrag send: #doButtonAction to: self].
]

{ #category : #accessing }
SimpleButtonMorph >> actionSelector [

	^ actionSelector

]

{ #category : #accessing }
SimpleButtonMorph >> actionSelector: aSymbolOrString [

	(nil = aSymbolOrString or:
	 ['nil' = aSymbolOrString or:
	 [aSymbolOrString isEmpty]])
		ifTrue: [^ actionSelector := nil].

	actionSelector := aSymbolOrString asSymbol.

]

{ #category : #menu }
SimpleButtonMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	self addLabelItemsTo: aCustomMenu hand: aHandMorph.
	(target isKindOf: BookMorph)
		ifTrue:
			[aCustomMenu add: 'set page sound' translated action: #setPageSound:.
			aCustomMenu add: 'set page visual' translated action: #setPageVisual:]
		ifFalse:
			[
			aCustomMenu add: 'change action selector' translated action: #setActionSelector.
			aCustomMenu add: 'change arguments' translated action: #setArguments.
			aCustomMenu add: 'change when to act' translated action: #setActWhen.
			aCustomMenu add: 'set target' translated action: #sightTargets:.
			target ifNotNil: [aCustomMenu add: 'clear target' translated action: #clearTarget]].

]

{ #category : #menu }
SimpleButtonMorph >> addLabelItemsTo: aCustomMenu hand: aHandMorph [ 
	aCustomMenu add: 'change label' translated action: #setLabel
]

{ #category : #menu }
SimpleButtonMorph >> addTargetingMenuItems: aCustomMenu hand: aHandMorph [ 
	"Add targeting menu items"
	aCustomMenu addLine.

	aCustomMenu add: 'set target' translated action: #targetWith:.
	aCustomMenu add: 'sight target' translated action: #sightTargets:.
	target
		ifNotNil: [aCustomMenu add: 'clear target' translated action: #clearTarget]
]

{ #category : #accessing }
SimpleButtonMorph >> arguments [

	^ arguments

]

{ #category : #accessing }
SimpleButtonMorph >> arguments: aCollection [

	arguments := aCollection asArray copy.

]

{ #category : #menu }
SimpleButtonMorph >> clearTarget [

	target := nil.

]

{ #category : #button }
SimpleButtonMorph >> doButtonAction [
	"Perform the action of this button. Subclasses may override this method. The default behavior is to send the button's actionSelector to its target object with its arguments."

	(target notNil and: [actionSelector notNil]) 
		ifTrue: 
			[target perform: actionSelector withArguments: arguments].
	actWhen == #startDrag ifTrue: [oldColor ifNotNil: [self color: oldColor]]
]

{ #category : #geometry }
SimpleButtonMorph >> extent: newExtent [
	| label |
	super extent: newExtent.
	submorphs size = 1 ifTrue:
		["keep the label centered"
		"NOTE: may want to test more that it IS a label..."
		label := self firstSubmorph.
		label position: self center - (label extent // 2)]
]

{ #category : #layout }
SimpleButtonMorph >> fitContents [
	| aMorph aCenter |
	aCenter := self center.
	self hasSubmorphs ifFalse: [^self].
	aMorph := self firstSubmorph.
	self extent: aMorph extent + (self borderWidth + 6).
	self center: aCenter.
	aMorph position: aCenter - (aMorph extent // 2)
]

{ #category : #'event handling' }
SimpleButtonMorph >> handlesMouseDown: evt [
	^  self isPartsDonor not

]

{ #category : #'event handling' }
SimpleButtonMorph >> handlesMouseStillDown: evt [
	^actWhen == #whilePressed
]

{ #category : #initialization }
SimpleButtonMorph >> initialize [

	self initializeAllButLabel; setDefaultLabel
]

{ #category : #initialization }
SimpleButtonMorph >> initializeAllButLabel [
	super initialize.
	self
		 borderWidth: 1 ;
		 color: (Color r: 0.4 g: 0.8 b: 0.6) ;
		 borderColor: self color darker ;
		 borderStyle: BorderStyle thinGray.
	target := nil.
	actionSelector := #flash.
	arguments := Array empty.
	actWhen := #buttonUp
]

{ #category : #initialization }
SimpleButtonMorph >> initializeWithLabel: labelString [

	self initializeAllButLabel; label: labelString

]

{ #category : #accessing }
SimpleButtonMorph >> label [

	| s |
	s := ''.
	self allMorphsDo: [:m | (m isKindOf: StringMorph) ifTrue: [s := m contents]].
	^ s
]

{ #category : #accessing }
SimpleButtonMorph >> label: aString [

	| oldLabel m |
	(oldLabel := self findA: StringMorph)
		ifNotNil: [oldLabel delete].
	m := StringMorph contents: aString font: TextStyle defaultFont.
	self extent: m extent + (self borderWidth + 6).
	m position: self center - (m extent // 2).
	self addMorph: m.
	m lock
]

{ #category : #accessing }
SimpleButtonMorph >> label: aString font: aFont [

	| oldLabel m |
	(oldLabel := self findA: StringMorph)
		ifNotNil: [oldLabel delete].
	m := StringMorph contents: aString font: (aFont ifNil: [Preferences standardButtonFont]).
	self extent: (m width + 6) @ (m height + 6).
	m position: self center - (m extent // 2).
	self addMorph: m.
	m lock

]

{ #category : #accessing }
SimpleButtonMorph >> labelString: aString [

	| existingLabel |
	(existingLabel := self findA: StringMorph)
		ifNil:
			[self label: aString]
		ifNotNil:
			[existingLabel contents: aString.
			self fitContents]

]

{ #category : #'event handling' }
SimpleButtonMorph >> mouseDown: evt [

	super mouseDown: evt.
	evt yellowButtonPressed ifTrue: [ ^self ] .
	mouseDownTime := Time millisecondClockValue.
	oldColor := self fillStyle. 
	actWhen == #buttonDown
		ifTrue: [ self doButtonAction]
		ifFalse: [ self updateVisualState: evt ].
	self mouseStillDown: evt.
]

{ #category : #'event handling' }
SimpleButtonMorph >> mouseMove: evt [
	actWhen == #buttonDown ifTrue: [^ self].
	self updateVisualState: evt.
]

{ #category : #'event handling' }
SimpleButtonMorph >> mouseStillDown: evt [
	actWhen == #whilePressed ifFalse:[^self].
	(self containsPoint: evt cursorPoint) ifTrue:[self doButtonAction].
]

{ #category : #'events-processing' }
SimpleButtonMorph >> mouseStillDownStepRate [
	"Answer how often I want the #handleMouseStillDown: stepped"
	^200
]

{ #category : #'event handling' }
SimpleButtonMorph >> mouseUp: evt [
	super mouseUp: evt.
	oldColor ifNotNil:
		["if oldColor nil, it signals that mouse had not gone DOWN
		inside me, e.g. because of a cmd-drag; in this case we want
		to avoid triggering the action!"
		self color: oldColor.
		oldColor := nil.
		(self containsPoint: evt cursorPoint) 
				ifTrue: [ actWhen == #buttonUp 
							ifTrue: [self doButtonAction]  ]
				ifFalse: [ self mouseLeave: evt "This is a balk. Note that we have left." ]].
	self borderStyle style = #inset ifTrue: [self borderRaised].
		

]

{ #category : #'objects from disk' }
SimpleButtonMorph >> objectForDataStream: refStrm [

	^ super objectForDataStream: refStrm


	"I am about to be written on an object file.  If I send a message to a BookMorph, it would be bad to write that object out.  Create and write out a URLMorph instead.
	Feb 2007: It seems unlikely that Squeak Pages will be used in the OLPC image.  Don't use this code.  Consider removing all code that supports SqueakPages."
"
	| bb thatPage um stem ind sqPg |
	(actionSelector == #goToPageMorph:fromBookmark:) | 
		(actionSelector == #goToPageMorph:) ifFalse: [
			^ super objectForDataStream: refStrm].	'normal case'.

	target url ifNil: ['Later force target book to get a url.'.
		bb := SimpleButtonMorph new.	'write out a dummy'.
		bb label: self label.
		bb bounds: bounds.
		refStrm replace: self with: bb.
		^ bb].

	(thatPage := arguments first) url ifNil: [
			'Need to assign a url to a page that will be written later.
			It might have bookmarks too.  Don't want to recurse deeply.  
			Have that page write out a dummy morph to save its url on the server.'.
		stem := target getStemUrl.	'know it has one'.
		ind := target pages identityIndexOf: thatPage.
		thatPage reserveUrl: stem,(ind printString),'.sp'].
	um := URLMorph newForURL: thatPage url.
	sqPg := thatPage sqkPage clone.
	sqPg contentsMorph: nil.
	um setURL: thatPage url page: sqPg.
	(SqueakPage stemUrl: target url) = (SqueakPage stemUrl: thatPage url) 
		ifTrue: [um book: true]
		ifFalse: [um book: target url].  	'remember which book'.
	um privateOwner: owner.
	um bounds: bounds.
	um isBookmark: true; label: self label.
	um borderWidth: borderWidth; borderColor: borderColor.
	um color: color.
	refStrm replace: self with: um.
	^ um
"
]

{ #category : #copying }
SimpleButtonMorph >> recolor: c [
	self color: c.
	oldColor := c
]

{ #category : #menu }
SimpleButtonMorph >> setActWhen [

	| selections |
	selections := #(buttonDown buttonUp whilePressed startDrag).
	actWhen := UIManager default 
		chooseFrom: (selections collect: [:t | t translated]) 
		values: selections
		title: 'Choose one of the following conditions' translated.
]

{ #category : #menu }
SimpleButtonMorph >> setActionSelector [

	| newSel |
	newSel := UIManager default
		request:
'Please type the selector to be sent to
the target when this button is pressed' translated
		initialAnswer: actionSelector.
	newSel isEmpty ifFalse: [self actionSelector: newSel].

]

{ #category : #menu }
SimpleButtonMorph >> setArguments [

	| s newArgs newArgsArray |
	s := WriteStream on: ''.
	arguments do: [:arg | arg printOn: s. s nextPutAll: '. '].
	newArgs := UIManager default
		request:
'Please type the arguments to be sent to the target
when this button is pressed separated by periods' translated
		initialAnswer: s contents.
	newArgs isEmpty ifFalse: [
		newArgsArray := Compiler evaluate: '{', newArgs, '}' for: self.
		self arguments: newArgsArray].

]

{ #category : #initialization }
SimpleButtonMorph >> setDefaultLabel [
	self label: 'Flash'.

]

{ #category : #menu }
SimpleButtonMorph >> setLabel [

	| newLabel |
	newLabel := UIManager default
		request: 'Please enter a new label for this button'
		initialAnswer: self label.
	newLabel isEmpty ifFalse: [self labelString: newLabel].

]

{ #category : #menu }
SimpleButtonMorph >> setPageSound: event [

	^ target menuPageSoundFor: self event: event
]

{ #category : #menu }
SimpleButtonMorph >> setPageVisual: event [

	^ target menuPageVisualFor: self event: event
]

{ #category : #menu }
SimpleButtonMorph >> setTarget [
	
	| newLabel |
	newLabel := UIManager default request: 'Enter an expression that create the target' translated initialAnswer: 'World'.
	newLabel isEmpty
		ifFalse: [self target: (Compiler evaluate: newLabel)]
]

{ #category : #menu }
SimpleButtonMorph >> setTarget: evt [ 
	| rootMorphs |
	rootMorphs := self world rootMorphsAt: evt hand targetPoint.
	target := rootMorphs size > 1
				ifTrue: [rootMorphs second]
]

{ #category : #accessing }
SimpleButtonMorph >> target [

	^ target

]

{ #category : #accessing }
SimpleButtonMorph >> target: anObject [

	target := anObject

]

{ #category : #'visual properties' }
SimpleButtonMorph >> updateVisualState: evt [
	
	(self containsPoint: evt cursorPoint)
		ifTrue: [
			oldColor ifNotNil: [self color: (oldColor mixed: 1/2 with: Color white)].
			self borderStyle style = #raised ifTrue: [self borderInset]]
		ifFalse: [
			oldColor ifNotNil: [self color: oldColor].
			self borderStyle style = #inset ifTrue: [self borderRaised]].

]

{ #category : #copying }
SimpleButtonMorph >> veryDeepFixupWith: deepCopier [
	"If target and arguments fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals!!"

super veryDeepFixupWith: deepCopier.
target := deepCopier references at: target ifAbsent: [target].
arguments := arguments collect: [:each |
	deepCopier references at: each ifAbsent: [each]].

]

{ #category : #copying }
SimpleButtonMorph >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  	Warning!!  Every instance variable defined in this class must be handled.  We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

super veryDeepInner: deepCopier.
"target := target.		Weakly copied"
"actionSelector := actionSelector.		a Symbol"
"arguments := arguments.		All weakly copied"
actWhen := actWhen veryDeepCopyWith: deepCopier.
oldColor := oldColor veryDeepCopyWith: deepCopier.
mouseDownTime := nil.
]
