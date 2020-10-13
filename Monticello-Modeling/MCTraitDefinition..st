Class {
	#name : #MCTraitDefinition,
	#superclass : #MCClassDefinition,
	#category : #'Monticello-Modeling'
}

{ #category : #'instance creation' }
MCTraitDefinition class >> name: classNameString traitComposition:  traitCompositionString category:  categoryString comment:  commentString commentStamp:   commentStamp [
	^ self instanceLike:
		(self new initializeWithName: classNameString 
			traitComposition:  traitCompositionString
			category:  categoryString
			comment:  commentString  
			commentStamp:   commentStamp)

]

{ #category : #visiting }
MCTraitDefinition >> = aDefinition [
	self flag: #traits. "Ugly we harcoded the super superclass method.  We will have to refactor the definition hierarchy"
	
	^ (aDefinition isKindOf: MCDefinition)
		and: [(self isRevisionOf: aDefinition)
		and: [self traitCompositionString = aDefinition traitCompositionString
		and: [category = aDefinition category
		and: [comment = aDefinition comment]]]]
]

{ #category : #visiting }
MCTraitDefinition >> accept: aVisitor [
	^ aVisitor visitTraitDefinition: self

]

{ #category : #accessing }
MCTraitDefinition >> classTraitCompositionString [
	^self traitComposition ifNil: ['{}'].
]

{ #category : #visiting }
MCTraitDefinition >> createClass [
	^ClassDescription
		newTraitNamed: name
		uses: (Compiler evaluate: self traitCompositionString)
		category: category
		in: Environment current
		

]

{ #category : #testing }
MCTraitDefinition >> hasClassInstanceVariables [
	^ false


]

{ #category : #testing }
MCTraitDefinition >> hasTraitComposition [
	^self traitCompositionString ~= '{}'
]

{ #category : #comparing }
MCTraitDefinition >> hash [

	| hash |
	hash := name hashWithInitialHash: 0.
	hash := self traitCompositionString hashWithInitialHash: hash.
	hash := (category ifNil: ['']) hashWithInitialHash: hash.
	^hash

]

{ #category : #initializing }
MCTraitDefinition >> initializeWithName: classNameString 
	traitComposition:  traitCompositionString
	category:  categoryString
	comment:  commentString  
	commentStamp:   commentStampString [
					
		name := classNameString asSymbol.
		traitComposition := traitCompositionString.
	     category := categoryString.
		comment := commentString withSqueakLineEndings.
		commentStamp :=  commentStampString ifNil: [self defaultCommentStamp]

]

{ #category : #installing }
MCTraitDefinition >> load [
	 self createClass ifNotNil: [:trait |
		self hasComment ifTrue: [trait classComment: comment stamp: commentStamp]]
]

{ #category : #printing }
MCTraitDefinition >> printClassSideDefinitionOn: stream [
	stream
		nextPutAll: self className;
		nextPutAll: ' classTrait ';
		cr; tab;
		nextPutAll: 'uses: ';
 		nextPutAll: self classTraitCompositionString
]

{ #category : #printing }
MCTraitDefinition >> printDefinitionOn: stream [
	stream nextPutAll: 'Trait named: #', self className;
		 cr;
		 tab;
		 nextPutAll: 'uses: ';
		 nextPutAll: self traitCompositionString;
		 cr;
		 tab;
		 nextPutAll: 'category: ';
		 store: self category asString

]

{ #category : #comparing }
MCTraitDefinition >> requirements [
	"Assuming that traits in a composition can be identified by
	testing for the first character beeing an uppercase character
	(and thus not a special character such as {, # etc.)"

	| tokens traitNames |
	self hasTraitComposition ifFalse: [ ^Array empty ].
	tokens := (Scanner new scanTokens: self traitComposition) flattened.
	traitNames := tokens select: [:each | each first isUppercase].
	^traitNames asArray
]

{ #category : #accessing }
MCTraitDefinition >> traitComposition [
	^traitComposition
]
