"
A StringMorph that constantly tries to show the current data from the target object.  When sent #step, it shows what the target objects has (target perform: getSelector).  When edited (with shift-click), it writes back to the target.

floatPrecision = 1. to round to integer.
floatPrecision = .1 to round to 1 decimal place, etc.

Even when ((target == nil) or: [getSelector == nil]), the user would still like to edit the string with shift-click.
"
Class {
	#name : #UpdatingStringMorph,
	#superclass : #StringMorph,
	#instVars : [
		'format',
		'target',
		'lastValue',
		'getSelector',
		'putSelector',
		'floatPrecision',
		'growable',
		'stepTime',
		'autoAcceptOnFocusLoss',
		'minimumWidth',
		'maximumWidth'
	],
	#category : #'Morphic-Widgets'
}

{ #category : #'instance creation' }
UpdatingStringMorph class >> on: targetObject selector: aSymbol [

	^ self new
		getSelector: aSymbol;
		target: targetObject


]

{ #category : #editing }
UpdatingStringMorph >> acceptContents [

	self informTarget.

]

{ #category : #editing }
UpdatingStringMorph >> acceptValue: aValue [

	self updateContentsFrom: (self acceptValueFromTarget: aValue).

]

{ #category : #'target access' }
UpdatingStringMorph >> acceptValueFromTarget: v [
	"Accept a value from the target"

	lastValue := v.
	self format == #string ifTrue: [^ v asString].
	self format == #symbol ifTrue: [^ v asString translated].
	(format == #default and: [v isNumber]) ifTrue:
		[^ self stringForNumericValue: v].
	^ v printString translated
]

{ #category : #editing }
UpdatingStringMorph >> addCustomMenuItems: menu hand: aHandMorph [ 
	| prefix |
	super addCustomMenuItems: menu hand: aHandMorph.
	prefix := (self growable
				ifTrue: ['stop being growable']
				ifFalse: ['start being growable']) translated.
	menu add: prefix action: #toggleGrowability.
	menu add: 'decimal places...' translated action: #setPrecision.
	menu add: 'font size...' translated action: #setFontSize.
	menu add: 'font style...' translated action: #setFontStyle
]

{ #category : #accessing }
UpdatingStringMorph >> autoAcceptOnFocusLoss [
	^ autoAcceptOnFocusLoss ~~ false
]

{ #category : #accessing }
UpdatingStringMorph >> autoAcceptOnFocusLoss: aBoolean [
	autoAcceptOnFocusLoss := aBoolean
]

{ #category : #'target access' }
UpdatingStringMorph >> checkTarget [
	""
	getSelector ifNil: [^ true].
	^ getSelector numArgs = 0.

]

{ #category : #accessing }
UpdatingStringMorph >> decimalPlaces [
	"Answer the number of decimal places to show."

	| places |
	(places := self valueOfProperty: #decimalPlaces) ifNotNil: [^ places].
	self setProperty: #decimalPlaces toValue: (places := Utilities decimalPlacesForFloatPrecision: self floatPrecision).
	^ places
]

{ #category : #accessing }
UpdatingStringMorph >> decimalPlaces: aNumber [
	"Set the receiver's number of decimal places to be shown.  If my target is a morph or a player, tell it about the change, in case it wants to remember it."

	| constrained |
	self setProperty: #decimalPlaces toValue: (constrained := aNumber min: 11).
	self pvtFloatPrecision: (Utilities floatPrecisionForDecimalPlaces: constrained).
	(target isMorph or:[target isPlayer]) ifTrue:
		[target noteDecimalPlaces: constrained forGetter: getSelector]
]

{ #category : #editing }
UpdatingStringMorph >> doneWithEdits [
	"If in a SyntaxMorph, shrink min width after editing"

	| editor |
	super doneWithEdits.
	(owner respondsTo: #parseNode) ifTrue: [minimumWidth := 8].
	editor := (submorphs detect: [ :sm | sm isKindOf: StringMorphEditor ] ifNone: [ ^self ]).
	editor delete.
]

{ #category : #layout }
UpdatingStringMorph >> fitContents [
	"Overridden to respect minimum and maximum widfth."
	
	| newExtent |
	newExtent :=  self measureContents.
	self extent: ((newExtent x max: self minimumWidth) min: self maximumWidth) @ newExtent y.
]

{ #category : #accessing }
UpdatingStringMorph >> floatPrecision [
	"Answer the floatPrecision to use:
		1.0 ->	show whole number
		0.1	->	show one digit of precision
		.01 ->	show two digits of precision
		etc.
	Initialize the floatPrecision to 1 if it is not already defined"

	floatPrecision isNumber ifFalse:
		[self target: target].  "Fixes up errant cases from earlier bug"
	^ floatPrecision

]

{ #category : #accessing }
UpdatingStringMorph >> format [
	"Answer the receiver's format: #default or #string"

	^ format ifNil: [format := #default]
]

{ #category : #accessing }
UpdatingStringMorph >> getSelector [

	^ getSelector

]

{ #category : #accessing }
UpdatingStringMorph >> getSelector: aSymbol [

	getSelector := aSymbol.

]

{ #category : #accessing }
UpdatingStringMorph >> growable [

	^ growable ~~ false

]

{ #category : #accessing }
UpdatingStringMorph >> growable: aBoolean [

	growable := aBoolean.

]

{ #category : #'events-processing' }
UpdatingStringMorph >> handlerForMouseDown: evt [
	"Answer an object to field the mouseDown event provided, or nil if none"

	| aHandler |
	aHandler := super handlerForMouseDown: evt.
	aHandler == self ifTrue:	[^ self]. "I would get it anyways"
	"Note: This is a hack to allow value editing in viewers"
	((owner wantsKeyboardFocusFor: self) and:
		[self userEditsAllowed]) ifTrue: [^ self].
	^ aHandler
]

{ #category : #'event handling' }
UpdatingStringMorph >> handlesMouseDown: evt [
	(owner wantsKeyboardFocusFor: self)
		ifTrue:[^true].
	^ super handlesMouseDown: evt
]

{ #category : #'target access' }
UpdatingStringMorph >> informTarget [
	"Obtain a value from my contents, and tell my target about it.  The putSelector can take one argument (traditional) or two (as used by Croquet)"

	| newValue typeIn |
	(target notNil and: [putSelector notNil]) 
		ifTrue: 
			[typeIn := contents.
			(newValue := self valueFromContents) ifNotNil: 
					[self checkTarget.
					putSelector numArgs = 1 
						ifTrue: [target perform: putSelector with: newValue].
					putSelector numArgs = 2 
						ifTrue: 
							[target 
								perform: putSelector
								with: newValue
								with: self].
					target isMorph ifTrue: [target changed]].
			self fitContents.
			(format == #default and: [newValue isNumber]) 
				ifTrue: [self setDecimalPlacesFromTypeIn: typeIn]]
]

{ #category : #initialization }
UpdatingStringMorph >> initialize [
	"Initialize the receiver to have default values in its instance variables."
	super initialize.
""
	format := #default.
	"formats: #string, #default"
	target := getSelector := putSelector := nil.
	floatPrecision := 1.
	growable := true.
	stepTime := nil.
	autoAcceptOnFocusLoss := true.
	minimumWidth := 8.
	maximumWidth := 366
]

{ #category : #'target access' }
UpdatingStringMorph >> isEtoyReadout [
	"Answer whether the receiver can serve as an etoy readout"

	^ true
]

{ #category : #editing }
UpdatingStringMorph >> lostFocusWithoutAccepting [
	"The message is sent when the user, having been in an editing episode on the receiver, changes the keyboard focus -- typically by clicking on some editable text somewhere else -- without having accepted the current edits."

	self autoAcceptOnFocusLoss ifTrue: [self doneWithEdits; acceptContents]
]

{ #category : #accessing }
UpdatingStringMorph >> maximumWidth [
	"Answer the maximum width that the receiver can have.   A nil value means no maximum, and for practical purposes results in a value of 99999 here temporarily, for help in future debugging"

	^ maximumWidth ifNil: [99999]
]

{ #category : #accessing }
UpdatingStringMorph >> maximumWidth: aValue [
	"Set the maximum width that the receiver can have."

	maximumWidth := aValue
]

{ #category : #accessing }
UpdatingStringMorph >> minWidth [
	"Answer the minimum width that the receiver can have.  A nonzero value here keeps the receiver from degenerating into something that cannot ever be seen or touched again!  Obeyed by fitContents."

	^ minimumWidth ifNil: [minimumWidth := 8]
]

{ #category : #accessing }
UpdatingStringMorph >> minWidth: aWidth [
	"Set the minimum width that the receiver can have.  A nonzero value here keeps the receiver from degenerating into something that cannot ever be seen or touched again!  Obeyed by fitContents."

	minimumWidth := aWidth
]

{ #category : #'event handling' }
UpdatingStringMorph >> mouseDown: evt [
	"The mouse went down over the receiver.  If appropriate, launch a mini-editor so that the user can commence text-editing here"

	(owner wantsKeyboardFocusFor: self) ifTrue:
		[self userEditsAllowed ifTrue:
			[(owner respondsTo: #parseNode)
					ifTrue: 	"leave space for editing"
						[minimumWidth := (49 max: minimumWidth)].
			self launchMiniEditor: evt]]
]

{ #category : #accessing }
UpdatingStringMorph >> putSelector [

	^ putSelector

]

{ #category : #accessing }
UpdatingStringMorph >> putSelector: aSymbol [

	putSelector := aSymbol.

]

{ #category : #accessing }
UpdatingStringMorph >> pvtFloatPrecision: aNumber [
	"Private - Set the floatPrecision instance variable to the given number"

	floatPrecision := aNumber
]

{ #category : #'target access' }
UpdatingStringMorph >> readFromTarget [
	"Update my readout from my target"

	| v ret places |
	(target isNil or: [getSelector isNil]) ifTrue: [^contents].
	ret := self checkTarget.
	ret ifFalse: [^ '0'].
	((target isMorph) or:[target isPlayerLike]) ifTrue:[
	places := target decimalPlacesForGetter: getSelector.
	(places ~= nil and: [ places ~= (self valueOfProperty: #decimalPlaces ifAbsent: [0])])  ifTrue: [ self decimalPlaces: places ]].
	v := target perform: getSelector.	"scriptPerformer"
	(v isKindOf: Text) ifTrue: [v := v asString].
	^self acceptValueFromTarget: v
]

{ #category : #editing }
UpdatingStringMorph >> setDecimalPlaces: places [
	"Set the number of decimal places, and update the display."

	self decimalPlaces: places.
	self acceptValueFromTarget: lastValue
]

{ #category : #'target access' }
UpdatingStringMorph >> setDecimalPlacesFromTypeIn: typeIn [
	"The user has typed in a number as the new value of the receiver.  Glean off decimal-places-preference from the type-in"

	| decimalPointPosition tail places |
	(typeIn includes: $e) ifTrue: [^ self].
	decimalPointPosition := typeIn indexOf: $. ifAbsent: [nil].
	places := 0.
	decimalPointPosition
		ifNotNil:
			[tail := typeIn copyFrom: decimalPointPosition + 1 to: typeIn size.
			[places < tail size and: [(tail at: (places + 1)) isDigit]]
				whileTrue:
					[places := places + 1]].
		
	self decimalPlaces: places
]

{ #category : #editing }
UpdatingStringMorph >> setFontSize [
	| sizes reply family |
	family := font ifNil: [TextStyle default] ifNotNil: [font textStyle].
	family ifNil: [family := TextStyle default].  "safety net -- this line SHOULD be unnecessary now"
	sizes := 	family fontNamesWithPointSizes.
	reply := UIManager default chooseFrom: sizes values: sizes.
	reply ifNotNil:
		[self font: (family fontAt: (sizes indexOf: reply))]
]

{ #category : #editing }
UpdatingStringMorph >> setFontStyle [
	| aList reply style |
	aList := (TextConstants select: [:anItem | anItem isKindOf: TextStyle]) 
				keys asArray.
	reply := UIManager default chooseFrom: aList values: aList.
	reply notNil 
		ifTrue: 
			[(style := TextStyle named: reply) ifNil: 
					[Beeper beep.
					^true].
			self font: style defaultFont]
]

{ #category : #editing }
UpdatingStringMorph >> setPrecision [
	"Allow the user to specify a number of decimal places.  This UI is invoked from a menu.  Nowadays the precision can be set by simple type-in, making this menu approach mostly obsolete.  However, it's still useful for read-only readouts, where type-in is not allowed."

	| aMenu |
	aMenu := MenuMorph new.
	aMenu addTitle: ('How many decimal places? (currently {1})' translated format: {self decimalPlaces}).
	0 to: 10 do:
		[:places |
			aMenu add: places asString target: self selector: #setDecimalPlaces: argument: places].
	aMenu popUpInWorld
]

{ #category : #editing }
UpdatingStringMorph >> setToAllowTextEdit [
	"Set up the receiver so that it will be receptive to text editing, even if there is no putSelector provided"

	self setProperty: #okToTextEdit toValue: true
]

{ #category : #'stepping and presenter' }
UpdatingStringMorph >> step [
	| s |
	super step.
	hasFocus ifFalse:
		["update contents, but only if user isn't editing this string"
		s := self readFromTarget.
		s = contents ifFalse:
			[self updateContentsFrom: s]]

]

{ #category : #'stepping and presenter' }
UpdatingStringMorph >> stepTime [

	^ stepTime ifNil: [200]

]

{ #category : #stepping }
UpdatingStringMorph >> stepTime: mSecsPerStep [

	stepTime := mSecsPerStep truncated.

]

{ #category : #'target access' }
UpdatingStringMorph >> stringForNumericValue: aValue [
	"Answer a suitably-formatted string representing the value."

	| barePrintString |
	((barePrintString := aValue printString) includes: $e)  ifTrue: [^ barePrintString].
	^ aValue printShowingDecimalPlaces: self decimalPlaces
]

{ #category : #accessing }
UpdatingStringMorph >> target [

	^ target

]

{ #category : #accessing }
UpdatingStringMorph >> target: anObject [

	target := anObject.
	getSelector ifNotNil: [floatPrecision := anObject defaultFloatPrecisionFor: getSelector]

]

{ #category : #editing }
UpdatingStringMorph >> toggleGrowability [
	growable := self growable not.
	self updateContentsFrom: self readFromTarget.
	growable ifTrue: [self fitContents]
]

{ #category : #stepping }
UpdatingStringMorph >> updateContentsFrom: aValue [
	self growable
		ifTrue:
			[self contentsFitted: aValue]
		ifFalse:
			[self contentsClipped: aValue]
]

{ #category : #formats }
UpdatingStringMorph >> useDefaultFormat [
	"Use the object's own printString format."

	format := #default.

]

{ #category : #formats }
UpdatingStringMorph >> useStringFormat [

	format := #string.
]

{ #category : #formats }
UpdatingStringMorph >> useSymbolFormat [

	format := #symbol.
]

{ #category : #editing }
UpdatingStringMorph >> userEditsAllowed [
	"Answer whether user-edits are allowed to this field"

	^ putSelector notNil or: [self hasProperty: #okToTextEdit]
]

{ #category : #accessing }
UpdatingStringMorph >> valueFromContents [
	"Return a new value from the current contents string."

"
	| expression tilePadMorphOrNil asNumberBlock |
	asNumberBlock := [:string | [string asNumber]
				on: Error
				do: []].
	format = #string
		ifTrue: [^ contents].
	(format = #default
			and: [self owner isKindOf: NumericReadoutTile])
		ifTrue: [^ asNumberBlock value: contents].
	tilePadMorphOrNil := self ownerThatIsA: TilePadMorph.
	(tilePadMorphOrNil notNil
			and: [tilePadMorphOrNil type = #Number])
		ifTrue: [^ asNumberBlock value: contents].
	expression := Vocabulary eToyVocabulary translationKeyFor: contents.
	expression isNil
		ifTrue: [expression := contents].
	^ Compiler evaluate: expression
"

	format = #symbol ifTrue: [^ lastValue].
	format = #string ifTrue: [^ contents].
	(owner notNil and: [owner isNumericReadoutTile]) ifTrue: [
		^ Number readFrom: contents
	].
	target ifNotNil: [target owner ifNotNil: [
		((target owner isTilePadMorph) and: [target owner type = #Number])
			ifTrue: [^ Number readFrom: contents]]].
	^ Compiler evaluate: contents

]

{ #category : #copying }
UpdatingStringMorph >> veryDeepFixupWith: deepCopier [
	"If target field is weakly copied, fix it here.  If they were in the tree being copied, fix them up, otherwise point to the originals!!"

super veryDeepFixupWith: deepCopier.
target := deepCopier references at: target ifAbsent: [target].

]

{ #category : #copying }
UpdatingStringMorph >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared."

	super veryDeepInner: deepCopier.
	format := format veryDeepCopyWith: deepCopier.
	target := target.					"Weakly copied"
	lastValue := lastValue veryDeepCopyWith: deepCopier.
	getSelector := getSelector.			"Symbol"
	putSelector := putSelector.		"Symbol"
	floatPrecision := floatPrecision veryDeepCopyWith: deepCopier.
	growable := growable veryDeepCopyWith: deepCopier.
	stepTime := stepTime veryDeepCopyWith: deepCopier.
	autoAcceptOnFocusLoss := autoAcceptOnFocusLoss veryDeepCopyWith: deepCopier.
	minimumWidth := minimumWidth veryDeepCopyWith: deepCopier.
	maximumWidth := maximumWidth veryDeepCopyWith: deepCopier.
	self setProperty: #decimalPlaces toValue: ((self valueOfProperty: #decimalPlaces ifAbsent: [0]) veryDeepCopyWith: deepCopier).

]

{ #category : #'event handling' }
UpdatingStringMorph >> wouldAcceptKeyboardFocus [
	^ (self hasProperty: #okToTextEdit) or: [super wouldAcceptKeyboardFocus]
]
