"
This kind of topic uses subclasses and methods to encode books and pages.
"
Class {
	#name : #ClassBasedHelpTopic,
	#superclass : #AbstractHelpTopic,
	#instVars : [
		'helpClass',
		'subtopics'
	],
	#category : #'HelpSystem-Core-Model'
}

{ #category : #editing }
ClassBasedHelpTopic >> accept: newContents for: subtopic [
	"Supports indirect content storage in classes other than helpClass."
	
	| topicClass topicMethodSelector code indirect |
	(indirect := subtopic contentsAsIs isMessageSend)
		ifFalse: [
			topicClass := self helpClass.
			topicMethodSelector := subtopic key asLegalSelector asSymbol]
		ifTrue: [
			topicClass := subtopic contentsAsIs receiver.
			topicMethodSelector := subtopic contentsAsIs selector].
		
	code := String streamContents:[:s|
		s nextPutAll: topicMethodSelector.
		s crtab; nextPutAll: '"This method was automatically generated. Edit it using:"'.
		s crtab; nextPutAll: '"', self helpClass name,' edit: ', subtopic key storeString,'"'.
		
		indirect ifTrue: [s crtab; nextPutAll: '^ ('] ifFalse: [
			s crtab; nextPutAll: '^(HelpTopic'.
			s crtab: 2; nextPutAll: 'title: ', subtopic title storeString.
			s crtab: 2; nextPutAll: 'contents: '].
		
		s cr; nextPutAll: (String streamContents:[:c| c nextChunkPutWithStyle: newContents]) storeString.
		s nextPutAll:' readStream nextChunkText)'.
		
		indirect ifFalse: [
			subtopic key ifNotNil: [s crtab: 3; nextPutAll: 'key: ', subtopic key storeString; nextPutAll: ';'].
			subtopic shouldStyle ifNotNil: [s crtab: 3; nextPutAll: 'shouldStyle: ', subtopic shouldStyle storeString; nextPutAll: ';'].
			s crtab: 3; nextPutAll: 'yourself']
	].

	topicClass class
		compile: code
		classified: ((topicClass class organization categoryOfElement: topicMethodSelector) ifNil:['pages']).
]

{ #category : #accessing }
ClassBasedHelpTopic >> contents [
	"A book has no contents. Only its pages do."
	
	^ ''
]

{ #category : #testing }
ClassBasedHelpTopic >> hasSubtopics [

	^ self helpClass pages notEmpty or: [self helpClass subclasses notEmpty]
]

{ #category : #accessing }
ClassBasedHelpTopic >> helpClass [

	^ helpClass
]

{ #category : #accessing }
ClassBasedHelpTopic >> helpClass: aHelpClass [

	helpClass := aHelpClass.
]

{ #category : #accessing }
ClassBasedHelpTopic >> icon [
	^ self helpClass icon
]

{ #category : #testing }
ClassBasedHelpTopic >> isEditable [
	^ true
]

{ #category : #accessing }
ClassBasedHelpTopic >> priority [

	^ self helpClass priority
]

{ #category : #updating }
ClassBasedHelpTopic >> refresh [

	self updateSubtopics.
	self changed: #subtopicsUpdated.
]

{ #category : #accessing }
ClassBasedHelpTopic >> subtopics [

	^ subtopics ifNil: [self updateSubtopics]
]

{ #category : #accessing }
ClassBasedHelpTopic >> title [
	^ self helpClass bookName
]

{ #category : #updating }
ClassBasedHelpTopic >> updateSubtopics [
	"build a list of subtopics; start with the list of page names specified by the helpClass' #pages method, remembering that it is an ordered list of 
	 - selectors that return a HelpTopic,
	-  or the name of a class that must in turn provide help topics etc. This allows for hierarchies with 'subtrees in the middle'.
	The order of the pages reflects the order of the selectors and class names given.
	Then all the subclasses that are not #ignore'd and not already included are added.
	Finally the list of class names and messages is used to assemble the actual help topics.
	
	Questions: 
		is it actually useful to include the possibility of class names as per the CustomHelpHelpBuilder>createTopicFrom: code?
		is the #ignore testing worth keeping?"
		
	| pages |
	pages := (self helpClass pages collect: [:pageSelectorOrClassName |
		(Smalltalk hasClassNamed: pageSelectorOrClassName asString)
			ifTrue: [Smalltalk classNamed: pageSelectorOrClassName asString]
			ifFalse: [pageSelectorOrClassName]]) asOrderedCollection.

	self helpClass subclasses
		select: [:cls | cls ignore not]
		thenDo: [:cls | pages addIfNotPresent: cls].	

	^ subtopics := pages withIndexCollect: [:pageSelectorOrClass :priority |
		pageSelectorOrClass isBehavior
			ifFalse: [(self helpClass perform: pageSelectorOrClass)
							priority: priority - pages size;
							key: pageSelectorOrClass;
							in: [:topic |
								"Use my choice of styling if my subtopics do not care."
								topic shouldStyle ifNil: [topic shouldStyle: self usesCodeStyling]];
							yourself]
			ifTrue: [pageSelectorOrClass asHelpTopic]]
]

{ #category : #testing }
ClassBasedHelpTopic >> usesCodeStyling [
	"ask my helpClass if it wants pages styled for code; at some point it should be made possible for individual topics to make this choice and the help browser will do The Right Thing for each one"
		^helpClass ifNil:[false] ifNotNil:[:hC| hC usesCodeStyling]
]
