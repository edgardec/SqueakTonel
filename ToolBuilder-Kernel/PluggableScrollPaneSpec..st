Class {
	#name : #PluggableScrollPaneSpec,
	#superclass : #PluggableCompositeSpec,
	#instVars : [
		'morph',
		'morphClass',
		'borderWidth',
		'vScrollBarPolicy',
		'hScrollBarPolicy'
	],
	#category : #'ToolBuilder-Kernel'
}

{ #category : #accessing }
PluggableScrollPaneSpec >> borderWidth [

	^ borderWidth
]

{ #category : #accessing }
PluggableScrollPaneSpec >> borderWidth: anObject [

	borderWidth := anObject
]

{ #category : #building }
PluggableScrollPaneSpec >> buildWith: builder [

	^ builder buildPluggableScrollPane: self
]

{ #category : #accessing }
PluggableScrollPaneSpec >> hScrollBarPolicy [

	^ hScrollBarPolicy
]

{ #category : #accessing }
PluggableScrollPaneSpec >> hScrollBarPolicy: anObject [
	"#always, #never, #whenNeeded"

	hScrollBarPolicy := anObject
]

{ #category : #accessing }
PluggableScrollPaneSpec >> morph [

	^ morph
]

{ #category : #accessing }
PluggableScrollPaneSpec >> morph: anObject [

	morph := anObject
]

{ #category : #accessing }
PluggableScrollPaneSpec >> morphClass [

	^ morphClass
]

{ #category : #accessing }
PluggableScrollPaneSpec >> morphClass: anObject [

	morphClass := anObject
]

{ #category : #accessing }
PluggableScrollPaneSpec >> vScrollBarPolicy [

	^ vScrollBarPolicy
]

{ #category : #accessing }
PluggableScrollPaneSpec >> vScrollBarPolicy: anObject [
	"#always, #never, #whenNeeded"
	
	vScrollBarPolicy := anObject
]
