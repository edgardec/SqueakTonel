"
PluggableActionButtonSpec is intended as a HINT for the builder that this widget will be used as push (action) button. Unless explicitly supported it will be automatically substituted by PluggableButton.
"
Class {
	#name : #PluggableActionButtonSpec,
	#superclass : #PluggableButtonSpec,
	#category : #'ToolBuilder-Kernel'
}

{ #category : #building }
PluggableActionButtonSpec >> buildWith: builder [
	^builder buildPluggableActionButton: self
]
