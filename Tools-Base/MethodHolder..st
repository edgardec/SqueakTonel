Class {
	#name : #MethodHolder,
	#superclass : #CodeHolder,
	#instVars : [
		'methodClass',
		'methodSelector'
	],
	#category : #'Tools-Base'
}

{ #category : #menu }
MethodHolder >> addModelMenuItemsTo: aCustomMenu forMorph: aMorph hand: aHandMorph [
	aCustomMenu addLine.
	aCustomMenu add: 'whose script is this?' translated target: self action: #identifyScript
	
]

{ #category : #miscellaneous }
MethodHolder >> changeMethodSelectorTo: aSelector [
	"Change my method selector as noted.  Reset currentCompiledMethod"

	methodSelector := aSelector.
	currentCompiledMethod := methodClass compiledMethodAt: aSelector ifAbsent: [nil]
]

{ #category : #miscellaneous }
MethodHolder >> compiledMethod [

	^ methodClass compiledMethodAt: methodSelector
]

{ #category : #contents }
MethodHolder >> contents [
	"Answer the contents, with due respect for my contentsSymbol"

	contents := methodClass sourceCodeAt: methodSelector ifAbsent: [''].
	currentCompiledMethod := methodClass compiledMethodAt: methodSelector ifAbsent: [nil].

	self showingDecompile ifTrue: [^ self decompiledSourceIntoContents].
	self showingDocumentation ifTrue: [^ self commentContents].
	^ contents := self sourceStringPrettifiedAndDiffed asText makeSelectorBoldIn: methodClass
]

{ #category : #contents }
MethodHolder >> contents: input notifying: aController [ 
	| selector |
	(selector := methodClass newParser parseSelector: input asText) ifNil:
		[self inform: 'Sorry - invalid format for the 
method name and arguments -- cannot accept.'.
		^ false].

	selector == methodSelector ifFalse:
		[self inform:
'You cannot change the name of
the method here -- it must continue
to be ', methodSelector.
		^ false].

	selector := methodClass
				compile: input asText
				classified: self selectedMessageCategoryName
				notifying: aController.
	selector == nil ifTrue: [^ false].
	contents := input asString copy.
	currentCompiledMethod := methodClass compiledMethodAt: methodSelector.
	^ true
]

{ #category : #menu }
MethodHolder >> doItReceiver [
	"If there is an instance associated with me, answer it, for true mapping of self.  If not, then do what other code-bearing tools do, viz. give access to the class vars."
	^ self selectedClass
]

{ #category : #miscellaneous }
MethodHolder >> identifyScript [
	| msg aPlayer |
	msg := methodClass isUniClass
		ifTrue:
			[aPlayer := methodClass someInstance.
			aPlayer costume
				ifNotNil:
					['This holds code for a script
named ', methodSelector, ' belonging
to an object named ', aPlayer externalName]
				ifNil:
					['This formerly held code for a script
named ', methodSelector, ' for a Player
who once existed but now is moribund.']]
		ifFalse:
			['This holds code for the method
named ', methodSelector, '
for class ', methodClass name].
	self inform: msg
]

{ #category : #miscellaneous }
MethodHolder >> methodClass: aClass methodSelector: aSelector [
	methodClass := aClass.
	methodSelector := aSelector.
	currentCompiledMethod := aClass compiledMethodAt: aSelector ifAbsent: [nil]
]

{ #category : #selection }
MethodHolder >> selectedClass [
	^ methodClass theNonMetaClass
]

{ #category : #selection }
MethodHolder >> selectedClassOrMetaClass [
	^ methodClass
]

{ #category : #selection }
MethodHolder >> selectedMessageCategoryName [
	^ methodClass organization categoryOfElement: methodSelector
]

{ #category : #selection }
MethodHolder >> selectedMessageName [
	^ methodSelector
]

{ #category : #miscellaneous }
MethodHolder >> versions [
	"Return a VersionsBrowser (containing a list of ChangeRecords) of older versions of this method."

	^ VersionsBrowser new scanVersionsOf: self compiledMethod
			class: self selectedClass 
			meta: methodClass isMeta 
			category: self selectedMessageCategoryName
				"(classOfMethod whichCategoryIncludesSelector: selectorOfMethod)"
			selector: methodSelector
]
