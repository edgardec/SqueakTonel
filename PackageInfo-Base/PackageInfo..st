"
PackageInfo is used by the system to figure out which classes and methods belong to which package. By default, class categories and method categories are matched against my packageName, but subclasses could override this behavior.

For an interesting use of PackageInfo subclasses have a look at OMeta2. It presents the same code base as two different packages, one using decompiled code for bootstrapping, the other using the actual OMeta syntax.
"
Class {
	#name : #PackageInfo,
	#superclass : #Object,
	#instVars : [
		'packageName',
		'methodCategoryPrefix',
		'preamble',
		'postscript',
		'preambleOfRemoval',
		'postscriptOfRemoval'
	],
	#classInstVars : [
		'default'
	],
	#category : #'PackageInfo-Base'
}

{ #category : #'packages access' }
PackageInfo class >> allPackages [
	^PackageOrganizer default packages
]

{ #category : #compatibility }
PackageInfo class >> default [
	^ self allPackages detect: [:ea | ea class = self] ifNone: [self new register]
]

{ #category : #'class initialization' }
PackageInfo class >> initialize [
	self allSubclassesDo: [:ea | ea new register]
]

{ #category : #'packages access' }
PackageInfo class >> named: aString [
	^ Environment current packageOrganizer packageNamed: aString ifAbsent: [(self new packageName: aString) register]
]

{ #category : #'registration \/ unregistration' }
PackageInfo class >> registerPackage: aString [
	"for compatibility with old fileOuts"
	^ Smalltalk at: #FilePackageManager ifPresent: [:p | p registerPackage: aString]
]

{ #category : #'registration \/ unregistration' }
PackageInfo class >> registerPackageName: aString [
	^ PackageOrganizer default registerPackageNamed: aString
]

{ #category : #comparing }
PackageInfo >> = other [
	^ other species = self species and: [other packageName = self packageName]
]

{ #category : #enumerating }
PackageInfo >> actualMethodsDo: aBlock [
	"Evaluate aBlock with the actual method objects in this package."
	| enum |
	self extensionMethods do:
		[:mr|
		aBlock value: mr compiledMethod].
	enum := [:behavior|
			behavior organization categories do:
				[:cat|
				(self isForeignClassExtension: cat) ifFalse:
					[(behavior organization listAtCategoryNamed: cat) do:
						[:s|
						aBlock value: (behavior compiledMethodAt: s)]]]].
	self classes do:
		[:c| enum value: c; value: c classSide]
		
]

{ #category : #modifying }
PackageInfo >> addCoreMethod: aMethodReference [
	| category |
	category := self baseCategoryOfMethod: aMethodReference.
	aMethodReference actualClass organization
		classify: aMethodReference methodSymbol
		under: category
		suppressIfDefault: false
]

{ #category : #modifying }
PackageInfo >> addExtensionMethod: aMethodReference [
	| category |
	category := self baseCategoryOfMethod: aMethodReference.
	aMethodReference actualClass organization
		classify: aMethodReference methodSymbol
		under: self methodCategoryPrefix, '-', category
]

{ #category : #modifying }
PackageInfo >> addMethod: aMethodReference [
	(self includesClass: aMethodReference class)
		ifTrue: [self addCoreMethod: aMethodReference]
		ifFalse: [self addExtensionMethod: aMethodReference]
]

{ #category : #listing }
PackageInfo >> allOverriddenMethods [
	"search classes and meta classes"
	^ Array streamContents: [:stream |
		self allOverriddenMethodsDo: [:each | stream nextPut: each]]

]

{ #category : #enumerating }
PackageInfo >> allOverriddenMethodsDo: aBlock [
	"Evaluates aBlock with all the overridden methods in the system"
	^ ProtoObject withAllSubclassesDo: [:class | 
		self overriddenMethodsInClass: class do: aBlock]

]

{ #category : #modifying }
PackageInfo >> baseCategoryOfMethod: aMethodReference [
	| oldCat oldPrefix tokens | 
	oldCat := aMethodReference category.
	({ 'as yet unclassified'. 'all' } includes: oldCat) ifTrue: [ oldCat := '' ].
	tokens := oldCat findTokens: '*-' keep: '*'.

	"Strip off any old prefixes"
	((tokens at: 1 ifAbsent: [ '' ]) = '*') ifTrue: [
		[ ((tokens at: 1 ifAbsent: [ '' ]) = '*') ]
			whileTrue: [ tokens removeFirst ].
		oldPrefix := tokens removeFirst asLowercase.
		[ (tokens at: 1 ifAbsent: [ '' ]) asLowercase = oldPrefix ]
			whileTrue: [ tokens removeFirst ].
	].

	tokens isEmpty ifTrue: [^ 'as yet unclassified'].
	^ String streamContents:
		[ :s |
		tokens
			do: [ :tok | s nextPutAll: tok ]
			separatedBy: [ s nextPut: $- ]]
]

{ #category : #testing }
PackageInfo >> category: categoryName matches: prefix [
	| prefixSize catSize |
	categoryName ifNil: [ ^false ].
	catSize := categoryName size.
	prefixSize := prefix size.
	catSize < prefixSize ifTrue: [ ^false ].
	(categoryName findString: prefix startingAt: 1 caseSensitive: false) = 1
		ifFalse: [ ^false ].
	^(categoryName at: prefix size + 1 ifAbsent: [ ^true ]) = $-
]

{ #category : #naming }
PackageInfo >> categoryName [
	|category|
	category := self class category.
	^ (category endsWith: '-Info')
		ifTrue: [category copyUpToLast: $-]
		ifFalse: [category]
]

{ #category : #testing }
PackageInfo >> changeRecordForOverriddenMethod: aMethodReference [
	self changeRecordsForMethod: aMethodReference do: [:record |
		(self includesMethodCategory: record category
			ofClass: aMethodReference actualClass)
				ifTrue: [^record]].
	^nil
]

{ #category : #enumerating }
PackageInfo >> changeRecordsForMethod: aMethodReference do: aBlock [
	"Evaluate aBlock with one ChangeRecord per overriding package, followed by the latest non-override"
	| overridingPackages method position sourceFilesCopy |
	overridingPackages := Set new.
	method := aMethodReference compiledMethod.
	position := method filePosition.
	sourceFilesCopy := SourceFiles collect: [:x | x ifNotNil: [x readOnlyCopy]].
	[ | file prevPos prevFileIndex chunk stamp methodCategory methodPackage tokens |
	method fileIndex = 0 ifTrue: [^ nil].
	file := sourceFilesCopy at: method fileIndex.
	[position notNil & file notNil]
		whileTrue:
		[file position: (0 max: position-150).  "Skip back to before the preamble"
		[file position < (position-1)]  "then pick it up from the front"
			whileTrue: [chunk := file nextChunk].

		"Preamble is likely a linked method preamble, if we're in
			a changes file (not the sources file).  Try to parse it
			for prior source position and file index"
		prevPos := nil.
		stamp := ''.
		(chunk findString: 'methodsFor:' startingAt: 1) > 0
			ifTrue: [tokens := Scanner new scanTokens: chunk]
			ifFalse: [tokens := Array new  "ie cant be back ref"].
		((tokens size between: 7 and: 8)
			and: [(tokens at: tokens size-5) = #methodsFor:])
			ifTrue:
				[(tokens at: tokens size-3) = #stamp:
				ifTrue: ["New format gives change stamp and unified prior pointer"
						stamp := tokens at: tokens size-2.
						prevPos := tokens last.
						prevFileIndex := sourceFilesCopy fileIndexFromSourcePointer: prevPos.
						prevPos := sourceFilesCopy filePositionFromSourcePointer: prevPos]
				ifFalse: ["Old format gives no stamp; prior pointer in two parts"
						prevPos := tokens at: tokens size-2.
						prevFileIndex := tokens last].
				(prevPos = 0 or: [prevFileIndex = 0]) ifTrue: [prevPos := nil]].
		((tokens size between: 5 and: 6)
			and: [(tokens at: tokens size-3) = #methodsFor:])
			ifTrue:
				[(tokens at: tokens size-1) = #stamp:
				ifTrue: ["New format gives change stamp and unified prior pointer"
						stamp := tokens at: tokens size]].
		methodCategory := tokens after: #methodsFor: ifAbsent: [ClassOrganizer default].
		methodPackage := PackageOrganizer default packageOfMethodCategory: methodCategory ofClass: aMethodReference actualClass ifNone: [#unknown].
		(overridingPackages includes: methodPackage)
			ifFalse: [aBlock value: (ChangeRecord new
				file: file position: position type: #method
				class: aMethodReference classSymbol category: methodCategory
				meta: aMethodReference classIsMeta stamp: stamp)].
		(self isOverrideCategory: methodCategory)
			ifTrue: [overridingPackages add: methodPackage]
			ifFalse: [(overridingPackages includes: methodPackage)
				ifFalse: [^nil]].
		position := prevPos.
		prevPos notNil ifTrue:
			[file := sourceFilesCopy at: prevFileIndex]].
		^nil]
			ensure: [sourceFilesCopy do: [:x | x ifNotNil: [x close]]]
	
]

{ #category : #listing }
PackageInfo >> classes [
	| environment organization |
	environment := Environment  current.
	organization := environment organization.
	^(self systemCategories gather:
		[:cat |
		(organization listAtCategoryNamed: cat)
			collect: [:className | environment valueOf: className]])
				sorted: [:a :b | a className <= b className]
]

{ #category : #listing }
PackageInfo >> classesAndMetaClasses [
	"Return a Set with all classes and metaclasses belonging to this package"

	| baseClasses result |
	baseClasses := self classes.
	result := (Set new: baseClasses size * 2) 
		addAll: baseClasses;
		yourself.
	baseClasses do: [ :c | 
		result add: c classSide].
	^result

]

{ #category : #testing }
PackageInfo >> coreCategoriesForClass: aClass [
	^ aClass organization categories select: [:cat | (self isForeignClassExtension: cat) not]
]

{ #category : #listing }
PackageInfo >> coreMethods [
	^ self classesAndMetaClasses gather: [:class | self coreMethodsForClass: class]
]

{ #category : #testing }
PackageInfo >> coreMethodsForClass: aClass [
	^ (aClass selectors difference:
		((self foreignExtensionMethodsForClass: aClass) collect: [:r | r methodSymbol]))
			asArray collect: [:sel | self referenceForMethod: sel ofClass: aClass]
]

{ #category : #testing }
PackageInfo >> extensionCategoriesForClass: aClass [
	^ aClass organization categories select: [:cat | self isYourClassExtension: cat]
]

{ #category : #listing }
PackageInfo >> extensionClasses [
	^ self externalBehaviors reject: [:classOrTrait | (self extensionCategoriesForClass: classOrTrait) isEmpty]
]

{ #category : #listing }
PackageInfo >> extensionMethods [
	^ self externalBehaviors gather: [:classOrTrait | self extensionMethodsForClass: classOrTrait]
]

{ #category : #testing }
PackageInfo >> extensionMethodsForClass: aClass [
	^ (self extensionCategoriesForClass: aClass)
		gather: [:cat | self methodsInCategory: cat ofClass: aClass ]
]

{ #category : #testing }
PackageInfo >> extensionMethodsFromClasses: classes [
	^classes
		gather: [:class | self extensionMethodsForClass: class]
]

{ #category : #modifying }
PackageInfo >> externalBehaviors [
	^self externalClasses , self externalTraits
]

{ #category : #dependencies }
PackageInfo >> externalCallers [
	^ self 
		externalRefsSelect: [:literal | literal isKindOf: Symbol] 
		thenCollect: [:l | l].
]

{ #category : #dependencies }
PackageInfo >> externalClasses [
	| myClasses |
	myClasses := self classesAndMetaClasses.
	^ Array streamContents:
		[:s |
		ProtoObject withAllSubclassesDo:
			[:class |
			(myClasses includes: class) ifFalse: [s nextPut: class]]]
]

{ #category : #naming }
PackageInfo >> externalName [
	^ self packageName
]

{ #category : #dependencies }
PackageInfo >> externalRefsSelect: selBlock thenCollect: colBlock [
	| pkgMethods dependents extMethods otherClasses otherMethods classNames |

	classNames := self classes collect: [:c | c name].
	extMethods := self extensionMethods collect: [:mr | mr methodSymbol].
	otherClasses := self externalClasses difference: self externalSubclasses.
	otherMethods :=  otherClasses gather: [:c | c selectors].
	pkgMethods := self methods asSet collect: [:mr | mr methodSymbol].
	pkgMethods removeAllFoundIn: otherMethods.

	dependents := Set new.
	otherClasses do: [:c |
		c selectorsAndMethodsDo:
			[:sel :compiled |
			| refs |
			(extMethods includes: sel) ifFalse: 
				[refs := compiled literals select: selBlock thenCollect: colBlock.
				refs do: [:ea |
					((classNames includes: ea) or: [pkgMethods includes: ea])
							ifTrue: [dependents add: (self referenceForMethod: sel ofClass: c) -> ea]]]]].
	^ dependents
]

{ #category : #dependencies }
PackageInfo >> externalSubclasses [
	| pkgClasses subClasses |
	pkgClasses := self classes.
	subClasses := Set new.
	pkgClasses do: [:c | subClasses addAll: (c allSubclasses)].
	^ subClasses difference: pkgClasses

]

{ #category : #modifying }
PackageInfo >> externalTraits [
	^ Array streamContents: [:s |
		| behaviors |
		behaviors := self classesAndMetaClasses.
		Environment current allTraits do: [:trait |
			(behaviors includes: trait) ifFalse: [s nextPut: trait].
			(behaviors includes: trait classSide) ifFalse: [s nextPut: trait classSide]]].			
]

{ #category : #dependencies }
PackageInfo >> externalUsers [
	^ self 
		externalRefsSelect: [:literal | literal isVariableBinding] 
		thenCollect: [:l | l key]
]

{ #category : #listing }
PackageInfo >> foreignClasses [
	| s environment |
	s := IdentitySet new.
	environment := Environment current.
	self foreignSystemCategories
		do: [:c | (SystemOrganization listAtCategoryNamed: c)
				do: [:cl | 
					| cls | 
					cls := environment valueOf: cl.
					s add: cls;
					  add: cls class]].
	^ s
]

{ #category : #testing }
PackageInfo >> foreignExtensionCategoriesForClass: aClass [
	^ aClass organization categories select: [:cat | self isForeignClassExtension: cat]
]

{ #category : #testing }
PackageInfo >> foreignExtensionMethodsForClass: aClass [
	^ (self foreignExtensionCategoriesForClass: aClass)
		gather: [:cat | (aClass organization listAtCategoryNamed: cat)
						  collect: [:sel | self referenceForMethod: sel ofClass: aClass]]
]

{ #category : #listing }
PackageInfo >> foreignSystemCategories [
	^ SystemOrganization categories
		reject: [:cat | self includesSystemCategory: cat] 
]

{ #category : #'preamble\/postscript' }
PackageInfo >> hasPostscript [
	^ self isScript: postscript not: self postscriptDefault
]

{ #category : #'preamble\/postscript' }
PackageInfo >> hasPostscriptOfRemoval [
	^ self isScript: postscriptOfRemoval not: self postscriptOfRemovalDefault
]

{ #category : #'preamble\/postscript' }
PackageInfo >> hasPreamble [
	^ self isScript: preamble not: self preambleDefault
]

{ #category : #'preamble\/postscript' }
PackageInfo >> hasPreambleOfRemoval [
	^ self isScript: preambleOfRemoval not: self preambleOfRemovalDefault
]

{ #category : #comparing }
PackageInfo >> hash [
	^ packageName hash
]

{ #category : #testing }
PackageInfo >> includesChangeRecord: aChangeRecord [
	^ aChangeRecord methodClass notNil and:
		[self
			includesMethodCategory: aChangeRecord category
			ofClass: aChangeRecord methodClass]
]

{ #category : #testing }
PackageInfo >> includesClass: aClass [
	^ self includesSystemCategory: aClass category
]

{ #category : #testing }
PackageInfo >> includesClassNamed: aClassName [
	^ self includesSystemCategory: ((SystemOrganization categoryOfElement: aClassName) ifNil: [^false])
]

{ #category : #testing }
PackageInfo >> includesMethod: aSymbol ofClass: aClass [
	aClass ifNil: [^ false].
	^ self
		includesMethodCategory: ((aClass organization categoryOfElement: aSymbol)
										ifNil: [' '])
		ofClass: aClass
]

{ #category : #testing }
PackageInfo >> includesMethodCategory: categoryName ofClass: aClass [
	^ (self isYourClassExtension: categoryName)
		or: [(self includesClass: aClass)
				and: [(self isForeignClassExtension: categoryName) not]]
]

{ #category : #testing }
PackageInfo >> includesMethodCategory: categoryName ofClassNamed: aClass [
	^ (self isYourClassExtension: categoryName)
		or: [(self includesClassNamed: aClass)
				and: [(self isForeignClassExtension: categoryName) not]]
]

{ #category : #testing }
PackageInfo >> includesMethodReference: aMethodRef [
	^ self includesMethod: aMethodRef methodSymbol ofClass: aMethodRef actualClass
]

{ #category : #testing }
PackageInfo >> includesSystemCategory: categoryName [
	^ self category: categoryName matches: self systemCategoryPrefix
]

{ #category : #testing }
PackageInfo >> isForeignClassExtension: categoryName [
	^ categoryName first = $* and: [(self isYourClassExtension: categoryName) not]
]

{ #category : #testing }
PackageInfo >> isOverrideCategory: aString [
	^ aString first = $* and: [aString endsWith: '-override']
]

{ #category : #testing }
PackageInfo >> isOverrideMethod: aMethodReference [
	^ self isOverrideCategory: aMethodReference category
]

{ #category : #testing }
PackageInfo >> isOverrideOfYourMethod: aMethodReference [
	"Answers true if the argument overrides a method in this package"
	^ (self isYourClassExtension: aMethodReference category) not and:
		[(self changeRecordForOverriddenMethod: aMethodReference) notNil]
]

{ #category : #'preamble\/postscript' }
PackageInfo >> isScript: script not: default [
	^ script notNil
		and: [ | contents |
			contents := script contents asString withBlanksTrimmed.
			contents notEmpty and: [contents ~= default and: [contents ~= 'nil']]]
]

{ #category : #testing }
PackageInfo >> isYourClassExtension: categoryName [
	^ categoryName notNil and: [self category: categoryName asLowercase matches: self methodCategoryPrefix]
]

{ #category : #'source code management' }
PackageInfo >> linesOfCode [
	"An approximate measure of lines of code.
	Includes comments, but excludes blank lines."
	^self methods inject: 0 into: [:sum :each | sum + each compiledMethod linesOfCode]
]

{ #category : #naming }
PackageInfo >> methodCategoryPrefix [
	^ methodCategoryPrefix ifNil: [methodCategoryPrefix := '*', self packageName asLowercase]
]

{ #category : #listing }
PackageInfo >> methods [
	^ (self extensionMethods, self coreMethods) select: [:method |
		method isValid
			and: [method isLocalSelector]]
]

{ #category : #testing }
PackageInfo >> methodsInCategory: aString ofClass: aClass [ 
	^Array streamContents: [:stream |
		self methodsInCategory: aString ofClass: aClass 
			do: [:each | stream nextPut: each]]

]

{ #category : #enumerating }
PackageInfo >> methodsInCategory: aString ofClass: aClass do: aBlock [
	((aClass organization listAtCategoryNamed: aString) ifNil: [^self])
		do: [:sel | aBlock value: (self referenceForMethod: sel ofClass: aClass)]
]

{ #category : #naming }
PackageInfo >> name [

^ self packageName
]

{ #category : #testing }
PackageInfo >> outsideClasses [
	^ProtoObject withAllSubclasses asSet difference: self classesAndMetaClasses
]

{ #category : #listing }
PackageInfo >> overriddenMethods [
	^ Array streamContents: [:stream |
		self overriddenMethodsDo: [:each | stream nextPut: each]]

]

{ #category : #enumerating }
PackageInfo >> overriddenMethodsDo: aBlock [
	"Enumerates the methods the receiver contains which have been overridden by other packages"
	^ self allOverriddenMethodsDo: [:ea |
		(self isOverrideOfYourMethod: ea)
			ifTrue: [aBlock value: ea]]
]

{ #category : #listing }
PackageInfo >> overriddenMethodsInClass: aClass [
	^Array streamContents: [:stream |
		self overriddenMethodsInClass: aClass
			do: [:each | stream nextPut: each]]

]

{ #category : #enumerating }
PackageInfo >> overriddenMethodsInClass: aClass do: aBlock [
	"Evaluates aBlock with the overridden methods in aClass"
	^ self overrideCategoriesForClass: aClass do: [:cat |
		self methodsInCategory: cat ofClass: aClass do: aBlock]
]

{ #category : #testing }
PackageInfo >> overrideCategoriesForClass: aClass [
	^Array streamContents: [:stream |
		self overrideCategoriesForClass: aClass
			do: [:each | stream nextPut: each]]

]

{ #category : #enumerating }
PackageInfo >> overrideCategoriesForClass: aClass do: aBlock [
	"Evaluates aBlock with all the *foo-override categories in aClass"
	^ aClass organization categories do: [:cat |
		(self isOverrideCategory: cat) ifTrue: [aBlock value: cat]]
]

{ #category : #listing }
PackageInfo >> overrideMethods [
	^ self extensionMethods select: [:ea | self isOverrideMethod: ea]
]

{ #category : #naming }
PackageInfo >> packageName [
	^ packageName ifNil: [packageName := self categoryName]
]

{ #category : #naming }
PackageInfo >> packageName: aString [
	packageName := aString
]

{ #category : #'preamble\/postscript' }
PackageInfo >> postscript [
	^ postscript ifNil: [
		postscript := StringHolder new contents: self postscriptDefault]
]

{ #category : #'preamble\/postscript' }
PackageInfo >> postscript: aString [

postscript := StringHolder new contents: aString
]

{ #category : #'preamble\/postscript' }
PackageInfo >> postscriptDefault [
	^ '"below, add code to be run after the loading of this package"'
]

{ #category : #'preamble\/postscript' }
PackageInfo >> postscriptOfRemoval [
	^ postscriptOfRemoval ifNil: [
		postscriptOfRemoval := StringHolder new contents: self postscriptOfRemovalDefault]
]

{ #category : #'preamble\/postscript' }
PackageInfo >> postscriptOfRemoval: aString [

postscriptOfRemoval := StringHolder new contents: aString

]

{ #category : #'preamble\/postscript' }
PackageInfo >> postscriptOfRemovalDefault [
	^ '"below, add code to clean up after the unloading of this package"'
]

{ #category : #'preamble\/postscript' }
PackageInfo >> preamble [
	^ preamble ifNil: [
		preamble := StringHolder new contents: self preambleDefault]
]

{ #category : #'preamble\/postscript' }
PackageInfo >> preamble: aString [

preamble := StringHolder new contents: aString
]

{ #category : #'preamble\/postscript' }
PackageInfo >> preambleDefault [
	^ '"below, add code to be run before the loading of this package"'

]

{ #category : #'preamble\/postscript' }
PackageInfo >> preambleOfRemoval [
	^ preambleOfRemoval ifNil: [
		preambleOfRemoval := StringHolder new contents: self preambleOfRemovalDefault]
]

{ #category : #'preamble\/postscript' }
PackageInfo >> preambleOfRemoval: aString [

preambleOfRemoval := StringHolder new contents: aString

]

{ #category : #'preamble\/postscript' }
PackageInfo >> preambleOfRemovalDefault [
	^'"below, add code to prepare for the unloading of this package"'
]

{ #category : #printing }
PackageInfo >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: self packageName;
		nextPut: $)
]

{ #category : #testing }
PackageInfo >> referenceForMethod: aSymbol ofClass: aClass [
	^ MethodReference class: aClass selector: aSymbol
]

{ #category : #registering }
PackageInfo >> register [
	Environment current packageOrganizer registerPackage: self
]

{ #category : #modifying }
PackageInfo >> removeMethod: aMethodReference [
]

{ #category : #listing }
PackageInfo >> selectors [
	^ self methods collect: [:ea | ea methodSymbol]
]

{ #category : #listing }
PackageInfo >> systemCategories [
	^ Environment current organization categories select: [:cat | self includesSystemCategory: cat]
]

{ #category : #naming }
PackageInfo >> systemCategoryPrefix [
	^ self packageName
]
