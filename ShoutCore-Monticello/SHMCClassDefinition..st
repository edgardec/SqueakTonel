Class {
	#name : #SHMCClassDefinition,
	#superclass : #Object,
	#instVars : [
		'classDefinition',
		'items',
		'meta'
	],
	#category : #'ShoutCore-Monticello'
}

{ #category : #'as yet unclassified' }
SHMCClassDefinition class >> classDefinition: aMCClassDefinition items: anObject meta: aBoolean [
	^self new
		classDefinition: aMCClassDefinition;
		items: anObject;
		meta: aBoolean;
		yourself
]

{ #category : #'act like a class' }
SHMCClassDefinition >> allInstVarNames [
	| superclassOrDef answer classOrDef instVars|
	
	answer := meta
		ifTrue:[classDefinition classInstVarNames asArray]
		ifFalse:[	classDefinition instVarNames asArray].
	classOrDef := classDefinition.
	[superclassOrDef := (classOrDef isKindOf: MCClassDefinition)
		ifTrue:[ |s|
			s := classOrDef superclassName.
			items 
				detect: [:ea | ea isClassDefinition and: [ea className = s]]
				ifNone: [Smalltalk at: s asSymbol ifAbsent:[nil]]]
		ifFalse:[ | sc |
			sc := classOrDef superclass.
			sc ifNotNil:[
				items 
					detect: [:ea | ea isClassDefinition and: [ea className = sc name asString]]
					ifNone: [sc]	]].
	superclassOrDef isNil
	] whileFalse:[
		instVars := (superclassOrDef isKindOf: MCClassDefinition)
			ifTrue:[
				meta 
					ifTrue:[superclassOrDef classInstVarNames]
					ifFalse:[superclassOrDef instVarNames]]
			ifFalse:["real"
				meta
					ifTrue:[superclassOrDef theNonMetaClass class  instVarNames]
					ifFalse:[superclassOrDef theNonMetaClass instVarNames]].		
		answer := answer, instVars.
		classOrDef := superclassOrDef].
	^answer
]

{ #category : #'act like a class' }
SHMCClassDefinition >> allowUnderscoreAssignments [

	^nil
]

{ #category : #'act like environment' }
SHMCClassDefinition >> bindingOf: aSymbol [
	| binding |
	(binding := Smalltalk bindingOf: aSymbol)
		ifNotNil: [^binding].
	items do:[:each |
		(each isClassDefinition and: [each className = aSymbol])
			ifTrue:[^aSymbol -> each]].
	^nil
]

{ #category : #accessing }
SHMCClassDefinition >> classDefinition: aMCClassDefinition [
	classDefinition := aMCClassDefinition
]

{ #category : #'act like a class' }
SHMCClassDefinition >> classPool [
	| d |
	d := Dictionary new.
	classDefinition classVarNames do:[:each |
		d at: each put: nil].
	^d
]

{ #category : #'act like a class' }
SHMCClassDefinition >> environment [
	^self
]

{ #category : #'act like environment' }
SHMCClassDefinition >> hasBindingThatBeginsWith: aString [

	(Smalltalk globals hasBindingThatBeginsWith: aString) ifTrue: [^true].
	items do:[:each |
		(each isClassDefinition and: [each className beginsWith: aString])
			ifTrue:[^true]].
	^false
]

{ #category : #accessing }
SHMCClassDefinition >> items: anObject [
	items := anObject
]

{ #category : #accessing }
SHMCClassDefinition >> meta: aBoolean [
	meta := aBoolean
]

{ #category : #'act like a class' }
SHMCClassDefinition >> sharedPools [
	| d |
	d := Set new.
	classDefinition poolDictionaries do:
		[:poolName|
		(Smalltalk at: poolName asSymbol ifAbsent:[nil]) ifNotNil: [:pool| d add: pool]].
	^d
]

{ #category : #'act like a class' }
SHMCClassDefinition >> shoutParserClass [
	"Answer the parser class"
	^SHParserST80
]

{ #category : #'act like a class' }
SHMCClassDefinition >> theNonMetaClass [
	^self copy meta: false; yourself
]

{ #category : #'act like a class' }
SHMCClassDefinition >> withAllSuperclasses [

	| result |
	result := OrderedCollection new.
	self withAllSuperclassesDo: [ :each | result addFirst: each ].
	^result
]

{ #category : #'act like a class' }
SHMCClassDefinition >> withAllSuperclassesDo: aBlock [

	| superclassOrDef classOrDef |
	aBlock value: self.
	classOrDef := classDefinition.
	[ 
		superclassOrDef := (classOrDef isKindOf: MCClassDefinition)
			ifTrue: [
				| superclassName |
				superclassName := classOrDef superclassName.
				items 
					detect: [ :each | 
						each isClassDefinition and: [
							each className = superclassName ] ]
					ifNone: [ Smalltalk classNamed: superclassName ] ]
			ifFalse: [ 
				classOrDef superclass ifNotNil: [ :superclass |
					| superclassName |
					superclassName := superclass name asString.
					items 
						detect: [ :each | 
							each isClassDefinition and: [
								each className = superclassName ] ]
						ifNone: [ superclass ] ] ].
		superclassOrDef isNil ] 
		whileFalse: [
			aBlock value: (superclassOrDef isBehavior
							ifTrue: [superclassOrDef]
							ifFalse: [(superclassOrDef isKindOf: SHMCClassDefinition)
										ifTrue: [superclassOrDef]
										ifFalse: [SHMCClassDefinition 
													classDefinition: superclassOrDef 
													items: items 
													meta: (superclassOrDef className includes: $ )]]).
			classOrDef := superclassOrDef ]
]
