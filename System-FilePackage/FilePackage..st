Class {
	#name : #FilePackage,
	#superclass : #Object,
	#instVars : [
		'fullName',
		'sourceSystem',
		'classes',
		'doIts',
		'classOrder'
	],
	#classVars : [
		'LogFileStream'
	],
	#category : #'System-FilePackage'
}

{ #category : #'conflict checker logging' }
FilePackage class >> closeLog [
	self logFileStream close.
	LogFileStream := nil.
]

{ #category : #'instance creation' }
FilePackage class >> fromFileNamed: aName [
	^self new fromFileNamed: aName
]

{ #category : #'instance creation' }
FilePackage class >> fromStream: aStream named: aName [
	^self new fromStream: aStream named: aName
]

{ #category : #'conflict checker logging' }
FilePackage class >> log: aString [
	Transcript show: aString.
	self logFileStream nextPutAll: aString.

]

{ #category : #'conflict checker logging' }
FilePackage class >> logCr [
	Transcript cr.
	self logFileStream nextPut: Character cr.

]

{ #category : #'conflict checker logging' }
FilePackage class >> logFileStream [

	LogFileStream ifNil:
		[LogFileStream := FileStream fileNamed: 'ConflictChecker.log'.
		LogFileStream setToEnd].
	^ LogFileStream
]

{ #category : #'conflict checker preferences' }
FilePackage class >> showIdenticalConflicts [
	"(Not implemented yet.  Need to implement versionFromChangeSet first for this to work for the 'false' case.)"
	"Set this to true if we want to show conflicts with methods which have an identical timestamp to the one being checked.  This type of conflict usually just proves that you've already loaded the changeset (or some part of it) in your image."
	^ true

]

{ #category : #'conflict checker preferences' }
FilePackage class >> verboseConflicts [
	"Set this to true if we want to list each replacing (potentially conflicting) method being checked."
	^ true
]

{ #category : #'fileIn\/fileOut' }
FilePackage >> askForDoits [
	| choice choices |
	choices := #('do not process' 'at the beginning' 'at the end' 'cancel').
	choice := nil.
	[choices includes: choice] whileFalse: [
		choice := UIManager default chooseFrom: choices values: choices title:
'The package contains unprocessed doIts.
When would like to process those?'].
	^choices indexOf: choice
]

{ #category : #accessing }
FilePackage >> classAt: className [
	^self classes at: className
]

{ #category : #'change record types' }
FilePackage >> classComment: chgRec [

	(self getClass: chgRec methodClassName) classComment: chgRec
]

{ #category : #accessing }
FilePackage >> classes [
	^classes
]

{ #category : #'change record types' }
FilePackage >> doIt: chgRec [
	| string |
	string := chgRec string.
	('*ubclass:*instanceVariableNames:*classVariableNames:*poolDictionaries:*category:*'
		match: string) ifTrue:[^self classDefinition: string with: chgRec].
	('*named:*uses:*category:*'
		match: string) ifTrue:["Trait" ^ self traitDefinition: string with: chgRec].
	('* class*instanceVariableNames:*'
		match: string) ifTrue:[^self metaClassDefinition: string with: chgRec].
	('* removeSelector: *'
		match: string) ifTrue:[^self removedMethod: string with: chgRec].
	('* comment:*'
		match: string) ifTrue:[^self msgClassComment: string with: chgRec].
	('* initialize'
		match: string) ifTrue:[^self]. "Initialization is done based on class>>initialize"
	('''From *'
		match: string) ifTrue:[^self possibleSystemSource: chgRec].
	doIts add: chgRec.
]

{ #category : #'fileIn\/fileOut' }
FilePackage >> fileIn [
	| doitsMark |
	doitsMark := 1.
	doIts isEmpty ifFalse:[doitsMark := self askForDoits].
	doitsMark = 4 ifTrue: [^nil].
	doitsMark = 2 ifTrue:[self fileInDoits].
	classOrder do:[:cls|
		cls fileInDefinition.
	].
	classes do:[:cls|
		Transcript cr; show:'Filing in ', cls name.
		cls fileInMethods.
		cls hasMetaclass ifTrue:[cls metaClass fileInMethods].
	].
	doitsMark = 3 ifTrue:[self fileInDoits].
]

{ #category : #'fileIn\/fileOut' }
FilePackage >> fileInDoits [
	doIts do:[:chgRec| chgRec fileIn].
]

{ #category : #reading }
FilePackage >> fileInFrom: aStream [
	| changes |
	changes := ChangeSet scanFile: aStream from: 0 to: aStream size.
	aStream close.
	('Processing ', self packageName) 
		displayProgressFrom: 1
		to: changes size
		during:[:bar| | chgRec |
			1 to: changes size do:[:i|
				bar value: i.
				chgRec := changes at: i.
				self perform: chgRec type asSimpleSetter with: chgRec.
			].
		].
]

{ #category : #'fileIn\/fileOut' }
FilePackage >> fileOut [
	"Ask the user for a file path where I should save my contents; if the file already exists ask for a replacement name"
	| fileName |
	fileName := UIManager default saveFilenameRequest: 'Enter the file name' initialAnswer: self fullPackageName.
	fileName ifNil:[^self].
	[FileStream
		newFileNamed: fileName
		do: [:stream | 
			sourceSystem isEmpty
				ifFalse: [stream nextChunkPut: sourceSystem printString;
						 cr].
			self fileOutOn: stream.
			stream cr; cr.
			self classes do: [:cls | cls needsInitialize
						ifTrue: [stream cr; nextChunkPut: cls name , ' initialize']].
			stream cr]
	] on: FileExistsException
		do: [:ex |  fileName := UIManager default saveFilenameRequest: 'Last entered filename already exists; try again' initialAnswer: self fullPackageName.
			ex retry]
]

{ #category : #'fileIn\/fileOut' }
FilePackage >> fileOutDoits: aStream [
	doIts do:[:chgRec| chgRec fileOutOn: aStream].
]

{ #category : #'fileIn\/fileOut' }
FilePackage >> fileOutOn: aStream [
	| doitsMark |
	doitsMark := 1.
	doIts isEmpty ifFalse:[doitsMark := self askForDoits].
	doitsMark = 4 ifTrue: [^nil].
	doitsMark = 2 ifTrue:[self fileOutDoits: aStream].
	classOrder do:[:cls|
		cls fileOutDefinitionOn: aStream.
	].
	classes do:[:cls|
		cls fileOutMethodsOn: aStream.
		cls hasMetaclass ifTrue:[cls metaClass fileOutMethodsOn: aStream].
	].
	doitsMark = 3 ifTrue:[self fileOutDoits: aStream].
]

{ #category : #accessing }
FilePackage >> fixClassOrder [
	"Essentially bubble sort the classOrder so that superclasses appear before subclasses"
	| superClass index subClass superIndex |
	index := 0.
	[index < classOrder size] whileTrue:[
		subClass := classOrder at: (index := index + 1).
		superClass := nil.
		subClass isMeta ifTrue:[
			"Treat non-meta as superclass"
			superClass := self classes at: subClass name ifAbsent:[nil].
		] ifFalse:[
			subClass hasDefinition ifTrue:[
				superClass := self classes 
					at: (Scanner new scanTokens: subClass definition) first ifAbsent:[nil].
				superClass ifNotNil:[superClass hasDefinition ifFalse:[superClass := nil]].
			].
		].
		superClass ifNotNil:[
			superIndex := classOrder indexOf: superClass ifAbsent:[self error:'Where is the class?'].
			superIndex > index ifTrue:[
				"Move superClass before index"
				classOrder remove: superClass.
				classOrder add: superClass before: subClass.
				"Rewind index - we need to check superClass itself"
				index := index - 1.
			].
		].
	].

]

{ #category : #initialize }
FilePackage >> fromFileNamed: aName [
	fullName := aName.
	FileStream readOnlyFileNamed: aName do: [:stream |
		stream setConverterForCode.
		self fileInFrom: stream]
]

{ #category : #initialize }
FilePackage >> fromFileNamed: aName encoding: encodingName [
	| stream |
	fullName := aName.
	stream := FileStream readOnlyFileNamed: aName.
	stream converter: (TextConverter newForEncoding: encodingName).
	self fileInFrom: stream.
]

{ #category : #reading }
FilePackage >> fromStream: aStream named: aName [
	| changes |
	changes := ChangeSet scanFile: aStream from: 0 to: aStream size.
	aStream close.
	('Processing ', aName) 
		displayProgressFrom: 1
		to: changes size
		during:[:bar| | chgRec |
			1 to: changes size do:[:i|
				bar value: i.
				chgRec := changes at: i.
				self perform: chgRec type asSimpleSetter with: chgRec.
			].
		].
]

{ #category : #accessing }
FilePackage >> fullName: aString [
	fullName := aString
]

{ #category : #accessing }
FilePackage >> fullPackageName [
	^fullName
]

{ #category : #private }
FilePackage >> getBehavior: name factory: pseudoBehaviorFactory [
	| pseudoBehavior |
	(classes includesKey: name) ifTrue:[
		^classes at: name.
	].
	pseudoBehavior := pseudoBehaviorFactory new.
	pseudoBehavior name: name.
	classes at: name put: pseudoBehavior.
	^pseudoBehavior.
]

{ #category : #private }
FilePackage >> getClass: className [
	^ self getBehavior: className factory: PseudoClass
]

{ #category : #private }
FilePackage >> getTrait: traitName [
	^ self getBehavior: traitName factory: PseudoTrait
]

{ #category : #initialize }
FilePackage >> initialize [
	classes := Dictionary new.
	classOrder := OrderedCollection new.
	sourceSystem := ''.
	doIts := OrderedCollection new.
]

{ #category : #private }
FilePackage >> metaClassDefinition: string with: chgRec [
	| tokens theClass |
	tokens := Scanner new scanTokens: string.
	theClass := self getClass: (tokens at: 1).
	theClass metaClass definition: string.
	classOrder add: theClass metaClass.
]

{ #category : #'change record types' }
FilePackage >> method: chgRec [
	(self getClass: chgRec methodClassName) methodChange: chgRec
]

{ #category : #private }
FilePackage >> msgClassComment: string with: chgRec [
	| tokens theClass |
	tokens := Scanner new scanTokens: string.
	(tokens size = 3 and:[(tokens at: 3) isString]) ifTrue:[
		theClass := self getClass: tokens first.
		^theClass commentString: tokens last].
	(tokens size = 4 and:[(tokens at: 3) asString = 'class' and:[(tokens at: 4) isString]]) ifTrue:[
		theClass := self getClass: tokens first.
		theClass metaClass commentString: tokens last].

]

{ #category : #accessing }
FilePackage >> packageInfo [
	^String streamContents:[:s|
		s nextPutAll:'Package: '.
		s nextPutAll: self fullPackageName; cr; cr.
		sourceSystem isEmpty ifFalse:[
			s nextPutAll: sourceSystem; cr; cr].
		doIts isEmpty ifFalse:[
			s nextPutAll:'Unresolvable doIts:'; cr; cr.
			doIts do:[:chgRec|
				s nextPut:$!; nextPutAll: chgRec string; nextPut: $!; cr]]].
]

{ #category : #accessing }
FilePackage >> packageName [
	^FileDirectory localNameFor: self fullPackageName
]

{ #category : #private }
FilePackage >> possibleSystemSource: chgRec [
	| tokens |
	sourceSystem isEmpty ifTrue:[
		tokens := Scanner new scanTokens: chgRec string.
		(tokens size = 1 and:[tokens first isString]) ifTrue:[
			sourceSystem := tokens first.
			^self]].
	doIts add: chgRec.
]

{ #category : #'change record types' }
FilePackage >> preamble: chgRec [
	self doIt: chgRec
]

{ #category : #accessing }
FilePackage >> removeClass: aPseudoClass [
	(self classes removeKey: aPseudoClass name).
	classOrder copy do:[:cls|
		cls name = aPseudoClass name ifTrue:[ classOrder remove: cls].
	].
]

{ #category : #accessing }
FilePackage >> removeDoIts [
	doIts := OrderedCollection new.
]

{ #category : #private }
FilePackage >> removedMethod: string with: chgRec [
	| class tokens |
	tokens := Scanner new scanTokens: string.
	(tokens size = 3 and:[(tokens at: 2) == #removeSelector: ]) ifTrue:[
		class := self getClass: (tokens at: 1).
		^class removeSelector: (tokens at: 3).
	].
	(tokens size = 4 and:[(tokens at: 2) == #class and:[(tokens at: 3) == #removeSelector:]]) ifTrue:[
		class := self getClass: (tokens at: 1).
		^class metaClass removeSelector: (tokens at: 4).
	].
	doIts add: chgRec
]

{ #category : #accessing }
FilePackage >> renameClass: aPseudoClass to: newName [
	| oldName |
	oldName := aPseudoClass name.
	self classes removeKey: oldName.
	self classes at: newName put: aPseudoClass.
	aPseudoClass renameTo: newName.
]

{ #category : #private }
FilePackage >> sampleMethod [
"	In an existing method there are always a number of changes.
	Other stuff
		will be deleted
	Or even better,
		some things may be just modified.
"
]
