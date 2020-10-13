"
ObjectExplorerWrappers represent an item displayed in an object explorer tree. In addition to the common ListItemWrapper behavior it adds methods to refresh the list entry with updated values from the model. It is mostly used in #explorerContents methods to describe which instance variables of an object should be displayed in the explorer.

Additionally, the value displayed can be visualized with a small icon which is defined by the class of the value object through the method #iconOrThumbnailOfSize:.

Contributed by Bob Arning as part of the ObjectExplorer package.

"
Class {
	#name : #ObjectExplorerWrapper,
	#superclass : #ListItemWrapper,
	#instVars : [
		'itemName',
		'parent'
	],
	#classVars : [
		'ShowContentsInColumns'
	],
	#category : #'Morphic-Explorer'
}

{ #category : #'instance creation' }
ObjectExplorerWrapper class >> forError: message [
	
	^ ObjectExplorerWrapper
		with: message
		name: '<error>' translated
		model: nil
]

{ #category : #preferences }
ObjectExplorerWrapper class >> showClassIcons [
	^ Browser showClassIcons
]

{ #category : #preferences }
ObjectExplorerWrapper class >> showClassIcons: aBoolean [
	Browser showClassIcons: aBoolean.
]

{ #category : #preferences }
ObjectExplorerWrapper class >> showContentsInColumns [
	<preference: 'Use columns in object explorer'
		categoryList: #(Tools exploring)
		description: 'If enabled, the object explorer will show key in the first column and values in the second column.'
		type: #Boolean>
	^ ShowContentsInColumns ifNil: [true]
]

{ #category : #preferences }
ObjectExplorerWrapper class >> showContentsInColumns: aBoolean [

	ShowContentsInColumns := aBoolean.
]

{ #category : #'instance creation' }
ObjectExplorerWrapper class >> with: anObject name: aString model: aModel [

	^self new 
		setItem: anObject name: aString model: aModel
]

{ #category : #'instance creation' }
ObjectExplorerWrapper class >> with: anObject name: aString model: aModel parent: aParent [

	^self new 
		setItem: anObject name: aString model: aModel parent: aParent

]

{ #category : #converting }
ObjectExplorerWrapper >> asString [
	| explorerString label separator |
	explorerString := 
		[self objectString]
			on: Error 
			do: ['<error: ', self object class name, ' in asExplorerString: evaluate "' , self itemName , ' asExplorerString" to debug>'].
	(explorerString includes: Character cr)
		ifTrue: [explorerString := explorerString withSeparatorsCompacted].

	label := self itemName ifNil: [''].
	(label includes: Character cr)
		ifTrue: [label := label withSeparatorsCompacted].
	 
	separator := self class showContentsInColumns
		ifTrue: [String tab]
		ifFalse: [label ifEmpty: [''] ifNotEmpty: [': ']].

	^ '{1}{2}{3}' format: {label. separator. explorerString}
]

{ #category : #accessing }
ObjectExplorerWrapper >> contents [

	^ [self object explorerContents
		do: [:wrapper | wrapper parent: self];
		yourself] ifError: [:msg | {self class forError: msg}]
]

{ #category : #accessing }
ObjectExplorerWrapper >> hasContents [

	^ self object hasContentsInExplorer
	

]

{ #category : #accessing }
ObjectExplorerWrapper >> icon [
	"Answer a form to be used as icon"
	^ Preferences visualExplorer
		ifTrue: [([self object iconOrThumbnailOfSize: 12] on: Error do: [nil])
			ifNil: [self class showClassIcons
				ifTrue: [ToolIcons iconNamed: self object class theNonMetaClass toolIcon]
				ifFalse: [self class showContentsInColumns
					ifTrue: [ToolIcons iconNamed: #blank] 
					ifFalse: [nil]]]]
		ifFalse: [nil]
]

{ #category : #accessing }
ObjectExplorerWrapper >> itemName [

	^ self item key
]

{ #category : #accessing }
ObjectExplorerWrapper >> itemName: newName [

	self item key: newName.
]

{ #category : #accessing }
ObjectExplorerWrapper >> object [

	^ self item value
]

{ #category : #accessing }
ObjectExplorerWrapper >> object: anObject [

	self item value: anObject.
]

{ #category : #accessing }
ObjectExplorerWrapper >> objectString [
	"Answers a string representation of the object that well be combined with #itemName when requested from the tree model. Overwrite this in custom wrappers to modify parent-specific representations without having to modify #asExplorerString in the particular object."
	
	^ self object asExplorerString
]

{ #category : #accessing }
ObjectExplorerWrapper >> parent [
	^ parent
]

{ #category : #accessing }
ObjectExplorerWrapper >> parent: aWrapper [
	
	parent := aWrapper.
]

{ #category : #monitoring }
ObjectExplorerWrapper >> refresh [
	
	self parent ifNil: [^ self].
	[model explorerContents detect: [:wrapper | wrapper itemName = self itemName]
		ifFound: [:wrapper | ^ self object: wrapper object ]
		ifNone: [^ self object: nil]] 
			on: Error 
			do: [ :ex | self object: nil ]
]

{ #category : #initialization }
ObjectExplorerWrapper >> setItem: anObject name: aString model: aModel [

	self setItem: aString -> anObject model: aModel.
]

{ #category : #initialization }
ObjectExplorerWrapper >> setItem: anObject name: aString model: aModel parent: itemParent [

	self parent: itemParent.
	self setItem: anObject name: aString model: aModel
]
