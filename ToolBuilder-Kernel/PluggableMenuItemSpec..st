Class {
	#name : #PluggableMenuItemSpec,
	#superclass : #ToolBuilderSpec,
	#instVars : [
		'label',
		'action',
		'checked',
		'enabled',
		'separator',
		'subMenu',
		'checkable'
	],
	#category : #'ToolBuilder-Kernel'
}

{ #category : #accessing }
PluggableMenuItemSpec >> action [
	"Answer the action associated with the receiver"
	^action
]

{ #category : #accessing }
PluggableMenuItemSpec >> action: aMessageSend [
	"Answer the action associated with the receiver"
	action := aMessageSend
]

{ #category : #initialize }
PluggableMenuItemSpec >> analyzeLabel [
	"For Morphic compatiblity. Some labels include markup such as <on>, <off> etc.
	Analyze the label for these annotations and take appropriate action."
	| marker |
	marker := label copyFrom: 1 to: (label indexOf: $>).
	(marker = '<on>' or:[marker = '<yes>']) ifTrue:[
		checkable := true.
		checked := true.
		label := label copyFrom: marker size+1 to: label size.
	].
	(marker = '<off>' or:[marker = '<no>']) ifTrue:[
		checkable := true.
		checked := false.
		label := label copyFrom: marker size+1 to: label size.
	].

]

{ #category : #accessing }
PluggableMenuItemSpec >> beCheckable [
	checkable := true.
]

{ #category : #building }
PluggableMenuItemSpec >> buildWith: builder [
	^ builder buildPluggableMenuItem: self
]

{ #category : #accessing }
PluggableMenuItemSpec >> checked [
	"Answer whether the receiver is checked"
	^checked ifNil:[false]
]

{ #category : #accessing }
PluggableMenuItemSpec >> checked: aBool [
	"Indicate whether the receiver is checked"
	checked := aBool.
]

{ #category : #accessing }
PluggableMenuItemSpec >> enabled [
	"Answer whether the receiver is enabled"
	^enabled ifNil:[true]
]

{ #category : #accessing }
PluggableMenuItemSpec >> enabled: aBool [
	"Indicate whether the receiver is enabled"
	enabled := aBool
]

{ #category : #initialize }
PluggableMenuItemSpec >> initialize [
	checkable := false.
]

{ #category : #accessing }
PluggableMenuItemSpec >> isCheckable [
	^ checkable
]

{ #category : #accessing }
PluggableMenuItemSpec >> label [
	"Answer the receiver's label"
	^label
]

{ #category : #accessing }
PluggableMenuItemSpec >> label: aString [
	"Set the receiver's label"
	label := aString
]

{ #category : #accessing }
PluggableMenuItemSpec >> separator [
	"Answer whether the receiver should be followed by a separator"
	^separator ifNil:[false]
]

{ #category : #accessing }
PluggableMenuItemSpec >> separator: aBool [
	"Indicate whether the receiver should be followed by a separator"
	separator := aBool.
]

{ #category : #accessing }
PluggableMenuItemSpec >> subMenu [
	"Answer the receiver's subMenu"
	^subMenu
]

{ #category : #accessing }
PluggableMenuItemSpec >> subMenu: aMenuSpec [
	"Answer the receiver's subMenu"
	subMenu := aMenuSpec
]
