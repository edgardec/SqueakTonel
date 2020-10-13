Class {
	#name : #StringButtonMorph,
	#superclass : #StringMorph,
	#instVars : [
		'target',
		'actionSelector',
		'arguments',
		'actWhen',
		'oldColor'
	],
	#category : #'MorphicExtras-Widgets'
}

{ #category : #printing }
StringButtonMorph class >> defaultNameStemForInstances [
	^ 'SButton' translatedNoop
]

{ #category : #'submorphs-add\/remove' }
StringButtonMorph >> actWhen: aSymbol [
	"Set the condition under which to invoke my action to one of: #buttonDown, #buttonUp, and #whilePressed."

	actWhen := aSymbol.

]

{ #category : #accessing }
StringButtonMorph >> actionSelector [

	^ actionSelector

]

{ #category : #accessing }
StringButtonMorph >> actionSelector: aSymbolOrString [

	(nil = aSymbolOrString or:
	 ['nil' = aSymbolOrString or:
	 [aSymbolOrString isEmpty]])
		ifTrue: [^ actionSelector := nil].

	actionSelector := aSymbolOrString asSymbol.

]

{ #category : #'e-toy support' }
StringButtonMorph >> adaptToWorld: aWorld [
	super adaptToWorld: aWorld.
	target := target adaptedToWorld: aWorld.
]

{ #category : #menu }
StringButtonMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu add: 'change label' translated action: #setLabel.
	aCustomMenu add: 'change action selector' translated action: #setActionSelector.
	aCustomMenu add: 'change arguments' translated action: #setArguments.
	aCustomMenu add: 'change when to act' translated action: #setActWhen.
	self addTargetingMenuItems: aCustomMenu hand: aHandMorph .
]

{ #category : #menu }
StringButtonMorph >> addTargetingMenuItems: aCustomMenu hand: aHandMorph [ 
	"Add targeting menu items"
	aCustomMenu addLine.

	aCustomMenu add: 'set target' translated action: #targetWith:.
	aCustomMenu add: 'sight target' translated action: #sightTargets:.
	target
		ifNotNil: [aCustomMenu add: 'clear target' translated action: #clearTarget]
]

{ #category : #accessing }
StringButtonMorph >> arguments [

	^ arguments

]

{ #category : #accessing }
StringButtonMorph >> arguments: aCollection [

	arguments := aCollection asArray copy.

]

{ #category : #menu }
StringButtonMorph >> clearTarget [

	target := nil.

]

{ #category : #button }
StringButtonMorph >> doButtonAction [
	"Perform the action of this button. Subclasses may override this method. The default behavior is to send the button's actionSelector to its target object with its arguments."

	(target notNil and: [actionSelector notNil]) 
		ifTrue: 
			[Cursor normal 
				showWhile: [target perform: actionSelector withArguments: arguments]]
]

{ #category : #'event handling' }
StringButtonMorph >> handlesMouseDown: evt [

	^ true

]

{ #category : #'event handling' }
StringButtonMorph >> handlesMouseStillDown: evt [
	^actWhen == #whilePressed
]

{ #category : #initialization }
StringButtonMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	target := nil.
	actionSelector := #flash.
	arguments := Array empty.
	actWhen := #buttonUp.
	self contents: 'Flash'
]

{ #category : #'event handling' }
StringButtonMorph >> mouseDown: evt [

	oldColor := color.
	actWhen == #buttonDown
		ifTrue: [self doButtonAction].

]

{ #category : #'event handling' }
StringButtonMorph >> mouseMove: evt [
	actWhen == #buttonDown ifTrue: [^ self].
	(self containsPoint: evt cursorPoint)
		ifTrue:[self color: (oldColor alphaMixed: 1/2 with: Color white)]
		ifFalse: [self color: oldColor].

]

{ #category : #'event handling' }
StringButtonMorph >> mouseStillDown: evt [
	actWhen == #whilePressed ifFalse: [^ self].
	(self containsPoint: evt cursorPoint) ifTrue:[self doButtonAction].
]

{ #category : #'event handling' }
StringButtonMorph >> mouseUp: evt [

	self color: oldColor.
	(actWhen == #buttonUp and: [self containsPoint: evt cursorPoint])
		ifTrue: [self doButtonAction].

]

{ #category : #menu }
StringButtonMorph >> setActWhen [

	| selections |
	selections := #(buttonDown buttonUp whilePressed).
	actWhen := UIManager default 
		chooseFrom: (selections collect: [:t | t translated]) 
		values: selections
		title: 'Choose one of the following conditions' translated.

]

{ #category : #menu }
StringButtonMorph >> setActionSelector [

	| newSel |
	newSel := UIManager default
		request:
'Please type the selector to be sent to
the target when this button is pressed' translated
		initialAnswer: actionSelector.
	newSel isEmpty ifFalse: [self actionSelector: newSel].

]

{ #category : #menu }
StringButtonMorph >> setArguments [

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

{ #category : #menu }
StringButtonMorph >> setLabel [

	| newLabel |
	newLabel := UIManager default
		request:
'Please type a new label for this button'
		initialAnswer: self contents.
	newLabel isEmpty ifFalse: [self contents: newLabel].

]

{ #category : #menu }
StringButtonMorph >> setTarget: evt [ 
	| rootMorphs |
	rootMorphs := self world rootMorphsAt: evt  targetPoint.
	target := rootMorphs size > 1
		ifTrue: [rootMorphs second]
		ifFalse: [nil]
]

{ #category : #accessing }
StringButtonMorph >> target [

	^ target

]

{ #category : #accessing }
StringButtonMorph >> target: anObject [

	target := anObject

]

{ #category : #copying }
StringButtonMorph >> updateReferencesUsing: aDictionary [
	"If the arguments array points at a morph we are copying, then point at the new copy.  And also copies the array, which is important!"

	super updateReferencesUsing: aDictionary.
	arguments := arguments collect:
		[:old | aDictionary at: old ifAbsent: [old]].

]

{ #category : #copying }
StringButtonMorph >> veryDeepFixupWith: deepCopier [
	"If target and arguments fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals!!"

super veryDeepFixupWith: deepCopier.
target := deepCopier references at: target ifAbsent: [target].
arguments := arguments collect: [:each |
	deepCopier references at: each ifAbsent: [each]].

]

{ #category : #copying }
StringButtonMorph >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  	Warning!!  Every instance variable defined in this class must be handled.  We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

super veryDeepInner: deepCopier.
"target := target.		Weakly copied"
"actionSelector := actionSelector.		a Symbol"
"arguments := arguments.		All weakly copied"
actWhen := actWhen veryDeepCopyWith: deepCopier.
oldColor := oldColor veryDeepCopyWith: deepCopier.
]
