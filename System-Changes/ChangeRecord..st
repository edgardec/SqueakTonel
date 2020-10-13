"
A ChangeRecord represents a change recorded on a file in fileOut format.
It includes a type (more needs to be done here), and additional information
for certain types such as method defs which need class and category.
"
Class {
	#name : #ChangeRecord,
	#superclass : #Object,
	#instVars : [
		'file',
		'position',
		'type',
		'class',
		'category',
		'meta',
		'stamp'
	],
	#category : #'System-Changes'
}

{ #category : #access }
ChangeRecord >> category [
	^category
]

{ #category : #initialization }
ChangeRecord >> class: clsName category: cat method: method sourceFiles: fileArray [
	"This should be enough to find all the information for a method, or method deletion"

	file := fileArray at: method fileIndex.
	position := method filePosition.
	type := #method.
	class := clsName copyUpTo: $ .	"the non-meta part of a class name"
	category := cat.
	meta := clsName endsWith: ' class'.
	self readStamp.
]

{ #category : #access }
ChangeRecord >> commentClass [ 
	| commentClass |
	type == #classComment ifFalse: [^ nil].
	(Smalltalk includesKey: class asSymbol) ifFalse: [^ nil].
	commentClass := Smalltalk at: class asSymbol.
	^meta ifTrue: [commentClass class]
		ifFalse: [commentClass]
]

{ #category : #access }
ChangeRecord >> file [
	^file
]

{ #category : #initialization }
ChangeRecord >> file: f position: p type: t [
	file := f.
	position := p.
	type := t
]

{ #category : #initialization }
ChangeRecord >> file: f position: p type: t class: c category: cat meta: m stamp: s [
	self file: f position: p type: t.
	class := c.
	category := cat.
	meta := m.
	stamp := s
]

{ #category : #initialization }
ChangeRecord >> fileIn [
	^ self fileIn: Smalltalk globals.
]

{ #category : #initialization }
ChangeRecord >> fileIn: anEnvironment [
	"File the receiver in.  If I represent a method or a class-comment, file the method in and make a note of it in the recent-submissions list; if I represent a do-it, then, well, do it; if I represent a reorganization then get organized!"

	Cursor read showWhile:
		[| s cls aSelector |
		type == #doIt
			ifTrue:
				[((s := self string) beginsWith: '----') ifFalse: [Compiler evaluate: s]]
			ifFalse:
				[cls := self methodClass: anEnvironment.
				 type == #method ifTrue:
					[[cls compile: self text classified: category withStamp: stamp notifying: nil]
					on: CurrentEnvironment do: [:e | e resume: anEnvironment].
					(aSelector := self methodSelector) ifNotNil:
						[RecentMessages default recordSelector: aSelector forClass: cls inEnvironment: anEnvironment]].
				 type == #classComment ifTrue:
					[cls comment: self text stamp: stamp.
					RecentMessages default recordSelector: #Comment forClass: cls inEnvironment: anEnvironment].
				 type == #reorganize ifTrue:
					[cls organization changeFromString: self text]]]
]

{ #category : #access }
ChangeRecord >> fileIndex [
	SourceFiles withIndexDo: [:sf :i| sf name = file name ifTrue: [^i]].
	^nil
]

{ #category : #access }
ChangeRecord >> fileName [
	^(file ifNotNil: [ file name ]) 
			ifNil: [ '<no file>' ]
]

{ #category : #access }
ChangeRecord >> fileOutOn: aFileStream [
	"File the receiver out on the given file stream"

	| aString |
	type == #method
		ifTrue:
			[aFileStream nextPut: $!.
			aString :=  class asString
							, (meta ifTrue: [' class methodsFor: ']
									ifFalse: [' methodsFor: '])
							, category asString printString.
			stamp ifNotNil:
				[aString := aString, ' stamp: ''', stamp, ''''].
			aFileStream nextChunkPut: aString.
			aFileStream cr].

	type == #preamble ifTrue: [aFileStream nextPut: $!].

	type == #classComment
		ifTrue:
			[aFileStream nextPut: $!.
			aFileStream nextChunkPut: class asString, ' commentStamp: ', stamp storeString.
			aFileStream cr].

	aFileStream nextChunkPut: self string.
	type == #method ifTrue: [aFileStream nextChunkPut: ' '].
	aFileStream cr
]

{ #category : #access }
ChangeRecord >> headerFor: selector [

	^ '    ' , class , (meta ifTrue: [' class '] ifFalse: [' '])
				, selector
				, (stamp isEmpty ifTrue: [''] ifFalse: ['; ' , stamp])
]

{ #category : #access }
ChangeRecord >> isMetaClassChange [
	^meta
]

{ #category : #access }
ChangeRecord >> methodClass [
	^ self methodClass: Smalltalk globals.
]

{ #category : #access }
ChangeRecord >> methodClass: anEnvironment [
	| methodClassName methodClass |
	(#(method #classComment) includes: type) ifFalse: [ ^ nil ].
	methodClassName := class substrings
		ifEmpty: [ ^ nil ]
		ifNotEmptyDo:
			[ : parts | parts first asSymbol ].
	(anEnvironment includesKey: methodClassName) ifFalse: [ ^ nil ].
	methodClass := anEnvironment at: methodClassName.
	^ meta
		ifTrue: [ methodClass class ]
		ifFalse: [ methodClass ]
]

{ #category : #access }
ChangeRecord >> methodClassName [
	| tokens |
	(class isNil
	and: [type = #doIt
	and: [([(tokens := Scanner new scanTokens: self text) size >= 3]
			on: Error do: [:ex| false])
	and: [(tokens includes: #'.') not "exclude multi-statement doits"
	and: [tokens first isSymbol
	and: [tokens first isKeyword not
	and: [tokens first first canBeGlobalVarInitial
	and: [(tokens includes: #instanceVariableNames:)
		or: [tokens second == #comment:
		or: [tokens third == #comment:]]]]]]]]]) ifTrue:
		["Could be a class definition.
			Class definitions start with Superclass blahSubclass: #ClassName
			Metaclass definitions start with ClassName class instanceVariableNames:"
		 (tokens second isSymbol
		  and: [tokens second isKeyword
		  and: [tokens third isSymbol
		  and: [tokens third isKeyword not
		  and: [(2 to: tokens size by: 2) allSatisfy: [:i| (tokens at: i) isKeyword]]]]]) ifTrue:
			[^tokens third].
		 (tokens size = 4
		  and: [tokens second = #class
		  and: [(tokens third = #instanceVariableNames: or: [tokens third = #comment:])
		  and: [tokens last isString]]]) ifTrue:
			[^tokens first].
		 (tokens size = 3
		  and: [tokens second = #comment:
		  and: [tokens last isString]]) ifTrue:
			[^tokens first]].
	^class
]

{ #category : #access }
ChangeRecord >> methodSelector [
	^type == #method ifTrue:
		[(Smalltalk at: class ifAbsent: [Object]) newParser parseSelector: self string]
]

{ #category : #access }
ChangeRecord >> originalChangeSetForSelector: methodSelector [
	"Returns the original changeset which contained this method version.  If it is contained in the .sources file, return #sources.  If it is in neither (e.g. its changeset was deleted), return nil.  (The selector is passed in purely as an optimization.)"

	| likelyChangeSets originalChangeSet |
	(file localName findTokens: '.') last = 'sources'
		ifTrue: [^ #sources].
	likelyChangeSets := ChangeSet allChangeSets select: 
		[:cs | (cs atSelector: methodSelector class: self methodClass) ~~ #none].
	originalChangeSet := likelyChangeSets
		detect: [:cs | cs containsMethodAtPosition: position]
		ifNone: [nil].
	^ originalChangeSet  "(still need to check for sources file)"
]

{ #category : #access }
ChangeRecord >> position [
	^ position
]

{ #category : #access }
ChangeRecord >> position: anInteger [
	"Set the position.  Dangerous!  Used in condenseChanges implementation by a very knowledgeable client!"
	position := anInteger
]

{ #category : #access }
ChangeRecord >> prior [
	| currFile preamble prevPos tokens prevFileIndex |
	currFile := file readOnlyCopy.
	currFile position: (0 max: position - 150).
	[currFile position < (position - 1)] whileTrue: [preamble := currFile nextChunk].
	currFile close.
	prevPos := nil.
	(preamble findString: 'methodsFor:' startingAt: 1) > 0
		ifTrue: [tokens := Scanner new scanTokens: preamble]
		ifFalse: [tokens := Array new].
	((tokens size between: 7 and: 8)
	and: [(tokens at: tokens size - 5) == #methodsFor:]) ifTrue: [
		(tokens at: tokens size - 3) == #stamp:
		ifTrue: [
			prevPos := tokens last.
			prevFileIndex := SourceFiles fileIndexFromSourcePointer: prevPos.
			prevPos := SourceFiles filePositionFromSourcePointer: prevPos]
		ifFalse: [
			prevPos := tokens at: tokens size - 2.
			prevFileIndex := tokens last].
		(prevPos = 0 or: [prevFileIndex = 0]) ifTrue: [prevPos := nil]].
	prevPos ifNil: [^ nil].
	^ {prevFileIndex. prevPos. 
		SourceFiles sourcePointerFromFileIndex: prevFileIndex andPosition: prevPos}
]

{ #category : #access }
ChangeRecord >> readStamp [
	"Get the time stamp of this method off the file"

	| item tokens anIndex |
	stamp := ''.
	file ifNil: [^ stamp].
	file position: position.
	item := file nextChunk.
	tokens := Scanner new scanTokens: item.
	tokens size < 3 ifTrue: [^ stamp].
	anIndex := tokens indexOf: #stamp: ifAbsent: [^ stamp].
	^ stamp := tokens at: (anIndex + 1).

]

{ #category : #access }
ChangeRecord >> stamp [
	^ stamp
]

{ #category : #access }
ChangeRecord >> stamp: threePartString [

	stamp := threePartString
]

{ #category : #access }
ChangeRecord >> string [ 
	| string |
	file openReadOnly.
	file position: position.
	string := file nextChunk.
	file close.
	^ string
]

{ #category : #access }
ChangeRecord >> text [
	| text |
	^ file ifNil: ['']
		ifNotNil: [
			file openReadOnly.
			file position: position.
			text := file nextChunkText.
			file close.
			text]
]

{ #category : #access }
ChangeRecord >> timeStamp [
	"Answer a TimeStamp that corresponds to my (text) stamp"
	| tokens |
	tokens := self stamp findTokens: Character separators.
	^ tokens size > 2
		ifTrue: [[| date time |
			date := Date fromString: (tokens at: tokens size - 1).
			time := Time fromString: tokens last.
			TimeStamp date: date time: time]
				on: Error
				do: [:ex | ex
						return: (TimeStamp fromSeconds: 0)]]
		ifFalse: [TimeStamp fromSeconds: 0]
]

{ #category : #access }
ChangeRecord >> type [
	^ type
]
