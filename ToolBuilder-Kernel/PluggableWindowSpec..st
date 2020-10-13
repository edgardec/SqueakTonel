"
A common window. Expects to see change/update notifications when the label should change.

Instance variables:
	label	<String|Symbol> The selector under which to retrieve the label or the label directly
	extent	<Point>	The (initial) extent of the window.
	closeAction		<Symbol>	The action to perform when the window is closed.
"
Class {
	#name : #PluggableWindowSpec,
	#superclass : #PluggableCompositeSpec,
	#instVars : [
		'label',
		'extent',
		'closeAction',
		'multiWindowStyle'
	],
	#category : #'ToolBuilder-Kernel'
}

{ #category : #building }
PluggableWindowSpec >> buildWith: builder [
	^builder buildPluggableWindow: self.
]

{ #category : #accessing }
PluggableWindowSpec >> closeAction [
	"Answer the receiver's closeAction"
	^closeAction
]

{ #category : #accessing }
PluggableWindowSpec >> closeAction: aSymbol [
	"Answer the receiver's closeAction"
	closeAction := aSymbol.
]

{ #category : #accessing }
PluggableWindowSpec >> extent [
	"Answer the window's (initial) extent"
	^extent
]

{ #category : #accessing }
PluggableWindowSpec >> extent: aPoint [
	"Indicate the window's (initial) extent"
	extent := aPoint
]

{ #category : #accessing }
PluggableWindowSpec >> label [
	"Answer the selector for retrieving the window's label"
	^label
]

{ #category : #accessing }
PluggableWindowSpec >> label: aString [
	"Indicate the selector for retrieving the window's label"
	label := aString
]

{ #category : #accessing }
PluggableWindowSpec >> multiWindowStyle [
	"Answer the value of multiWindowStyle, a Symbol or nil"
	^multiWindowStyle
]

{ #category : #accessing }
PluggableWindowSpec >> multiWindowStyle: aSymbol [
	"Set the value of multiWindowStyle, one of #labelButton or #tabbed"

	multiWindowStyle := aSymbol
]
