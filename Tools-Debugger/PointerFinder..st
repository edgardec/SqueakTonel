"
I can search for reasons why a certain object isn't garbage collected.  I'm a quick port of a VisualWorks program written by Hans-Martin Mosner.  Call me as shown below.  I'll search for a path from a global variable to the given object, presenting it in a small morphic UI.

Examples:
	PointerFinder on: self currentHand
	PointerFinder on: StandardSystemView someInstance

Now, let's see why this image contains more HandMorphs as expected...

HandMorph allInstancesDo: [:e | PointerFinder on: e]
"
Class {
	#name : #PointerFinder,
	#superclass : #Model,
	#instVars : [
		'goal',
		'parents',
		'toDo',
		'toDoNext',
		'hasGemStone',
		'pointerList',
		'objectList',
		'parentsSize',
		'todoSize',
		'depth',
		'pointerListIndex',
		'excludedObjects'
	],
	#category : #'Tools-Debugger'
}

{ #category : #'instance creation' }
PointerFinder class >> on: anObject [ 
	^ self
		on: anObject
		except: Array empty
]

{ #category : #'instance creation' }
PointerFinder class >> on: anObject except: aCollection [
	^ self new 
		goal: anObject;
		excludedObjects: aCollection;
		search;
		open
]

{ #category : #utilities }
PointerFinder class >> pointersTo: anObject [
	"Find all occurrences in the system of pointers to the argument anObject."
	"(PointerFinder pointersTo: Browser) inspect."

	^ self pointersTo: anObject except: #()

]

{ #category : #utilities }
PointerFinder class >> pointersTo: anObject except: objectsToExclude [
	"Find all occurrences in the system of pointers to the argument anObject. 
	Remove objects in the exclusion list from the results."
	
	^ anObject inboundPointersExcluding: objectsToExclude
]

{ #category : #utilities }
PointerFinder class >> pointersToItem: index of: anArray [
	"Find all occurrences in the system of pointers to the given element of the given array. 
	This is useful for tracing up a pointer chain from an inspector on the results of a previous 	call of pointersTo:. To find out who points to the second element of the results, one would 	evaluate:

		PointerFinder pointersToItem: 2 of: self

	in the inspector."

	^ self pointersTo: (anArray at: index) except: (Array with: anArray)
]

{ #category : #'pointer-list' }
PointerFinder >> arrowKey: key from: aController [
	key = $i ifTrue: [^ self inspectObject].
	^ super arrowKey: key from: aController
]

{ #category : #'initialize-release' }
PointerFinder >> buildList [
	| list obj parent object key |
	list := OrderedCollection new.
	obj := goal.
	
	[list addFirst: obj.
	obj := parents at: obj ifAbsent: [].
	obj == nil] whileFalse.
	list removeFirst.
	parent := Smalltalk.
	objectList := OrderedCollection new.
	pointerList := OrderedCollection new.
	[list isEmpty]
		whileFalse: 
			[object := list removeFirst.
			key := nil.
			(parent isKindOf: Dictionary)
				ifTrue: [list size >= 2
						ifTrue: 
							[key := parent keyAtValue: list second ifAbsent: [].
							key == nil
								ifFalse: 
									[object := list removeFirst; removeFirst.
									pointerList add: key printString , ' -> ' , object class name]]].
			key == nil
				ifTrue: 
					[parent class == object ifTrue: [key := 'CLASS'].
					key == nil ifTrue: [1 to: parent class instSize do: [:i | key == nil ifTrue: [(parent instVarAt: i)
									== object ifTrue: [key := parent class instVarNameForIndex: i]]]].
					key == nil ifTrue: [parent isCompiledCode ifTrue: [key := 'literals?']].
					key == nil ifTrue: [1 to: parent basicSize do: [:i | key == nil ifTrue: [(parent basicAt: i)
									== object ifTrue: [key := i printString]]]].
					key == nil ifTrue: [(parent isMorph and: [object isKindOf: Array]) ifTrue: [key := 'submorphs?']].
					key == nil ifTrue: [key := '???'].
					pointerList add: key , ': ' , object class name, (object isMorph ifTrue: [' (', object identityHash asString, ')'] ifFalse: [ String empty ]) ].
			objectList add: object.
			parent := object]
]

{ #category : #'ui-building' }
PointerFinder >> buildWith: builder [
	| listSpec windowSpec |
	windowSpec := builder pluggableWindowSpec new
		model: self;
		label: 'Pointer Finder'.

	listSpec := builder pluggableListSpec new
		model: self;
		frame: (0@0 corner: 1@1);
		list: #pointerList;
		getIndex: #pointerListIndex;
		setIndex: #pointerListIndex:;
		menu: #menu:shifted:;
		keyPress: #arrowKey:from:;
		doubleClick: #inspectObject;
		yourself.

	windowSpec children: {listSpec}.
		
	^ builder build: windowSpec.
]

{ #category : #accessing }
PointerFinder >> excludedObjects [
	^ excludedObjects
]

{ #category : #'initialize-release' }
PointerFinder >> excludedObjects: aCollection [ 
	excludedObjects := aCollection asIdentitySet
]

{ #category : #private }
PointerFinder >> follow: anObject from: parentObject [ 
	anObject == goal ifTrue:
		[ parents
			at: anObject
			put: parentObject.
		^ true ].
	anObject shouldFollowOutboundPointers ifFalse: [ ^ false ].
	((parents includesKey: anObject) or: [ anObject class = self class ]) ifTrue: [ ^ false ].
	parents
		at: anObject
		put: parentObject.
	toDoNext add: anObject.
	^ false
]

{ #category : #private }
PointerFinder >> followObject: anObject [

	(self excludedObjects includes: anObject)
		ifTrue: [^ false].
	anObject outboundPointersDo: [:ea |
		(self follow: ea from: anObject)
			ifTrue: [^ true]].
	^ false
]

{ #category : #'initialize-release' }
PointerFinder >> goal: anObject [
	goal := anObject
]

{ #category : #'ui-building' }
PointerFinder >> initialExtent [
	^ 300 @ 300
]

{ #category : #'initialize-release' }
PointerFinder >> initialize [
	parents := IdentityDictionary new: 20000.
	parents at: Smalltalk put: nil.
	parents at: Processor put: nil.
	parents at: self put: nil.

	toDo := OrderedCollection new: 5000.
	toDo add: Smalltalk.
	toDoNext := OrderedCollection new: 5000.

	excludedObjects := IdentitySet new
]

{ #category : #'pointer-list' }
PointerFinder >> inspectObject [
	pointerListIndex = 0 ifTrue: [^ Beeper beep].
	(objectList at: pointerListIndex) inspect
]

{ #category : #'pointer-list' }
PointerFinder >> menu: aMenu shifted: shifted [

	^ self menu: aMenu for: #(pointerListMenu pointerListMenuShifted:) shifted: shifted
]

{ #category : #'ui-building' }
PointerFinder >> open [
	^ ToolBuilder open: self.
]

{ #category : #'morphic ui' }
PointerFinder >> openInMorphic [
	| window list |
	window := (SystemWindow labelled: 'Pointer Finder')
		model: self.
	list := PluggableListMorph new
		doubleClickSelector: #inspectObject;

		on: self
		list: #pointerList
		selected: #pointerListIndex
		changeSelected: #pointerListIndex:
		menu: #menu:shifted:
		keystroke: #arrowKey:from:.
		"For doubleClick to work best disable autoDeselect"
		list autoDeselect: false.
	window addMorph: list frame: (0@0 extent: 1@1).
	list color: Color lightMagenta.
	window openInWorld
]

{ #category : #'message handling' }
PointerFinder >> perform: selector orSendTo: otherTarget [
	selector == #inspectObject ifTrue: [^ self inspectObject].
	selector == #searchAgain ifTrue: [^ self searchAgain].
	^ super perform: selector orSendTo: otherTarget
]

{ #category : #'pointer-list' }
PointerFinder >> pointerList [
	^ pointerList asArray
]

{ #category : #'pointer-list' }
PointerFinder >> pointerListIndex [
	^ pointerListIndex ifNil: [0]
]

{ #category : #'pointer-list' }
PointerFinder >> pointerListIndex: anInteger [
	pointerListIndex := anInteger.
	self changed: #pointerListIndex
]

{ #category : #'pointer-list' }
PointerFinder >> pointerListMenu: aMenu [

	<pointerListMenu>	
	^ aMenu
		addList: #(
			('Inspect (i)' #inspectObject 'Live long and prosper!')
			-
			('Search again' #searchAgain 'Search again\for the same object' withCRs));
		yourself.
]

{ #category : #application }
PointerFinder >> search [
	Smalltalk garbageCollect.

	self initialize.
	
	Cursor wait showWhile: [
		[[toDo isEmpty or: [self followObject: toDo removeFirst]] whileFalse.
		toDo isEmpty and: [toDoNext isEmpty not]]
			whileTrue: 
				[toDo := toDoNext.
				toDoNext := OrderedCollection new: 5000]].

	self buildList
]

{ #category : #'pointer-list' }
PointerFinder >> searchAgain [
	self pointerListIndex: 0.
	self search.
	self changed: #pointerList
]

{ #category : #application }
PointerFinder >> update [
	('done: ' , parents size asString , ' todo: ' , toDo size asString , '   ') displayAt: 0@0
]
