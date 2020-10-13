Class {
	#name : #PluggableDialogSpec,
	#superclass : #PluggableCompositeSpec,
	#instVars : [
		'title',
		'message',
		'extent',
		'buttons',
		'closeAction',
		'exclusive',
		'autoCancel'
	],
	#category : #'ToolBuilder-Kernel'
}

{ #category : #accessing }
PluggableDialogSpec >> autoCancel [
	"Automatically cancel the dialog if the user clicks outside its bounds."
	
	^ autoCancel
]

{ #category : #accessing }
PluggableDialogSpec >> autoCancel: aBoolean [
	autoCancel := aBoolean.
]

{ #category : #building }
PluggableDialogSpec >> buildWith: builder [
	^builder buildPluggableDialog: self.
]

{ #category : #accessing }
PluggableDialogSpec >> buttons [

	^ buttons
]

{ #category : #accessing }
PluggableDialogSpec >> buttons: anObject [

	buttons := anObject
]

{ #category : #accessing }
PluggableDialogSpec >> closeAction [

	^ closeAction
]

{ #category : #accessing }
PluggableDialogSpec >> closeAction: anObject [

	closeAction := anObject
]

{ #category : #accessing }
PluggableDialogSpec >> exclusive [
	^ exclusive
]

{ #category : #accessing }
PluggableDialogSpec >> exclusive: aBoolean [
	exclusive := aBoolean.
]

{ #category : #accessing }
PluggableDialogSpec >> extent [

	^ extent
]

{ #category : #accessing }
PluggableDialogSpec >> extent: anObject [

	extent := anObject
]

{ #category : #'layout hints' }
PluggableDialogSpec >> horizontalResizing [
	^ #rigid
]

{ #category : #'window compatibility' }
PluggableDialogSpec >> label [
	^ self title
]

{ #category : #'window compatibility' }
PluggableDialogSpec >> label: stringOrSymbol [
	self title: stringOrSymbol.
]

{ #category : #accessing }
PluggableDialogSpec >> message [

	^ message
]

{ #category : #accessing }
PluggableDialogSpec >> message: anObject [

	message := anObject
]

{ #category : #accessing }
PluggableDialogSpec >> title [

	^ title
]

{ #category : #accessing }
PluggableDialogSpec >> title: anObject [

	title := anObject
]

{ #category : #'layout hints' }
PluggableDialogSpec >> verticalResizing [
	^ #rigid
]
