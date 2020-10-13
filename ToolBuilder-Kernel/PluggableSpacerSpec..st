Class {
	#name : #PluggableSpacerSpec,
	#superclass : #PluggableWidgetSpec,
	#instVars : [
		'extent'
	],
	#category : #'ToolBuilder-Kernel'
}

{ #category : #building }
PluggableSpacerSpec >> buildWith: builder [
	^builder buildPluggableSpacer: self
]

{ #category : #'layout hints' }
PluggableSpacerSpec >> extent [

	^ extent ifNil: [5@5]
]

{ #category : #'layout hints' }
PluggableSpacerSpec >> extent: aPoint [

	extent := aPoint.
]

{ #category : #convenience }
PluggableSpacerSpec >> fillSpaceHorizontally [

	self horizontalResizing: #spaceFill.
]

{ #category : #convenience }
PluggableSpacerSpec >> fillSpaceVertically [

	self verticalResizing: #spaceFill.
]

{ #category : #accessing }
PluggableSpacerSpec >> horizontalResizing [

	^ super horizontalResizing ifNil: [#rigid]
]

{ #category : #accessing }
PluggableSpacerSpec >> verticalResizing [

	^ super verticalResizing ifNil: [#rigid]
]
