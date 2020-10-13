"
PluggableRadioButton is intended as a HINT for the builder that this widget will be used as radio button. Unless explicitly supported it will be automatically substituted by PluggableButton.
"
Class {
	#name : #PluggableRadioButtonSpec,
	#superclass : #PluggableButtonSpec,
	#category : #'ToolBuilder-Kernel'
}

{ #category : #building }
PluggableRadioButtonSpec >> buildWith: builder [
	^builder buildPluggableRadioButton: self
]
