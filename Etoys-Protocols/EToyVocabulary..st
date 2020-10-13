"
EToyVocabulary - a vocabulary mirroring the capabilities available to end users in Squeak's old 1997-2000 etoy prototype.
"
Class {
	#name : #EToyVocabulary,
	#superclass : #Vocabulary,
	#category : #'Etoys-Protocols'
}

{ #category : #accessing }
EToyVocabulary class >> masterOrderingOfCategorySymbols [
	"Answer a dictatorially-imposed presentation list of category symbols.
	This governs the order in which available vocabulary categories are presented in etoy viewers using the etoy vocabulary.
	The default implementation is that any items that are in this list will occur first, in the order specified here; after that, all other items will come, in alphabetic order by their translated wording."

	EToyVocabulary class decompile:  #masterOrderingOfCategorySymbols.
	self flag: #(('scripts' translatedNoop) ('variables' translatedNoop) ('as object' translatedNoop)).

	^ {'basic' translatedNoop. 'color' translatedNoop. 'geometry' translatedNoop. 
		'more geometry' translatedNoop.
		'pen use' translatedNoop. 'tests' translatedNoop. 'motion' translatedNoop. 'fill & border' translatedNoop. 'scripting' translatedNoop. 'sound' translatedNoop. 'observation' translatedNoop. 'button' translatedNoop. 'layout' translatedNoop. 'drag & drop' translatedNoop. 'search' translatedNoop. 'miscellaneous' translatedNoop}
		collect: [:each | each asSymbol]
]

{ #category : #accessing }
EToyVocabulary class >> morphClassesDeclaringViewerAdditions [
	"Answer a list of actual morph classes that either implement #additionsToViewerCategories,
	or that have methods that match #additionToViewerCategory* ."

	^(Morph withAllSubclasses select: [ :ea | ea hasAdditionsToViewerCategories ])
]

{ #category : #accessing }
EToyVocabulary class >> vocabularySummary [
	"Answer a string describing all the vocabulary defined anywhere in the 
	system."
	"
	(StringHolder new contents: EToyVocabulary vocabularySummary)  
	openLabel: 'EToy Vocabulary' translated 
	"
	| etoyVocab |
	etoyVocab := Vocabulary eToyVocabulary.
	etoyVocab initialize.		"just to make sure that it's unfiltered."
	^ String streamContents: [:s |
		self morphClassesDeclaringViewerAdditions do: [:cl | | allAdditions | 
			s nextPutAll: cl name; cr.
			allAdditions := cl allAdditionsToViewerCategories.
			cl unfilteredCategoriesForViewer do: [ :cat |
				allAdditions at: cat ifPresent: [ :additions | | interfaces |
					interfaces := ((etoyVocab categoryAt: cat) ifNil: [ ElementCategory new ]) elementsInOrder.
					interfaces := interfaces
								select: [:ea | additions
										anySatisfy: [:tuple | (tuple first = #slot
												ifTrue: [tuple at: 7]
												ifFalse: [tuple at: 2])
												= ea selector]].
					s tab; nextPutAll: cat translated; cr.
					interfaces
						do: [:if | | rt | 
							s tab: 2.
							rt := if resultType.
							rt = #unknown
								ifTrue: [s nextPutAll: 'command' translated]
								ifFalse: [s nextPutAll: 'property' translated;
										 nextPut: $(;
										 nextPutAll: (if companionSetterSelector
											ifNil: ['RO']
											ifNotNil: ['RW']) translated;
										 space;
										 nextPutAll: rt translated;
										 nextPutAll: ') '].
							s tab; print: if wording; space.
							if argumentVariables
								do: [:av | s nextPutAll: av variableName;
										 nextPut: $(;
										 nextPutAll: av variableType asString;
										 nextPut: $)]
								separatedBy: [s space].
							s tab; nextPutAll: if helpMessage; cr]]]]]
]

{ #category : #initialization }
EToyVocabulary >> addCustomCategoriesTo: categoryList [
	"Add any further categories to the categoryList -- for benefit of subclasses wishing to override."
]

{ #category : #'method list' }
EToyVocabulary >> allMethodsInCategory: aCategoryName forInstance: anObject ofClass: aClass [
	"Answer a list of all methods in the etoy interface which are in the given category, on behalf of anObject, or if it is nil, aClass"

	| aCategory unfiltered suitableSelectors isAll |

	aCategoryName ifNil: [^ OrderedCollection new].
	aClass isUniClass ifTrue:
		[aCategoryName = ScriptingSystem nameForScriptsCategory ifTrue:
			[^ aClass namedTileScriptSelectors].
		aCategoryName = ScriptingSystem nameForInstanceVariablesCategory ifTrue:
			[^ aClass slotInfo keys asArray sort collect:
				[:anInstVarName | anInstVarName asGetterSelector]]].
	unfiltered := (isAll := aCategoryName = self allCategoryName)
		ifTrue:
			[methodInterfaces collect: [:anInterface | anInterface selector]]
		ifFalse:
			[aCategory := categories detect: [:cat | cat categoryName = aCategoryName] 
							ifNone: [^ OrderedCollection new].
			aCategory elementsInOrder collect: [:anElement | anElement selector]].

	(anObject isKindOf: Player) ifTrue:
		[suitableSelectors := anObject costume selectorsForViewer.
		unfiltered := unfiltered  select:
			[:aSelector | suitableSelectors includes: aSelector]].
	(isAll and: [aClass isUniClass]) ifTrue:
		[unfiltered addAll: aClass namedTileScriptSelectors.
		unfiltered addAll: (aClass slotInfo keys asArray sort collect:
			[:anInstVarName | anInstVarName asGetterSelector])].

	^ (unfiltered copyWithoutAll: #(dummy unused)) sorted
]

{ #category : #'category list' }
EToyVocabulary >> categoryListForInstance: anObject ofClass: aClass limitClass: mostGenericClass [
	"Answer the category list for the given object, considering only code implemented in aClass and lower"

	^ (anObject isPlayerLike)
		ifTrue:
			[self flag: #deferred.  "The bit commented out on next line is desirable but not yet workable, because it delivers categories that are not relevant to the costume in question"
			"#(scripts #'instance variables'), (super categoryListForInstance: anObject ofClass: aClass limitClass: mostGenericClass)]"

			self translatedWordingsFor: ((mostGenericClass == aClass)
				ifFalse:
					[anObject categoriesForVocabulary: self]
				ifTrue:
					[{ScriptingSystem nameForScriptsCategory.  ScriptingSystem nameForInstanceVariablesCategory}])]
		ifFalse:
			[super categoryListForInstance: anObject ofClass: aClass limitClass: mostGenericClass]
]

{ #category : #initialization }
EToyVocabulary >> encompassesAPriori: aClass [
	"Answer whether an object, by its very nature, is one that the receiver embraces"

	^ aClass isKindOf: Player class
]

{ #category : #initialization }
EToyVocabulary >> includesSelector: aSelector forInstance: anInstance ofClass: aTargetClass limitClass: mostGenericClass [
	"Answer whether the vocabulary includes the given selector for the given class (and instance, if provided), only considering method implementations in mostGenericClass and lower"

	| classToUse aClass |
	(aTargetClass isUniClass and:
		[(aTargetClass namedTileScriptSelectors includes: aSelector) or:
			[aTargetClass slotInfo keys anySatisfy:
				[:anInstVarName | (anInstVarName asGetterSelector) = aSelector or: [(anInstVarName asSetterSelector) = aSelector]]]])
					 ifTrue: [^ true].

	(methodInterfaces includesKey: aSelector) ifFalse: [^ false].
	classToUse := self classToUseFromInstance: anInstance ofClass: aTargetClass.
	^ (aClass := classToUse whichClassIncludesSelector: aSelector)
		ifNil:
			[false]
		ifNotNil:
			[aClass includesBehavior: mostGenericClass]

]

{ #category : #initialization }
EToyVocabulary >> initialize [
	"Initialize the receiver (automatically called when instances are created via 'new')"

	| classes categorySymbols |
	super initialize.
	self vocabularyName: #eToy.
	self documentation: '"EToy" is a vocabulary that provides the equivalent of the 1997-2000 etoy prototype'.
	categorySymbols := Set new.
	classes := self class morphClassesDeclaringViewerAdditions.
	classes do:
		[:aMorphClass | categorySymbols addAll: aMorphClass unfilteredCategoriesForViewer].
	self addCustomCategoriesTo: categorySymbols.  "For benefit, e.g., of EToyVectorVocabulary"

	categorySymbols asOrderedCollection do:
		[:aCategorySymbol | | selectors aMethodCategory |
			aMethodCategory := ElementCategory new categoryName: aCategorySymbol.
			selectors := Set new.
			classes do:
				[:aMorphClass |
					 (aMorphClass additionsToViewerCategory: aCategorySymbol) do:
						[:anElement | | selector aMethodInterface |
						aMethodInterface := self methodInterfaceFrom: anElement.
						selectors add: (selector := aMethodInterface selector).
						(methodInterfaces includesKey: selector) ifFalse:
							[methodInterfaces at: selector put: aMethodInterface].
						self flag: #deferred.
						"NB at present, the *setter* does not get its own method interface.  Need to revisit"].

			(selectors copyWithout: #unused) sorted do:
				[:aSelector |
					aMethodCategory elementAt: aSelector put: (methodInterfaces at: aSelector)]].
				 
			self addCategory: aMethodCategory].

	self addCategoryNamed: ScriptingSystem nameForInstanceVariablesCategory.
	self addCategoryNamed: ScriptingSystem nameForScriptsCategory.
	self setCategoryDocumentationStrings.
	(self respondsTo: #applyMasterOrdering)
		ifTrue: [ self applyMasterOrdering ].
]

{ #category : #testing }
EToyVocabulary >> isEToyVocabulary [
	^true
]

{ #category : #'method list' }
EToyVocabulary >> masterOrderingOfPhraseSymbols [
	"Answer a dictatorially-imposed presentation list of phrase-symbols.  This governs the order in which suitable phrases are presented in etoy viewers using the etoy vocabulary.  For any given category, the default implementation is that any items that are in this list will occur first, in the order specified here; after that, all other items will come, in alphabetic order by formal selector."

	^ #(beep: forward: turn: getX getY getLocationRounded getHeading getScaleFactor

		getLeft getRight getTop getBottom  
		getLength getWidth 
		getTheta getDistance getHeadingTheta getUnitVector

		startScript: pauseScript: stopScript: startAll: pauseAll: stopAll: tellAllSiblings: doScript:

		getColor getUseGradientFill getSecondColor  getRadialGradientFill  getBorderWidth getBorderColor getBorderStyle getRoundedCorners getDropShadow getShadowColor 

		getVolume play playUntilPosition: stop rewind getIsRunning getRepeat getPosition getTotalFrames getTotalSeconds getFrameGraphic getVideoFileName getSubtitlesFileName

		getGraphic getBaseGraphic

		getAllowEtoyUserCustomEvents 

		#getAutoExpansion #getAutoLineLayout #getBatchPenTrails getDropProducesWatcher #getFenceEnabled #getIndicateCursor #getIsOpenForDragNDrop #getIsPartsBin #getMouseOverHalos #getOriginAtCenter #getShowThumbnail

	 getFenceEnabled getKeepTickingWhilePainting getOliveHandleForScriptedObjects  getUseVectorVocabulary 

)
]

{ #category : #initialization }
EToyVocabulary >> methodInterfaceFrom: elementTuple [
	"Tedious revectoring:  The argument is a tuple of the sort that #additionsToViewerCategory: answers a list of; answer a MethodInterface"

	^ elementTuple first == #command
		ifTrue:
			[MethodInterface new initializeFromEToyCommandSpec: elementTuple category: nil]
		ifFalse:  "#slot format"
			[MethodInterface new initializeFromEToySlotSpec: elementTuple]
]

{ #category : #initialization }
EToyVocabulary >> objectForDataStream: refStrm [
	"I am about to be written on an object file.  Write a path to me in the other system instead."

	vocabularyName == #eToy ifFalse: [^ self].

	^ DiskProxy 
		global: #Vocabulary
		selector: #vocabularyNamed: 
		args: (Array with: vocabularyName)

]

{ #category : #'method list' }
EToyVocabulary >> phraseSymbolsToSuppress [
	"Answer a dictatorially-imposed list of phrase-symbols that are to be suppressed from viewers when the eToyFriendly preference is set to true.  This list at the moment corresponds to the wishes of Alan and Kim and the LA teachers using Squeak in school-year 2001-2"

	^ Preferences eToyFriendly
		ifTrue:
			[#(moveToward: followPath goToRightOf:
				getViewingByIcon initiatePainting
				append: prepend: getClipSubmorphs touchesA:)]
		ifFalse:
			[#()]
]

{ #category : #initialization }
EToyVocabulary >> setCategoryDocumentationStrings [
	"Initialize the documentation strings associated with the old etoy categories, in English"

	self setCategoryStrings: #(
(basic					'basic'					'a few important things')
(#'book navigation'		'book navigation'		'relating to book, stacks, etc')
(button					'button'					'for thinking of this object as a push-button control')
(collections				'collections'				'for thinking of this object as a collection')
(fog					'fog'					'3D fog')
(geometry				'geometry' 				'measurements and coordinates')
(#'color & border'		'color & border'			'matters concerning the colors and borders of objects')
(graphics				'graphics'				'for thinking of this object as a picture')
(variables				'variables'				'variables added by this object')
(joystick				'joystick'				'the object as a Joystick')
(miscellaneous			'miscellaneous' 			'various commands')
(motion					'motion' 				'matters relating to moving and turning')
(paintbox				'paintbox'				'the painting palette')
(#'pen trails'			'pen trails'				'relating to trails put down by pens')
(#'pen use'				'pen use' 				'use of an object''s "pen"')
(playfield				'playfield'				'the object as a container for other visible objects')
(sampling				'sampling'				'sampling')
(scripting				'scripting'				'commands to start and stop scripts')
(scripts					'scripts'					'methods added by this object')
(slider					'slider'					'functions useful to sliders')
(speaker				'speaker'				'the object as an audio Speaker')
(#'stack navigation'		'stack navigation'		'navigation within a stck')
(storyboard				'storyboard'				'storyboard')
(tests					'tests'					'yes/no tests, to use in "Test" panes of scripts')
(text					'text'					'The object as text')
(vector					'vector'					'The object as a vector')
(viewing				'viewing'				'matters relating to viewing')
 ) 
]
