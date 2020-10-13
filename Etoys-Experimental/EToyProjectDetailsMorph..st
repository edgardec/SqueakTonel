Class {
	#name : #EToyProjectDetailsMorph,
	#superclass : #EToyProjectRenamerMorph,
	#instVars : [
		'projectDetails'
	],
	#classVars : [
		'AgeTriplets',
		'RegionTriplets',
		'SubjectTriplets'
	],
	#category : #'Etoys-Experimental'
}

{ #category : #'instance creation' }
EToyProjectDetailsMorph class >> getFullInfoFor: aProject ifValid: aMessageSend expandedFormat: expandedFormat [
	"Obtain project info for the project by putting up a dialog-box showing current values for the various project-info variables and allowing the user to change the data."

	| detailsMorph  |
	detailsMorph := self basicNew.
	detailsMorph expandedFormat: expandedFormat;
		project: aProject actionBlock: aMessageSend;
		initialize;
		beSticky;
		openCenteredInWorld
]

{ #category : #'as yet unclassified' }
EToyProjectDetailsMorph class >> test1: aProject [
"EToyProjectDetailsMorph test1: Project current"

	(self basicNew)
		project: aProject
		actionBlock: [ :x | 
			aProject world setProperty: #ProjectDetails toValue: x.
			x at: 'projectname' ifPresent: [ :newName | 
				aProject renameTo: newName.
			]
		];

		initialize;
		openCenteredInWorld
]

{ #category : #'project details' }
EToyProjectDetailsMorph >> copyOutDetails [
	"Prepare a new Dictionary holding project-info details as noted in the dialog."

	| newDetails elements item user |
	newDetails := Dictionary new.
	self fieldToDetailsMappings do: [ :each |
		namedFields at: each first ifPresent: [ :field |
				(#('age' 'subject' 'region') includes: each first)
					ifFalse:
							[newDetails at: each second put: field contents string]
						ifTrue:
							[elements := self choicesFor: each first.  "triplet"
							item := elements detect: [:el | el third = field contents string translated] ifNone: [nil].
							item ifNotNil:
								[newDetails at: each second put: item first]]]].


	namedFields at: 'projectname' ifPresent: [ :field |
		newDetails at: 'projectname' put: field contents string withBlanksTrimmed].

	namedFields
		at: 'author'
		ifPresent: [:field | 
			user := field contents string withBlanksTrimmed.
			newDetails at: 'projectauthor' put: user.
			user isEmpty
				ifTrue: [user := nil].
			theProject
				ifNotNil: [theProject forgetExistingURL]].

	^ newDetails
]

{ #category : #'as yet unclassified' }
EToyProjectDetailsMorph >> doExpand [

	self expandedFormat: true.
	self copyOutDetails.
	self rebuild.

]

{ #category : #utilities }
EToyProjectDetailsMorph >> doOK [
	"User hit the ok button in the project-info dialog.  Store the updated project-info back in the project. Call the message-send residing in the receiver's actionBlock to carry out any subsequent desired task.  Note that this method sets the 'arguments' of the message-send in the actionBlock"

	| args actionSelector  |
	self validateTheProjectName ifFalse: [^false].
	projectDetails := self copyOutDetails.

	theProject acceptProjectDetails: projectDetails.  "Make sure project & world feel the changes"

	self delete.
	actionBlock isMessageSend "new way -- hopefully all cases"
		ifTrue:  "please excuse this ugly, non-modular code..."
			[actionSelector := actionBlock selector.
			args := (actionSelector = #handUserSorterMorphForProjectNamed:) 
				ifTrue:
					[{theProject name}]
				ifFalse:
					[actionSelector numArgs = 0
						ifTrue:
							[nil]
						ifFalse:
							[Array with: projectDetails]].
			actionBlock arguments: args.
			actionBlock value]

		ifFalse:  "Old way, with actionBlock actually a block of one argument.  This should no longer occur."
			[actionBlock value: projectDetails].
]

{ #category : #'as yet unclassified' }
EToyProjectDetailsMorph >> expandButton [

	^self
		buttonNamed: 'More' translated
		action: #doExpand 
		color: self buttonColor 
		help: 'Show more info on this project.' translated.

]

{ #category : #'as yet unclassified' }
EToyProjectDetailsMorph >> expandedFormat [

	^ Preferences expandedPublishing
			or: [self valueOfProperty: #expandedFormat ifAbsent: [false]]

]

{ #category : #'as yet unclassified' }
EToyProjectDetailsMorph >> expandedFormat: aBoolean [

	self setProperty: #expandedFormat toValue: aBoolean
]

{ #category : #'project details' }
EToyProjectDetailsMorph >> fieldToDetailsMappings [
	"Answer an array describing, top to bottom, the details of each element.
		Each element is a tuple consisting of:
			1.	field name (internal)
			2.	key in the project-details dictionary
			3.	text (english version) to be shown in the entry's label at left.
			4. vertical space to allow
			5. entry type: (if missing, text is implied)
				#text --> editable text field
				#popUp --> pop-up of choices"
	^{
		{#description. 'projectdescription'. 'Description' translatedNoop. 100}. 
		{#author. 'projectauthor'. 'Author' translatedNoop. 20}.
		{#keywords. 'projectkeywords'. 'Tags' translatedNoop. 20}.
		"{#subject.  'projectcategory'.  'Subject' translatedNoop.  20.  #popUp}.
		{#age.		'projectage'.	'Target Age' translatedNoop.  20.  #popUp}.
		{#region.		'projectregion'.	'Region' translatedNoop.  20.  #popUp}.	"

	}

]

{ #category : #'project details' }
EToyProjectDetailsMorph >> fillInDetails [
	"Given that the receiver's namedFields is already set up, give each such field its appropriate initial value."

	| elements |
	theProject ifNotNil:
		[namedFields at: 'projectname' ifPresent:
			[:field | field contentsWrapped: theProject name]].

	projectDetails ifNotNil:
		[self fieldToDetailsMappings do: [ :tuple |
			namedFields at: tuple first ifPresent: [ :field |
				projectDetails at: tuple second ifPresent: [ :data |
					elements := self choicesFor: tuple first.
					elements
						ifNil:
							[field contentsWrapped: data]
						ifNotNil:
							[| item |
							item := elements detect: [:el | el first = data] ifNone: [nil].
							item ifNotNil:
								[field contentsWrapped: item third translated]
							ifNil:
								[field contentsWrapped: '(none)' translated]]]]].
		"Compatibility with older projects"
		projectDetails at: 'projectcategory' ifPresent: [:data |
			((self choicesFor: #subject)
				detect: [:el | el first = data]
				ifNone: [nil])
					ifNotNil: [:item |
						namedFields
							at: #keywords
							ifPresent: [:field |
								field contentsWrapped:
									(item third translated,
									', ',
									field contents asString)]]]]
]

{ #category : #'as yet unclassified' }
EToyProjectDetailsMorph >> project: aProject actionBlock: aBlock [

	theProject := aProject.
	actionBlock := aBlock.
	projectDetails := theProject world valueOfProperty: #ProjectDetails ifAbsent: [Dictionary new]
]

{ #category : #'as yet unclassified' }
EToyProjectDetailsMorph >> projectDetails: aDictionary [

	projectDetails := aDictionary.
]

{ #category : #initialization }
EToyProjectDetailsMorph >> rebuild [
	"Rebuild the receiver from scratch."

	| bottomButtons header toAdd |
	self removeAllMorphs.
	header := self addARow: {
		(self lockedString: 'Please describe this project' translated) listDirection: #topToBottom.
	}.
	header color: ScriptingSystem baseColor.
	self addARow: {
		self lockedString: 'Project Name' translated.
		self inAColumnForText: {self fieldForProjectName}
	}.
	self expandedFormat ifTrue: [
		self fieldToDetailsMappings do: [ :each |
			toAdd := (each size < 5 or: [each fifth = #text])
				ifTrue:
					[self genericTextFieldNamed: each first]
				ifFalse:
					[self popUpEntryNamed: each first menuTitle: each third].

			self addARow: {
				self lockedString: each third translated.
				self inAColumnForText: {toAdd height: each fourth}
			}.
		].
	].
	bottomButtons := self expandedFormat ifTrue: [
		{
			self okButton.
			self cancelButton.
		}
	] ifFalse: [
		{
			self okButton.
			self expandButton.
			self cancelButton.
		}
	].
	self addARow: bottomButtons.
	self fillInDetails.
]

{ #category : #initialization }
EToyProjectDetailsMorph >> space [
	^ RectangleMorph new extent: 5 @ 5;
		 color: Color transparent;
		 borderWidth: 0 
]
