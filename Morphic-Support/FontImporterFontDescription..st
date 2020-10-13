Class {
	#name : #FontImporterFontDescription,
	#superclass : #Object,
	#instVars : [
		'fontname',
		'filename',
		'children',
		'parent'
	],
	#category : #'Morphic-Support'
}

{ #category : #comparing }
FontImporterFontDescription >> <= other [

	^ self fontname asString <= other fontname asString
]

{ #category : #accessing }
FontImporterFontDescription >> addChild: aChild [

	^ self children add: aChild
]

{ #category : #accessing }
FontImporterFontDescription >> allFilenames [

	^ self filename
		ifNil: [
			(self children
				select: [:child | child filename notNil]
				thenCollect: [:child | child filename])
			asSet asArray]
		ifNotNil: [:f | {f}] 
]

{ #category : #accessing }
FontImporterFontDescription >> children [

	^ children ifNil: [children := OrderedCollection new].
]

{ #category : #accessing }
FontImporterFontDescription >> children: anObject [

	children := anObject
]

{ #category : #accessing }
FontImporterFontDescription >> filename [

	^ filename
]

{ #category : #accessing }
FontImporterFontDescription >> filename: anObject [

	filename := anObject
]

{ #category : #accessing }
FontImporterFontDescription >> fontname [

	^ fontname
]

{ #category : #accessing }
FontImporterFontDescription >> fontname: anObject [

	fontname := anObject
]

{ #category : #testing }
FontImporterFontDescription >> hasChildren [

	^ self children notNil and: [self children notEmpty]
]

{ #category : #actions }
FontImporterFontDescription >> normalize [

	self children size = 1 ifTrue: [ | pseudoChild |
		pseudoChild := self children removeFirst.
		(self filename notNil and: [pseudoChild filename ~=  self filename])
			ifTrue: [self error: 'Inconsistent state'].
		self filename: pseudoChild filename]
]

{ #category : #accessing }
FontImporterFontDescription >> parent [

	^ parent
]

{ #category : #accessing }
FontImporterFontDescription >> parent: anObject [

	parent := anObject
]

{ #category : #printing }
FontImporterFontDescription >> printOn: aStream [

	self parent ifNotNil: [:p | aStream nextPutAll: p fontname; nextPut: $ ].
	aStream nextPutAll: self fontname.
	self children notEmpty ifTrue: [aStream nextPut: $ ].
	self children
		do: [:subfont | aStream nextPutAll: subfont fontname]
		separatedBy: [aStream nextPut: $/].
	aStream nextPut: $ ; nextPut: $(.
	self allFilenames
		do: [:filename | aStream nextPutAll: filename]
		separatedBy: [aStream nextPut: $,; nextPut: $ ].
	aStream nextPut: $).

]
