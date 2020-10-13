"
This class presents a view of a two change sets at once, and supports copying changes between change sets.

"
Class {
	#name : #DualChangeSorter,
	#superclass : #Model,
	#instVars : [
		'leftCngSorter',
		'rightCngSorter'
	],
	#category : #'Tools-Changes'
}

{ #category : #opening }
DualChangeSorter class >> open [
	"Open a new instance of the receiver's class"

	self new open
]

{ #category : #opening }
DualChangeSorter class >> prototypicalToolWindow [
	"Answer an example of myself seen in a tool window, for the benefit of parts-launching tools"

 	^ ToolBuilder build: self new
]

{ #category : #'class initialization' }
DualChangeSorter class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry"
	self environment
		at: #Flaps
		ifPresent: [:cl | cl registerQuad: {#DualChangeSorter,		#prototypicalToolWindow.	'Change Sorter' translatedNoop.		'Shows two change sets side by side' translatedNoop}
						forFlapNamed: 'Tools']
]

{ #category : #'class initialization' }
DualChangeSorter class >> unload [
	"Unload the receiver from global registries"

	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self] 
]

{ #category : #toolbuilder }
DualChangeSorter >> buildWith: builder [
	| windowSpec window |
	leftCngSorter := ChangeSorter new myChangeSet: ChangeSet current.
	leftCngSorter parent: self.
	rightCngSorter := ChangeSorter new myChangeSet: 
			ChangeSet secondaryChangeSet.
	rightCngSorter parent: self.

	windowSpec := builder pluggableWindowSpec new.
	windowSpec model: self.
	windowSpec label: 'Change Sorter'.
	windowSpec children: OrderedCollection new.
	windowSpec label: #labelString.
	leftCngSorter buildWith: builder in: windowSpec rect: (0@0 extent: 0.5@1).
	rightCngSorter buildWith: builder in: windowSpec rect: (0.5@0 extent: 0.5@1).
	window := builder build: windowSpec.
	leftCngSorter addDependent: window.		"so it will get changed: #relabel"
	rightCngSorter addDependent: window.	"so it will get changed: #relabel"
	^window
]

{ #category : #'user interface' }
DualChangeSorter >> defaultWindowColor [
	^ (Color r: 0.719 g: 0.9 b: 0.9)
]

{ #category : #other }
DualChangeSorter >> isLeftSide: theOne [
	"Which side am I?"
	^ theOne == leftCngSorter
]

{ #category : #other }
DualChangeSorter >> labelString [
	"The window label"
	^'Changes go to "', ChangeSet current name,  '"'.
]

{ #category : #other }
DualChangeSorter >> modelWakeUp [
	"A window with me as model is being entered.  Make sure I am up-to-date with the changeSets."

	"Dumb way"
	leftCngSorter canDiscardEdits 
		ifTrue: [leftCngSorter update]	"does both"
		ifFalse: [rightCngSorter update].

]

{ #category : #initialization }
DualChangeSorter >> okToChange [
	^ leftCngSorter okToChange & rightCngSorter okToChange
]

{ #category : #initialization }
DualChangeSorter >> open [
	^ToolBuilder open: self
]

{ #category : #other }
DualChangeSorter >> other: theOne [
	"Return the other side's ChangeSorter"
	^ theOne == leftCngSorter
		ifTrue: [rightCngSorter]
		ifFalse: [leftCngSorter]
]

{ #category : #initialization }
DualChangeSorter >> release [
	leftCngSorter release.
	rightCngSorter release.
]
