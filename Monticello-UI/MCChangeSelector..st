Class {
	#name : #MCChangeSelector,
	#superclass : #MCPatchBrowser,
	#instVars : [
		'kept'
	],
	#category : #'Monticello-UI'
}

{ #category : #ui }
MCChangeSelector >> buttonSpecs [
	^ #((Select select 'Select these changes')
		 (Cancel cancel 'Cancel the operation')
		)
]

{ #category : #actions }
MCChangeSelector >> cancel [
	self answer: nil
]

{ #category : #ui }
MCChangeSelector >> defaultLabel [
	^ 'Change Selector'
]

{ #category : #'private-ui' }
MCChangeSelector >> innerButtonRow [
	^ self buttonRow: self innerButtonSpecs
]

{ #category : #'private-ui' }
MCChangeSelector >> innerButtonSpecs [
	^
		#(('Select All' selectAll 'select all changes')
		  ('Select None' selectNone 'select no changes'))
]

{ #category : #accessing }
MCChangeSelector >> kept [
	^ kept ifNil: [kept := Set new]
]

{ #category : #actions }
MCChangeSelector >> listSelectionAt: aNumber [
	^ self kept includes: (self items at: aNumber)
]

{ #category : #actions }
MCChangeSelector >> listSelectionAt: aNumber put: aBoolean [
	| item |
	item := self items at: aNumber.
	aBoolean
		ifTrue: [self kept add: item ]
		ifFalse: [self kept remove: item ifAbsent: []]
]

{ #category : #actions }
MCChangeSelector >> select [
	self answer: (MCPatch operations: kept)
]

{ #category : #actions }
MCChangeSelector >> selectAll [
	kept addAll: self items.
	self changed: #list
]

{ #category : #actions }
MCChangeSelector >> selectNone [
	kept := Set new.
	self changed: #list
]

{ #category : #ui }
MCChangeSelector >> widgetSpecs [
	Preferences annotationPanes ifFalse: [ ^#(
		((buttonRow) (0 0 1 0) (0 0 0 defaultButtonPaneHeight))
		((multiListMorph:selection:listSelection:menu: list selection listSelectionAt: methodListMenu:) (0 0 1 0.4) (0 defaultButtonPaneHeight 0 0))
		((innerButtonRow) (0 0.4 1 0.4) (0 0 0 defaultButtonPaneHeight))
		((textMorph: text) (0 0.4 1 1) (0 defaultButtonPaneHeight 0 0))
		)].

	^ {
		#((buttonRow) (0 0 1 0) (0 0 0 defaultButtonPaneHeight)).
		#((multiListMorph:selection:listSelection:menu: list selection listSelectionAt: methodListMenu:) (0 0 1 0.4) (0 defaultButtonPaneHeight 0 0)).
		#((innerButtonRow) (0 0.4 1 0.4) (0 0 0 defaultButtonPaneHeight)).
		{ #(textMorph: annotations). #(0 0.4 1 0.4). { 0. self defaultButtonPaneHeight. 0. self defaultButtonPaneHeight+self defaultAnnotationPaneHeight. }}.
		{ #(textMorph: text). #(0 0.4 1 1). { 0. self defaultButtonPaneHeight+self defaultAnnotationPaneHeight. 0. 0.}}
	}
]
