Class {
	#name : #PluggableAlternateMultiSelectionListSpec,
	#superclass : #PluggableMultiSelectionListSpec,
	#category : #'ToolBuilder-Kernel'
}

{ #category : #building }
PluggableAlternateMultiSelectionListSpec >> buildWith: builder [
	^ builder buildPluggableAlternateMultiSelectionList: self
]
