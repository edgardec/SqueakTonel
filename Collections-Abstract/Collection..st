"
I am the abstract superclass of all classes that represent a group of elements.
"
Class {
	#name : #Collection,
	#superclass : #Object,
	#category : #'Collections-Abstract'
}

{ #category : #'class initialization' }
Collection class >> initialize [
	"Set up a Random number generator to be used by atRandom when the 
	user does not feel like creating his own Random generator."

	Smalltalk addToStartUpList: self
]

{ #category : #testing }
Collection class >> isAbstract [
	^self = Collection
]

{ #category : #'instance creation' }
Collection class >> ofSize: n [
	"Create a new collection of size n with nil as its elements.
	This method exists because OrderedCollection new: n creates an
	empty collection,  not one of size n."
	^ self new: n
]

{ #category : #'instance creation' }
Collection class >> with: anObject [ 
	"Answer an instance of me containing anObject."

	^ self new
		add: anObject;
		yourself
]

{ #category : #'instance creation' }
Collection class >> with: firstObject with: secondObject [ 
	"Answer an instance of me containing the two arguments as elements."

	^ self new
		add: firstObject;
		add: secondObject;
		yourself
]

{ #category : #'instance creation' }
Collection class >> with: firstObject with: secondObject with: thirdObject [ 
	"Answer an instance of me containing the three arguments as elements."

	^ self new
		add: firstObject;
		add: secondObject;
		add: thirdObject;
		yourself
]

{ #category : #'instance creation' }
Collection class >> with: firstObject with: secondObject with: thirdObject with: fourthObject [ 
	"Answer an instance of me, containing the four arguments as the elements."

	^ self new
		add: firstObject;
		add: secondObject;
		add: thirdObject;
		add: fourthObject;
		yourself
]

{ #category : #'instance creation' }
Collection class >> with: firstObject with: secondObject with: thirdObject with: fourthObject with: fifthObject [
	"Answer an instance of me, containing the five arguments as the elements."

	^ self new
		add: firstObject;
		add: secondObject;
		add: thirdObject;
		add: fourthObject;
		add: fifthObject;
		yourself
]

{ #category : #'instance creation' }
Collection class >> with: firstObject with: secondObject with: thirdObject with: fourthObject with: fifthObject with: sixthObject [
	"Answer an instance of me, containing the six arguments as the elements."

	^ self new
		add: firstObject;
		add: secondObject;
		add: thirdObject;
		add: fourthObject;
		add: fifthObject;
		add: sixthObject;
		yourself
]

{ #category : #'instance creation' }
Collection class >> withAll: aCollection [
	"Create a new collection containing all the elements from aCollection."

	^ (self new: aCollection size)
		addAll: aCollection;
		yourself
]

{ #category : #arithmetic }
Collection >> * arg [

	^ arg adaptToCollection: self andSend: #*
]

{ #category : #arithmetic }
Collection >> + arg [

	^ arg adaptToCollection: self andSend: #+
]

{ #category : #copying }
Collection >> , aCollection [

	^ self copy addAll: aCollection asCollection; yourself
]

{ #category : #arithmetic }
Collection >> - arg [

	^ arg adaptToCollection: self andSend: #-
]

{ #category : #arithmetic }
Collection >> / arg [

	^ arg adaptToCollection: self andSend: #/
]

{ #category : #arithmetic }
Collection >> // arg [

	^ arg adaptToCollection: self andSend: #//
]

{ #category : #arithmetic }
Collection >> \\ arg [

	^ arg adaptToCollection: self andSend: #\\
]

{ #category : #'math functions' }
Collection >> abs [
	"Absolute value of all elements in the collection"
	^ self collect: [:a | a abs]
]

{ #category : #adapting }
Collection >> adaptToCollection: rcvr andSend: selector [
	"If I am involved in arithmetic with another Collection, return a Collection of
	the results of each element combined with the scalar in that expression."

	rcvr isSequenceable & self isSequenceable ifFalse:
		[self error: 'Only sequenceable collections may be combined arithmetically'].
	^ rcvr with: self collect:
		[:rcvrElement :myElement | rcvrElement perform: selector with: myElement]
]

{ #category : #adapting }
Collection >> adaptToComplex: rcvr andSend: selector [
	"If I am involved in arithmetic with a scalar, return a Collection of
	the results of each element combined with the scalar in that expression."

	^ self collect: [:element | rcvr perform: selector with: element]
]

{ #category : #adapting }
Collection >> adaptToNumber: rcvr andSend: selector [
	"If I am involved in arithmetic with a scalar, return a Collection of
	the results of each element combined with the scalar in that expression."

	^ self collect: [:element | rcvr perform: selector with: element]
]

{ #category : #adapting }
Collection >> adaptToPoint: rcvr andSend: selector [
	"If I am involved in arithmetic with a scalar, return a Collection of
	the results of each element combined with the scalar in that expression."

	^ self collect: [:element | rcvr perform: selector with: element]
]

{ #category : #adapting }
Collection >> adaptToString: rcvr andSend: selector [
	"If I am involved in arithmetic with a String, convert it to a Number."
	^ rcvr asNumber perform: selector with: self
]

{ #category : #adding }
Collection >> add: newObject [ 
	"Include newObject as one of the receiver's elements. Answer newObject. 
	ArrayedCollections cannot respond to this message."

	self subclassResponsibility
]

{ #category : #adding }
Collection >> add: newObject withOccurrences: anInteger [
	"Add newObject anInteger times to the receiver. Do nothing if anInteger is less than one. Answer newObject."

	anInteger timesRepeat: [self add: newObject].
	^ newObject
]

{ #category : #adding }
Collection >> addAll: aCollection [ 
	"Include all the elements of aCollection as the receiver's elements. Answer 
	aCollection. Actually, any object responding to #do: can be used as argument."

	aCollection do: [:each | self add: each].
	^ aCollection
]

{ #category : #adding }
Collection >> addAllFirstTo: anOrderedCollection [
	"Add all of my elements to the beginning of anOrderedCollection"

	self do: [ :each | anOrderedCollection addFirst: each ]
]

{ #category : #adding }
Collection >> addIfNotPresent: anObject [
	"Include anObject as one of the receiver's elements, but only if there
	is no such element already. Anwser anObject."

	(self includes: anObject) ifFalse: [self add: anObject].
	^ anObject
]

{ #category : #enumerating }
Collection >> allSatisfy: aBlock [
	"Evaluate aBlock with the elements of the receiver.
	If aBlock returns false for any element return false.
	Otherwise return true."

	self do: [:each | (aBlock value: each) ifFalse: [^ false]].
	^ true
]

{ #category : #accessing }
Collection >> any: numberOfElements [

	^ self any: numberOfElements as: self species
]

{ #category : #accessing }
Collection >> any: numberOfElements as: aClass [
	"Enumerate this collection and return the specified number of elements. Signals an error if this collection has not enough elements."
	
	| index result |
	index := 0.
	result := aClass new: numberOfElements.
	
	result fillFrom: self with: [:each |
		(index := index + 1) > numberOfElements
			ifTrue: [^ result]
			ifFalse: [each]].

	index = numberOfElements
		ifFalse: [self error: 'Not enough elements in this collection.'].
	
	^ result
]

{ #category : #accessing }
Collection >> anyOne [
	"Answer a representative sample of the receiver. This method can
	be helpful when needing to preinfer the nature of the contents of 
	semi-homogeneous collections."

	self do: [:each | ^ each].
	self errorEmptyCollection
]

{ #category : #enumerating }
Collection >> anySatisfy: aBlock [
	"Evaluate aBlock with the elements of the receiver.
	If aBlock returns true for any element return true.
	Otherwise return false."

	self do: [:each | (aBlock value: each) ifTrue: [^ true]].
	^ false
]

{ #category : #'math functions' }
Collection >> arcCos [
	^self collect: [:each | each arcCos]
]

{ #category : #'math functions' }
Collection >> arcSin [
	^self collect: [:each | each arcSin]
]

{ #category : #'math functions' }
Collection >> arcTan [
	^self collect: [:each | each arcTan]
]

{ #category : #converting }
Collection >> asArray [
	"Answer an Array whose elements are the elements of the receiver.
	Implementation note: Cannot use ''Array withAll: self'' as that only
	works for SequenceableCollections which support the replacement 
	primitive."

	| array index |
	array := Array new: self size.
	index := 0.
	self do: [:each | array at: (index := index + 1) put: each].
	^ array
]

{ #category : #converting }
Collection >> asBag [
	"Answer a Bag whose elements are the elements of the receiver."

	^ Bag withAll: self
]

{ #category : #converting }
Collection >> asByteArray [
	"Answer a ByteArray whose elements are the elements of the receiver.
	Implementation note: Cannot use ''ByteArray withAll: self'' as that only
	works for SequenceableCollections which support the replacement 
	primitive."

	| array index |
	array := ByteArray new: self size.
	index := 0.
	self do: [:each | array at: (index := index + 1) put: each].
	^ array
]

{ #category : #converting }
Collection >> asCharacterSet [
	"Answer a CharacterSet whose elements are the unique elements of the receiver.
	The reciever should only contain characters."

	^ CharacterSet newFrom: self
]

{ #category : #converting }
Collection >> asCollection [

	^ self
]

{ #category : #'printing - obsolete' }
Collection >> asCommaString [
	"Return collection printed as 'a, b, c' "

	self flag: #deprecate.
	^ self asArray joinSeparatedBy: ', '
		
]

{ #category : #'printing - obsolete' }
Collection >> asCommaStringAnd [
	"Return collection printed as 'a, b and c' "

	self flag: #deprecate.
	^String streamContents: [:s | self asStringOn: s delimiter: ', ' last: ' and ']
		
]

{ #category : #converting }
Collection >> asIdentitySet [
	^(IdentitySet new: self size) addAll: self; yourself
]

{ #category : #converting }
Collection >> asOrderedCollection [
	"Answer an OrderedCollection whose elements are the elements of the
	receiver. The order in which elements are added depends on the order
	in which the receiver enumerates its elements. In the case of unordered
	collections, the ordering is not necessarily the same for multiple 
	requests for the conversion."

	^ self as: OrderedCollection
]

{ #category : #converting }
Collection >> asSet [
	"Answer a Set whose elements are the unique elements of the receiver."

	^ Set withAll: self
]

{ #category : #converting }
Collection >> asSortedArray [
	"Return a copy of the receiver in sorted order, as an Array.  6/10/96 sw"

	^ self asSortedCollection asArray
]

{ #category : #converting }
Collection >> asSortedCollection [
	"Answer a SortedCollection whose elements are the elements of the 
	receiver. The sort order is the default less than or equal. 
	Use #sorted: if you don't really need a SortedCollection, but a sorted collection!"
	
	^self as: SortedCollection
]

{ #category : #converting }
Collection >> asSortedCollection: aSortBlock [ 
	"Answer a SortedCollection whose elements are the elements of the 
	receiver. The sort order is defined by the argument, aSortBlock.
	Use #sorted: if you don't really need a SortedCollection, but a sorted collection!"

	| aSortedCollection |
	aSortedCollection := SortedCollection new: self size.
	aSortedCollection sortBlock: aSortBlock.
	aSortedCollection addAll: self.
	^ aSortedCollection
]

{ #category : #'printing - obsolete' }
Collection >> asStringOn: aStream delimiter: delimString [

	self flag: #deprecate.
	^ self asArray joinOn: aStream separatedBy: delimString
]

{ #category : #'printing - obsolete' }
Collection >> asStringOn: aStream delimiter: delimString last: lastDelimString [
	"Print elements on a stream separated
	with a delimiter between all the elements and with
	a special one before the last like: 'a, b and c'.
	Uses #asString instead of #print:

	Note: Feel free to improve the code to detect the last element."

	| n sz |
	self flag: #deprecate.
	
	n := 1.
	sz := self size.
	self do: [:elem |
		n := n + 1.
		aStream nextPutAll: elem asString]
	separatedBy: [
		aStream nextPutAll: (n = sz ifTrue: [lastDelimString] ifFalse: [delimString])]
]

{ #category : #enumerating }
Collection >> associationsDo: aBlock [
	"Evaluate aBlock for each of the receiver's elements (key/value 
	associations).  If any non-association is within, the error is not caught now,
	but later, when a key or value message is sent to it."

	self do: aBlock
]

{ #category : #accessing }
Collection >> atRandom [
	"Answer a random element of the receiver.  Uses the process-local random number generator. Causes an error if self has no elements."

	^self atRandom: ThreadSafeRandom value

"Examples:
	#('one' 'or' 'the' 'other') atRandom
	(1 to: 10) atRandom
	'Just pick one of these letters at random' atRandom
	#(3 7 4 9 21) asSet atRandom		(just to show it also works for Sets)
"
]

{ #category : #accessing }
Collection >> atRandom: aGenerator [
	"Answer a random element of the receiver. Uses aGenerator which
	should be kept by the user in a variable and used every time. Use
	this instead of #atRandom for better uniformity of random numbers because 
	only you use the generator. Causes an error if self has no elements."

	| randomIndex index |
	self emptyCheck.
	randomIndex := aGenerator nextInt: self size.
	index := 1.
	self do: [ :each |
		index = randomIndex ifTrue: [ ^each ].
		index := index + 1 ]
]

{ #category : #'math functions' }
Collection >> average [
	^ self sum / self size
]

{ #category : #accessing }
Collection >> capacity [
	"Answer the current capacity of the receiver."

	^ self size
]

{ #category : #'math functions' }
Collection >> ceiling [
	^ self collect: [:a | a ceiling]
]

{ #category : #enumerating }
Collection >> collect: aBlock [ 
	"Evaluate aBlock with each of the receiver's elements as the argument.  
	Collect the resulting values into a collection like the receiver. Answer  
	the new collection."

	| newCollection |
	newCollection := self species new.
	self do: [:each | newCollection add: (aBlock value: each)].
	^ newCollection
]

{ #category : #enumerating }
Collection >> collect: aBlock as: aClass [
	"Evaluate aBlock with each of the receiver's elements as the argument.  
	Collect the resulting values into an instance of aClass. Answer the resulting collection."

	^(aClass new: self size) fillFrom: self with: aBlock
]

{ #category : #enumerating }
Collection >> collect: aBlock into: aCollection [
	"Evaluate aBlock with each of the receiver's elements as the argument.  
	Collect the resulting values into aCollection. Answer aCollection."

	^aCollection fillFrom: self with: aBlock
]

{ #category : #enumerating }
Collection >> collect: collectBlock thenDo: doBlock [ 
	"Utility method to improve readability."
	^ (self collect: collectBlock) do: doBlock
]

{ #category : #enumerating }
Collection >> collect: collectBlock thenSelect: selectBlock [
	"Utility method to improve readability."

	^ (self collect: collectBlock) select: selectBlock
]

{ #category : #testing }
Collection >> contains: aBlock [
	"VW compatibility"
	^self anySatisfy: aBlock
]

{ #category : #'filter streaming' }
Collection >> contents [
	^ self
]

{ #category : #copying }
Collection >> copyWith: newElement [
	"Answer a new collection with newElement added (as last
	element if sequenceable)."

	^ self copy
		add: newElement;
		yourself
]

{ #category : #copying }
Collection >> copyWithDependent: newElement [
	"Answer a new collection with newElement added (as last
	element if sequenceable)."
	^self copyWith: newElement
]

{ #category : #copying }
Collection >> copyWithout: oldElement [ 
	"Answer a copy of the receiver that does not contain any
	elements equal to oldElement."

	^ self reject: [:each | each = oldElement]

"Examples:
	'fred the bear' copyWithout: $e
	#(2 3 4 5 5 6) copyWithout: 5
"
]

{ #category : #copying }
Collection >> copyWithoutAll: aCollection [
	"Answer a copy of the receiver that does not contain any elements 
	equal to those in aCollection."

	^ self reject: [:each | aCollection includes: each]
]

{ #category : #'math functions' }
Collection >> cos [
	^self collect: [:each | each cos]
]

{ #category : #enumerating }
Collection >> count: aBlock [ 
	"Evaluate aBlock with each of the receiver's elements as the argument.  
	Answer the number of elements that answered true."

	| sum |
	sum := 0.
	self do: [:each | (aBlock value: each) ifTrue: [sum := sum + 1]].
	^ sum
]

{ #category : #'math functions' }
Collection >> degreeCos [
	^self collect: [:each | each degreeCos]
]

{ #category : #'math functions' }
Collection >> degreeSin [
	^self collect: [:each | each degreeSin]
]

{ #category : #enumerating }
Collection >> detect: aBlock [ 
	"Evaluate aBlock with each of the receiver's elements as the argument. 
	Answer the first element for which aBlock evaluates to true. If there is
	no such element, raise an error."

	^ self
		detect: aBlock
		ifFound: [:element | element]
		ifNone: [self errorNotFound: aBlock]
]

{ #category : #enumerating }
Collection >> detect: aBlock ifFound: foundBlock [
	"Evaluate aBlock with each of the receiver's elements as the argument.  
	Answer the first element for which aBlock evaluates to true. If there is
	no such element, return nil."
	
	^ self 
		detect: aBlock
		ifFound: foundBlock
		ifNone: nil
]

{ #category : #enumerating }
Collection >> detect: aBlock ifFound: foundBlock ifNone: exceptionBlock [ 
	"Evaluate aBlock with each of the receiver's elements as the argument.
	If there is any element for which aBlock evaluates to true, then evaluate
	foundBlock with that element and answer the result of that foundBlock.
	If aBlock does never evaluate to true, evaluate exceptionBlock, which
	may or may not raise an error."
	
	self do: [:each | (aBlock value: each) ifTrue: [^ foundBlock value: each]].
	^ exceptionBlock value

]

{ #category : #enumerating }
Collection >> detect: aBlock ifNone: exceptionBlock [ 
	"Evaluate aBlock with each of the receiver's elements as the argument.  
	Answer the first element for which aBlock evaluates to true. If there is
	no such element, evaluate exceptionBlock."

	^ self
		detect: aBlock
		ifFound: [:element | element]
		ifNone: exceptionBlock
]

{ #category : #enumerating }
Collection >> detectMax: aBlock [
	"Evaluate aBlock with each of the receiver's elements as the argument. 
	Answer the element for which aBlock evaluates to the highest magnitude.
	If collection empty, return nil.  This method might also be called elect:."

	| maxElement maxValue |
	self do: [:each | | val | 
		maxValue
			ifNotNil: [ 
				(val := aBlock value: each) > maxValue
					ifTrue: [ 
						maxElement := each.
						maxValue := val ] ]
			ifNil: [ 
				"first element"
				maxElement := each.
				maxValue := aBlock value: each ].
				"Note that there is no way to get the first element that works 
				for all kinds of Collections.  Must test every one."].
	^ maxElement
]

{ #category : #enumerating }
Collection >> detectMin: aBlock [
	"Evaluate aBlock with each of the receiver's elements as the argument. 
	Answer the element for which aBlock evaluates to the lowest number.
	If collection empty, return nil."

	| minElement minValue |
	self do: [:each | | val | 
		minValue
			ifNotNil: [ 
				(val := aBlock value: each) < minValue
					ifTrue: [ 
						minElement := each.
						minValue := val ] ]
			ifNil: [ 
				"first element"
				minElement := each.
				minValue := aBlock value: each ].
				"Note that there is no way to get the first element that works 
				for all kinds of Collections.  Must test every one."].
	^ minElement
]

{ #category : #enumerating }
Collection >> detectSum: aBlock [
	"Evaluate aBlock with each of the receiver's elements as the argument. 
	Return the sum of the answers."
	| sum |
	sum := 0.
	self do: [:each | 
		sum := (aBlock value: each) + sum].  
	^ sum
]

{ #category : #enumerating }
Collection >> difference: aCollection [
	"Answer the set theoretic difference of two collections."

	^ self reject: [:each | aCollection includes: each]
]

{ #category : #enumerating }
Collection >> do: aBlock [ 
	"Evaluate aBlock with each of the receiver's elements as the argument."

	self subclassResponsibility
]

{ #category : #enumerating }
Collection >> do: aBlock displayingProgress: aStringOrBlock [
	"Enumerate aBlock displaying progress information. 
	If the argument is a string, use a static label for the process. 
	If the argument is a block, evaluate it with the element to retrieve the label.
		Smalltalk allClasses 
			do:[:aClass| (Delay forMilliseconds: 1) wait]
			displayingProgress: 'Processing...'.
		Smalltalk allClasses 
			do:[:aClass| (Delay forMilliseconds: 1) wait]
			displayingProgress:[:aClass| 'Processing ', aClass name].
	"
	^self do: aBlock displayingProgress: aStringOrBlock every: 20
]

{ #category : #enumerating }
Collection >> do: aBlock displayingProgress: aStringOrBlock every: msecs [
	"Enumerate aBlock displaying progress information. 
	If the argument is a string, use a static label for the process. 
	If the argument is a block, evaluate it with the element to retrieve the label.
	The msecs argument ensures that updates happen at most every msecs.
	Example:
		Smalltalk allClasses 
			do:[:aClass| (Delay forMilliseconds: 1) wait]
			displayingProgress:[:aClass| 'Processing ', aClass name]
			every: 0.
		Smalltalk allClasses 
			do:[:aClass| (Delay forMilliseconds: 1) wait]
			displayingProgress:[:aClass| 'Processing ', aClass name]
			every: 100.
	"
	| size labelBlock count oldLabel lastUpdate |
	labelBlock := aStringOrBlock isString 
		ifTrue:[[:item| aStringOrBlock]] 
		ifFalse:[aStringOrBlock].
	oldLabel := nil.
	count := lastUpdate := 0.
	size := self size.
	'' displayProgressFrom: 0 to: size during:[:bar |
		self do:[:each| | newLabel |
			"Special handling for first and last element"
			(count = 0 or:[count+1 = size 
				or:[(Time millisecondsSince: lastUpdate) >= msecs]]) ifTrue:[
					bar value: count.
					oldLabel = (newLabel := (labelBlock value: each) ifNil:[oldLabel]) ifFalse:[
					ProgressNotification signal: '' extra: (oldLabel := newLabel).
				].
				lastUpdate := Time millisecondClockValue.
			].
			aBlock value: each.
			count := count + 1.
	]]
]

{ #category : #enumerating }
Collection >> do: elementBlock separatedBy: separatorBlock [
	"Evaluate the elementBlock for all elements in the receiver,
	and evaluate the separatorBlock between."

	| beforeFirst | 
	beforeFirst := true.
	self do:
		[:each |
		beforeFirst
			ifTrue: [beforeFirst := false]
			ifFalse: [separatorBlock value].
		elementBlock value: each]
]

{ #category : #enumerating }
Collection >> do: aBlock without: anItem [ 
	"Enumerate all elements in the receiver. 
	Execute aBlock for those elements that are not equal to the given item"

	^ self do: [:each | anItem = each ifFalse: [aBlock value: each]]
]

{ #category : #private }
Collection >> emptyCheck [

	self isEmpty ifTrue: [self errorEmptyCollection]
]

{ #category : #private }
Collection >> errorDifferentSize [
	
	self error: 'otherCollection must be the same size'
]

{ #category : #private }
Collection >> errorEmptyCollection [

	self error: 'this collection is empty'
]

{ #category : #private }
Collection >> errorKeyNotFound: key [
	"Signal KeyNotFound error"
	^(KeyNotFound key: key) signal
]

{ #category : #private }
Collection >> errorNoMatch [

	self error: 'collection sizes do not match'
]

{ #category : #private }
Collection >> errorNotFound: anObject [
	"anObject was not found in this collection, raise appropriate error."

	^(NotFound object: anObject) signal
]

{ #category : #private }
Collection >> errorNotKeyed [

	self error: ('Instances of {1} do not respond to keyed accessing messages.' translated format: {self class name})

]

{ #category : #'math functions' }
Collection >> exp [
	^self collect: [:each | each exp]
]

{ #category : #private }
Collection >> fillFrom: aCollection with: aBlock [
	"Evaluate aBlock with each of aCollections's elements as the argument.  
	Collect the resulting values into self. Answer self."

	aCollection do: [ :each |
		self add: (aBlock value: each) ]
]

{ #category : #enumerating }
Collection >> findFirstInByteString: aByteString startingAt: start [
	"Find the index of first character starting at start in aByteString that is included in the receiver.
	Default is to use a naive algorithm.
	Subclasses might want to implement a more efficient scheme"

	start to: aByteString size do:
		[:index |
		(self includes: (aByteString at: index)) ifTrue: [^ index]].
	^ 0
]

{ #category : #'filter streaming' }
Collection >> flattenOnStream: aStream [ 
	^ aStream writeCollection: self
]

{ #category : #'math functions' }
Collection >> floor [
	^ self collect: [:a | a floor]
]

{ #category : #enumerating }
Collection >> fold: binaryBlock [
	"Evaluate the block with the first two elements of the receiver,
	 then with the result of the first evaluation and the next element,
	 and so on.  Answer the result of the final evaluation. If the receiver
	 is empty, raise an error. If the receiver has a single element, answer
	 that element."
	"#('if' 'it' 'is' 'to' 'be' 'it' 'is' 'up' 'to' 'me') fold: [:a :b | a, ' ', b]"

	^self reduce: binaryBlock
]

{ #category : #enumerating }
Collection >> gather: aBlock [
	^ Array streamContents:
		[:stream |
		self do: [:ea | stream nextPutAll: (aBlock value: ea)]]
]

{ #category : #enumerating }
Collection >> groupBy: keyBlock [
	"Like in SQL operation - Split the recievers contents into collections of elements for which keyBlock returns the same results, and return them."

	| result |
	result := Dictionary new.
	self do: [ :each | 
		| key |
		key := keyBlock value: each.
		(result at: key ifAbsentPut: [ OrderedCollection new ]) 
			add: each ].
	^result
]

{ #category : #enumerating }
Collection >> groupBy: keyBlock having: selectBlock [ 
	"Like in SQL operation - Split the recievers contents into collections of elements for which keyBlock returns the same results, and return those collections allowed by selectBlock."

	^(self groupBy: keyBlock) select: selectBlock
]

{ #category : #comparing }
Collection >> hash [
	"Answer an integer hash value for the receiver such that,
	  -- the hash value of an unchanged object is constant over time, and
	  -- two equal objects have equal hash values"

	| hash |

	hash := self species hash.
	self size <= 10 ifTrue:
		[self do: [:elem | hash := hash bitXor: elem hash]].
	^hash bitXor: self size hash
]

{ #category : #converting }
Collection >> histogramOf: aBlock [

	^ self collect: aBlock as: Bag
]

{ #category : #testing }
Collection >> identityIncludes: anObject [ 
	"Answer whether anObject is one of the receiver's elements."

	self do: [:each | anObject == each ifTrue: [^true]].
	^false
]

{ #category : #testing }
Collection >> ifEmpty: aBlock [
	"Evaluate aBlock if I'm empty, return myself otherwise."

	self isEmpty ifTrue: [^ aBlock value].
]

{ #category : #testing }
Collection >> ifEmpty: emptyBlock ifNotEmpty: notEmptyBlock [
	"Evaluate emptyBlock if I'm empty, notEmptyBlock otherwise. If the notEmptyBlock has an argument, evalualte it with myself as its argument. See also #ifEmpty:ifNotEmptyDo:."

	self isEmpty ifTrue: [^ emptyBlock value].
	^ notEmptyBlock cull: self
]

{ #category : #testing }
Collection >> ifEmpty: emptyBlock ifNotEmptyDo: notEmptyBlock [
	"Evaluate emptyBlock if I'm empty, notEmptyBlock otherwise"
	"Evaluate the notEmptyBlock with the receiver as its argument"

	self isEmpty ifTrue: [ ^emptyBlock value ].
	^notEmptyBlock value: self
]

{ #category : #testing }
Collection >> ifNotEmpty: aBlock [
	"Evaluate aBlock if I'm not empty, return myself otherwise. If aBlock has an argument, evaluate it with myself as its argument. See also #ifNotEmptyDo:."

	self isEmpty ifFalse: [^ aBlock cull: self].
]

{ #category : #testing }
Collection >> ifNotEmpty: notEmptyBlock ifEmpty: emptyBlock [
	"Evaluate emptyBlock if I'm empty, notEmptyBlock otherwise. If the notEmptyBlock has an argument, evaluate it with myself as its argument. See also #ifNotEmptyDo:ifEmpty:."

	self isEmpty ifFalse: [^notEmptyBlock cull: self].
	^ emptyBlock value
]

{ #category : #testing }
Collection >> ifNotEmptyDo: aBlock [
	"Evaluate the given block with the receiver as its argument."

	self isEmpty ifFalse: [^ aBlock value: self].

]

{ #category : #testing }
Collection >> ifNotEmptyDo: notEmptyBlock ifEmpty: emptyBlock [
	"Evaluate emptyBlock if I'm empty, notEmptyBlock otherwise
	Evaluate the notEmptyBlock with the receiver as its argument"

	self isEmpty ifFalse: [ ^notEmptyBlock value: self ].
	^emptyBlock value
]

{ #category : #testing }
Collection >> includes: anObject [ 
	"Answer whether anObject is one of the receiver's elements."

	^ self anySatisfy: [:each | each = anObject]
]

{ #category : #testing }
Collection >> includesAllOf: aCollection [ 
	"Answer whether all the elements of aCollection are in the receiver."
	aCollection do: [:elem | (self includes: elem) ifFalse: [^ false]].
	^ true
]

{ #category : #testing }
Collection >> includesAnyOf: aCollection [ 
	"Answer whether any element of aCollection is one of the receiver's elements."
	aCollection do: [:elem | (self includes: elem) ifTrue: [^ true]].
	^ false
]

{ #category : #testing }
Collection >> includesSubstringAnywhere: testString [
	"Answer whether the receiver includes, anywhere in its nested structure, a string that has testString as a substring"
	self do:
		[:element |
			(element isString)
				ifTrue:
					[(element includesSubstring: testString) ifTrue: [^ true]].
			(element isCollection)
				ifTrue:
					[(element includesSubstringAnywhere: testString) ifTrue: [^ true]]].
	^ false

"#(first (second third) ((allSentMessages ('Elvis' includes:)))) includesSubstringAnywhere:  'lvi'"
]

{ #category : #enumerating }
Collection >> inject: thisValue into: binaryBlock [ 
	"Accumulate a running value associated with evaluating the argument, 
	binaryBlock, with the current value of the argument, thisValue, and the 
	receiver as block arguments. For instance, to sum the numeric elements 
	of a collection, aCollection inject: 0 into: [:subTotal :next | subTotal + 
	next]."

	| nextValue |
	nextValue := thisValue.
	self do: [:each | nextValue := binaryBlock value: nextValue value: each].
	^nextValue
]

{ #category : #enumerating }
Collection >> intersection: aCollection [
	"Answer the set theoretic intersection of two collections."

	^ self select: [:each | aCollection includes: each]
]

{ #category : #testing }
Collection >> isCollection [
	"Return true if the receiver is some sort of Collection and responds to basic collection messages such as #size and #do:"
	^true
]

{ #category : #testing }
Collection >> isEmpty [
	"Answer whether the receiver contains any elements.
	 This implementation uses the do: block rather than
	 self size = 0 since size may be implemented in terms
	 of do:, and hence is slow for all but very small collections."

	self do: [:element | ^false].
	^true
]

{ #category : #testing }
Collection >> isEmptyOrNil [
	"Answer whether the receiver contains any elements, or is nil.  Useful in numerous situations where one wishes the same reaction to an empty collection or to nil"

	^ self isEmpty
]

{ #category : #private }
Collection >> isOfSameSizeCheck: otherCollection [

	otherCollection size = self size ifFalse: [self errorDifferentSize]
]

{ #category : #testing }
Collection >> isSequenceable [
	^ false
]

{ #category : #testing }
Collection >> isZero [
	"Answer whether the receiver is zero"
	^ false
]

{ #category : #'math functions' }
Collection >> ln [
	^self collect: [:each | each ln]
]

{ #category : #'math functions' }
Collection >> log [
	^ self collect: [:each | each log]
]

{ #category : #'math functions' }
Collection >> log2 [
	^ self collect: [:each | each log2]
]

{ #category : #'math functions' }
Collection >> max [
	"Answer the maximum value in the collection.  The collection must be non-empty and contain 'compatible' Magnitudes (eg: don't try this with a collection containing both Dates and Characters)."
	^ self inject: self anyOne into: [:max :each | max max: each]
]

{ #category : #'math functions' }
Collection >> min [
	"Answer the minimum value in the collection.  The collection must be non-empty and contain 'compatible' Magnitudes (eg: don't try this with a collection containing both Dates and Characters)."
	^ self inject: self anyOne into: [:min :each | min min: each]
]

{ #category : #'math functions' }
Collection >> minMax [
	"Scans for minimum and maximum in one pass returning the results as a two-element array"
	| min max |
	min := max := self anyOne.
	self do: [ :each |
		min := min min: each.
		max := max max: each ].
	^ Array with: min with: max
]

{ #category : #'math functions' }
Collection >> negated [
	"Negated value of all elements in the collection"
	^ self collect: [:a | a negated]
]

{ #category : #enumerating }
Collection >> noneSatisfy: aBlock [
	"Evaluate aBlock with the elements of the receiver.
	If aBlock returns false for all elements return true.
	Otherwise return false"

	self do: [:item | (aBlock value: item) ifTrue: [^ false]].
	^ true
]

{ #category : #testing }
Collection >> notEmpty [
	"Answer whether the receiver contains any elements."

	^ self isEmpty not
]

{ #category : #enumerating }
Collection >> occurrencesOf: anObject [ 
	"Answer how many of the receiver's elements are equal to anObject."

	| tally |
	tally := 0.
	self do: [:each | anObject = each ifTrue: [tally := tally + 1]].
	^tally
]

{ #category : #printing }
Collection >> printElementsOn: aStream [

	aStream nextPut: $(.
	
	self
		printElementsOn: aStream
		separatedBy: String space.
		
	aStream nextPut: $).
]

{ #category : #printing }
Collection >> printElementsOn: aStream separatedBy: delimiter [
	"Do not use #print: on the delemiter to have more control over the output. Strings get quoted, Characters get prefixed, etc."

	self
		do: [:element | aStream print: element]
		separatedBy: [aStream nextPutAll: delimiter asString].
]

{ #category : #printing }
Collection >> printNameOn: aStream [
	super printOn: aStream
]

{ #category : #printing }
Collection >> printOn: aStream [ 
	"Append a sequence of characters that identify the receiver to aStream."

	self printNameOn: aStream.
	self printElementsOn: aStream
]

{ #category : #'printing - obsolete' }
Collection >> printOn: aStream delimiter: delimString [

	self flag: #deprecate.
	self
		printElementsOn: aStream
		separatedBy: delimString.
]

{ #category : #'printing - obsolete' }
Collection >> printOn: aStream delimiter: delimString last: lastDelimString [
	"Print elements on a stream separated
	with a delimiter between all the elements and with
	a special one before the last like: 'a, b and c'

	Note: Feel free to improve the code to detect the last element."

	| n sz |
	self flag: #deprecate.
	n := 1.
	sz := self size.
	self do: [:elem |
		n := n + 1.
		aStream print: elem]
	separatedBy: [
		n = sz
			ifTrue: [aStream print: lastDelimString]
			ifFalse: [aStream print: delimString]]
]

{ #category : #arithmetic }
Collection >> raisedTo: arg [

	^ arg adaptToCollection: self andSend: #raisedTo:
]

{ #category : #'math functions' }
Collection >> range [
	^ self max - self min
]

{ #category : #'math functions' }
Collection >> reciprocal [
	"Return the reciever full of reciprocated elements"
	^ self collect: [:a | a reciprocal]
]

{ #category : #enumerating }
Collection >> reduce: binaryBlock [
	"Apply the argument, binaryBlock cumulatively to the elements of the receiver.
	For sequenceable collections the elements will be used in order, for unordered
	collections the order is unspecified."

	| first nextValue |
	first := true.
	self do: [ :each |
		first
			ifTrue: [ nextValue := each. first := false ]
			ifFalse: [ nextValue := binaryBlock value: nextValue value: each ] ].
	first ifTrue: [ self errorEmptyCollection ].
	^nextValue
]

{ #category : #enumerating }
Collection >> reject: aBlock [ 
	"Evaluate aBlock with each of the receiver's elements as the argument. 
	Collect into a new collection like the receiver only those elements for 
	which aBlock evaluates to false. Answer the new collection."

	^self select: [:element | (aBlock value: element) == false]
]

{ #category : #enumerating }
Collection >> reject: rejectBlock thenDo: doBlock [ 
	"Utility method to improve readability."
	^ (self reject: rejectBlock) do: doBlock
]

{ #category : #removing }
Collection >> remove: oldObject [ 
	"Remove oldObject from the receiver's elements. Answer oldObject 
	unless no element is equal to oldObject, in which case, raise an error.
	ArrayedCollections cannot respond to this message."

	^ self remove: oldObject ifAbsent: [self errorNotFound: oldObject]
]

{ #category : #removing }
Collection >> remove: oldObject ifAbsent: anExceptionBlock [ 
	"Remove oldObject from the receiver's elements. If several of the 
	elements are equal to oldObject, only one is removed. If no element is 
	equal to oldObject, answer the result of evaluating anExceptionBlock. 
	Otherwise, answer the argument, oldObject. ArrayedCollections cannot 
	respond to this message."

	self subclassResponsibility
]

{ #category : #removing }
Collection >> removeAll [
	"Remove each element from the receiver and leave it empty.
	ArrayedCollections cannot respond to this message.
	There are two good reasons why a subclass should override this message:
	1) the subclass does not support being modified while being iterated
	2) the subclass provides a much faster way than iterating through each element"

	self do: [:each | self remove: each].
]

{ #category : #removing }
Collection >> removeAll: aCollection [ 
	"Remove each element of aCollection from the receiver. If successful for 
	each, answer aCollection. Otherwise create an error notification.
	ArrayedCollections cannot respond to this message."

	aCollection == self ifTrue: [^self removeAll].
	aCollection do: [:each | self remove: each].
	^ aCollection
]

{ #category : #removing }
Collection >> removeAllFoundIn: aCollection [ 
	"Remove each element of aCollection which is present in the receiver 
	from the receiver. Answer aCollection. No error is raised if an element
	isn't found. ArrayedCollections cannot respond to this message."

	aCollection do: [:each | self remove: each ifAbsent: []].
	^ aCollection
]

{ #category : #removing }
Collection >> removeAllSuchThat: aBlock [ 
	"Evaluate aBlock for each element and remove all that elements from
	the receiver for that aBlock evaluates to true.  Use a copy to enumerate 
	collections whose order changes when an element is removed (i.e. Sets)."

	self copy do: [:each | (aBlock value: each) ifTrue: [self remove: each]]
]

{ #category : #'math functions' }
Collection >> roundTo: quantum [
	^self collect: [ :ea | ea roundTo: quantum ]
]

{ #category : #'math functions' }
Collection >> rounded [
	^ self collect: [:a | a rounded]
]

{ #category : #enumerating }
Collection >> select: aBlock [ 
	"Evaluate aBlock with each of the receiver's elements as the argument. 
	Collect into a new collection like the receiver, only those elements for 
	which aBlock evaluates to true. Answer the new collection."

	| newCollection |
	newCollection := self species new.
	self do: [:each | (aBlock value: each) ifTrue: [newCollection add: each]].
	^newCollection
]

{ #category : #enumerating }
Collection >> select: selectBlock thenCollect: collectBlock [
	"Utility method to improve readability."

	^ (self select: selectBlock) collect: collectBlock
]

{ #category : #enumerating }
Collection >> select: selectBlock thenDo: doBlock [ 
	"Utility method to improve readability."
	^ (self select: selectBlock) do: doBlock
]

{ #category : #'math functions' }
Collection >> sign [
	^self collect: [:each | each sign]
]

{ #category : #'math functions' }
Collection >> sin [
	^self collect: [:each | each sin]
]

{ #category : #accessing }
Collection >> size [
	"Answer how many elements the receiver contains."

	| tally |
	tally := 0.
	self do: [:each | tally := tally + 1].
	^ tally
]

{ #category : #sorting }
Collection >> sorted [
	"Return a new sequenceable collection which contains the same elements as self but its elements are sorted in ascending order using the #'<=' operator."

	^self sorted: nil
]

{ #category : #sorting }
Collection >> sorted: aSortBlockOrNil [
	"Return a new sequenceable collection which contains the same elements as self but its elements are sorted by aSortBlockOrNil. The block should take two arguments and return true if the first element should preceed the second one. If aSortBlock is nil then <= is used for comparison."

	^self asArray sort: aSortBlockOrNil
]

{ #category : #'math functions' }
Collection >> sqrt [
	^ self collect: [:each | each sqrt]
]

{ #category : #'math functions' }
Collection >> squared [
	^ self collect: [:each | each * each]
]

{ #category : #printing }
Collection >> storeOn: aStream [ 
	"Refer to the comment in Object|storeOn:."

	| noneYet |
	aStream nextPutAll: '(('.
	aStream nextPutAll: self class name.
	aStream nextPutAll: ' new)'.
	noneYet := true.
	self do: 
		[:each | 
		noneYet
			ifTrue: [noneYet := false]
			ifFalse: [aStream nextPut: $;].
		aStream nextPutAll: ' add: '.
		aStream store: each].
	noneYet ifFalse: [aStream nextPutAll: '; yourself'].
	aStream nextPut: $)
]

{ #category : #'math functions' }
Collection >> sum [
	"Compute the sum of all the elements in the receiver"

	^self reduce:[:a :b| a + b]
]

{ #category : #accessing }
Collection >> take: maxNumberOfElements [
	"Returns maxNumberOfElements as a new collection (using my #species) or less if the collection is not large enough."

	^ self any: (maxNumberOfElements min: self size)
]

{ #category : #'math functions' }
Collection >> tan [
	^self collect: [:each | each tan]
]

{ #category : #converting }
Collection >> topologicallySortedUsing: aSortBlock [ 
	"Answer a SortedCollection whose elements are the elements of the 
	receiver, but topologically sorted. The topological order is defined 
	by the argument, aSortBlock."

	| aSortedCollection |
	aSortedCollection := SortedCollection new: self size.
	aSortedCollection sortBlock: aSortBlock.
	self do: [:each | aSortedCollection addLast: each].	"avoids sorting"
	^ aSortedCollection sortTopologically

]

{ #category : #'math functions' }
Collection >> truncated [
	^ self collect: [:a | a truncated]
]

{ #category : #enumerating }
Collection >> try: aBlock [
	"Evaluate aBlock with each of the receiver's elements as the argument. On error, skip that element and continue."

	^ self try: aBlock ignore: Error
]

{ #category : #enumerating }
Collection >> try: aBlock ignore: exceptionOrExceptionSet [
	"Evaluate aBlock with each of the receiver's elements as the argument. On error, skip that element and continue."

	^ self
		try: aBlock
		ignore: exceptionOrExceptionSet
		ifException: nil
]

{ #category : #enumerating }
Collection >> try: aBlock ignore: exceptionOrExceptionSet ifException: unaryBlockOrNil [
      "Evaluate aBlock with each of the receiver's elements as the argument. On error, evaluate a block and/or continue."

      ^ self do: [:ea |
              [aBlock value: ea]
                      on: exceptionOrExceptionSet
                      do: [:err | unaryBlockOrNil ifNotNil: [unaryBlockOrNil value: err]]]
]

{ #category : #enumerating }
Collection >> try: aBlock ignore: exceptionOrExceptionSet logged: aBoolean [
	"Evaluate aBlock with each of the receiver's elements as the argument. On error, skip that element and continue."

	^ self
		try: aBlock
		ignore: exceptionOrExceptionSet
		ifException: (aBoolean ifTrue: [[:err| Transcript showln: err messageText]])
]

{ #category : #enumerating }
Collection >> union: aCollection [
	"Answer the set theoretic union of two collections."

	^ self asSet addAll: aCollection; yourself
]

{ #category : #'filter streaming' }
Collection >> write: anObject [ 
	^ self add: anObject
]
