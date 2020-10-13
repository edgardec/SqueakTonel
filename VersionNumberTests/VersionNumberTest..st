"
This is the unit tests for the class VersionNumber.

VersionNumber has no specification beyond its implementation. There are few important elements to be noted:

	* Does NOT support 0 in versioning, i.e. 0, 1.0, 5.0.843, etc.
	* Does support empty version from a string, e.g. '', or a collection, e.g. #().
	* VersionNumber>>fromString will ignore trailing numbers if not sperated by a dot.
	* VersionNumber>>next advances the minor number (last value), without turn over.
	* VersionNumber>>branchNext creates a sub-minor version number, e.g. 1.5 becomes 1.5.1.
	* VersionNumber>>previous reduces may truncate the number, e.g. 9.1 -> 9, 1 to empty.
	* An annoying character improperly displayed as """" should be removed from source code.
"
Class {
	#name : #VersionNumberTest,
	#superclass : #ClassTestCase,
	#category : #VersionNumberTests
}

{ #category : #Coverage }
VersionNumberTest >> classToBeTested [

	^ VersionNumber
]

{ #category : #Coverage }
VersionNumberTest >> selectorsToBeIgnored [
	^ super selectorsToBeIgnored.
]

{ #category : #Running }
VersionNumberTest >> setUp [
	super setUp.
]

{ #category : #Running }
VersionNumberTest >> tearDown [
	super tearDown.
]

{ #category : #Tests }
VersionNumberTest >> testAsVersion [
	"note: a version number string '3 2 1' will only consider the first number as a version, ignoring the trailing '2 1'. Whether it is a desired feature or not should be determined."
	
	| numbers |
	numbers := { 
		'' -> #(). '1 '-> #(1). '1.2' -> #(1 2). '3.4.5' -> #(3 4 5). 
		'6.7.890' -> #(6 7 890). '9 8' -> #(9). '98 7 6' -> #(98). '54.3 2 1' -> #(54 3)
	}.
	
	numbers do: [:item | | version |
		version := (item key) asVersion.
	
		self assert: (VersionNumber = version class).
		self assert: ((item value) = version numbers).
	].

	self assert: 9999999999999999999 equals: '9999999999999999999' asVersion numbers first.
	
	self should: ['-1' asVersion] raise: TestResult error.
	self should: [' 1' asVersion] raise: TestResult error. "notice leading space!"
	self should: ['version' asVersion] raise: TestResult error.
	self should: ['1.2.10.20.-1.4' asVersion] raise: TestResult error.
	self should: ['1.2.10.20.R4' asVersion] raise: TestResult error.
]

{ #category : #Tests }
VersionNumberTest >> testBranchNext [
	| numbers |
	numbers := #(#(1) #(9) #(1 2) #(1 9) #(1 9 1) #(1 9 9) #(1 1 1 1 1 99)).
	
	numbers do: [:item | | temp version |
		version := VersionNumber fromCollection: item.
		
		temp := item asOrderedCollection.
		temp add: 1.

		self assert: (temp asArray = version branchNext numbers).
	].
]

{ #category : #Tests }
VersionNumberTest >> testFirst [
	| version |
	version := VersionNumber first.
	self assert: (VersionNumber = version class).
	self assert: (#(1) = version numbers).
]

{ #category : #Tests }
VersionNumberTest >> testFromCollection [
	| numbers |
	numbers := #(#(1) #(1 2) #(3 4 5) #(6 7 890)).
	
	numbers do: [:item | | version |
		version := VersionNumber fromCollection: item.
	
		self assert: (VersionNumber = version class).
		self assert: (item = version numbers).
	].

	self assert: #() equals: (VersionNumber fromCollection: #()) numbers.
	self assert: #(9999999999999999999) equals: (VersionNumber fromCollection: #(9999999999999999999)) numbers.
	
	self should: [VersionNumber fromCollection: #(0)] raise: TestResult error.
	self should: [VersionNumber fromCollection: #(-1)] raise: TestResult error.
	self should: [VersionNumber fromCollection: #(1 2 10 20 -1 4)] raise: TestResult error.
	self should: [VersionNumber fromCollection: #(1 2 10 20 '1' 4)] raise: TestResult error.
	self should: [VersionNumber fromCollection: #('version')] raise: TestResult error.
	
]

{ #category : #Tests }
VersionNumberTest >> testFromString [
	"note: a version number string '3 2 1' will only consider the first number as a version, ignoring the trailing '2 1'. Whether it is a desired feature or not should be determined."
	
	| numbers |
	numbers := { 
		'' -> #(). '1 '-> #(1). '1.2' -> #(1 2). '3.4.5' -> #(3 4 5). 
		'6.7.890' -> #(6 7 890). '9 8' -> #(9). '98 7 6' -> #(98). '54.3 2 1' -> #(54 3)
	}.
	
	numbers do: [:item | | version |
		version := VersionNumber fromString: (item key).
	
		self assert: (VersionNumber = version class).
		self assert: ((item value) = version numbers).
	].

	self assert: #(9999999999999999999) equals: (VersionNumber fromString: '9999999999999999999') numbers.
	
	self should: [VersionNumber fromString: '-1'] raise: TestResult error.
	self should: [VersionNumber fromString: ' 1'] raise: TestResult error. "notice leading space!"
	self should: [VersionNumber fromString: 'version'] raise: TestResult error.
	self should: [VersionNumber fromString: '1.2.10.20.-1.4'] raise: TestResult error.
	self should: [VersionNumber fromString: '1.2.10.20.R4'] raise: TestResult error.
	
]

{ #category : #Tests }
VersionNumberTest >> testInitializeNumbers [
	| numbers |
	numbers := #(#(1) #(1 2) #(3 4 5) #(6 7 890)).
	
	numbers do: [:item | | version |
		version := VersionNumber new initializeNumbers: item.
	
		self assert: (VersionNumber = version class).
		self assert: (item = version numbers).
	].

	self assert: #() equals: (VersionNumber new initializeNumbers: #()) numbers.
	self assert: #(9999999999999999999) equals: (VersionNumber new initializeNumbers: #(9999999999999999999)) numbers.
	
	self should: [VersionNumber new initializeNumbers: #(0)] raise: TestResult error.
	self should: [VersionNumber new initializeNumbers: #(-1)] raise: TestResult error.
	self should: [VersionNumber new initializeNumbers: #(1 2 10 20 -1 4)] raise: TestResult error.
	self should: [VersionNumber new initializeNumbers: #(1 2 10 20 '1' 4)] raise: TestResult error.
	self should: [VersionNumber new initializeNumbers: #('version')] raise: TestResult error.
	
]

{ #category : #Tests }
VersionNumberTest >> testIsEqual [
	"Test VersionNumber>>="
	
	| version |
	version := VersionNumber first.
	self assert: (VersionNumber new initializeNumbers: #(1)) = version.
	self assert: (VersionNumber new initializeNumbers: #(2)) = (version next).
	self assert: (VersionNumber new initializeNumbers: #(1 1)) = (version branchNext).
]

{ #category : #Tests }
VersionNumberTest >> testNext [
	| numbers |
	numbers := #(#(1) #(9) #(1 2) #(1 9) #(1 9 1) #(1 9 9) #(1 1 1 1 1 99)).
	
	numbers do: [:item | | version temp |
		version := VersionNumber fromCollection: item.
		
		temp := item copy.
		temp atLast: 1 put: (temp last + 1).

		self assert: (temp = version next numbers).
	].
]

{ #category : #Tests }
VersionNumberTest >> testPrevious [
	| numbers |
	numbers := { 
		#(1) -> #(). #(2) -> #(1). #(9) -> #(8).
		#(7 9) -> #(7 8). #(7 1) -> #(7). #(9 9 9 9 1) -> #(9 9 9 9).
	}.
	
	numbers do: [:item | | version |
		version := VersionNumber fromCollection: (item key).
		
		self assert: ((item value) = version previous numbers).
	].
]
