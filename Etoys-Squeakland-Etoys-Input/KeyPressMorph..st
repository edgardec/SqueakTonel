Class {
	#name : #KeyPressMorph,
	#superclass : #Morph,
	#instVars : [
		'currentKey',
		'lastTimePressed',
		'isWaitingToSetCurrentKey'
	],
	#category : #'Etoys-Squeakland-Etoys-Input'
}

{ #category : #'viewer categories' }
KeyPressMorph class >> additionsToViewerCategories [
^ #(
(#input (
#(slot currentKey 'The current key' String readOnly Player getCurrentKey Player unused)
#(slot keyIsPressed 'Whether the current key is pressed at the moment' Boolean readOnly Player getKeyIsPressed Player unused)
#(slot timePressed 'The time in milliseconds the current key has been pressed' Number readOnly Player getTimePressed Player unused)
)))
]

{ #category : #'parts bin' }
KeyPressMorph class >> descriptionForPartsBin [
	^ self
		partName: 'Key press' translatedNoop
		categories: {'Just for Fun' translatedNoop}
		documentation: 'An object that tells you when a specific key has been pressed.' translatedNoop

]

{ #category : #actions }
KeyPressMorph >> changeCurrentKey [
	isWaitingToSetCurrentKey
		ifTrue: [self setCurrentKey: currentKey]
		ifFalse: [self say: 'Press new key' translated;
					color: Color red muchLighter.
			isWaitingToSetCurrentKey := true]
]

{ #category : #accessing }
KeyPressMorph >> currentKey [
	^ currentKey
]

{ #category : #events }
KeyPressMorph >> handleKeyboardEvent: anEvent [
	isWaitingToSetCurrentKey
		ifTrue: [self setCurrentKey: anEvent keyString asLowercase]
		ifFalse: [self setIsPressed: anEvent]

]

{ #category : #events }
KeyPressMorph >> handleListenEvent: anEvent [
	anEvent isMouse
		ifTrue: [self handleMouseEvent: anEvent]
		ifFalse: [self handleKeyboardEvent: anEvent]
]

{ #category : #events }
KeyPressMorph >> handleMouseEvent: anEvent [
	(isWaitingToSetCurrentKey and: [anEvent type = #mouseUp])
		ifTrue: [self setCurrentKey: self currentKey]
]

{ #category : #initialize }
KeyPressMorph >> initialize [
	super initialize.
	currentKey := 'a'.
	isWaitingToSetCurrentKey := false.	
	self layoutPolicy: TableLayout new;
		listDirection: #topToBottom;
	 	wrapCentering: #topLeft;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		layoutInset: 5;
		color: Color blue muchLighter;
		borderColor: Color blue;
		cornerStyle: #rounded;
		rebuild

]

{ #category : #events }
KeyPressMorph >> intoWorld: aWorld [
	super intoWorld: aWorld.
	self registerToEvents.

]

{ #category : #accessing }
KeyPressMorph >> isPressed [
	^ self timePressed > 0
]

{ #category : #events }
KeyPressMorph >> outOfWorld: aWorld [
	self unregisterToEvents.
	super outOfWorld: aWorld.

]

{ #category : #building }
KeyPressMorph >> rebuild [
	| keyButton |
	self removeAllMorphs.
	self addMorphBack: 'Key:' translated asMorph.
	self addMorphBack: (keyButton := SimpleButtonMorph new
								labelString: self currentKey;
								color: Color white;
								target: self;
								actionSelector: #changeCurrentKey;
								yourself).
	keyButton width < 50
		ifTrue: [keyButton width: 50]
]

{ #category : #events }
KeyPressMorph >> registerToEvents [
	self currentHand
		addKeyboardListener: self;
		addMouseListener: self
]

{ #category : #events }
KeyPressMorph >> setCurrentKey: aString [
	isWaitingToSetCurrentKey := false.
	self stopSayingOrThinking;
		color: Color blue muchLighter.
	currentKey := aString.
	self rebuild
]

{ #category : #events }
KeyPressMorph >> setIsPressed: anEvent [ 
	anEvent keyString asLowercase = self currentKey asLowercase
		ifFalse: [^ self].
	anEvent type caseOf: {
		[#keyDown] -> [self isPressed ifTrue: [^ self].
				lastTimePressed := Time millisecondClockValue].
		[#keyUp] -> [lastTimePressed := nil]
	} otherwise: [].
	lastTimePressed notNil
		ifTrue: [self borderWidth: 2]
		ifFalse: [self borderWidth: 0]

]

{ #category : #accessing }
KeyPressMorph >> timePressed [
	^ lastTimePressed
			ifNil: [0]
			ifNotNil: [:last | Time millisecondsSince: last]
]

{ #category : #events }
KeyPressMorph >> unregisterToEvents [
	self currentHand
		removeKeyboardListener: self;
		removeMouseListener: self
]
