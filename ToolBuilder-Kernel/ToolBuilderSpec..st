"
I am an abstract widget specification. I can be rendered using many different UI frameworks.
"
Class {
	#name : #ToolBuilderSpec,
	#superclass : #Object,
	#instVars : [
		'name',
		'help'
	],
	#category : #'ToolBuilder-Kernel'
}

{ #category : #building }
ToolBuilderSpec >> buildWith: aBuilder [
	^self subclassResponsibility
]

{ #category : #accessing }
ToolBuilderSpec >> help [
	"Answer the message to get the help texts of this element."
	^ help
]

{ #category : #accessing }
ToolBuilderSpec >> help: aSymbol [ 
	"Indicate the message to retrieve the help texts of this element."
	help := aSymbol
]

{ #category : #accessing }
ToolBuilderSpec >> name [
	^ name
]

{ #category : #accessing }
ToolBuilderSpec >> name: anObject [
	name := anObject
]
