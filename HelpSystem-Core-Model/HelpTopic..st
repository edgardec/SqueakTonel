"
This is a configurable version of a help topic. You can define its contents, title, icon, and subtopics manually.

Help builders make use of this.
"
Class {
	#name : #HelpTopic,
	#superclass : #AbstractHelpTopic,
	#instVars : [
		'title',
		'key',
		'icon',
		'contents',
		'subtopics',
		'priority',
		'isEditable',
		'shouldStyle'
	],
	#category : #'HelpSystem-Core-Model'
}

{ #category : #'instance creation' }
HelpTopic class >> named: aString [
	"Create a new instance with given title and empty contents"
	
	^(self new)
		title: aString;
		yourself
]

{ #category : #'instance creation' }
HelpTopic class >> title: aTitle contents: aText [
	"Create a new instance with given title and content"
	
	^(self new)
		title: aTitle;
		contents: aText;
		yourself.
		
]

{ #category : #'instance creation' }
HelpTopic class >> title: aTitle icon: anIcon contents: aText [
	"Create a new instance with given title, icon and content"
	
	^(self new)
		title: aTitle;
		icon: anIcon;
		contents: aText;
		yourself.
		
]

{ #category : #'instance creation' }
HelpTopic class >> title: aTitle icon: anIcon readOnlyContents: aText [
	"Create a new instance with given title, icon and content"
	
	^self new
		title: aTitle;
		icon: anIcon;
		contents: aText;
		isEditable: false;
		yourself.
		
]

{ #category : #'instance creation' }
HelpTopic class >> title: aTitle readOnlyContents: aText [
	"Create a new instance with given title and content"
	
	^ self new
		title: aTitle;
		contents: aText;
		isEditable: false;
		yourself.
		
]

{ #category : #accessing }
HelpTopic >> addSubtopic: aTopic [
	"Adds the given topic to the receivers collection of subtopics"
	
	self subtopics add: aTopic.
	self changed: #subtopicAdded with: aTopic.
	^aTopic
]

{ #category : #accessing }
HelpTopic >> contents [
	"Returns the receivers contents. Supports indirect contents through message sends."
	
	^ contents value
]

{ #category : #accessing }
HelpTopic >> contents: anObject [
	"Sets the receivers contents to the given object" 
		
	contents := anObject
]

{ #category : #accessing }
HelpTopic >> contentsAsIs [

	^ contents
]

{ #category : #defaults }
HelpTopic >> defaultTitle [
	"Returns the receivers default title"
	
	^'Unnamed Topic'
	
]

{ #category : #accessing }
HelpTopic >> icon [ 
 	"Returns the receivers icon"
	
	^icon
]

{ #category : #accessing }
HelpTopic >> icon: aSymbol [
	"Sets the receivers icon"
	
	icon := aSymbol 
]

{ #category : #'initialize-release' }
HelpTopic >> initialize [ 
	"Initializes the receiver"
	
	super initialize.
	self title: self defaultTitle.
	self contents: ''.
]

{ #category : #accessing }
HelpTopic >> isEditable [
	^ isEditable ifNil: [true]
]

{ #category : #accessing }
HelpTopic >> isEditable: aBoolean [
	isEditable := aBoolean.
]

{ #category : #accessing }
HelpTopic >> key [

	^ key
]

{ #category : #accessing }
HelpTopic >> key: aSymbol [

	key := aSymbol.
]

{ #category : #accessing }
HelpTopic >> priority [
	"A hint for tools to influence sort order."
	
	^ priority
]

{ #category : #accessing }
HelpTopic >> priority: anInteger [

	priority := anInteger.
]

{ #category : #accessing }
HelpTopic >> shouldStyle [
	^ shouldStyle
]

{ #category : #accessing }
HelpTopic >> shouldStyle: aBoolean [
	shouldStyle := aBoolean.
]

{ #category : #operating }
HelpTopic >> sortSubtopicsByTitle [
	"Sort the subtopics by title"
	
	subtopics := self subtopics sorted
]

{ #category : #accessing }
HelpTopic >> subtopics [ 
	"Returns the receivers list of subtopics"
	
	^subtopics ifNil: [ subtopics := OrderedCollection new ]
]

{ #category : #accessing }
HelpTopic >> subtopics: aCollection [ 
	"Sets the receivers subtopics"
	
	subtopics := aCollection 
]

{ #category : #accessing }
HelpTopic >> title [
	"Returns the receivers title"
	
	^ title
]

{ #category : #accessing }
HelpTopic >> title: anObject [
	"Sets the receivers title"
	
	title := anObject
]

{ #category : #testing }
HelpTopic >> usesCodeStyling [

	^ self shouldStyle ifNil: [false]
]
