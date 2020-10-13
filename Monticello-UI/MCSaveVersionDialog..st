Class {
	#name : #MCSaveVersionDialog,
	#superclass : #MCPatchBrowser,
	#instVars : [
		'name',
		'message',
		'ignore',
		'patchBlock'
	],
	#category : #'Monticello-UI'
}

{ #category : #actions }
MCSaveVersionDialog >> accept [
	| logMessage logMessageWidget |
	self updateItems.
	logMessage := (logMessageWidget := self findTextMorph: #logMessage) text asString.
	(logMessage isEmpty or: [logMessage beginsWith: 'empty log message'])
		ifTrue:
			[(UIManager confirm: 'the log message is empty; are you sure you want to commit') ifFalse: [^ self]]
		ifFalse: [logMessageWidget accept].
	self answer: {
		(self findTextMorph: #versionName) text asString.
		logMessage.
		ignore }
]

{ #category : #ui }
MCSaveVersionDialog >> buttonSpecs [
	^ #((Accept accept 'accept version name and log message')
		(Cancel cancel 'cancel saving version')
		) 
]

{ #category : #actions }
MCSaveVersionDialog >> cancel [
	self answer: nil
]

{ #category : #ui }
MCSaveVersionDialog >> defaultExtent [ 
	^ 700@600
]

{ #category : #ui }
MCSaveVersionDialog >> defaultLabel [
	^ 'Edit Version Name and Message:  ', self name
]

{ #category : #actions }
MCSaveVersionDialog >> ignore [
	^ ignore ifNil: [ignore := Set new]
]

{ #category : #actions }
MCSaveVersionDialog >> ignoreSelection [
	selection
		ifNil: [ignore size = items size
			ifFalse: [ignore addAll: items]
			ifTrue: [ignore removeAll]]
		ifNotNil: [
			ignore remove: selection ifAbsent: [
				ignore add: selection].
			self advanceSelection].
	self changed: #list

]

{ #category : #actions }
MCSaveVersionDialog >> installSelection [
	super installSelection.
	selection ifNotNil: [
		ignore remove: selection ifAbsent: [].
		self changed: #list].


]

{ #category : #accessing }
MCSaveVersionDialog >> list [
  ^ self items collect: [:each |
        (self reverts includes: each)
            ifFalse: [(self ignore includes: each)
                        ifFalse: [each summary]
                        ifTrue: [Text
					string: '( ', each summary, ' )'
					attributes: (self userInterfaceTheme ignoredOperationAttributes ifNil: [{TextColor color: Color gray}])]]
            ifTrue: [Text
			string: '( ', each summary, ' )'
			attributes: (self userInterfaceTheme revertedOperationAttributes ifNil: [ {TextEmphasis struckOut} ]) ]]
]

{ #category : #accessing }
MCSaveVersionDialog >> logMessage [
	^ message ifNil: ['empty log message']
]

{ #category : #accessing }
MCSaveVersionDialog >> logMessage: aString [
	message := aString.
	self changed: #logMessage
]

{ #category : #accessing }
MCSaveVersionDialog >> message [

	^ message
]

{ #category : #accessing }
MCSaveVersionDialog >> message: anObject [

	message := anObject
]

{ #category : #menus }
MCSaveVersionDialog >> methodListKey: aKeystroke from: aListMorph [ 
	aKeystroke caseOf: {
		[$I] -> [self ignoreSelection].
		[$e] -> [self refresh].
	} otherwise: [super methodListKey: aKeystroke from: aListMorph ]
]

{ #category : #menus }
MCSaveVersionDialog >> methodListMenu: aMenu [
	super methodListMenu: aMenu.
	aMenu addList:#(-
		('ignore (I)'	ignoreSelection 'Toggle inclusion of this change when saving.')
		('refresh (e)'	refresh 'Refresh the list of changes to this package.')).
	^aMenu
]

{ #category : #accessing }
MCSaveVersionDialog >> name [
	^ name
]

{ #category : #accessing }
MCSaveVersionDialog >> name: anObject [

	name := anObject
]

{ #category : #actions }
MCSaveVersionDialog >> okToClose [
	^ (self findTextMorph: #logMessage)
		ifNil: [true]
		ifNotNil:
			[:widget | widget canDiscardEdits or: [self confirm: 'Version notes are not saved.
Is it OK to discard those notes?' translated]]
]

{ #category : #accessing }
MCSaveVersionDialog >> patchBlock [

	^ patchBlock
]

{ #category : #accessing }
MCSaveVersionDialog >> patchBlock: anObject [

	patchBlock := anObject.
	self updateItems
]

{ #category : #actions }
MCSaveVersionDialog >> refresh [
	self
		 updateItems ;
		 changed: #list
]

{ #category : #ui }
MCSaveVersionDialog >> representsSameBrowseeAs: anotherModel [ 
	^ self class = anotherModel class
	and: [ self versionName = anotherModel versionName ]
]

{ #category : #ui }
MCSaveVersionDialog >> updateItems [
	" update our items using the patchBlock "
	self patch: patchBlock value
]

{ #category : #accessing }
MCSaveVersionDialog >> versionName [
	^ name
]

{ #category : #accessing }
MCSaveVersionDialog >> versionName: aString [
	name := aString.
	self changed: #versionName
]

{ #category : #ui }
MCSaveVersionDialog >> widgetSpecs [
	^ #(	
		((listMorph:selection:menu:keystroke: list selection methodListMenu: methodListKey:from:) (0 0 0.5 0.6) (0 0 0 -47) )
		((inputMorph: versionName) (0.5 0 1 0) (0 0 0 defaultInputFieldHeight))
		((textMorph: logMessage) (0.5 0 1 0.6) (0 defaultInputFieldHeight 0 -47))
		((buttonRow) (0.5 0.6 1 0.6) (0 -47 0 0))
		((textMorph: annotations) (0 0.6 0.5 0.6) (0 -47 0 0))
		((textMorph: text) (0 0.6 1 1) (0 0 0 0))
		)
]
