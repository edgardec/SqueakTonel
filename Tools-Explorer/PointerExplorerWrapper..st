"
A subclass of ObjectExplorerWrapper for use with PointerExplorer.  #contents is overridden to work backwards: it returns wrappers for the objects pointing to item rather than for the objects that item points to.
"
Class {
	#name : #PointerExplorerWrapper,
	#superclass : #ObjectExplorerWrapper,
	#instVars : [
		'weakOnly'
	],
	#category : #'Tools-Explorer'
}

{ #category : #converting }
PointerExplorerWrapper >> asString [

	^ self object identityHash asString, ': ', super asString.
]

{ #category : #accessing }
PointerExplorerWrapper >> contents [
	"Return the wrappers with the objects holding references to item. Eldest objects come first, weak only referencers are at the end and have parentheses around their identity hash."

	| objects weakOnlyReferences |
	objects := self object inboundPointersExcluding: { self. self item. model }.
	weakOnlyReferences := OrderedCollection new.
	objects removeAllSuchThat: [ :each |
		each class == self class 
			or: [ each class == PointerExplorer
			or: [ (each isContext
				and: [ (each objectClass: each receiver) == PointerExplorer ] )
			or: [ (each pointsOnlyWeaklyTo: self object)
				ifTrue: [ weakOnlyReferences add: each. true ]
				ifFalse: [ false ] ] ] ] ].
	 ^(objects replace: [ :each |	
		self class with: each name: (self nameForParent: each) model: self object ])
		addAll: (weakOnlyReferences replace: [ :each |
			(self class with: each name: '(', (self nameForParent: each), ')' model: self object)
				weakOnly: true;
				yourself ]);
		yourself
]

{ #category : #testing }
PointerExplorerWrapper >> hasContents [
	^true
]

{ #category : #testing }
PointerExplorerWrapper >> isWeakOnly [

	^weakOnly ifNil: [ false ] "This #ifNil: message is only here to avoid errors when updating an image with opened PointerExplorers."
]

{ #category : #accessing }
PointerExplorerWrapper >> memberNameFrom: aParent to: aChild [

	1 to: aParent class instSize do: [ :instVarIndex |
		(aParent instVarAt: instVarIndex) == aChild
			ifTrue: [ ^ '''', (aParent class instVarNameForIndex: instVarIndex), '''' ]].

	"This covers compiled methods and compiled blocks."
	aParent isCompiledCode ifTrue: [
		1 to: aParent numLiterals do: [ :index |
			(aParent literalAt: index) == aChild
				ifTrue: [^ 'literal', index asString]]].

	"This also covers arrays"
	1 to: aParent basicSize do: [ :index |
		(aParent basicAt: index) == aChild
			ifTrue: [^ index asString]].
	^ '???'
]

{ #category : #accessing }
PointerExplorerWrapper >> nameForParent: anObject [

	^  self memberNameFrom: anObject to: self object
]

{ #category : #accessing }
PointerExplorerWrapper >> preferredColor [

	^self isWeakOnly
		ifTrue: [ Color gray ]
		ifFalse: [ super preferredColor ]
]

{ #category : #accessing }
PointerExplorerWrapper >> weakOnly: aBoolean [

	weakOnly := aBoolean
]
