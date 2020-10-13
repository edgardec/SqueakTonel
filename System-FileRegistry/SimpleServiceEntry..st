"
I represent a service

provider : the service provider
label : to be display in a menu
selector : to do the service
useLineAfter
stateSelector : a secondary selector (to be able to query state of the provider for example)
description : a description for balloon for example
argumentGetter : a selector to get additional arguments with (if selector requres them)
buttonLabel : a short label

The entire client interface (provided by FileList and other users of the registry)
is this (browse #getArgumentsFrom: and the 
senders of #argumentGetter:):

fullName (returns a String with the full filename)
dirAndFileName (returns {directory. fileName})
readOnlyStream (returns an open read-only stream)

"
Class {
	#name : #SimpleServiceEntry,
	#superclass : #Model,
	#instVars : [
		'provider',
		'label',
		'selector',
		'useLineAfter',
		'stateSelector',
		'description',
		'argumentGetter',
		'buttonLabel'
	],
	#category : #'System-FileRegistry'
}

{ #category : #'instance creation' }
SimpleServiceEntry class >> provider: anObject label: aString selector: aSymbol [

	^self new provider: anObject label: aString selector: aSymbol
]

{ #category : #'instance creation' }
SimpleServiceEntry class >> provider: anObject label: aString selector: aSymbol description: anotherString [

	^self new provider: anObject label: aString selector: aSymbol description: anotherString
]

{ #category : #'instance creation' }
SimpleServiceEntry class >> provider: anObject label: aString selector: aSymbol description: anotherString buttonLabel: aLabel [
	"Answer a new service object with the given initializations.  This variant allows a custom button label to be provided, in order to preserve precious horizontal real-estate in the button pane, while still allowing more descriptive wordings in the popup menu"

	^ self new provider: anObject label: aString selector: aSymbol description: anotherString; buttonLabel: aLabel; yourself
]

{ #category : #'services menu' }
SimpleServiceEntry >> addServiceFor: served toMenu: aMenu [
	aMenu add: self label 
		target: self 
		selector: self requestSelector 
		argument: served.
	self useLineAfter ifTrue: [ aMenu addLine ].
]

{ #category : #accessing }
SimpleServiceEntry >> argumentGetter: aBlock [

	argumentGetter := aBlock
]

{ #category : #toolbuilder }
SimpleServiceEntry >> buildWith: builder in: aModel [
	"Answer a button spec that will trigger the receiver service in aModel"
	| buttonSpec |
	buttonSpec := builder pluggableActionButtonSpec new.
	buttonSpec 
		model: self; 
		label: self buttonLabel;
		help: self description;
		action: (MessageSend receiver: aModel selector: #executeService: argument: self).
	^builder build: buttonSpec
]

{ #category : #accessing }
SimpleServiceEntry >> buttonLabel [
	"Answer the label to be emblazoned on a button representing the service in a file list, for example"

	^ buttonLabel ifNil: [label]
]

{ #category : #accessing }
SimpleServiceEntry >> buttonLabel: aString [ 
	"Set the receiver's buttonLabel, to be used on a button in a 
	tool-pane; this is split out so that a more abbreviated wording 
	can be deployed if desired"
	buttonLabel := aString translated
]

{ #category : #'performing service' }
SimpleServiceEntry >> buttonToTriggerIn: aFileList [
	"Answer a button that will trigger the receiver service in a file list"

	| aButton |
	aButton :=  PluggableButtonMorph
					on: self
					getState: nil
					action: #performServiceFor:.
	aButton 
		arguments: { aFileList }.

	aButton
		color: Color transparent;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		label: self buttonLabel;
		askBeforeChanging: true;
		onColor: Color white offColor: Color white.
		aButton setBalloonText: self description.

	^ aButton
]

{ #category : #accessing }
SimpleServiceEntry >> description [
	"may be used for balloon or other"

	^ description

]

{ #category : #accessing }
SimpleServiceEntry >> description: aString [
	"may be used for balloon or other"

	description := aString

]

{ #category : #accessing }
SimpleServiceEntry >> extraSelector [
	"normally should not be used directly"

	^stateSelector
]

{ #category : #accessing }
SimpleServiceEntry >> extraSelector: aSymbol [

	stateSelector := aSymbol
]

{ #category : #'performing service' }
SimpleServiceEntry >> getArgumentsFrom: aProvider [

	argumentGetter ifNil: [^aProvider fullName].
	^argumentGetter value: aProvider
]

{ #category : #accessing }
SimpleServiceEntry >> label [

	^label
]

{ #category : #extra }
SimpleServiceEntry >> performExtraFor: anObject [
	"carry out the extra service I provide"
	"the stateSelector can be used to ask state of the provider to be reflected in button or other"

	^stateSelector numArgs = 0
		ifTrue: [provider perform: stateSelector]
		ifFalse: [provider perform: stateSelector with: (self getArgumentsFrom: anObject) ]

]

{ #category : #'performing service' }
SimpleServiceEntry >> performServiceFor: anObject [
	"carry out the service I provide"

	^selector numArgs = 0
		ifTrue: [provider perform: selector]
		ifFalse: [
			selector numArgs = 1
				ifTrue: [ provider perform: selector with: (self getArgumentsFrom: anObject) ]
				ifFalse: [ provider perform: selector withArguments: (self getArgumentsFrom: anObject) ]]
]

{ #category : #printing }
SimpleServiceEntry >> printOn: aStream [

	aStream nextPutAll: self class name; nextPutAll: ': ('.
	self provider
		ifNotNil: [ aStream nextPutAll: provider printString].
	aStream nextPutAll: ' --- '. 
	self selector
		ifNotNil: [ aStream nextPutAll: selector asString].
	aStream nextPut: $)


]

{ #category : #accessing }
SimpleServiceEntry >> provider [

	^ provider
]

{ #category : #accessing }
SimpleServiceEntry >> provider: anObject label: aString selector: aSymbol [ 
	"basic initialization message"
	provider := anObject.
	label := aString translated.
	selector := aSymbol.
	stateSelector := #none.
	description := ''
]

{ #category : #'performing service' }
SimpleServiceEntry >> provider: anObject label: aString selector: aSymbol description: anotherString [ 
	"basic initialization message"
	self
		provider: anObject
		label: aString
		selector: aSymbol.
	stateSelector := #none.
	description := anotherString translated
]

{ #category : #extra }
SimpleServiceEntry >> requestExtraSelector [
	"send me this message to ask me to perform secondary service"

	^#performExtraFor:

]

{ #category : #'performing service' }
SimpleServiceEntry >> requestSelector [
	"send me this message to ask me to perform my service"

	^#performServiceFor:

]

{ #category : #accessing }
SimpleServiceEntry >> selector [
	"normally should not be used directly"

	^selector
]

{ #category : #'services menu' }
SimpleServiceEntry >> useLineAfter [

	^useLineAfter == true
]

{ #category : #'services menu' }
SimpleServiceEntry >> useLineAfter: aBoolean [

	useLineAfter := aBoolean

]
