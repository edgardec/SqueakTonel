"
A panel with a (possibly changing) set of child elements. Expects to see change/update notifications when the childrens change.
"
Class {
	#name : #PluggablePanelSpec,
	#superclass : #PluggableCompositeSpec,
	#category : #'ToolBuilder-Kernel'
}

{ #category : #building }
PluggablePanelSpec >> buildWith: builder [
	^builder buildPluggablePanel: self.
]
