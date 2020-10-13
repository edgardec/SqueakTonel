"
This class implements a list item wrapper for help topics.

Instance Variables

"
Class {
	#name : #HelpTopicListItemWrapper,
	#superclass : #PluggableListItemWrapper,
	#instVars : [
		'parent'
	],
	#category : #'HelpSystem-Core-UI'
}

{ #category : #'instance creation' }
HelpTopicListItemWrapper class >> with: anObject model: aModel parent: aParent [

	^self new 
		setItem: anObject model: aModel parent: aParent

]

{ #category : #accessing }
HelpTopicListItemWrapper >> asString [
	"Returns a string used as a label"
	
	^ self item title
]

{ #category : #accessing }
HelpTopicListItemWrapper >> balloonText [
	"Returns a string used for fly by help"
	
	^self item title
]

{ #category : #accessing }
HelpTopicListItemWrapper >> contents [
	
	^self item subtopics sorted collect: [ :each | 
		HelpTopicListItemWrapper with: each model: self model parent: self]

]

{ #category : #accessing }
HelpTopicListItemWrapper >> hasContents [
	
	^ self item hasSubtopics
]

{ #category : #accessing }
HelpTopicListItemWrapper >> icon [
	"Either return the icon for the given topic"
	
	| symbol |
	self item icon ifNotNil: [:icon | ^ icon].
	symbol := self item hasSubtopics 
					 ifTrue: [#bookIcon] 
			  		 ifFalse: [#pageIcon].
	^HelpIcons iconNamed: symbol
]

{ #category : #accessing }
HelpTopicListItemWrapper >> item [

	^ super item ifNil: [HelpTopic new]
]

{ #category : #accessing }
HelpTopicListItemWrapper >> parent [

	^ parent
]

{ #category : #accessing }
HelpTopicListItemWrapper >> parent: aWrapper [

	parent := aWrapper.
]

{ #category : #initialization }
HelpTopicListItemWrapper >> setItem: anObject [

	item ifNotNil: [:obj | obj removeDependent: self].
	super setItem: anObject.
	item ifNotNil: [:obj | obj addDependent: self].
]

{ #category : #initialization }
HelpTopicListItemWrapper >> setItem: anObject model: aModel parent: itemParent [

	self parent: itemParent.
	self setItem: anObject model: aModel.
]

{ #category : #accessing }
HelpTopicListItemWrapper >> update: aspect [

	super update: aspect.
	
	"Map the domain-specific aspect to a framework-specific one."
	aspect = #subtopicsUpdated ifTrue: [
		self changed: #contents].
]

{ #category : #accessing }
HelpTopicListItemWrapper >> update: aspect with: object [

	super update: aspect with: object.
	
	"Map the domain-specific aspect to a framework-specific one."
	aspect = #subtopicAdded ifTrue: [
		self changed: #contents].
]
