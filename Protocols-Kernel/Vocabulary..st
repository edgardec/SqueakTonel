"
Vocabulary

vocabularyName	a Symbol -- the formal name by which this vocabulary is known.
categories			a list of ElementCategory objects: the categories that comprise the vocabulary
methodInterfaces 	an IdentityDictionary; keys are method selectors, values are MethodInterfaces

A Vocabulary can be either be *abstract*, i.e. associated with a *class*, or it can be *bound to an instance*.  The form that is bound to an instance is still in its infancy however.

object				in the *bound* form, an actual object is associated with the vocabulary
limitClass			in the *bound* form, an actual limit class is assocaited with the vocabulary

AllMethodInterfaces	This class variable is available to hold on to all method interfaces
						defined in the system, regardless of class.  Not deployed in 
						the first version of this code to be circulated externally.

AllVocabularies		A dictionary associating symbols with actual abstract vocabulary instances

------
Hints on making a vocabulary for a new foreign language.  You need build a method like #addGermanVocabulary.  Execute

	Transcript show: Vocabulary eToyVocabulary strings.

and copy the text from the transcript to the method you are building.
	A cheap trick to get started is to use a web site that translates.  Here is how.  For an entry like:  

(clearTurtleTrails			'clear pen trails'			'Clear all the pen trails in the interior.')

	substitute exclamation points for single quotes by using Alt-shift-j.  Most of the statements are imperatives.

(clearOwnersPenTrails !clear all pen trails! !clear all pen trails in my containing play field!) 

	This translates to

(ClearOwnersPenTrails! reinigt allen Kugelschreiber verfolgt! ! Reinigt allen Kugelschreiber Pfade in meinem enthaltenden Spiel Feld sind!) 

	Which is laughable, and will certainly stimulate the author to improve it.
------
"
Class {
	#name : #Vocabulary,
	#superclass : #ObjectWithDocumentation,
	#instVars : [
		'vocabularyName',
		'categories',
		'methodInterfaces',
		'object',
		'limitClass',
		'translationTable'
	],
	#classVars : [
		'AllStandardVocabularies',
		'LanguageSymbols',
		'LanguageTable'
	],
	#category : #'Protocols-Kernel'
}

