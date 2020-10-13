Class {
	#name : #EToyProjectQueryMorph,
	#superclass : #EToyProjectDetailsMorph,
	#category : #'Etoys-Experimental'
}

{ #category : #'instance creation' }
EToyProjectQueryMorph class >> onServer: aProjectServer [
	"EToyProjectQueryMorph onServer: SuperSwikiServer testOnlySuperSwiki"

	| detailsMorph messageToSendIfValid |

	detailsMorph := self basicNew.

	messageToSendIfValid := MessageSend receiver: detailsMorph selector: #carryOutQuery:onProjectServer: arguments: {nil. aProjectServer}.

	detailsMorph
		project: nil
		actionBlock: messageToSendIfValid;

"***		actionBlock: [ :x | 
			criteria := OrderedCollection new.
			x keysAndValuesDo: [ :k :v |
				(clean := v withBlanksTrimmed convertToEncoding: SuperSwikiServer defaultEncodingName) isEmpty
					ifFalse: [criteria add: k,': *',clean,'*']].
			aProjectServer queryProjectsAndShow: criteria];  ****"

		initialize;
		openCenteredInWorld
]

{ #category : #'as yet unclassified' }
EToyProjectQueryMorph class >> test1: aProject [
"EToyProjectQueryMorph test1: nil"

	

	(self basicNew)
		project: aProject
		actionBlock: [ :x | | criteria | 
			criteria := OrderedCollection new.
			x keysAndValuesDo: [ :k :v | | clean |
				(clean := v withBlanksTrimmed) isEmpty ifFalse: [
					criteria add: k,': *',clean,'*'
				].
			].
			SuperSwikiServer testOnlySuperSwiki queryProjectsAndShow: criteria
		];

		initialize;
		openCenteredInWorld
]

{ #category : #initialization }
EToyProjectQueryMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color
		r: 0.545
		g: 0.47
		b: 0.621
]

{ #category : #'ok button hit' }
EToyProjectQueryMorph >> doOK [
	"User hit the ok button in the project-query dialog."

	| details |
	details := self copyOutDetails.

	self delete.
	actionBlock isMessageSend "new way -- hopefully all cases"
		ifTrue:
			[actionBlock arguments: {details. actionBlock arguments second}.
			actionBlock value]

		ifFalse:  "Old way, with actionBlock actually a block of one argument.  This should no longer occur."
			[actionBlock value: details].
]

{ #category : #'as yet unclassified' }
EToyProjectQueryMorph >> fillInDetails [

	"leave them blank for now"
]

{ #category : #'as yet unclassified' }
EToyProjectQueryMorph >> project: ignored actionBlock: aBlock [

	actionBlock := aBlock.
	projectDetails := Dictionary new.
]

{ #category : #utilities }
EToyProjectQueryMorph >> rebuild [
	"Rebuild the receiver from scratch."

	| toAdd isText |
	self removeAllMorphs.
	self addARow: {
		self lockedString: 'Enter things to search for' translated.
	}.
	self addARow: {
		self lockedString: 'Project Name' translated.
		self inAColumnForText: {self fieldForProjectName}
	}.
	self fieldToDetailsMappings do: [ :each |
		isText := each size < 5 or: [each fifth = #text].
		self addARow: {
			self lockedString: each third translated.
				toAdd := isText
					ifTrue:
						[self genericTextFieldNamed: each first]
					ifFalse:
						[self popUpEntryNamed: each first menuTitle: each third].

				self inAColumnForText: {toAdd height: each fourth}

		}.
	].

	self addARow: {
		self okButton.
		self cancelButton.
	}.
	self fillInDetails.
]
