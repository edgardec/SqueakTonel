"
An instance of ProtocolBrowser shows the methods a class understands--inherited or implemented at this level--as a ""flattened"" list.
"
Class {
	#name : #ProtocolBrowser,
	#superclass : #MessageSet,
	#instVars : [
		'selectedClass',
		'selectedSelector'
	],
	#classVars : [
		'TextMenu'
	],
	#category : #'Protocols-Tools'
}

{ #category : #'instance creation' }
ProtocolBrowser class >> openFullProtocolForClass: aClass [ 
	"Create and schedule a browser for the entire protocol of the class."
	"ProtocolBrowser openFullProtocolForClass: ProtocolBrowser."
	| aPBrowser label |
	aPBrowser := ProtocolBrowser new on: aClass.
	label := 'Entire protocol of: ', aClass name.
	self open: aPBrowser name: label
]

{ #category : #'instance creation' }
ProtocolBrowser class >> openSubProtocolForClass: aClass [ 
	"Create and schedule a browser for the entire protocol of the class."
	"ProtocolBrowser openSubProtocolForClass: ProtocolBrowser."
	| aPBrowser label |
	aPBrowser := ProtocolBrowser new onSubProtocolOf: aClass.
	label := 'Sub-protocol of: ', aClass name.
	self open: aPBrowser name: label
]

{ #category : #utilities }
ProtocolBrowser class >> parse: aStringOrText toClassAndSelector: csBlock [
	"Decode strings of the form    <selectorName> (<className> [class])"
	| string i classAndSelString|
	aStringOrText ifNil: [^ csBlock value: nil value: nil].
	string := aStringOrText asString.
	i := string indexOf: $(.
	"Rearrange to  <className> [class] <selectorName> , and use MessageSet"
	classAndSelString := (string copyFrom: i + 1 to: string size - 1) , ' ' ,
						(string copyFrom: 1 to: i - 1) withoutTrailingBlanks.
	super parse: classAndSelString toClassAndSelector: csBlock.
]

{ #category : #accessing }
ProtocolBrowser >> getList [
	"Answer the receiver's message list."
	^ messageList
]

{ #category : #accessing }
ProtocolBrowser >> growable [
	"Answer whether the receiver is subject to manual additions and deletions"

	^ false
]

{ #category : #private }
ProtocolBrowser >> initListFrom: selectorCollection highlighting: aClass [ 
	"Make up the messageList with items from aClass in boldface."
	messageList := OrderedCollection new.
	selectorCollection do: [ :selector |  
		| defClass item |
		defClass := aClass whichClassIncludesSelector: selector.
		item := selector, '     (' , defClass name , ')'.
		defClass == aClass ifTrue: [item := item asText allBold].
		messageList add: (
			MethodReference new
				setClass: defClass 
				methodSymbol: selector 
				stringVersion: item
		)
	].
	selectedClass := aClass.
]

{ #category : #accessing }
ProtocolBrowser >> list [
	"Answer the receiver's message list."
	^ messageList
]

{ #category : #private }
ProtocolBrowser >> on: aClass [ 
	"Initialize with the entire protocol for the class, aClass."
	self initListFrom: aClass allSelectors sorted
		highlighting: aClass
]

{ #category : #private }
ProtocolBrowser >> onSubProtocolOf: aClass [ 
	"Initialize with the entire protocol for the class, aClass,
		but excluding those inherited from Object."
	| selectors |
	selectors := Set new.
	aClass withAllSuperclasses do:
		[:each | (each == Object or: [each == ProtoObject]) 
			ifFalse: [selectors addAll: each selectors]].
	self initListFrom: selectors sorted
		highlighting: aClass
]

{ #category : #'class list' }
ProtocolBrowser >> selectedClassOrMetaClass [
	^selectedClass
]

{ #category : #accessing }
ProtocolBrowser >> selector [
	"Answer the receiver's selected selector."
	^ selectedSelector
]

{ #category : #accessing }
ProtocolBrowser >> selector: aString [
	"Set the currently selected message selector to be aString."
	selectedSelector := aString.
	self changed: #selector
]

{ #category : #accessing }
ProtocolBrowser >> setSelector: aString [
	"Set the currently selected message selector to be aString."
	selectedSelector := aString
]
