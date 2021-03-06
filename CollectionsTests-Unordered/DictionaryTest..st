Class {
	#name : #DictionaryTest,
	#superclass : #TestCase,
	#classInstVars : [
		'testToto',
		'pt1'
	],
	#category : #'CollectionsTests-Unordered'
}

{ #category : #tests }
DictionaryTest >> testAdd [
	
	| dict |
	dict := Dictionary new.
	dict add: #a -> 1.
	dict add: #b -> 2.
	self assert: (dict at: #a) = 1.
	self assert: (dict at: #b) = 2
]

{ #category : #tests }
DictionaryTest >> testAddAll [
	
	| dict1 dict2 |
	dict1 := Dictionary new.
	dict1 at: #a put:1 ; at: #b put: 2. 
	dict2 := Dictionary new.
	dict2 at: #a put: 3 ; at: #c put: 4.
	dict1 addAll: dict2.
	self assert: (dict1 at: #a) = 3.
	self assert: (dict1 at: #b) = 2.
	self assert: (dict1 at: #c) = 4.

	dict1 := Dictionary new.
	dict1 at: #a put:1 ; at: #b put: 2. 
	dict1 addAll: {#a -> 3. #c -> 4}.
	self assert: (dict1 at: #a) = 3.
	self assert: (dict1 at: #b) = 2.
	self assert: (dict1 at: #c) = 4.
]

{ #category : #'tests - association' }
DictionaryTest >> testAddAssociation [
	"self run:#testAddAssociation"
	"self debug:#testAddAssociation"
	
	| dict |
	dict := Dictionary new.
	dict at: #a put: 1.
	dict at: #b put: 2.
	self assert: (dict at: #a) = 1.
	self assert: (dict at: #b) = 2.
	
	dict at: #a put: 10.
	dict at: #c put: 2.
	
	self assert: (dict at: #a) = 10.
	self assert: (dict at: #b) = 2.
	self assert: (dict at: #c) = 2
	
	
]

{ #category : #'tests - basic' }
DictionaryTest >> testArraySizeOfNew [
	"Test the special cases implemented in HashedCollection class >> #new and #new: using Dictionary as an example because HashedCollection is abstract."
	
	| goodPrimes |
	goodPrimes := HashedCollection goodPrimes.
	self assert: (goodPrimes includes: Dictionary new array size).
	0 to: 100 do: [ :size |
		| dictionary |
		dictionary := Dictionary new: size.
		self assert: (goodPrimes includes: dictionary array size).
		self assert: dictionary capacity >= size ]
]

{ #category : #tests }
DictionaryTest >> testAsSet [
	"Non regression test for http://bugs.squeak.org/view.php?id=7258"
	
	| aDictionary aSet assoc0 assoc1 |
	
	"Create a dictionary"
	aDictionary := Dictionary new.
	
	"Convert it to a Set"
	aSet := aDictionary asSet.

	"Add two associations to it"	
	assoc0 := #first -> 0.
	assoc1 := #first -> 1.
	aSet add: assoc0 copy; add: assoc1.
	
	"Check if the two associations were added (that should happen if they are different)"
	self
		assert: (assoc0 copy ~= assoc1) ==> (aSet size > 1)
		description:
  			'When adding two different elements, the set size should be greater than one'
]

{ #category : #'tests - association' }
DictionaryTest >> testAssociationsSelect [
	| answer d |
	d := Dictionary new.
	d at: (Array with: #hello with: #world)
	  put: #fooBar.
	d at: Smalltalk put: #'Smalltalk is the key'.
	d at: #Smalltalk put: Smalltalk.
	answer := d
				associationsSelect: [:assoc | assoc key == #Smalltalk
						and: [assoc value == Smalltalk]].
	self
		should: [answer isKindOf: Dictionary].
	self
		should: [answer size = 1].
	self
		should: [(answer at: #Smalltalk)
				== Smalltalk].
	answer := d
				associationsSelect: [:assoc | assoc key == #NoSuchKey
						and: [assoc value == #NoSuchValue]].
	self
		should: [answer isKindOf: Dictionary].
	self
		should: [answer size = 0]
]

{ #category : #'tests - basic' }
DictionaryTest >> testAtError [
	"self run: #testAtError"
	
	| dict |
	dict := Dictionary new.
	dict at: #a put: 666.
	self shouldnt: [ dict at: #a ] raise: KeyNotFound.
	self should: [ dict at: #b ] raise: KeyNotFound.
	
	
]

{ #category : #'tests - basic' }
DictionaryTest >> testAtIfAbsent [
	"self run: #testAtIfAbsent"
	
	| dict |
	dict := Dictionary new.
	dict at: #a put: 666.
	
	self assert: (dict at: #a ifAbsent: [nil]) = 666.
	
	self assert: (dict at: #b ifAbsent: [nil]) isNil.

	
]

{ #category : #'tests - basic' }
DictionaryTest >> testAtIfPresentIfAbsent [
	"Test at:ifPresent:ifAbsent:"
	| dict present absent |
	dict := Dictionary new.
	present := absent := false.
	dict at: #foo ifPresent:[:v| present := true] ifAbsent:[absent := true].
	self deny: present.
	self assert: absent.

	dict at: #foo put: #bar.
	present := absent := false.
	dict at: #foo ifPresent:[:v| present := true] ifAbsent:[absent := true].
	self assert: present.
	self deny: absent.

	present := absent := false.
	dict at: #foo ifPresent:[:v| present := true. nil] ifAbsent:[absent := true].
	self assert: present.
	self deny: absent.

]

{ #category : #'tests - basic' }
DictionaryTest >> testAtIfPresentIfAbsentPut [
	"Test at:ifPresent:ifAbsentPut:"
	| dict present absent |
	dict := Dictionary new.
	present := absent := false.
	self assert: (dict at: #foo ifPresent:[:v| present := true. v] ifAbsentPut:[absent := true. #present])
		equals: #present.
	self deny: present.
	self assert: absent.

	present := absent := false.
	self assert: (dict at: #foo ifPresent:[:v| present := true. v] ifAbsentPut:[absent := true. #absent])
		equals: #present.
	self assert: present.
	self deny: absent.
]

{ #category : #'tests - implementation' }
DictionaryTest >> testAtNil [
	"(self run: #testAtNil)"
	"nil is a valid key in squeak. In VW nil is not a valid key"
	"Ansi 1.9 p, 168
    		5.7.2.5 Message: at: key put: newElement
    		Synopsis
    			Store newElement at key in the receiver. Answer newElement.
    		Definition: <abstractDictionary>
    		If lookup succeeds for key, then newElement replaces the element previously stored at key.
    		Otherwise, the newElement is stored at the new key. In either case, subsequent successful
    		lookups for key will answer newElement.  Answer newElement.

    		The result is undefined if the key is nil.

		This clearly indicates that different smalltalks where doing different assumptions."
	
	
	
	| dict1  |
	dict1 := Dictionary new.
	dict1 at: nil put: #none.
	self assert: (dict1 at: nil) = #none. 
	
]

{ #category : #'tests - basic' }
DictionaryTest >> testAtPut [
	"self run: #testAtPut"
	"self debug: #testAtPut"
	
	| adictionary |
	adictionary := Dictionary new.
	adictionary at: #a put: 3.
	self assert: (adictionary at: #a) = 3.
	adictionary at: #a put: 3.
	adictionary at: #a put: 4.
	self assert: (adictionary at: #a) = 4.
	adictionary at: nil put: 666.
	self assert: (adictionary at: nil) = 666
]

{ #category : #'tests - basic' }
DictionaryTest >> testAtPutNil [
	"self run: #testAtPut"
	"self debug: #testAtPut"
	
	| dict |
	dict := Dictionary new.
	dict at: nil put: 1.
	self assert: (dict at: nil) = 1.
	dict at: #a put: nil.
	self assert: (dict at: #a) = nil.
	dict at: nil put: nil.
	self assert: (dict at: nil) = nil.
	
	
	
]

{ #category : #'tests - collection protocol' }
DictionaryTest >> testCollect [
	"Ensure that Dictionary>>collect: answers a dictionary not something else"
	| dict expected result |
	dict := Dictionary newFromPairs:{
		#first.		1.
		#second.	2.
		#third.		3.
		#fourth.	4.
		#fifth.		5.
	}.
	result := dict collect:[:each| each asWords].
	expected := Dictionary newFromPairs:{
		#first.		'one'.
		#second.	'two'.
		#third.		'three'.
		#fourth.	'four'.
		#fifth.		'five'.
	}.
	self assert: result = expected.
]

{ #category : #'tests - collection protocol' }
DictionaryTest >> testCollectAs [

	| classes collection dictionary |
	classes := {Array . OrderedCollection . Set . Bag}.
	classes do: [:originClass |
			collection := originClass with: 1 with: 2 with: 3.
			dictionary := collection collect: [:v | v -> (v + 1)] as: Dictionary.
			self 
				assert: collection size equals: dictionary size;
				assert: (dictionary associations includesAllOf: { 1 -> 2 . 2 -> 3. 3 -> 4})]
]

{ #category : #tests }
DictionaryTest >> testComma [
	
	| dict1 dict2 dict3 |
	dict1 := Dictionary new.
	dict1 at: #a put:1 ; at: #b put: 2. 
	dict2 := Dictionary new.
	dict2 at: #a put: 3 ; at: #c put: 4.
	dict3 := dict1, dict2.
	self assert: (dict3 at: #a) = 3.
	self assert: (dict3 at: #b) = 2.
	self assert: (dict3 at: #c) = 4.
]

{ #category : #'tests - keys and value' }
DictionaryTest >> testDictionaryConcatenation [
	"self run: #testDictionaryConcatenation"
	
	
	| dict1 dict2 dict3 |
	dict1 := Dictionary new.
	dict1 at: #a put: 'Nicolas' ; at: #b put: 'Damien'. 
	
	dict2 := Dictionary new.
	dict2 at: #a put: 'Christophe' ; at: #c put: 'Anthony'.
	dict3 := dict1, dict2.
	
	self assert: (dict3 at: #a) = 'Christophe'.
	self assert: (dict3 at: #b) = 'Damien'.
	self assert: (dict3 at: #c) = 'Anthony'.
	

	
]

{ #category : #'tests - association' }
DictionaryTest >> testIncludesAssociation [
	"self run:#testIncludesAssociation"
	
	| dict |
	dict := Dictionary new.
	dict at: #a put: 1.
	dict at: #b put: 2.
	self assert: (dict includesAssociation: (#a -> 1)).
	self assert: (dict includesAssociation: (#b -> 2)).
	
	
]

{ #category : #'tests - association' }
DictionaryTest >> testIncludesAssociationNoValue [
	"self run:#testIncludesAssociationNoValue"
	"self debug:#testIncludesAssociationNoValue"
	
	| dict a1 a3 |
	a1 := Association key: #Italie.
	a3 := Association key: #France value: 'Paris'.
	
	self assert: (a1 key = #Italie).
	self assert: (a1 value isNil).
	
	dict := Dictionary new.
	dict add: a1.
	dict add: a3.
	self assert: (dict includesKey: #France).
	self assert: (dict includesKey: #Italie).
	self assert: (dict at: #Italie) isNil.
	self assert: (dict at: #France) = 'Paris'

	
	
	
]

{ #category : #'tests - basic' }
DictionaryTest >> testIncludesKey [
	"self run:#testIncludesKey"
	"self debug:#testIncludesKey"
	
	| dict a1 a2 a3 |
	a1 := Association key: 'Italie'.
	a2 := Association new.
	a3 := Association key: 'France' value: 'Paris'.
	
	dict := Dictionary new.
	dict add: a1 .
	dict add: a2.
	dict add: a3.
	self assert: (dict includesKey: #France).
	self assert: (dict includesKey: 'France').
	self assert: (dict includesKey: #Italie).
	self assert: (dict includesKey: nil).	
		
	self assert: (dict at: 'France' ) = 'Paris'.

]

{ #category : #'tests - integrity' }
DictionaryTest >> testIntegrityOfDictionaries [
	#(
		Dictionary
		IdentityDictionary
		SystemDictionary
		LiteralDictionary
		PluggableDictionary
		WeakValueDictionary) do: [ :dictionaryClassName |
			Smalltalk at: dictionaryClassName ifPresent: [ :dictionaryClass |
				dictionaryClass allInstancesDo: [ :dictionary |
					dictionary keysAndValuesDo: [ :key :value |
						self assert: (dictionary at: key) == value ].
					dictionary array doWithIndex: [ :association :index |
		                        association ifNotNil: [
	 	                               self assert: (dictionary scanFor: association key) = index ] ] ] ] ]
]

{ #category : #'tests - keys and value' }
DictionaryTest >> testKeyAtValue [
	"self run: #testKeyAtValue"
	"self debug: #testKeyAtValue"
	
	| dict |
	dict := Dictionary new.
	dict at: #a put: 1.
	dict at: #b put: 2.
	dict at: #c put: 1.
	
	self assert: (dict keyAtValue: 2) = #b.
	"which ever is answered depends on hashing, and hashing is improved in Spur."
	self assert: ((dict keyAtValue: 1) = #a or: [(dict keyAtValue: 1) = #c]).
	"ugly may be a bug, why not have a set #a and #c?  cuz that would be keys at value."
	
	self should: [dict keyAtValue: 0] raise: Error
	
	

]

{ #category : #'tests - keys and value' }
DictionaryTest >> testKeys [

	"self run:#testKeys "
	
	| a1 a2  dict | 
	a1 := Association key: 'France' value: 'Paris'.
	a2 := Association key: 'Italie' value: 'Rome'.
	dict := Dictionary new.
	dict add: a1.
	dict add: a2.
	 		
	self assert: (dict keys size) = 2.
	
	self assert: (dict keys includes: #France)
	
	


	
	
]

{ #category : #'tests - keys and value' }
DictionaryTest >> testKeysDo [
	"self run: #testKeysDo"
	"self debug: #testKeysDo"
	
	| dict res |
	dict := Dictionary new.
	
	dict at: #a put: 33.
	dict at: #b put: 66.
	
	res := OrderedCollection new.
	dict keysDo: [ :each | res add: each].
	
	self assert: res asSet = #(a b) asSet.


	
	
]

{ #category : #'tests - integrity' }
DictionaryTest >> testMethodDictionaries [
	MethodDictionary allInstancesDo: [ :dictionary |
		dictionary keysAndValuesDo: [ :key :value |
			self assert: (dictionary at: key) == value ].
		1 to: dictionary basicSize do: [ :index |
			(dictionary basicAt: index)
				ifNil: [ self assert: (dictionary array at: index) isNil ]
				ifNotNil: [ :key |
					self assert: (dictionary scanFor: key) = index ] ] ]
]

{ #category : #'tests - basic' }
DictionaryTest >> testNewFromIsolation [
	"self run:#testNewFromIsolation"
	"self debug:#testNewFromIsolation"
	
	| dict1 dict2 |
	dict1 := Dictionary new.
	dict1 at: #one put: 'foo'; at: #two put: 0@0.
	dict2 := Dictionary newFrom: dict1.
	dict2 at: #one put: 'bar'.

	self assert: (dict1 at: #one) = 'foo'.

]

{ #category : #tests }
DictionaryTest >> testNilHashCollision [
	"Ensures that fixCollisionsFrom: does the right thing in the presence of a nil key"
	| dict key |
	dict := Dictionary new.
	key := nil hash. "any key with same hash as nil"
	dict at: key hash put: 1.
	dict at: nil put: 2.
	self assert: (dict includesKey: nil).
	dict removeKey: key.
	self assert: (dict includesKey: nil).

]

{ #category : #'tests - basic' }
DictionaryTest >> testOccurrencesOf [
	"self run:#testOccurrencesOf"
	
	| dict |
	dict := Dictionary new.
	dict at: #a put: 1.
	dict at: #b put: 2.
	dict at: #c put: 1.
	dict at: #d put: 3.
	dict at: nil put: nil.
	dict at: #z put: nil.
	
	
	self assert: (dict occurrencesOf: 1 ) = 2.
	self assert: (dict occurrencesOf: nil ) = 2.
	
	
	
	
]

{ #category : #'tests - implementation' }
DictionaryTest >> testPseudoVariablesAreValidKeys [
	"(self run: #testPseudoVariablesAreValidKeys)"
	"true and false are valid keys"
	
	| dict1  |
	dict1 := Dictionary new.
	dict1 at: true put: #true.
	self assert: (dict1 at: true) = #true.
		
	dict1 at: false put: #false.
	self assert: (dict1 at: false) = #false.
]

{ #category : #'tests - collection protocol' }
DictionaryTest >> testReject [
	"Ensure that Dictionary>>reject: answers a dictionary not something else"
	| dict expected result |
	dict := Dictionary newFromPairs:{
		#first.		1.
		#second.	2.
		#third.		3.
		#fourth.	4.
		#fifth.		5.
	}.
	result := dict reject:[:each| each odd].
	expected := Dictionary newFromPairs:{
		#second.	2.
		#fourth.	4.
	}.
	self assert: result = expected.
]

{ #category : #tests }
DictionaryTest >> testRemoveAll [
	"Allows one to remove all elements of a collection" 
	
	| dict1 dict2 s2 |
	dict1 := Dictionary new.
	dict1 at: #a put:1 ; at: #b put: 2. 
	dict2 := dict1 copy.
	s2 := dict2 size.
	
	dict1 removeAll.
	
	self assert: dict1 size = 0.
	self assert: dict2 size = s2 description: 'the copy has not been modified'.
]

{ #category : #'tests - keys and value' }
DictionaryTest >> testRemoveKey [
		"self run:#testRemoveKey "

	| dict | 
	dict := Dictionary new.
	dict at: #a put: 1.
	dict at: #b put: 2.
	 
	self assert: (dict keys size) = 2.
	dict removeKey: #a.
	self assert: dict keys size  = 1.

	self should: [dict at: #a] raise: Error.
	self assert: (dict at: #b) = 2


	
	
]

{ #category : #'tests - collection protocol' }
DictionaryTest >> testSelect [
	"Ensure that Dictionary>>select: answers a dictionary not something else"
	| dict expected result |
	dict := Dictionary newFromPairs:{
		#first.		1.
		#second.	2.
		#third.		3.
		#fourth.	4.
		#fifth.		5.
	}.
	result := dict select:[:each| each odd].
	expected := Dictionary newFromPairs:{
		#first.		1.
		#third.		3.
		#fifth.		5.
	}.
	self assert: result = expected.
	result at: #first put: 0.
	self assert: (dict at: #first) = 1 "No side effects"
]

{ #category : #'tests - keys and value' }
DictionaryTest >> testValues [
	"self run:#testValues "
	
	| a1 a2 a3 dict | 
	a1 := Association key: 'France' value: 'Paris'.
	a2 := Association key: 'Italie' value: 'Rome'.
	dict := Dictionary new.
	dict add: a1.
	dict add: a2.
	 
	self assert: (dict values size ) = 2.
	self assert: (dict values includes: 'Paris').
	
	a3 := Association new.
	dict add: a3.
	self assert: (dict values size ) = 3.
	self assert: (dict values includes: nil).
	
	
	
	
	
	


	
	
]

{ #category : #tests }
DictionaryTest >> testWithAll [
	
	| dict1 dict2 |
	dict1 := Dictionary withAll: {#a -> 1. #b -> 2}.
	self assert: (dict1 at: #a) = 1.
	self assert: (dict1 at: #b) = 2.

	dict2 := Dictionary withAll: dict1.
	self assert: (dict2 at: #a) = 1.
	self assert: (dict2 at: #b) = 2.

]
