Class {
	#name : #TextLink,
	#superclass : #TextAction,
	#instVars : [
		'classAndMethod'
	],
	#category : #'Collections-Text'
}

{ #category : #'fileIn\/Out' }
TextLink class >> scanCharacter [
	"The character used to identify a subclass of TextAttribute for filein and fileout"
	^$L
]

{ #category : #'fileIn\/Out' }
TextLink class >> scanFrom: strm [
	"read a link in the funny format used by Text styles on files. LPoint +;LPoint Comment;"

	^ self new classAndMethod: (strm upTo: $;)
]

{ #category : #comparing }
TextLink >> = other [ 
	^ (other class == self class) 
		and: [other info = self info]
]

{ #category : #'event handling' }
TextLink >> actOnClickFor: aMessageSet [
	"Add to the end of the list.  'aClass selector', 'aClass Comment', 'aClass Definition', 'aClass Hierarchy' are the formats allowed."

	aMessageSet addItem: classAndMethod.
	^ true
]

{ #category : #'initialize-release' }
TextLink >> analyze: aString [

	| list |
	list := super analyze: aString.
	classAndMethod := list at: 1.
	^ list at: 2
]

{ #category : #'initialize-release' }
TextLink >> analyze: aString with: nonMethod [
	"Initalize this attribute holder with a piece text the user typed into a paragraph.  Returns the text to emphesize (may be different from selection)  Does not return self!.  nonMethod is what to show when clicked, i.e. the last part of specifier (Comment, Definition, or Hierarchy).  May be of the form:
Point
<Point>
Click Here<Point>
<Point>Click Here
"
	"Obtain the showing text and the instructions"
	| b1 b2 trim |
	b1 := aString indexOf: $<.
	b2 := aString indexOf: $>.
	(b1 < b2) & (b1 > 0) ifFalse: ["only one part"
		classAndMethod := self validate: aString, ' ', nonMethod.
		^ classAndMethod ifNotNil: [aString]].
	"Two parts"
	trim := aString withBlanksTrimmed.
	(trim at: 1) == $< 
		ifTrue: [(trim last) == $>
			ifTrue: ["only instructions" 
				classAndMethod := self validate: (aString copyFrom: b1+1 to: b2-1), ' ', nonMethod.
				^ classAndMethod ifNotNil: [classAndMethod]]
			ifFalse: ["at the front"
				classAndMethod := self validate: (aString copyFrom: b1+1 to: b2-1), ' ', nonMethod.
				^ classAndMethod ifNotNil: [aString copyFrom: b2+1 to: aString size]]]
		ifFalse: [(trim last) == $>
			ifTrue: ["at the end"
				classAndMethod := self validate: (aString copyFrom: b1+1 to: b2-1), ' ', nonMethod.
				^ classAndMethod ifNotNil: [aString copyFrom: 1 to: b1-1]]
			ifFalse: ["Illegal -- <> has text on both sides"
				^ nil]]

]

{ #category : #accessing }
TextLink >> classAndMethod: aString [
	classAndMethod := aString
]

{ #category : #comparing }
TextLink >> hash [
	"#hash is re-implemented because #= is re-implemented"
	^classAndMethod hash
]

{ #category : #accessing }
TextLink >> info [
	^ classAndMethod
]

{ #category : #'initialize-release' }
TextLink >> validate: specString [
	"Can this string be decoded to be Class space Method (or Comment, Definition, Hierarchy)? If so, return it in valid format, else nil" 

	| list first mid last |
	list := specString findTokens: ' 	.|'.
	list isEmpty ifTrue: [ ^nil ].
	last := list last.
	last first isUppercase ifTrue: [
		(#('Comment' 'Definition' 'Hierarchy') includes: last) ifFalse: [^ nil].
		"Check for 'Rectangle Comment Comment' and remove last one"
		(list at: list size - 1 ifAbsent: [^nil]) = last ifTrue: [list := list allButLast]].
	list size > 3 ifTrue: [^ nil].
	list size < 2 ifTrue: [^ nil].
	Symbol hasInterned: list first ifTrue: [:sym | first := sym].
	first ifNil: [^ nil].
	Smalltalk at: first ifAbsent: [^ nil].
	mid := list size = 3 
		ifTrue: [(list at: 2) = 'class' ifTrue: ['class '] ifFalse: [^ nil]]
		ifFalse: [''].
	"OK if method name is not interned -- may not be defined yet"
	^ first, ' ', mid, last
]

{ #category : #'fileIn\/fileOut' }
TextLink >> writeScanOn: strm [

	strm nextPut: self class scanCharacter; nextPutAll: classAndMethod; nextPut: $;
]
