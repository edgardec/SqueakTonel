"
CardPlayer
	Instance variables of the Uniclass represent the data in the ""fields"" of each card in the stack.
	Each Instance variable is some kind of value holder.

	The code for the *buttons* on the background resides in the CardPlayer uniclass.

privateMorphs -- OrderedCollection of objects specific to this card.

Individual CardPlayer classes need to store the search results of any instances that are templates.  As a hack, we use a class variable TemplateMatches in each individual class (CardPlayer21).  It is initialized in #matchIndex:.
TemplateMatches   an IndentityDictionary of 
		(aCardPlayer -> (list of matching cards, index in that list))

"
Class {
	#name : #CardPlayer,
	#superclass : #Player,
	#instVars : [
		'privateMorphs'
	],
	#category : #'Etoys-Stacks'
}

{ #category : #compiling }
CardPlayer class >> acceptsLoggingOfCompilation [
	"Answer whether methods of the receiver should be logged when submitted."

	^ #(CardPlayer) includes: self class theNonMetaClass name
]

{ #category : #slots }
CardPlayer class >> compileAccessorsFor: varName [
	"Compile instance-variable accessor methods for the given variable name"

	| nameString |
	nameString := varName asString capitalized.
	self compileSilently: ('get', nameString, '
	^ ', varName)
		classified: 'access'.
	self compileSilently: ('set', nameString, ': val
	', varName, ' := val')
		classified: 'access'
]

{ #category : #'instance creation' }
CardPlayer class >> isUniClass [
	"Answer, for the purpose of providing annotation in a method holder, whether the receiver is a uniClass."

	^ self ~~ CardPlayer
]

{ #category : #testing }
CardPlayer class >> officialClass [
	"Answer (for the purpose of copying mechanisms) the system class underlying the receiver."

	^ CardPlayer
]

{ #category : #slots }
CardPlayer class >> removeAccessorsFor: varName [
	"Remove the instance-variable accessor methods associated with varName"

	| nameString |
	nameString := varName asString capitalized.
	self removeSelectorSilently: ('get', nameString) asSymbol.
	self removeSelectorSilently: ('set', nameString, ':') asSymbol
]

{ #category : #compiling }
CardPlayer class >> wantsChangeSetLogging [
	"Log changes for CardPlayer itself, but not for automatically-created subclasses like CardPlayer1, CardPlayer2, but *do* log it for uniclasses that have been manually renamed."

	^ (self == CardPlayer or:
		[(self name beginsWith: 'CardPlayer') not]) or:
			[Preferences universalTiles]
]

{ #category : #'card data' }
CardPlayer >> allStringsAfter: aText [ 
	"return an OrderedCollection of strings of text in my instance vars.  If aText is non-nil, begin with that object."

	| list ok |
	list := OrderedCollection new.
	ok := aText isNil.
	self class variableDocks do: 
			[:vdock | | instVarValue string | 
			instVarValue := self perform: vdock playerGetSelector.
			ok ifFalse: [ok := instVarValue == aText].	"and do this one too"
			ok 
				ifTrue: 
					[string := nil.
					instVarValue isString ifTrue: [string := instVarValue].
					instVarValue isText ifTrue: [string := instVarValue string].
					instVarValue isNumber ifTrue: [string := instVarValue printString].
					instVarValue isMorph ifTrue: [string := instVarValue userString].	"not used"
					string ifNotNil: 
							[string isString ifTrue: [list add: string] ifFalse: [list addAll: string]]]].
	privateMorphs 
		ifNotNil: [privateMorphs do: [:mm | list addAll: (mm allStringsAfter: nil)]].
	^list
]

{ #category : #'card data' }
CardPlayer >> asKeys [
	| keys kk vd gotData |
	"Take my fields, tokenize the text, and return as an array in the same order as variableDocks.  Simple background fields on the top level.  If no data, return nil."

	keys := self class variableDocks copy.
	gotData := false.
	1 to: keys size do: [:ind |
		kk := nil.
		vd := self class variableDocks at: ind.
		vd type == #text ifTrue: [
			kk := (self perform: vd playerGetSelector) string
					substrings.
			kk isEmpty ifTrue: [kk := nil] ifFalse: [gotData := true]].
		keys at: ind put: kk].
	^ gotData ifTrue: [keys] ifFalse: [nil]
]

{ #category : #'card data' }
CardPlayer >> commitCardPlayerData [
	"Transport data back from the morphs that may be holding it into the instance variables that must hold it when the receiver is not being viewed"

	| prior |
	self class variableDocks do:
		[:aDock | aDock storeMorphDataInInstance: self].
	prior := nil.
	privateMorphs := OrderedCollection new.
	self costume ifNotNil:
		[self costume submorphs do:
			[:aMorph | aMorph renderedMorph isShared
				ifFalse:
					[aMorph setProperty: #priorMorph toValue: prior.
					privateMorphs add: aMorph.
					aMorph delete].
			prior := aMorph]]
]

{ #category : #'card data' }
CardPlayer >> commitCardPlayerDataFrom: aPlayfield [
	"Transport data back from the morphs that may be holding it into the instance variables that must hold it when the receiver is not being viewed"

	| prior itsOrigin |
	itsOrigin := aPlayfield topLeft.
	self class variableDocks do:
		[:aDock | aDock storeMorphDataInInstance: self].
	prior := nil.
	privateMorphs := OrderedCollection new.
	self costume ifNotNil:
		[self costume submorphs do:
			[:aMorph | aMorph renderedMorph isShared
				ifFalse:
					[aMorph setProperty: #priorMorph toValue: prior.
					privateMorphs add: aMorph.
					aMorph delete.
					aMorph position: (aMorph position - itsOrigin)].
			prior := aMorph]]
]

{ #category : #'card data' }
CardPlayer >> installPrivateMorphsInto: aBackground [
	"The receiver is being installed as the current card in a given pasteup morph being used as a background.  Install the receiver's private morphs into that playfield"

	
	self flag: #deferred.  "not robust if the background is showing a list view"
	privateMorphs ifNotNil: [privateMorphs do:
		[:aMorph | | prior originToUse |
			originToUse := aBackground topLeft.
			prior := aMorph valueOfProperty: #priorMorph ifAbsent: [nil].
			aMorph position: (aMorph position + originToUse).
			(prior notNil and: [aBackground submorphs includes: prior])
				ifTrue:
					[aBackground addMorph: aMorph after: prior]
				ifFalse:
					[aBackground addMorphFront: aMorph].
		aMorph removeProperty: #priorMorph]]
]

{ #category : #'card data' }
CardPlayer >> match: keys fields: docks [
	
	"see if each key occurs in my corresponding text instance."

	keys withIndexDo: [:kk :ind | | longString |
		kk ifNotNil: [
			longString := (self perform: (docks at: ind) playerGetSelector) string.
			kk do: [:aKey |
				((longString findString: aKey startingAt: 1 caseSensitive: false) > 0)
					ifFalse: [^ false]]]]. 	"all keys must match"
	^ true
]

{ #category : #'as template' }
CardPlayer >> matchIndex [
	| tms |
	"Index of one we are looking at, in the cards that matched the last search with this template."

	tms := self class classPool at: #TemplateMatches ifAbsent: [^ 0].
	^ (tms at: self ifAbsent: [#(0 0)]) second.

]

{ #category : #'as template' }
CardPlayer >> matchIndex: newPlace [
	| tms pair |
	"One we are looking at, in cards that matched the last template search."

	tms := self class classPool at: #TemplateMatches ifAbsent: [
		self class addClassVarName: 'TemplateMatches'.
		self class classPool at: #TemplateMatches put: IdentityDictionary new].
	pair := tms at: self ifAbsentPut: [Array new: 2].
	pair at: 2 put: newPlace.
	newPlace = 0 ifTrue: [^ self].
	pair first ifNil: [^ self].
	(costume valueOfProperty: #myStack ifAbsent: [^ self]) goToCard: 
		((pair first "list") at: newPlace).
	self changed: #matchIndex.	"update my selection"

]

{ #category : #'as template' }
CardPlayer >> matchNames [
	| list tms stk crds |
	"List of names of cards that matched the last template search."

	tms := self class classPool at: #TemplateMatches ifAbsent: [^ #()].
	list := (tms at: self ifAbsent: [#(#() 0)]) first.
	stk := costume valueOfProperty: #myStack ifAbsent: [nil].
	crds := stk ifNil: [#()] ifNotNil: [stk cards].
	^ list collect: [:cd | | str ll | 
		str := ''.
		(ll := cd allStringsAfter: nil) ifNotNil: [
			str := ll inject: '' into: [:strr :this | strr, this]]. 
		(str copyFrom: 1 to: (30 min: str size)), '...  (' , (crds indexOf: cd) printString, ')'].
		"Maybe include a card title?"
]

{ #category : #printing }
CardPlayer >> printOn: aStream [
	"Print out a human-readable representation of the receiver onto aStream"

	super printOn: aStream.
	self class instVarNames do:
		[:aName | aStream nextPutAll: ', ', aName, ' = ', (self instVarNamed: aName) printString]
]

{ #category : #'card data' }
CardPlayer >> privateMorphs [

	^ privateMorphs
]

{ #category : #'scripts-kernel' }
CardPlayer >> renameScript: oldSelector newSelector: newSelector [
	"Find all buttons that fire this script and tell them the new name"

	| stack |
	super renameScript: oldSelector newSelector: newSelector.
	costume allMorphsDo: [:mm |
		self retargetButton: mm oldSelector: oldSelector newSelector: newSelector].

	stack := costume valueOfProperty: #myStack.
	stack ifNotNil:
		[stack cards do: [:cc |
			cc privateMorphs do: [:pp | 
				pp allMorphsDo: [:mm |
					self retargetButton: mm oldSelector: oldSelector newSelector: newSelector]]]]
]

{ #category : #'as template' }
CardPlayer >> results [
	"Return my (cardlist index) pair from the last search"

	^ (self class classPool at: #TemplateMatches ifAbsent: [^ Array new: 2]) at: self

]

{ #category : #'scripts-kernel' }
CardPlayer >> retargetButton: mm oldSelector: oldSelector newSelector: newSelector [
	"changing the name of a script -- tell any buttons that fire it"

	(mm respondsTo: #scriptSelector) ifTrue: [
		mm scriptSelector == oldSelector ifTrue: [
			mm scriptSelector: newSelector.
			mm setNameTo: newSelector]].
	(mm respondsTo: #actionSelector) ifTrue: [
		mm actionSelector == oldSelector ifTrue: [
			mm target class == self class ifTrue: [
				mm actionSelector: newSelector.
				mm setNameTo: newSelector]]].

]

{ #category : #'slots-kernel' }
CardPlayer >> tileReferringToSelf [
	"Answer a tile that refers to the receiver.  For CardPlayer, want 'self', not the specific name of this card.  Script needs to work for any card of the background."

	Preferences universalTiles ifTrue:
		[^ self universalTileReferringToSelf].

	^ TileMorph new setToReferTo: self
]

{ #category : #'card data' }
CardPlayer >> url [
	"For now, don't know we could be on a server"

	^ nil
]
