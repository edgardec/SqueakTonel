"
A button, both for firing as well as used in radio-button style (e.g., carrying a selection).

Instance variables:
	action	<Symbol>	The action to perform when the button is fired.
	label	<Symbol|String>	The selector for retrieving the button's label or label directly.
	state	<Symbol>	The selector for retrieving the button's selection state.
	enabled	<Symbo>		The selector for retrieving the button's enabled state.
	color	<Symbo>		The selector for retrieving the button color.
	help	<String>		The balloon help for the button.
"
Class {
	#name : #PluggableButtonSpec,
	#superclass : #PluggableWidgetSpec,
	#instVars : [
		'action',
		'label',
		'state',
		'enabled',
		'style',
		'changeLabelWhen'
	],
	#category : #'ToolBuilder-Kernel'
}

{ #category : #accessing }
PluggableButtonSpec >> action [
	"Answer the action to be performed by the receiver"
	^action
]

{ #category : #accessing }
PluggableButtonSpec >> action: aSymbol [
	"Indicate the action to be performed by the receiver"
	action := aSymbol
]

{ #category : #building }
PluggableButtonSpec >> buildWith: builder [
	^builder buildPluggableButton: self
]

{ #category : #accessing }
PluggableButtonSpec >> changeLabelWhen [
	"When handled in in an update: handler, treat this symbol as notification
	that the button label should be updated."
	^changeLabelWhen
]

{ #category : #accessing }
PluggableButtonSpec >> changeLabelWhen: aSymbol [
	"When the button handles aSymbol in its update: handler, treat it
	as notification that the button label should be updated."
	changeLabelWhen := aSymbol
]

{ #category : #accessing }
PluggableButtonSpec >> enabled [
	"Answer the selector for retrieving the button's enablement"
	^enabled ifNil:[true]
]

{ #category : #accessing }
PluggableButtonSpec >> enabled: aSymbol [
	"Indicate the selector for retrieving the button's enablement"
	enabled := aSymbol
]

{ #category : #accessing }
PluggableButtonSpec >> label [
	"Answer the label (or the selector for retrieving the label)"
	^label
]

{ #category : #accessing }
PluggableButtonSpec >> label: aSymbol [
	"Indicate the selector for retrieving the label"
	label := aSymbol.
]

{ #category : #accessing }
PluggableButtonSpec >> state [
	"Answer the selector for retrieving the button's state"
	^state
]

{ #category : #accessing }
PluggableButtonSpec >> state: aSymbol [
	"Indicate the selector for retrieving the button's state"
	state := aSymbol.
]

{ #category : #accessing }
PluggableButtonSpec >> style [
	"Treat aSymbol as a hint to modify the button appearance."
	^style


]

{ #category : #accessing }
PluggableButtonSpec >> style: aSymbol [
	"Use aSymbol as a hint to modify the button appearance."
	style := aSymbol

]
