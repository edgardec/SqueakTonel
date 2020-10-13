"
MorphExtension provides access to extra instance state that is not required in most simple morphs.  This allows simple morphs to remain relatively lightweight while still admitting more complex structures as necessary.  The otherProperties field takes this policy to the extreme of allowing any number of additional named attributes, albeit at a certain cost in speed and space.
"
Class {
	#name : #MorphExtension,
	#superclass : #Object,
	#instVars : [
		'locked',
		'visible',
		'sticky',
		'balloonText',
		'balloonTextSelector',
		'externalName',
		'isPartsDonor',
		'actorState',
		'player',
		'eventHandler',
		'otherProperties'
	],
	#category : #'Morphic-Kernel'
}

{ #category : #accessing }
MorphExtension >> actorState [
	"answer the redeiver's actorState"
	^ actorState 
]

{ #category : #accessing }
MorphExtension >> actorState: anActorState [ 
"change the receiver's actorState"
	actorState := anActorState
]

{ #category : #'accessing - other properties' }
MorphExtension >> assureOtherProperties [
	"creates an otherProperties for the receiver if needed"
	otherProperties ifNil: [self initializeOtherProperties].
	^ otherProperties
]

{ #category : #accessing }
MorphExtension >> balloonText [
	^ balloonText
]

{ #category : #accessing }
MorphExtension >> balloonText: newValue [
	balloonText := newValue
]

{ #category : #accessing }
MorphExtension >> balloonTextSelector [
	^ balloonTextSelector
]

{ #category : #accessing }
MorphExtension >> balloonTextSelector: aSymbol [ 
	"change the receiver's balloonTextSelector"
	balloonTextSelector := aSymbol
]

{ #category : #'objects from disk' }
MorphExtension >> comeFullyUpOnReload: smartRefStream [
	"inst vars have default booplean values."

	locked ifNil: [locked := false].
	visible ifNil: [visible := true].
	sticky ifNil: [sticky := false].
	isPartsDonor ifNil: [isPartsDonor := false].
	^ self
]

{ #category : #'connectors-copying' }
MorphExtension >> copyWeakly [
	"list of names of properties whose values should be weak-copied when veryDeepCopying a morph.  See DeepCopier."

	^ #(formerOwner newPermanentPlayer logger graphModel gestureDictionaryOrName)
	"add yours to this list" 

	"formerOwner should really be nil at the time of the copy, but this will work just fine."
]

{ #category : #accessing }
MorphExtension >> eventHandler [
	"answer the receiver's eventHandler"
	^ eventHandler 
]

{ #category : #accessing }
MorphExtension >> eventHandler: newValue [
	eventHandler := newValue
]

{ #category : #viewer }
MorphExtension >> externalName [
	^ externalName
]

{ #category : #accessing }
MorphExtension >> externalName: aString [ 
	"change the receiver's externalName"
	externalName := aString
]

{ #category : #'accessing - other properties' }
MorphExtension >> hasOtherProperties [
	"answer whether the receiver has otherProperties"
	^ otherProperties notNil
]

{ #category : #'accessing - other properties' }
MorphExtension >> hasProperty: aSymbol [ 
	"Answer whether the receiver has the property named aSymbol"
	| property |
	otherProperties ifNil: [^ false].
	property := otherProperties at: aSymbol ifAbsent: [].
	property isNil ifTrue: [^ false].
	property == false ifTrue: [^ false].
	^ true
]

{ #category : #initialization }
MorphExtension >> initialize [
	"Init all booleans to default values"
	locked := false.
	visible := true.
	sticky := false.
	isPartsDonor := false.

]

{ #category : #'accessing - other properties' }
MorphExtension >> initializeOtherProperties [
	"private - initializes the receiver's otherProperties"
	otherProperties :=  IdentityDictionary new
]

{ #category : #other }
MorphExtension >> isDefault [
	"Return true if the receiver is a default and can be omitted"
	locked == true
		ifTrue: [^ false].
	visible == false
		ifTrue: [^ false].
	sticky == true
		ifTrue: [^ false].
	balloonText isNil
		ifFalse: [^ false].
	balloonTextSelector isNil
		ifFalse: [^ false].
	externalName isNil
		ifFalse: [^ false].
	isPartsDonor == true
		ifTrue: [^ false].
	actorState isNil
		ifFalse: [^ false].
	player isNil
		ifFalse: [^ false].
	eventHandler isNil
		ifFalse: [^ false].
	otherProperties ifNotNil: [otherProperties isEmpty ifFalse: [^ false]].
	^ true
]

{ #category : #'parts bin' }
MorphExtension >> isPartsDonor [
	"answer whether the receiver is PartsDonor"
	^ isPartsDonor
]

{ #category : #'parts bin' }
MorphExtension >> isPartsDonor: aBoolean [ 
	"change the receiver's isPartDonor property"
	isPartsDonor := aBoolean
]

{ #category : #'accessing - layout properties' }
MorphExtension >> layoutFrame [
	^self valueOfProperty: #layoutFrame
]

{ #category : #'accessing - layout properties' }
MorphExtension >> layoutFrame: aLayoutFrame [ 
	aLayoutFrame isNil
		ifTrue: [self removeProperty: #layoutFrame]
		ifFalse: [self setProperty: #layoutFrame toValue: aLayoutFrame]
]

{ #category : #'accessing - layout properties' }
MorphExtension >> layoutPolicy [
	^self valueOfProperty: #layoutPolicy
]

{ #category : #'accessing - layout properties' }
MorphExtension >> layoutPolicy: aLayoutPolicy [ 
	aLayoutPolicy isNil
		ifTrue: [self removeProperty: #layoutPolicy]
		ifFalse: [self setProperty: #layoutPolicy toValue: aLayoutPolicy]
]

{ #category : #'accessing - layout properties' }
MorphExtension >> layoutProperties [
	^self valueOfProperty: #layoutProperties
]

{ #category : #'accessing - layout properties' }
MorphExtension >> layoutProperties: newProperties [ 
	"Return the current layout properties associated with the receiver"

	newProperties isNil
		ifTrue: [self removeProperty: #layoutProperties]
		ifFalse: [self setProperty: #layoutProperties toValue: newProperties]
]

{ #category : #accessing }
MorphExtension >> locked [
	"answer whether the receiver is Locked"
	^ locked
]

{ #category : #accessing }
MorphExtension >> locked: aBoolean [ 
	"change the receiver's locked property"
	locked := aBoolean
]

{ #category : #'accessing - other properties' }
MorphExtension >> otherProperties [
	"answer the receiver's otherProperties"
	^ otherProperties
]

{ #category : #accessing }
MorphExtension >> player [
	"answer the receiver's player"
	^ player
]

{ #category : #accessing }
MorphExtension >> player: anObject [ 
	"change the receiver's player"
	player := anObject 
]

{ #category : #printing }
MorphExtension >> printOn: aStream [ 
	"Append to the argument, aStream, a sequence of characters that 
	identifies the receiver." 
	super printOn: aStream.
	aStream nextPutAll: ' ' , self identityHashPrintString.
	locked == true
		ifTrue: [aStream nextPutAll: ' [locked] '].
	visible == false
		ifTrue: [aStream nextPutAll: '[not visible] '].
	sticky == true
		ifTrue: [aStream nextPutAll: ' [sticky] '].
	balloonText
		ifNotNil: [aStream nextPutAll: ' [balloonText] '].
	balloonTextSelector
		ifNotNil: [aStream nextPutAll: ' [balloonTextSelector: ' , balloonTextSelector printString , '] '].
	externalName
		ifNotNil: [aStream nextPutAll: ' [externalName = ' , externalName , ' ] '].
	isPartsDonor == true
		ifTrue: [aStream nextPutAll: ' [isPartsDonor] '].
	player
		ifNotNil: [aStream nextPutAll: ' [player = ' , player printString , '] '].
	eventHandler
		ifNotNil: [aStream nextPutAll: ' [eventHandler = ' , eventHandler printString , '] '].
	(otherProperties isNil or: [otherProperties isEmpty ]) ifTrue: [^ self].
	aStream nextPutAll: ' [other: '.
	self otherProperties
		keysDo: [:aKey | aStream nextPutAll: ' (' , aKey , ' -> ' , (self otherProperties at: aKey) printString , ')'].
	aStream nextPut: $]
]

{ #category : #'accessing - other properties' }
MorphExtension >> privateOtherProperties: anIdentityDictionary [ 
	"private - change the receiver's otherProperties"
	otherProperties := anIdentityDictionary 
]

{ #category : #'connectors-copying' }
MorphExtension >> propertyNamesNotCopied [
	"list of names of properties whose values should be deleted when veryDeepCopying a morph.
	See DeepCopier."

	^ #(connectedConstraints connectionHighlights highlightedTargets)
	"add yours to this list" 

]

{ #category : #'accessing - other properties' }
MorphExtension >> removeOtherProperties [
	"Remove the 'other' properties"
	otherProperties := nil
]

{ #category : #'accessing - other properties' }
MorphExtension >> removeProperty: aSymbol [ 
	"removes the property named aSymbol if it exists"
	otherProperties ifNil: [^ self].
	otherProperties removeKey: aSymbol ifAbsent: [].
	otherProperties isEmpty ifTrue: [self removeOtherProperties]
]

{ #category : #'accessing - other properties' }
MorphExtension >> setProperty: aSymbol toValue: abObject [ 
	"change the receiver's property named aSymbol to anObject"
	self assureOtherProperties at: aSymbol put: abObject
]

{ #category : #'accessing - other properties' }
MorphExtension >> sortedPropertyNames [
	"answer the receiver's property names in a sorted way"

	| props |
	props := WriteStream on: (Array new: 10).
	locked == true ifTrue: [props nextPut: #locked].
	visible == false ifTrue: [props nextPut: #visible].
	sticky == true ifTrue: [props nextPut: #sticky].
	balloonText isNil ifFalse: [props nextPut: #balloonText].
	balloonTextSelector isNil ifFalse: [props nextPut: #balloonTextSelector].
	externalName isNil ifFalse: [props nextPut: #externalName].
	isPartsDonor == true ifTrue: [props nextPut: #isPartsDonor].
	actorState isNil ifFalse: [props nextPut: #actorState].
	player isNil ifFalse: [props nextPut: #player].
	eventHandler isNil ifFalse: [props nextPut: #eventHandler].
	 otherProperties ifNotNil: [otherProperties associationsDo: [:a | props nextPut: a key]].
	^props contents sort: [:s1 :s2 | s1 <= s2]
]

{ #category : #accessing }
MorphExtension >> sticky [
	^ sticky
]

{ #category : #accessing }
MorphExtension >> sticky: aBoolean [ 
	"change the receiver's sticky property"
	sticky := aBoolean
]

{ #category : #'accessing - other properties' }
MorphExtension >> valueOfProperty: aSymbol [ 
"answer the value of the receiver's property named aSymbol"

	^otherProperties ifNotNil: [ otherProperties at: aSymbol ifAbsent: nil ]
]

{ #category : #'accessing - other properties' }
MorphExtension >> valueOfProperty: aSymbol ifAbsent: aBlock [ 
	"if the receiver possesses a property of the given name, answer  
	its value. If not then evaluate aBlock and answer the result of  
	this block evaluation"
	otherProperties ifNil: [^ aBlock value].
	^otherProperties at: aSymbol ifAbsent: aBlock
]

{ #category : #'accessing - other properties' }
MorphExtension >> valueOfProperty: aSymbol ifAbsentPut: aBlock [ 
	"If the receiver possesses a property of the given name, answer  
	its value. If not, then create a property of the given name, give 
	it the value obtained by evaluating aBlock, then answer that  
	value"
	^self assureOtherProperties at: aSymbol ifAbsentPut: aBlock
]

{ #category : #'connectors-copying' }
MorphExtension >> veryDeepFixupWith: deepCopier [ 
	"If target and arguments fields were weakly copied, fix them here.
	If they were in the tree being copied, fix them up, otherwise point to the originals!!"

	super veryDeepFixupWith: deepCopier.
	otherProperties ifNil: [ ^self ].

	"Properties whose values are only copied weakly replace those values if they were copied via another path"
	self copyWeakly do: [ :propertyName |
		otherProperties at: propertyName ifPresent: [ :property |
			otherProperties at: propertyName
				put: (deepCopier references at: property ifAbsent: [ property ])]].

]

{ #category : #'connectors-copying' }
MorphExtension >> veryDeepInner: deepCopier [ 
	"Copy all of my instance variables.
	Some otherProperties need to be not copied at all, but shared. Their names are given by copyWeakly.
	Some otherProperties should not be copied or shared. Their names are given by propertyNamesNotCopied.
	This is special code for the dictionary. See DeepCopier, and veryDeepFixupWith:."

	| namesOfWeaklyCopiedProperties weaklyCopiedValues |
	super veryDeepInner: deepCopier.
	locked := locked veryDeepCopyWith: deepCopier.
	visible := visible veryDeepCopyWith: deepCopier.
	sticky := sticky veryDeepCopyWith: deepCopier.
	balloonText := balloonText veryDeepCopyWith: deepCopier.
	balloonTextSelector := balloonTextSelector veryDeepCopyWith: deepCopier.
	externalName := externalName veryDeepCopyWith: deepCopier.
	isPartsDonor := isPartsDonor veryDeepCopyWith: deepCopier.
	actorState := actorState veryDeepCopyWith: deepCopier.
	player := player veryDeepCopyWith: deepCopier.		"Do copy the player of this morph"
	eventHandler := eventHandler veryDeepCopyWith: deepCopier. 	"has its own restrictions"

	otherProperties ifNil: [ ^self ].

	otherProperties := otherProperties copy.
	self propertyNamesNotCopied do: [ :propName | otherProperties removeKey: propName ifAbsent: [] ].

	namesOfWeaklyCopiedProperties := self copyWeakly.
	weaklyCopiedValues := namesOfWeaklyCopiedProperties collect: [  :propName | otherProperties removeKey: propName ifAbsent: [] ].

	"Now copy all the others."
	otherProperties := otherProperties veryDeepCopyWith: deepCopier.

	"And replace the weak ones."
	namesOfWeaklyCopiedProperties with: weaklyCopiedValues do: [ :name :value | value ifNotNil: [ otherProperties at: name put: value ]].

]

{ #category : #accessing }
MorphExtension >> visible [
	"answer whether the receiver is visible"
	^ visible
]

{ #category : #accessing }
MorphExtension >> visible: newValue [
	visible := newValue
]
