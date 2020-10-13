"
SMObject is the abstract superclass for all objects living in an SMSqueakMap.

It has a unique UUID and a reference to the owning SMSqueakMap.
It has timestamps to record the birthtime and the last modification.
It has basic attributes like name, oneline summary and url.






"
Class {
	#name : #SMObject,
	#superclass : #Object,
	#instVars : [
		'id',
		'map',
		'created',
		'updated',
		'name',
		'summary',
		'url'
	],
	#category : #'SMBase-domain'
}

{ #category : #'instance creation' }
SMObject class >> newIn: aMap [
	"Create a new object in a given map with an UUID to ensure unique identity."

	^(self basicNew) map: aMap id: UUID new
]

{ #category : #comparing }
SMObject >> <= anSMObject [

	^name <= anSMObject name
]

{ #category : #accessing }
SMObject >> asString [
	^ self name
]

{ #category : #accessing }
SMObject >> created [
	^TimeStamp fromSeconds: created
]

{ #category : #accessing }
SMObject >> createdAsSeconds [
	^created
]

{ #category : #deletion }
SMObject >> delete [
	"Delete from map."

	map deleteObject: self
]

{ #category : #printing }
SMObject >> describe: string withBoldLabel: label on: stream [
	"Helper method for doing styled text."

	stream withAttribute: (TextEmphasis bold) do: [ stream nextPutAll: label ].
	stream nextPutAll: string; cr
]

{ #category : #accessing }
SMObject >> id [
	^id
]

{ #category : #accessing }
SMObject >> id: anId [
	id := anId
]

{ #category : #'initialize-release' }
SMObject >> initialize [
	"Initialize the receiver."

	updated := created := TimeStamp current asSeconds.
	name := summary := url := ''.
]

{ #category : #testing }
SMObject >> isAccount [
	^false
]

{ #category : #testing }
SMObject >> isCategory [
	^false
]

{ #category : #testing }
SMObject >> isPackage [
	^false
]

{ #category : #testing }
SMObject >> isPackageRelease [
	^false
]

{ #category : #testing }
SMObject >> isResource [
	^false
]

{ #category : #accessing }
SMObject >> map [
	^map
]

{ #category : #accessing }
SMObject >> map: aMap [
	map := aMap
]

{ #category : #'initialize-release' }
SMObject >> map: aMap id: anId [
	"Initialize the receiver."

	self initialize.
	map := aMap.
	id := anId
]

{ #category : #accessing }
SMObject >> name [
	^name
]

{ #category : #accessing }
SMObject >> name: aName [
	name := aName
]

{ #category : #printing }
SMObject >> printName [
	"Return a String identifying receiver without a context.
	Default is name."

	^self name
]

{ #category : #printing }
SMObject >> printOn: aStream [

	aStream nextPutAll: self class name, '[', name, ']'
]

{ #category : #updating }
SMObject >> stampAsUpdated [
	"This method should be called whenever the object is modified."

	updated := TimeStamp current asSeconds
]

{ #category : #accessing }
SMObject >> summary [
	^summary
]

{ #category : #accessing }
SMObject >> summary: aString [
	summary := aString
]

{ #category : #printing }
SMObject >> type [

	^'Object'
]

{ #category : #accessing }
SMObject >> updated [
	^TimeStamp fromSeconds: updated
]

{ #category : #accessing }
SMObject >> updatedAsSeconds [
	^updated
]

{ #category : #accessing }
SMObject >> url [
	^url
]

{ #category : #accessing }
SMObject >> url: aString [
	url := aString
]

{ #category : #accessing }
SMObject >> userInterface [
	"Return the object that we use for interacting with the user."

	^SMUtilities
]

{ #category : #private }
SMObject >> withId: aUUIDString in: aCollection [
	"Return the object with the corresponding id
	and nil if not found."

	| uuid |
	uuid := UUID fromString: aUUIDString.
	^aCollection detect: [:o | o id = uuid ] ifNone: [nil]
]
