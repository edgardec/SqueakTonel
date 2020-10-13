"
ObjectWithDocumentation - an abstract superclass for objects that allows maintenance of an authoring stamp, a body of documentation, and a properties dictionary.
The Properties implementation has not happened yet -- it would closely mirror the implementation of properties in the MorphExtension, for example.
"
Class {
	#name : #ObjectWithDocumentation,
	#superclass : #Object,
	#instVars : [
		'authoringStamp',
		'properties',
		'elementSymbol',
		'naturalLanguageTranslations'
	],
	#category : #'Protocols-Kernel'
}

{ #category : #accessing }
ObjectWithDocumentation >> documentation [
	"Answer the receiver's documentation"

	^self helpMessage
]

{ #category : #accessing }
ObjectWithDocumentation >> documentation: somethingUsefulHopefully [
	"Set the receiver's documentation, in the current langauge"

	self helpMessage: somethingUsefulHopefully
]

{ #category : #documentation }
ObjectWithDocumentation >> editDescription [
	"Allow the user to see and edit the documentation for this object"
	| reply helpMessage |
	helpMessage := self documentation ifNil: [String new].
	reply := UIManager default
				multiLineRequest: 'Kindly edit the description' translated
				centerAt: Sensor cursorPoint
				initialAnswer: helpMessage
				answerHeight: 200.
	reply isEmptyOrNil
		ifFalse: [self documentation: reply]
]

{ #category : #miscellaneous }
ObjectWithDocumentation >> elementSymbol [
	"Answer the receiver's element symbol"

	^ elementSymbol
]

{ #category : #private }
ObjectWithDocumentation >> getterSetterHelpMessage [
	"Returns a helpMessage that has been computed previously and needs to be translated and then formatted with the elementSymbol.
	'get value of {1}' translated format: {elSym}"

	^(self propertyAt: #getterSetterHelpMessage ifAbsent: [^nil])
		translated format: {self elementSymbol}
]

{ #category : #private }
ObjectWithDocumentation >> getterSetterHelpMessage: aString [
	"Sets a helpMessage that needs to be translated and then formatted with the elementSymbol.
	'get value of {1}' translated format: {elSym}"

	self propertyAt: #getterSetterHelpMessage put: aString
]

{ #category : #accessing }
ObjectWithDocumentation >> helpMessage [
	"Check if there is a getterSetterHelpMessage. 
	Otherwise try the normal help message or return nil."

	^ self getterSetterHelpMessage
		ifNil: [(self propertyAt: #helpMessage ifAbsent:
			[self legacyHelpMessage ifNil: [^ nil]]) translatedInDomain: 'Etoys-Tiles']
]

{ #category : #accessing }
ObjectWithDocumentation >> helpMessage: somethingUsefulHopefully [
	"Set the receiver's documentation, in the current langauge"

	self propertyAt: #helpMessage put: somethingUsefulHopefully
]

{ #category : #private }
ObjectWithDocumentation >> initWordingAndDocumentation [
	"Initialize wording and documentation (helpMessage) for getters and setters"

	| elSym |
	elSym := self elementSymbol.
	elSym
		ifNil: [^self].

	((elSym beginsWith: 'get')
		and: [elSym size > 3])
		ifTrue: [
			self wording: (elSym allButFirst: 3) withFirstCharacterDownshifted.
			self getterSetterHelpMessage: 'get value of {1}']
		ifFalse: [
			((elSym beginsWith: 'set')
				and: [elSym size > 4])
				ifTrue: [
					self wording: (elSym allButFirst: 3) withFirstCharacterDownshifted.
					self getterSetterHelpMessage: 'set value of {1}']]
]

{ #category : #initialization }
ObjectWithDocumentation >> initialize [
	"Initialize the receiver (automatically called when instances are created via 'new')"

	authoringStamp := Utilities changeStampPerSe

]

{ #category : #accessing }
ObjectWithDocumentation >> legacyHelpMessage [
	"If I have a help message stashed in my legacy naturalTranslations slot, answer its translated rendition, else answer nil.  If I *do* come across a legacy help message, transfer it to my properties dictionary."

	| untranslated |
	naturalLanguageTranslations isEmptyOrNil  "only in legacy (pre-3.8) projects"
		ifTrue: [^ nil].
	untranslated := naturalLanguageTranslations first helpMessage ifNil: [^ nil].
	self propertyAt: #helpMessage put: untranslated.
	naturalLanguageTranslations removeFirst.
	naturalLanguageTranslations isEmpty ifTrue: [naturalLanguageTranslations := nil].
	^ untranslated translated
]

{ #category : #migration }
ObjectWithDocumentation >> migrateWordAndHelpMessage [
	"Migrate the English wording and help message to the new structure"

	| englishElement |
	self initWordingAndDocumentation.
	(self properties includes: #wording)
		ifFalse: [
			englishElement := self naturalLanguageTranslations
				detect: [:each | each language == #English] ifNone: [^nil].
			self wording: englishElement wording.
			self helpMessage: englishElement helpMessage]
]

{ #category : #miscellaneous }
ObjectWithDocumentation >> naturalLanguageTranslations [
	^naturalLanguageTranslations ifNil: [OrderedCollection new]
]

{ #category : #private }
ObjectWithDocumentation >> properties [
	^properties ifNil: [properties := Dictionary new]
]

{ #category : #private }
ObjectWithDocumentation >> propertyAt: key [
	^self propertyAt: key ifAbsent: [nil]
]

{ #category : #private }
ObjectWithDocumentation >> propertyAt: key ifAbsent: aBlock [
	^properties
		ifNil: aBlock
		ifNotNil: [properties at: key ifAbsent: aBlock]
]

{ #category : #private }
ObjectWithDocumentation >> propertyAt: key put: aValue [
	self properties at: key put: aValue
]

{ #category : #accessing }
ObjectWithDocumentation >> untranslatedHelpMessage [
	"Check if there is a getterSetterHelpMessage. 
	Otherwise try the normal help message or return nil."

	^(self propertyAt: #getterSetterHelpMessage ifAbsent: [nil])
		ifNil: [(self propertyAt: #helpMessage ifAbsent: [nil])]
]

{ #category : #accessing }
ObjectWithDocumentation >> untranslatedWording [
	"Answer the receiver's wording"

	^self propertyAt: #wording ifAbsent: [nil]
]

{ #category : #accessing }
ObjectWithDocumentation >> wording [
	"Answer the receiver's wording"

	| wording |
	(wording := self propertyAt: #wording ifAbsent: [nil])
		ifNotNil: [^wording translatedInDomain: 'Etoys-Tiles' or: 'Etoys'].

	self initWordingAndDocumentation.
	^self propertyAt: #wording ifAbsent: ['']
]

{ #category : #accessing }
ObjectWithDocumentation >> wording: aString [
	"Set the receiver's wording, in the current langauge"

	self propertyAt: #wording put: aString
]
