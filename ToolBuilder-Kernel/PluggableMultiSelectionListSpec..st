"
PluggableMultiSelectionListSpec specifies a list with multiple selection behavior.

Instance variables:
	getSelectionList	<Symbol>	The message to retrieve the multiple selections.
	setSelectionList	<Symbol>	The message to indicate multiple selections.
"
Class {
	#name : #PluggableMultiSelectionListSpec,
	#superclass : #PluggableListSpec,
	#instVars : [
		'getSelectionList',
		'setSelectionList'
	],
	#category : #'ToolBuilder-Kernel'
}

{ #category : #building }
PluggableMultiSelectionListSpec >> buildWith: builder [
	^builder buildPluggableMultiSelectionList: self
]

{ #category : #accessing }
PluggableMultiSelectionListSpec >> getSelectionList [
	"Answer the message to retrieve the multiple selections"
	^getSelectionList
]

{ #category : #accessing }
PluggableMultiSelectionListSpec >> getSelectionList: aSymbol [
	"Indicate the message to retrieve the multiple selections"
	getSelectionList := aSymbol
]

{ #category : #accessing }
PluggableMultiSelectionListSpec >> setSelectionList [
	"Answer the message to indicate multiple selections"
	^setSelectionList
]

{ #category : #accessing }
PluggableMultiSelectionListSpec >> setSelectionList: aSymbol [
	"Indicate the message to indicate multiple selections"
	setSelectionList := aSymbol
]