{ #category : #'standard vocabulary access' }
Vocabulary class >> addStandardVocabulary: aVocabulary [
	"Add a vocabulary to the list of standard vocabularies"

	self allStandardVocabularies at: aVocabulary vocabularyName put: aVocabulary
]

{ #category : #'standard vocabulary access' }
Vocabulary class >> allStandardVocabularies [
	"Answer a list of the currently-defined vocabularies in my AllStandardVocabularies list"
	"Vocabulary allStandardVocabularies"

	^AllStandardVocabularies ifNil: [AllStandardVocabularies := IdentityDictionary new].


]

{ #category : #'class initialization' }
Vocabulary class >> embraceAddedTypeVocabularies [
	"If there are any type-vocabulary subclases not otherwise accounted for, acknowledge them at this time"

	
	DataType allSubclasses do:
		[:dataType | | vocabulary |
			vocabulary := dataType new.
			vocabulary representsAType
				ifTrue: [(self allStandardVocabularies includesKey: vocabulary vocabularyName)
					ifFalse: 	[self addStandardVocabulary: vocabulary]]]
]

{ #category : #'universal vocabularies' }
Vocabulary class >> fullVocabulary [
	"Answer the full vocabulary in my AllStandardVocabularies list, creating it if necessary"

	^ self allStandardVocabularies at: #Full ifAbsentPut: [FullVocabulary new]
]

{ #category : #'eToy vocabularies' }
Vocabulary class >> gettersForbiddenFromWatchers [
	"Answer getters that should not have watchers launched to them"

	^ #(colorSees copy isOverColor: seesColor: newClone getNewClone color:sees: touchesA: overlaps: overlapsAny: distanceToPlayer: bearingTo: bearingFrom:)
]

{ #category : #'class initialization' }
Vocabulary class >> initialize [
	"Initialize a few standard vocabularies and place them in the AllVocabularies list.  Call this to update all vocabularies."

	self initializeStandardVocabularies.
	self embraceAddedTypeVocabularies.

	"Vocabulary initialize"


]

{ #category : #'class initialization' }
Vocabulary class >> initializeSilently [
	"Initialize a few standard vocabularies and place them in the AllVocabularies list."

	self initializeStandardVocabularies.
	self embraceAddedTypeVocabularies.

	"Vocabulary initializeSilently"


]

{ #category : #'class initialization' }
Vocabulary class >> initializeStandardVocabularies [
	"Initialize a few standard vocabularies and place them in the AllStandardVocabularies list."

	AllStandardVocabularies := nil.
	Smalltalk at: #EToyVocabulary
		ifPresent:[:aClass| self addStandardVocabulary: aClass new].
	Smalltalk at: #EToyVectorVocabulary
		ifPresent:[:aClass| self addStandardVocabulary: aClass new].

	self addStandardVocabulary: self newPublicVocabulary.
	self addStandardVocabulary: FullVocabulary new.

	self addStandardVocabulary: self newQuadVocabulary.

	self addStandardVocabulary: ColorType new.
	self addStandardVocabulary: BooleanType new.
	self addStandardVocabulary: GraphicType new.
	Smalltalk at: #PlayerType
		ifPresent:[:aClass| self addStandardVocabulary: aClass new].
	self addStandardVocabulary: SoundType new.
	self addStandardVocabulary: StringType new.
	self addStandardVocabulary: MenuType new.
	self addStandardVocabulary: UnknownType new.
	Smalltalk at: #ScriptNameType
		ifPresent:[:aClass| self addStandardVocabulary: aClass new].
	Smalltalk at: #PointType
		ifPresent:[:aClass| self addStandardVocabulary: aClass new].

	self addStandardVocabulary: (SymbolListType new symbols: #(simple raised inset complexFramed complexRaised complexInset complexAltFramed complexAltRaised complexAltInset); vocabularyName: #BorderStyle; yourself).
	self addStandardVocabulary: (SymbolListType new symbols: #(lines arrows arrowheads dots); vocabularyName: #TrailStyle; yourself).
	self addStandardVocabulary: (SymbolListType new symbols: #(leftToRight rightToLeft topToBottom bottomToTop); vocabularyName: #ListDirection; yourself).

	self addStandardVocabulary: (SymbolListType new symbols: #(topLeft bottomRight center justified); vocabularyName: #ListCentering; yourself).

	self addStandardVocabulary: (SymbolListType new symbols: #(#center #topLeft #topRight #bottomLeft #bottomRight #topCenter #leftCenter #rightCenter #bottomCenter ); vocabularyName: #CellPositioning; yourself).

	self addStandardVocabulary: (SymbolListType new symbols: #(#none #localRect #localSquare #globalRect #globalSquare ); vocabularyName: #CellSpacing; yourself).

	self addStandardVocabulary: (SymbolListType new symbols: #(buttonDown whilePressed buttonUp); vocabularyName: #ButtonPhase; yourself).

	self addStandardVocabulary: (SymbolListType new symbols: #(rotate #'do not rotate' #'flip left right' #'flip up down'); vocabularyName: #RotationStyle; yourself).

	self addStandardVocabulary: (SymbolListType new symbols: #(rigid spaceFill shrinkWrap); vocabularyName: #Resizing; yourself).

	self addStandardVocabulary: self newSystemVocabulary.  "A custom vocabulary for Smalltalk -- still under development)"

	self numberVocabulary.  		"creates and adds it"
	"self wonderlandVocabulary."  	"creates and adds it"
	self vocabularyForClass: Time.   "creates and adds it"

	Smalltalk at: #KedamaPatchType ifPresent:[:aClass| 
		self addStandardVocabulary: (aClass new vocabularyName: #Patch; yourself).
	].
	self addStandardVocabulary: (SymbolListType new symbols: #(wrap stick bouncing); vocabularyName: #EdgeMode; yourself).
	self addStandardVocabulary: (SymbolListType new symbols: #(logScale linear color); vocabularyName: #PatchDisplayMode; yourself).
	
	self addStandardVocabulary: (SymbolListType new symbols: #(#top #'top right' #right #'bottom right' #bottom #'bottom left' #left #'top left' #center ); vocabularyName: #AttachmentEdge; yourself).
	
	Smalltalk
		at: #CalendarMorph
		ifPresent: [:aClass | aClass assureDateFormatEstablished].

	"Vocabulary initialize"
]

{ #category : #'type vocabularies' }
Vocabulary class >> newNumberVocabulary [
	"Answer a Vocabulary object representing the Number vocabulary to the list of AllVocabularies"

	^ NumberType new
]

{ #category : #'universal vocabularies' }
Vocabulary class >> newPublicVocabulary [
	| aVocabulary |
	"Answer a public vocabulary"

	aVocabulary := ScreenedVocabulary new.
	aVocabulary vocabularyName: #Public.
	aVocabulary documentation: '"Public" is vocabulary that excludes categories that start with "private" and methods that start with "private" or "pvt"'.

	aVocabulary categoryScreeningBlock: [:aCategoryName | (aCategoryName beginsWith: 'private') not].
	aVocabulary methodScreeningBlock: [:aSelector | 
		((aSelector beginsWith: 'private') or: [aSelector beginsWith: 'pvt']) not].
	^ aVocabulary

]

{ #category : #'testing and demo' }
Vocabulary class >> newQuadVocabulary [
	"Answer a Quad vocabulary -- something to mess with, to illustrate and explore ideas.  Applies to Quadrangles only."

	| aVocabulary  |
	aVocabulary := Vocabulary new vocabularyName: #Quad.
	aVocabulary documentation: 'A highly restricted test vocabulary that can be used with Quadrangle objects'.
	aVocabulary initializeFromTable:  #(
(borderColor borderColor: () Color (basic color) 'The color of the border' unused updating)
(borderWidth borderWidth: () Number (basic geometry) 'The width of the border' unused updating)
(insideColor insideColor: () Color (basic color) 'The color of the quadrangle' unused updating)
(display none () none (basic display) 'Display the quadrangle directly on the screen')
(width none () Number (geometry) 'The width of the object' unused updating)
(left setLeft: () Number (geometry) 'The left edge' unused updating)
(right setRight: () Number (geometry) 'The right edge' unused updating)
(width setWidth: () Number (geometry) 'The width of the object' unused updating)
(height setHeight: () Number (geometry) 'The height of the object' unused updating)
(hasPositiveExtent none () Boolean (tests) 'Whether the corner is to the lower-right of the origin' unused updating)
(isTall none () Boolean (tests) 'Whether the height is greater than the width' unused updating)).

	^ aVocabulary

"Vocabulary initialize"
"Quadrangle exampleInViewer"
]

{ #category : #'eToy vocabularies' }
Vocabulary class >> newSystemVocabulary [
	"Answer a Vocabulary object representing significant requests one can make to the Smalltalk object"

	| aVocabulary |
	aVocabulary := self new.

	aVocabulary vocabularyName: #System.
	aVocabulary documentation: 'Useful messages you might want to send to the current Smalltalk image'.
	aVocabulary initializeFromTable:  #(
(aboutThisSystem none () none (basic queries) 'put up a message describing the system' unused)
(saveAsNewVersion none () none (services) 'advance to the next available image-version number and save the image under that new name' unused znak)
(datedVersion none () String (queries) 'the version of the Squeak system')
(endianness none () String (queries) 'big or little - the byte-ordering of the hardware Squeak is currently running on')
(exitToDebugger none () none (dangerous) 'exits to the host debugger.  Do not use this -- I guarantee you will be sorry.')
(bytesLeft none () Number (basic services) 'perform a garbage collection and answer the number of bytes of free space remaining in the system')
"(browseAllCallsOn: none ((aSelector String)) none (#'queries') 'browse all calls on a selector')
(browseAllImplementorsOf: none ((aSelector String)) none (#'queries') 'browse all implementors of a selector')"

"(allMethodsWithSourceString:matchCase: none ((aString String) (caseSensitive Boolean)) none (queries) 'browse all methods that have the given source string, making the search case-sensitive or not depending on the argument provided.')

(browseMethodsWithString:matchCase: none ((aString String) (caseSensitive Boolean)) none (queries) 'browse all methods that contain the given string in any string literal, making the search case-sensitive or not depending on the argument provided.')

(browseAllImplementorsOf:localTo: none ((aSelector String) (aClass Class)) none (#'queries') 'browse all implementors of a selector that are local to a class')"

).
"(isKindOf: none 	((aClass Class)) Boolean (#'class membership') 'answer whether the receiver''s superclass chain includes aClass')"
	^ aVocabulary

"Vocabulary initialize"
"Vocabulary addStandardVocabulary: Vocabulary newSystemVocabulary"

"Smalltalk basicInspect"
"Smalltalk beViewed"

]

{ #category : #'testing and demo' }
Vocabulary class >> newTestVocabulary [
	"Answer a Test vocabulary -- something to mess with, to illustrate and explore ideas."

	| aVocabulary  |
	aVocabulary := Vocabulary new vocabularyName: #Test.
	aVocabulary documentation: 'An illustrative vocabulary for testing'.
	aVocabulary initializeFromTable:  #(
(isKindOf: none 	((aClass Class)) Boolean (#'class membership') 'answer whether the receiver''s superclass chain includes aClass')
(class none none Class (#'class membership' wimpy) 'answer the the class to which the receiver belongs')
(respondsTo: none ((aSelector Symbol))	Boolean (#'class membership') 'answer whether the receiver responds to the given selector')
(as:	none ((aClass Class)) Object (conversion) 'answer the receiver converted to be a member of aClass')).

	^ aVocabulary
"
	#((#'class membership' 	'Whether an object can respond to a given message, etc.' 	(isKindOf: class respondsTo:))
	(conversion 			'Messages to convert from one kind of object to another' 		(as:  asString))
	(copying				'Messages for making copies of objects'						(copy copyFrom:))
	(equality 				'Testing whether two objects are equal' 						( = ~= == ~~))
	(dependents				'Support for dependency notification'						(addDependent: removeDependent: release))) do:

		[:item | 
			aMethodCategory := ElementCategory new categoryName: item first.
			aMethodCategory documentation: item second.
			item third do:
				[:aSelector | 
					aMethodInterface := MethodInterface new initializeFor: aSelector.
					aVocabulary atKey: aSelector putMethodInterface: aMethodInterface.
					aMethodCategory elementAt: aSelector put: aMethodInterface].
			aVocabulary addCategory: aMethodCategory]."

]

{ #category : #'standard vocabulary access' }
Vocabulary class >> newTimeVocabulary [
	"Answer a Vocabulary object representing me" 
	| aVocabulary |
	"Vocabulary newTimeVocabulary"
	"Vocabulary addStandardVocabulary: Vocabulary newTimeVocabulary"

	aVocabulary := self new vocabularyName: #Time.
	aVocabulary documentation: 'Time knows about hours, minutes, and seconds.  For long time periods, use Date'.

#((accessing 			'The basic info'
		(hours minutes seconds))
(arithmetic 				'Basic numeric operations'
		(addTime: subtractTime: max: min: min:max:))
(comparing				'Determining which is larger'
		(= < > <= >= ~= between:and:))
(testing 				'Testing'
		(ifNil: ifNotNil:))
(printing 				'Return a string for this Time'
		(hhmm24 print24 intervalString printMinutes printOn:))
(converting 			'Converting it to another form'
		(asSeconds asString))
(copying 				'Make another one like me'
		(copy))
) do: [:item | | aMethodCategory | 
			aMethodCategory := ElementCategory new categoryName: item first.
			aMethodCategory documentation: item second.
			item third do:
				[:aSelector | | aMethodInterface | 
					aMethodInterface := MethodInterface new initializeFor: aSelector.
					aVocabulary atKey: aSelector putMethodInterface: aMethodInterface.
					aMethodCategory elementAt: aSelector put: aMethodInterface].
			aVocabulary addCategory: aMethodCategory].
	#(#addTime: subtractTime: max: min: = < > <= >= ~= ) do: [:sel |
		(aVocabulary methodInterfaceAt: sel ifAbsent: [self error: 'fix this method']) 
			argumentVariables: (OrderedCollection with:
				(Variable new name: nil type: aVocabulary vocabularyName))].
	^ aVocabulary
]

{ #category : #'type vocabularies' }
Vocabulary class >> numberVocabulary [
	"Answer the standard vocabulary representing numbers, creating it if necessary"

	^self allStandardVocabularies at: #Number ifAbsentPut: [self newNumberVocabulary]
]

{ #category : #recompilation }
Vocabulary class >> postRecompileAction [
	"The #Public Vocabulary (a newPublicVocabulary) is a ScreenedVocabulary which refers to blocks.
	 Rebuild it post recompile to ensure the blocks refer to current methods."

	self addStandardVocabulary: self newPublicVocabulary
]

{ #category : #'testing and demo' }
Vocabulary class >> quadVocabulary [
	"Answer the Quad vocabulary lurking in my AllStandardVocabularies list, creating it if necessary"
	"Vocabulary quadVocabulary"

	^ self allStandardVocabularies at: #Quad ifAbsentPut: [self newQuadVocabulary]
]

{ #category : #'testing and demo' }
Vocabulary class >> testVocabulary [
	"Answer the Test vocabulary lurking in my AllStandardVocabularies list, creating it if necessary"
	"Vocabulary testVocabulary"

	^ self allStandardVocabularies at: #Test ifAbsentPut: [self newTestVocabulary]
]

{ #category : #'type vocabularies' }
Vocabulary class >> typeChoices [
	"Answer a list of all user-choosable data types"

	| vocabulariesForType |
	vocabulariesForType := self allStandardVocabularies select: [:e | e representsAType].
	(Preferences valueOfFlag: #allowEtoyUserCustomEvents) ifFalse: [vocabulariesForType removeKey: #CustomEvents ifAbsent: []].
	^vocabulariesForType keys sort
]

{ #category : #'type vocabularies' }
Vocabulary class >> vocabularyForClass: aClass [
	"Answer the standard vocabulary for that class.  Create it if not present and init message exists.  Answer nil if none exists and no init message present."

	| initMsgName newTypeVocab |
	(self allStandardVocabularies includesKey: aClass name)
		ifTrue: [^self allStandardVocabularies at: aClass name].

	initMsgName := ('new', aClass name, 'Vocabulary') asSymbol.
	^(self respondsTo: initMsgName)
		 ifTrue:	[
			newTypeVocab := self perform: initMsgName.
			self addStandardVocabulary: newTypeVocab.
			newTypeVocab]
		ifFalse: [nil]
]

{ #category : #'type vocabularies' }
Vocabulary class >> vocabularyForType: aType [
	"Answer a vocabulary appropriate to the given type, which is normally going to be a symbol such as #Number or #Color.  Answer the Unknown vocabulary as a fall-back"

	| ucSym |
	(aType isKindOf: Vocabulary) ifTrue: [^ aType].
	ucSym := aType capitalized asSymbol.
	^self allStandardVocabularies at: ucSym ifAbsent: [self vocabularyNamed: #unknown]
]

{ #category : #'standard vocabulary access' }
Vocabulary class >> vocabularyFrom: aNameOrVocabulary [
	"Answer the standard vocabulary of the given name, or nil if none found,  For backward compatibilitythe parameter might be an actual vocabulary, in which case return it"

	(aNameOrVocabulary isKindOf: Vocabulary) ifTrue: [^ aNameOrVocabulary].
	^ self vocabularyNamed: aNameOrVocabulary
]

{ #category : #'standard vocabulary access' }
Vocabulary class >> vocabularyNamed: aName [
	"Answer the standard vocabulary of the given name, or nil if none found"

	^ self allStandardVocabularies at: aName asSymbol ifAbsent: []
]

{ #category : #initialization }
Vocabulary >> addCategory: aCategory [
	"Add the given category to my categories list"

	categories add: aCategory
]

{ #category : #initialization }
Vocabulary >> addCategoryNamed: aCategoryName [
	"Add a category of the given name to my categories list,"

	categories add: (ElementCategory new categoryName: aCategoryName asSymbol)
]

{ #category : #initialization }
Vocabulary >> addFromTable: aTable [
	"Add each method-specification tuples, each of the form:
		(1)	selector
		(2)	companion setter selector (#none or nil indicate none)
		(3)  argument specification array, each element being an array of the form
				<arg name>  <arg type>
		(4)  result type, (#none or nil indicate none)
		(5)  array of category symbols, i.e. the categories in which this element should appear.
		(6)  help message. (optional)
		(7)  wording (optional)
		(8)  auto update flag (optional) - if #updating, set readout to refetch automatically

	Make new categories as needed.
	Consult Vocabulary class.initializeTestVocabulary for an example of use"
				
	
	aTable do:
		[:tuple |   tuple fifth do: [:aCategorySymbol | | aSelector aMethodInterface aMethodCategory doc wording |
			(aMethodCategory := self categoryAt: aCategorySymbol) ifNil: [ 
					aMethodCategory := ElementCategory new categoryName: aCategorySymbol.
					self addCategory: aMethodCategory].		
		
			aMethodInterface := MethodInterface new.
			aSelector := tuple first.
			aMethodInterface selector: aSelector type: tuple fourth setter: tuple second.
			aMethodCategory elementAt: aSelector put: aMethodInterface.
			self atKey: aSelector putMethodInterface: aMethodInterface.
			((tuple third ~~ #none) and: [tuple third isEmptyOrNil not])
				ifTrue:
					[aMethodInterface argumentVariables: (tuple third collect:
						[:pair | Variable new name: pair first type: pair second])].

		
			doc := (tuple size >= 6 and: [(#(nil none unused) includes: tuple sixth) not])
				ifTrue:
					[tuple sixth]
				ifFalse:
					[nil].
			wording := (tuple size >= 7 and: [(#(nil none unused) includes: tuple seventh) not])
				ifTrue:
					[tuple seventh]
				ifFalse:
					[aSelector].
			aMethodInterface
				wording: wording;
				helpMessage: doc.
			tuple size >= 8 ifTrue:
				[aMethodInterface setToRefetch]]].

]

{ #category : #queries }
Vocabulary >> allCategoryName [
	"Answer the name by which the 'all' category is known.  This is redundant with two other things, including ClassOrganizer allCategory, at the moment -- should be cleaned up someday."

	^ #'-- all --'
]

{ #category : #queries }
Vocabulary >> allMethodsInCategory: categoryName [ 
	"Answer a list of methods in the category of the given name"

	^ self allMethodsInCategory: categoryName forInstance: object ofClass: object class
]

{ #category : #queries }
Vocabulary >> allMethodsInCategory: categoryName forInstance: anObject ofClass: aClass [
	"Answer a list of all methods in the etoy interface which are in the given category, on behalf of aClass and possibly anObject.  Note that there is no limitClass at play here."

	| aCategory |
	categoryName ifNil: [^ OrderedCollection new].
	categoryName = self allCategoryName ifTrue:
		[^ methodInterfaces collect: [:anInterface | anInterface selector]].

	aCategory := categories detect: [:cat | cat categoryName == categoryName asSymbol] ifNone: [^ OrderedCollection new].
	^ aCategory elementsInOrder collect: [:anElement | anElement selector] thenSelect:
			[:aSelector | aClass canUnderstand: aSelector]
]

{ #category : #queries }
Vocabulary >> allSelectorsInVocabulary [
	"Answer a list of all selectors in the vocabulary"

	^ methodInterfaces collect: [:m | m selector]
]

{ #category : #queries }
Vocabulary >> asSymbol [
	"Answer a symbol representing the receiver"

	^ self vocabularyName
]

{ #category : #queries }
Vocabulary >> atKey: aKey putMethodInterface: anInterface [
	"Place the given interface at the given key."

	methodInterfaces at: aKey put: anInterface
]

{ #category : #queries }
Vocabulary >> categories [
	"Answer a list of the categories in the receiver"

	^ categories
]

{ #category : #queries }
Vocabulary >> categoriesContaining: aSelector forClass: aClass [
	"Answer a list of categories that include aSelector"

	^ self categories select:
		[:aCategory | aCategory includesKey: aSelector]
]

{ #category : #queries }
Vocabulary >> categoryAt: aSymbol [
	"Answer the category which has the given symbol as its categoryName, else nil if none found"

	^ categories detect: [:aCategory | aCategory categoryName == aSymbol] ifNone: [nil]
]

{ #category : #queries }
Vocabulary >> categoryCommentFor: aCategoryName [
	"Answer diocumentation for the given category name, a symbol"

	categories do:
		[:cat | cat categoryName == aCategoryName ifTrue: [^ cat documentation]].

	aCategoryName = self allCategoryName ifTrue:
		[^ 'Shows all methods, whatever other categories they may belong to'].
	#(
	(all					'Danger! An old designation that usually does NOT include all of anything!')
	('as yet unclassified'	'Methods not yet given a specific classification in some class in which they are implemented')
	(private				'Methods that should only be called by self'))

		do:
			[:pair | pair first = aCategoryName ifTrue: [^ pair second]].

	^ aCategoryName, ' is a category that currently has no documentation'

]

{ #category : #queries }
Vocabulary >> categoryList [
	"Answer the category list considering only code implemented in my 
	limitClass and lower. This variant is used when the limitClass and 
	targetObjct are known"
	| classToUse |
	classToUse := object class.
	^ categories
		select: [:aCategory | | foundAMethod | 
			foundAMethod := false.
			aCategory elementsInOrder
				do: [:aSpec | | classThatImplements | 
					classThatImplements := classToUse whichClassIncludesSelector: aSpec selector.
					(classThatImplements notNil
							and: [classThatImplements includesBehavior: limitClass])
						ifTrue: [foundAMethod := true]].
			foundAMethod]
		thenCollect: [:aCategory | aCategory categoryName]
]

{ #category : #queries }
Vocabulary >> categoryListForInstance: targetObject ofClass: aClass limitClass: mostGenericClass [ 
	"Answer the category list for the given instance (may be nil) of the 
	given class, considering only code implemented in mostGenericClass and 
	lower "
	| classToUse |
	classToUse := targetObject
				ifNil: [aClass]
				ifNotNil: [targetObject class].
	^ categories
		select: [:aCategory | | foundAMethod | 
			foundAMethod := false.
			aCategory elementsInOrder
				do: [:aSpec | | classThatImplements | 
					classThatImplements := classToUse whichClassIncludesSelector: aSpec selector.
					(classThatImplements notNil
							and: [classThatImplements includesBehavior: mostGenericClass])
						ifTrue: [foundAMethod := true]].
			foundAMethod]
		thenCollect: [:aCategory | aCategory categoryName]
]

{ #category : #queries }
Vocabulary >> categoryWhoseTranslatedWordingIs: aWording [
	"Answer the category whose translated is the one provided, or nil if none"

	^ self categories detect: [:aCategory | aCategory wording = aWording] ifNone: [nil]

]

{ #category : #queries }
Vocabulary >> categoryWithNameIn: categoryNames thatIncludesSelector: aSelector forInstance: targetInstance ofClass: targetClass [
	"Answer the name of a category, from among the provided categoryNames, which defines the selector for the given class.  Note reimplementor"

	
	self categories do:
		[:aCategory | | itsName |
		((categoryNames includes: (itsName := aCategory categoryName)) and:  [aCategory includesKey: aSelector])
			ifTrue:
				[^ itsName]].
	^ nil
]

{ #category : #queries }
Vocabulary >> categoryWordingAt: aSymbol [
	"Answer the wording for the category at the given symbol"

	| result |
	result := self categoryAt: aSymbol.
	^result
		ifNotNil: [result wording]
		ifNil: [aSymbol]
]

{ #category : #queries }
Vocabulary >> classToUseFromInstance: anInstance ofClass: aClass [
	"A small convenience to assist in complications arising because an instance is sometimes provided and sometimes not"

	^ anInstance ifNotNil: [anInstance class] ifNil: [aClass]

]

{ #category : #queries }
Vocabulary >> encompassesAPriori: aClass [
	"Answer whether the receiver  a priori encompasses aClass -- see implementors"

	^ false
]

{ #category : #queries }
Vocabulary >> includesDefinitionForSelector: aSelector [
	"Answer whether the given selector is known to the vocabulary.  This is independent of whether its definition lies within the range specified by my limitClass.  Answer whether the given selector is known to the vocabulary.  Unsent at the moment, may disappear."

	^ methodInterfaces includesKey: aSelector
]

{ #category : #queries }
Vocabulary >> includesSelector: aSelector [
	"Answer whether the given selector is known to the vocabulary"

	^ methodInterfaces includesKey: aSelector
]

{ #category : #queries }
Vocabulary >> includesSelector: aSelector forInstance: anInstance ofClass: aTargetClass limitClass: mostGenericClass [
	"Answer whether the vocabulary includes the given selector for the given class (and instance, if provided), only considering method implementations in mostGenericClass and lower"

	| classToUse aClass |

	(methodInterfaces includesKey: aSelector) ifFalse: [^ false].
	classToUse := self classToUseFromInstance: anInstance ofClass: aTargetClass.
	^ (aClass := classToUse whichClassIncludesSelector: aSelector)
		ifNil:
			[false]
		ifNotNil:
			[(aClass includesBehavior: mostGenericClass) and:
				[(self someCategoryThatIncludes: aSelector) notNil]]

]

{ #category : #initialization }
Vocabulary >> initialize [
	"Initialize the receiver (automatically called when instances are created via 'new')"

	super initialize.
	vocabularyName := #unnamed.
	categories := OrderedCollection new.
	methodInterfaces := IdentityDictionary new
]

{ #category : #initialization }
Vocabulary >> initializeFor: anObject [
	"Initialize the receiver to bear a vocabulary suitable for anObject"

	object := anObject.
	vocabularyName := #unnamed.
	categories := OrderedCollection new.
	methodInterfaces := IdentityDictionary new.
	self documentation: 'A vocabulary that has not yet been documented'.

]

{ #category : #initialization }
Vocabulary >> initializeFromTable: aTable [
	"Initialize the receiver from a list of method-specification tuples, each of the form:
		(1)	selector
		(2)	companion setter selector (#none or nil indicate none)
		(3)  argument specification array, each element being an array of the form
				<arg name>  <arg type>
		(4)  result type, (#none or nil indicate none)
		(5)  array of category symbols, i.e. the categories in which this element should appear.
		(6)  help message. (optional)
		(7)  wording (optional)
		(8)  auto update flag (optional) - if #updating, set readout to refetch automatically

	Consult Vocabulary class.initializeTestVocabulary for an example of use"
				
	| categoryList |
	categoryList := Set new.
	aTable do:
		[:tuple | categoryList addAll: tuple fifth].
	categoryList sorted do:
		[:aCategorySymbol | | aMethodCategory |
			aMethodCategory := ElementCategory new categoryName: aCategorySymbol.
			aTable do:
				[:tuple | | doc aSelector wording aMethodInterface |
				(tuple fifth includes: aCategorySymbol) ifTrue:
					[aMethodInterface := MethodInterface new.
					aSelector := tuple first.
					aMethodInterface selector: aSelector type: tuple fourth setter: tuple second.
					aMethodCategory elementAt: aSelector put: aMethodInterface.
					self atKey: aSelector putMethodInterface: aMethodInterface.
					((tuple third ~~ #none) and: [tuple third isEmptyOrNil not])
						ifTrue:
							[aMethodInterface argumentVariables: (tuple third collect:
								[:pair | Variable new name: pair first type: pair second])].
					doc := (tuple size >= 6 and: [(#(nil none unused) includes: tuple sixth) not])
						ifTrue:
							[tuple sixth]
						ifFalse:
							[nil].
 					wording := (tuple size >= 7 and: [(#(nil none unused) includes: tuple seventh) not])
						ifTrue:
							[tuple seventh]
						ifFalse:
							[aSelector asString].
					aMethodInterface
						wording: wording;
						helpMessage: doc.
					tuple size >= 8 ifTrue:
						[aMethodInterface setToRefetch]]].
			self addCategory: aMethodCategory]
]

{ #category : #queries }
Vocabulary >> isEToyVocabulary [
	^false
]

{ #category : #queries }
Vocabulary >> methodInterfaceAt: aSelector ifAbsent: aBlock [
	"Answer the vocabulary's method interface for the given selector; if absent, return the result of evaluating aBlock"

	^methodInterfaces at: aSelector ifAbsent: aBlock
]

{ #category : #queries }
Vocabulary >> methodInterfaceForSelector: aSelector class: aClass [
	"Answer a method interface for the selector"

	^ self methodInterfaceAt: aSelector ifAbsent:
		[MethodInterface new conjuredUpFor: aSelector class: aClass]
]

{ #category : #queries }
Vocabulary >> methodInterfacesDo: aBlock [
	"Evaluate aBlock on behalf, in turn, of each of my methodInterfaces"

	methodInterfaces do: aBlock

	
]

{ #category : #queries }
Vocabulary >> methodInterfacesInCategory: categoryName forInstance: anObject ofClass: aClass limitClass: aLimitClass [
	"Answer a list of method interfaces of all methods in the given category, provided they are implemented no further away than aLimitClass."

	
	^ ((self allMethodsInCategory: categoryName forInstance: anObject ofClass: aClass) collect:
		[:sel | methodInterfaces at: sel ifAbsent:
			[MethodInterface new conjuredUpFor: sel class: aClass]]) select:
				[:aMethodInterface | | defClass |
					defClass := aClass whichClassIncludesSelector: aMethodInterface selector.
					(defClass notNil and: [defClass includesBehavior: aLimitClass])]
]

{ #category : #'method list' }
Vocabulary >> phraseSymbolsToSuppress [
	"Answer a dictatorially-imposed list of phrase-symbols that are to be suppressed from viewers, even if they otherwise show up.  Note that EToyVocabulary reimplements"

	^ #()
]

{ #category : #printing }
Vocabulary >> printOn: aStream [
	"Append to the argument, aStream, a sequence of characters that   identifies the receiver."

	super printOn: aStream.
	vocabularyName ifNotNil: [aStream nextPutAll: ' named "', vocabularyName, '"']
]

{ #category : #initialization }
Vocabulary >> renameCategoryFrom: oldName to: newName [
	"Rename the category currently known by oldName to be newName.  No senders at present but once a UI is establshed for renaming categories, this will be useful."

	| aCategory |
	(aCategory := self categoryAt: oldName) ifNil: [^ self].
	aCategory categoryName: newName
]

{ #category : #queries }
Vocabulary >> representsAType [
	"Answer whether this vocabulary represents an end-user-sensible data type"

	^ false
]

{ #category : #private }
Vocabulary >> setCategoryStrings: categoryTriplets [
	"Establish the category strings as per (internalCategorySymbol newCategoryWording balloon-help)"

	
	categoryTriplets do:
		[:triplet | | category |
			(category := self categoryAt: triplet first) ifNotNil: [
				category wording: triplet second.
				category helpMessage: triplet third]]
]

{ #category : #queries }
Vocabulary >> someCategoryThatIncludes: aSelector [
	"Answer the name of a category that includes the selector, nil if none"

	^ categories detect: [:c | c includesKey: aSelector] ifNone: [nil]
]

{ #category : #initialization }
Vocabulary >> strings [
	| strm |
	"Get started making a vocabulary for a foreign language.  That is, build a method like #addGermanVocabulary, but for another language.  
	Returns this vocabulary in the same form used as the input used for foreign languages.  To avoid string quote problems, execute
	Transcript show: Vocabulary eToyVocabulary strings.
and copy the text from the transcript to the method you are building."

	"selector		wording			documentation"

strm := WriteStream on: (String new: 400).
methodInterfaces keys asArray sort do: [:sel |
	strm cr; nextPut: $(;
		nextPutAll: sel; tab; tab; tab; nextPut: $';
		nextPutAll: (methodInterfaces at: sel) wording;
		nextPut: $'; tab; tab; tab; nextPut: $';
		nextPutAll: (methodInterfaces at: sel) documentation;
		nextPut: $'; nextPut: $)].
^ strm contents
]

{ #category : #translation }
Vocabulary >> translatedWordingFor: aSymbol [
	"If I have a translated wording for aSymbol, return it, else return aSymbol.  Caveat: at present, this mechanism is only germane for *assignment-operator wordings*"

	#(#':' #Incr: #Decr: #Mult:) with: #('' 'increase by' 'decrease by' 'multiply by') do:
		[:a :b | aSymbol = a ifTrue: [^ b translated]].

	^ aSymbol translated
]

{ #category : #translation }
Vocabulary >> translatedWordingsFor: symbolList [
	"Answer a list giving the translated wordings for the input list. Caveat: at present, this mechanism is only germane for *categories*"

	^ symbolList collect: [:sym | self translatedWordingFor: sym]

]

{ #category : #translation }
Vocabulary >> translationKeyFor: translatedWording [

	self flag: #yo.
	^ translatedWording.

]

{ #category : #translation }
Vocabulary >> translationTable [
	^translationTable ifNil: [ElementCategory new]
]

{ #category : #queries }
Vocabulary >> vocabularyName [
	"Answer the name of the vocabulary"

	^ vocabularyName
]

{ #category : #initialization }
Vocabulary >> vocabularyName: aName [
	"Set the name of the vocabulary as indicated"

	vocabularyName := aName
]
