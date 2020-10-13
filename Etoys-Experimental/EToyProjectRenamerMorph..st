Class {
	#name : #EToyProjectRenamerMorph,
	#superclass : #EToyGenericDialogMorph,
	#instVars : [
		'actionBlock',
		'theProject'
	],
	#category : #'Etoys-Experimental'
}

{ #category : #'as yet unclassified' }
EToyProjectRenamerMorph class >> validate: aProject andDo: aBlock [

	(self new)
		project: aProject actionBlock: aBlock;
		openCenteredInWorld
]

{ #category : #'as yet unclassified' }
EToyProjectRenamerMorph >> buttonColor [

	^color darker
]

{ #category : #'as yet unclassified' }
EToyProjectRenamerMorph >> buttonNamed: aString action: aSymbol color: aColor help: helpString [

	| f col |
	f := SimpleButtonMorph new
		target: self;
		label: aString translated font: self myFont;
		color: aColor;
		borderColor: aColor muchDarker;
		actionSelector: aSymbol;
		setBalloonText: helpString translated;
		hResizing: #spaceFill.
	col := (self inAColumn: {f}) hResizing: #spaceFill.
	^col
]

{ #category : #'as yet unclassified' }
EToyProjectRenamerMorph >> cancelButton [
	^ self
		buttonNamed: 'Cancel'
		action: #doCancel
		color: Color lightRed
		help: 'Cancel this Publish operation.' translated
]

{ #category : #initialization }
EToyProjectRenamerMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ (Color r: 1 g: 0.85 b: 0.975)
]

{ #category : #'as yet unclassified' }
EToyProjectRenamerMorph >> doCancel [

	self delete.
]

{ #category : #'ok button pressed' }
EToyProjectRenamerMorph >> doOK [
	"The user hit the ok button in the renamer dialog box; carry out the rename."

	| aName |
	self validateTheProjectName ifFalse: [^self].
	aName := (namedFields at: 'projectname') contents string withBlanksTrimmed.
	self delete.
	actionBlock isMessageSend
		ifTrue:
			[actionBlock arguments: (Array with: aName).
			actionBlock value]
		ifFalse:
			[actionBlock value: aName]
]

{ #category : #'as yet unclassified' }
EToyProjectRenamerMorph >> fieldForProjectName [

	| tm |

	tm := self genericTextFieldNamed: 'projectname'.
	tm crAction: (MessageSend receiver: self selector: #doOK).
	tm setBalloonText: 'Pick a name 24 characters or less and avoid the following characters:

 : < > | / \ ? * " .' translated.
	^tm
	

]

{ #category : #initialization }
EToyProjectRenamerMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	self vResizing: #shrinkWrap;
	  hResizing: #shrinkWrap;
	  layoutInset: 3;
	  cellInset: 3;
	  useRoundedCornersInEtoys;
	  rebuild
]

{ #category : #'as yet unclassified' }
EToyProjectRenamerMorph >> okButton [
	^ self
		buttonNamed: 'OK'
		action: #doOK
		color: Color lightGreen
		help: 'Change my name and continue publishing.' translated
]

{ #category : #'as yet unclassified' }
EToyProjectRenamerMorph >> project: aProject actionBlock: aBlock [

	theProject := aProject.
	actionBlock := aBlock.
	(namedFields at: 'projectname') contentsWrapped: theProject name.
]

{ #category : #'as yet unclassified' }
EToyProjectRenamerMorph >> rebuild [

	self removeAllMorphs.
	self addARow: {
		self lockedString: 'Please name this project'.
	}.
	self addARow: {
		self inAColumnForText: {self fieldForProjectName}
	}.
	self addARow: {
		self okButton.
		self cancelButton.
	}.

]

{ #category : #'as yet unclassified' }
EToyProjectRenamerMorph >> validateTheProjectName [

	| proposed |

	proposed := (namedFields at: 'projectname') contents string withBlanksTrimmed.
	proposed isEmpty ifTrue: [
		self inform: 'I do need a name for the project' translated.
		^false
	].
	proposed size > 24 ifTrue: [
		self inform: 'Please make the name 24 characters or less' translated.
		^false
	].
	(Project isBadNameForStoring: proposed) ifTrue: [
		self inform: 'Please remove any funny characters from the name' translated.
		^false
	].
	proposed = theProject name ifTrue: [^true].
	(ChangesOrganizer changeSetNamed: proposed) ifNotNil: [
		UIManager default inform: 'Sorry that name is already used' translated.
		^false
	].
	^true
]
