"
A PluggableTextSpec specifically intended to edit code. Uses Syntax-Highlighting.
"
Class {
	#name : #PluggableCodePaneSpec,
	#superclass : #PluggableTextSpec,
	#category : #'ToolBuilder-Kernel'
}

{ #category : #building }
PluggableCodePaneSpec >> buildWith: builder [
	^builder buildPluggableCodePane: self
]

{ #category : #accessing }
PluggableCodePaneSpec >> font [
	^ font ifNil: [Preferences standardCodeFont]
]

{ #category : #accessing }
PluggableCodePaneSpec >> stylerClass [

	^ super stylerClass ifNil: [Smalltalk classNamed: 'SHTextStylerST80']
]
