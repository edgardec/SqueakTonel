"
Adds inst vars layoutPolicy and layoutParameters to vanilla MorphExtension, for greater speed and to reduce the need for use of the otherProperties dictionary.
"
Class {
	#name : #MorphExtensionPlus,
	#superclass : #MorphExtension,
	#instVars : [
		'layoutProperties',
		'layoutPolicy'
	],
	#category : #'Etoys-Support'
}

{ #category : #testing }
MorphExtensionPlus >> isDefault [

	^ super isDefault and: [layoutPolicy isNil and: [layoutProperties isNil]].

]

{ #category : #accessing }
MorphExtensionPlus >> layoutPolicy [
	"Answer the layout policy."

	^ layoutPolicy
]

{ #category : #accessing }
MorphExtensionPlus >> layoutPolicy: p [
	"Set the layoutPolicy"

	layoutPolicy := p
]

{ #category : #accessing }
MorphExtensionPlus >> layoutProperties [
	"Answer the layout properties."

	^ layoutProperties
]

{ #category : #accessing }
MorphExtensionPlus >> layoutProperties: p [
	"Set the layoutProperties"

	layoutProperties := p
]

{ #category : #accessing }
MorphExtensionPlus >> otherProperties: p [
	"Set the receiver's otherProperties.  If the argument provided is empty, put nil in its place."

	otherProperties := p isEmptyOrNil ifTrue: [nil] ifFalse: [p]
]

{ #category : #printing }
MorphExtensionPlus >> printOn: aStream [ 
	"Append to the argument, aStream, a sequence of characters that 
	identifies the receiver." 

	super printOn: aStream.
	
	layoutPolicy ifNotNil:
		[aStream nextPutAll: ' [layoutPolicy - ', layoutPolicy class name, '] '].
	layoutProperties ifNotNil:
		[aStream nextPutAll: ' [layoutProperties] ']
	
]

{ #category : #'accessing - other properties' }
MorphExtensionPlus >> sortedPropertyNames [
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
	layoutProperties ifNotNil: [props nextPut: #layoutProperties].
	layoutPolicy ifNotNil: [props nextPut: #layoutPolicy].
	self hasOtherProperties 
		ifTrue: [self otherProperties associationsDo: [:a | props nextPut: a key]].
	^props contents sort: [:s1 :s2 | s1 <= s2]
]
