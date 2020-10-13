"
I create a set of ""stub"" widgets that are useful for testing. Instead of drawing themselves in some GUI, they simulate graphical widgets for testing purposes. Through my widgets, unit tests can simulate user actions and make assertions about the state of the display.

See TestRunnerPlusTest for examples.
"
Class {
	#name : #SUnitToolBuilder,
	#superclass : #ToolBuilder,
	#instVars : [
		'widgets'
	],
	#category : #'ToolBuilder-SUnit'
}

{ #category : #building }
SUnitToolBuilder >> buildPluggableButton: aSpec [
	| w |
	w := ButtonStub fromSpec: aSpec.
	self register: w id: aSpec name.
	^w
]

{ #category : #building }
SUnitToolBuilder >> buildPluggableList: aSpec [ 
	| w |
	w := ListStub fromSpec: aSpec.
	self register: w id: aSpec name.
	^w
]

{ #category : #building }
SUnitToolBuilder >> buildPluggableMenu: aSpec [ 
	^ MenuStub fromSpec: aSpec
]

{ #category : #building }
SUnitToolBuilder >> buildPluggablePanel: aSpec [
	| w |
	w := PanelStub fromSpec: aSpec.
	self register: w id: aSpec name.
	^w
]

{ #category : #building }
SUnitToolBuilder >> buildPluggableText: aSpec [ 
	| w |
	w := TextStub fromSpec: aSpec.
	self register: w id: aSpec name.
	^w
]

{ #category : #building }
SUnitToolBuilder >> buildPluggableTree: aSpec [
	| w |
	w := TreeStub fromSpec: aSpec.
	self register: w id: aSpec name.
	^w
]

{ #category : #building }
SUnitToolBuilder >> buildPluggableWindow: aSpec [
	| window children |
	window := WindowStub fromSpec: aSpec.
	children := aSpec children.
	children isSymbol 
		ifFalse: [window children: (children collect: [:ea | ea buildWith: self])].
	self register: window id: aSpec name.
	^ window
]

{ #category : #opening }
SUnitToolBuilder >> close: aWidget [
	aWidget close
]

{ #category : #opening }
SUnitToolBuilder >> open: anObject [
	^ self build: anObject
]

{ #category : #private }
SUnitToolBuilder >> register: widget id: id [
	id ifNil:[^self].
	widgets ifNil:[widgets := Dictionary new].
	widgets at: id put: widget.
]

{ #category : #private }
SUnitToolBuilder >> widgetAt: id ifAbsent: aBlock [
	widgets ifNil:[^aBlock value].
	^widgets at: id ifAbsent: aBlock
]
