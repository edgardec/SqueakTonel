Class {
	#name : #SystemChangeFileTest,
	#superclass : #TestCase,
	#instVars : [
		'tempChangesFile',
		'tempChangesName'
	],
	#category : #'SystemChangeNotification-Tests'
}

{ #category : #testing }
SystemChangeFileTest >> change: changeBlock verify: verifyBlock [
	self prepare: [] change: changeBlock verify: verifyBlock
]

{ #category : #private }
SystemChangeFileTest >> createClass: name [
	^Object
		subclass: name
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self genericClassCategory
]

{ #category : #accessing }
SystemChangeFileTest >> directory [
	"Where we want to place the temporary changes file"
	^FileDirectory default
]

{ #category : #testing }
SystemChangeFileTest >> expectedFailures [
	^#(
		#testCategoryModified
		#testClassReorganized
		#testProtocolModified
	)
]

{ #category : #private }
SystemChangeFileTest >> genericChangesName [
	^self prefixChangesName, self randomString, '.changes'
]

{ #category : #private }
SystemChangeFileTest >> genericClassCategory [
	^(self prefixClassCategory, self randomString capitalized) asSymbol
]

{ #category : #private }
SystemChangeFileTest >> genericClassName [
	^(self prefixClassName, self randomString capitalized) asSymbol
]

{ #category : #private }
SystemChangeFileTest >> genericInstVarName [
	^(self prefixInstVarName, self randomString capitalized) asSymbol
]

{ #category : #private }
SystemChangeFileTest >> genericProtocol [
	^(self prefixProtocol, self randomString) asSymbol
]

{ #category : #private }
SystemChangeFileTest >> genericSelector [
	^(self prefixSelector, self randomString capitalized) asSymbol
]

{ #category : #private }
SystemChangeFileTest >> performTest [

	Utilities
		useAuthorInitials: self className
		during: [ super performTest ]
]

{ #category : #private }
SystemChangeFileTest >> prefixChangesName [
	^self prefixGeneral
]

{ #category : #private }
SystemChangeFileTest >> prefixClassCategory [
	^self prefixGeneral, 'Category-'
]

{ #category : #private }
SystemChangeFileTest >> prefixClassName [
	^self prefixGeneral, 'Class'
]

{ #category : #private }
SystemChangeFileTest >> prefixGeneral [
	^self class name select: [:each | each isUppercase]
]

{ #category : #private }
SystemChangeFileTest >> prefixInstVarName [
	^self prefixGeneral asLowercase, 'InstVar'
]

{ #category : #private }
SystemChangeFileTest >> prefixProtocol [
	^self prefixGeneral asLowercase, ' protocol '
]

{ #category : #private }
SystemChangeFileTest >> prefixSelector [
	^self prefixGeneral asLowercase, 'Selector'
]

{ #category : #testing }
SystemChangeFileTest >> prepare: prepareBlock change: changeBlock verify: verifyBlock [
	"All tests follow this pattern. Beware that prepareBlock (and verifyBlock) will be evalutated twice."
	
	"Setup the testcourt"
	prepareBlock value.
	
	"Embrace the changeBlock so that any change to our testcourt
	will be recorded in our temporary changes file"
	self useTemporaryChangesFile.
	changeBlock value.
	"Check if the changes we made worked as expected. We need to do
	this before we switch back to the standard changes file"
	"We raise an Error if this fails, because then the testcase is broken"
	[verifyBlock value]
		on: TestFailure
		do: [self error: 'The verifyBlock needs to validate the changes made in the changeBlock'].
	self useStandardChangesFile.

	"Remove the testcourt completely"
	self removeTestcourt.

	"Setup the testcourt once again"
	prepareBlock value.

	"Replay the changes from the temporary changes file"
	self replayChanges.

	"See if we got the same changes as we did before using the changeBlock"
	verifyBlock value.

]

{ #category : #private }
SystemChangeFileTest >> randomString [
	^Character alphabet shuffled
]

{ #category : #running }
SystemChangeFileTest >> removeTestcourt [
	SystemOrganization categories do: [:each |
		(each beginsWith: self prefixClassCategory) ifTrue: [
			SystemOrganization removeSystemCategory: each]].
		
	(PackageOrganizer default packages select: [:packageInfo | packageInfo packageName beginsWith: self prefixGeneral ])
		do: [:packageInfo | packageInfo workingCopy unload].
]

{ #category : #private }
SystemChangeFileTest >> replayChanges [
	| file |
	file := FileStream fileNamed: (self directory fullNameFor: self tempChangesName).
	Transcript show: file contents; cr.
	file fileIn.

]

{ #category : #running }
SystemChangeFileTest >> tearDown [
	self useStandardChangesFile.
	tempChangesFile := tempChangesFile ifNotNil: [tempChangesFile close].
	(self directory fileExists: self tempChangesName)
		ifTrue: [self directory deleteFileNamed: self tempChangesName].
	self removeTestcourt.

]

{ #category : #accessing }
SystemChangeFileTest >> tempChangesName [
	^tempChangesName ifNil: [tempChangesName := self genericChangesName]
]

{ #category : #testing }
SystemChangeFileTest >> testCategoryAdded [
	| aClassCategory |
	aClassCategory := self genericClassCategory.
	self
		change: [
			SystemOrganization addCategory: aClassCategory.
		]
		verify: [
			self assert: (SystemOrganization categories includes: aClassCategory).
		]

]

{ #category : #testing }
SystemChangeFileTest >> testCategoryAddedBefore [
	| aClassCategory |
	aClassCategory := self genericClassCategory.
	self
		change: [
			SystemOrganization addCategory: aClassCategory before: nil.
		]
		verify: [
			self assert: (SystemOrganization categories includes: aClassCategory).
		]

]

{ #category : #tests }
SystemChangeFileTest >> testCategoryModified [
	self assert: false description: 'When does that happen?'
]

{ #category : #testing }
SystemChangeFileTest >> testCategoryRemoved [
	| aClassCategory |
	aClassCategory := self genericClassCategory.
	self
		prepare: [
			SystemOrganization addCategory: aClassCategory.
		]
		change: [
			SystemOrganization removeCategory: aClassCategory.
		]
		verify: [
			self deny: (SystemOrganization categories includes: aClassCategory).
		]

]

{ #category : #testing }
SystemChangeFileTest >> testCategoryRenamed [
	| aNewClassCategory anOldClassCategory |
	anOldClassCategory := self genericClassCategory.
	aNewClassCategory := self genericClassCategory.
	self
		prepare: [
			SystemOrganization addCategory: anOldClassCategory.
		]
		change: [
			SystemOrganization renameCategory: anOldClassCategory toBe: aNewClassCategory
		]
		verify: [
			self assert: (SystemOrganization categories includes: aNewClassCategory).
			self deny: (SystemOrganization categories includes: anOldClassCategory).
		]

]

{ #category : #testing }
SystemChangeFileTest >> testClassAdded [
	| aClassName |
	aClassName := self genericClassName.
	self
		change: [
			self createClass: aClassName.
		]
		verify: [
			self assert: (Smalltalk globals includesKey: aClassName).
		]


]

{ #category : #testing }
SystemChangeFileTest >> testClassCommented [
	| aClass aClassName aComment |
	aClassName := self genericClassName.
	self
		prepare: [
			aClass := self createClass: aClassName.
		]
		change: [
			aComment := self randomString.
			aClass classComment: aComment.
		]
		verify: [
			self assert: aClass organization classComment string = aComment.
		].
]

{ #category : #testing }
SystemChangeFileTest >> testClassModified [
	| aClass aClassName aInstVarName |
	aClassName := self genericClassName.
	self
		prepare: [
			aClass := self createClass: aClassName.
		]
		change: [
			aInstVarName := self genericInstVarName.
			aClass addInstVarName: aInstVarName.
		]
		verify: [
			self assert: (aClass instVarNames includes: aInstVarName).
		].
]

{ #category : #testing }
SystemChangeFileTest >> testClassRecategorized [
	| aClassName aNewClassCategory |
	aClassName := self genericClassName.
	aNewClassCategory := self genericClassCategory.
	self
		prepare: [
			self createClass: aClassName.
			SystemOrganization addCategory: aNewClassCategory.
		]
		change: [
			SystemOrganization classify: aClassName under: aNewClassCategory.
		]
		verify: [
			self assert: (SystemOrganization categoryOfElement: aClassName) = aNewClassCategory.
		]

]

{ #category : #testing }
SystemChangeFileTest >> testClassRemoved [
	| aClass aClassName |
	aClassName := self genericClassName.
	self
		prepare: [
			aClass := self createClass: aClassName.
		]
		change: [
			aClass removeFromSystem.
		]
		verify: [
			self deny: (Smalltalk globals includesKey: aClassName).
		].

]

{ #category : #testing }
SystemChangeFileTest >> testClassRenamed [
	| aClass aNewClassName anOldClassName |
	anOldClassName := self genericClassName.
	aNewClassName := self genericClassName.
	self
		prepare: [
			aClass := self createClass: anOldClassName.
		]
		change: [
			aClass rename: aNewClassName.
		]
		verify: [
			self assert: (Smalltalk globals includesKey: aNewClassName).
			self deny: (Smalltalk globals includesKey: anOldClassName).
		].
]

{ #category : #tests }
SystemChangeFileTest >> testClassReorganized [
	self assert: false description: 'When does that happen?'
]

{ #category : #testing }
SystemChangeFileTest >> testExpressionDoIt [
	| aClassName |
	aClassName := self genericClassName..
	self
		prepare: [
			self createClass: aClassName.
		]
		change: [
			Compiler evaluate: '(Smalltalk at: ', aClassName storeString, ') removeFromSystem'.
		]
		verify: [
			self deny: (Smalltalk globals includesKey: aClassName).
		].
]

{ #category : #testing }
SystemChangeFileTest >> testMethodAdded [
	| aClassName aClass aSelector |
	aClassName := self genericClassName.
	self
		prepare: [
			aClass := self createClass: aClassName.
		]
		change: [
			aSelector := self genericSelector.
			aClass compile: aSelector.
		]
		verify: [
			self assert: (aClass methodDict includesKey: aSelector).
		]


]

{ #category : #testing }
SystemChangeFileTest >> testMethodModified [
	| aClassName aClass aSelector aMethodSource |
	aClassName := self genericClassName.
	aSelector := self genericSelector.
	self
		prepare: [
			aClass := self createClass: aClassName.
			aClass compile: aSelector, ' ', self randomString storeString.
		]
		change: [
			aMethodSource := aSelector, ' ', self randomString storeString.
			aClass compile: aMethodSource.
		]
		verify: [
			self assert: (aClass sourceCodeAt: aSelector) string = aMethodSource.
		]


]

{ #category : #testing }
SystemChangeFileTest >> testMethodRecategorized [
	| aClassName aClass aNewProtocol aSelector anOldProtocol |
	aClassName := self genericClassName.
	aSelector := self genericSelector.
	anOldProtocol := self genericProtocol.
	self
		prepare: [
			aClass := self createClass: aClassName.
			aClass compile: aSelector classified: anOldProtocol.
		]
		change: [
			aNewProtocol := self genericProtocol.
			aClass organization classify: aSelector under: aNewProtocol.
		]
		verify: [
			self assert: (aClass organization categoryOfElement: aSelector) = aNewProtocol
		]


]

{ #category : #testing }
SystemChangeFileTest >> testMethodRemoved [
	| aClassName aClass aSelector |
	aClassName := self genericClassName.
	aSelector := self genericSelector.
	self
		prepare: [
			aClass := self createClass: aClassName.
			aClass compile: aSelector.
		]
		change: [
			aClass removeSelector: aSelector.
		]
		verify: [
			self deny: (aClass methodDict includesKey: aSelector).
		]


]

{ #category : #testing }
SystemChangeFileTest >> testProtocolAdded [
	| aClassName aClass aProtocol |
	aClassName := self genericClassName.
	aProtocol := self genericProtocol.
	self
		prepare: [
			aClass := self createClass: aClassName.
		]
		change: [
			aClass organization addCategory: aProtocol.
		]
		verify: [
			self assert: (aClass organization categories includes: aProtocol)
		]


]

{ #category : #testing }
SystemChangeFileTest >> testProtocolDefault [
	| aClassName aClass aSelector |
	aClassName := self genericClassName.
	self
		prepare: [
			aClass := self createClass: aClassName.
		]
		change: [
			aSelector := self genericSelector.
			aClass compile: aSelector.
		]
		verify: [
			self assert: (aClass organization categoryOfElement: aSelector) = aClass organization class default.
		]


]

{ #category : #tests }
SystemChangeFileTest >> testProtocolModified [
	self assert: false description: 'When does that happen?'
]

{ #category : #testing }
SystemChangeFileTest >> testProtocolRemoved [
	| aClassName aClass aProtocol |
	aClassName := self genericClassName.
	aProtocol := self genericProtocol.
	self
		prepare: [
			aClass := self createClass: aClassName.
			aClass organization addCategory: aProtocol.
		]
		change: [
			aClass organization removeCategory: aProtocol.
		]
		verify: [
			self deny: (aClass organization categories includes: aProtocol)
		]


]

{ #category : #testing }
SystemChangeFileTest >> testProtocolRenamed [
	| aClassName aClass anOldProtocol aNewProtocol |
	aClassName := self genericClassName.
	anOldProtocol := self genericProtocol.
	self
		prepare: [
			aClass := self createClass: aClassName.
			aClass organization addCategory: anOldProtocol.
		]
		change: [
			aNewProtocol := self genericProtocol.
			aClass organization renameCategory: anOldProtocol toBe: aNewProtocol.
		]
		verify: [
			self deny: (aClass organization categories includes: anOldProtocol).
			self assert: (aClass organization categories includes: aNewProtocol).
		]


]

{ #category : #private }
SystemChangeFileTest >> useStandardChangesFile [
	Smalltalk
		closeSourceFiles;
		openSourceFiles
]

{ #category : #private }
SystemChangeFileTest >> useTemporaryChangesFile [
	Smalltalk closeSourceFiles.
	tempChangesFile := self directory forceNewFileNamed: self tempChangesName.
	SourceFiles at: 2 put: tempChangesFile
]
