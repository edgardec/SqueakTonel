"
I'm responsible to help getting information about system space usage. The information I compute is represented by a spaceTallyItem

try something like: 

((SpaceTally new spaceTally: (Array with: TextMorph with: Point)) 
	asSortedCollection: [:a :b | a spaceForInstances > b spaceForInstances]) 

SpaceTally new systemWideSpaceTally


This class has been created from a part of SystemDictionary. It still deserves a nice
clean, such as using object instead of array having 4 slots.

sd-20 June 2003
"
Class {
	#name : #SpaceTally,
	#superclass : #Object,
	#instVars : [
		'results'
	],
	#category : #'System-Tools'
}

{ #category : #fileOut }
SpaceTally >> compareTallyIn: beforeFileName to: afterFileName [
	"SpaceTally new compareTallyIn: 'tally' to: 'tally2'"

	| answer s beforeDict a afterDict allKeys |
	beforeDict := Dictionary new.
	s := FileDirectory default fileNamed: beforeFileName.
	[s atEnd] whileFalse: [
		a := Array readFrom: s nextLine.
		beforeDict at: a first put: a allButFirst.
	].
	s close.
	afterDict := Dictionary new.
	s := FileDirectory default fileNamed: afterFileName.
	[s atEnd] whileFalse: [
		a := Array readFrom: s nextLine.
		afterDict at: a first put: a allButFirst.
	].
	s close.
	answer := WriteStream on: String new.
	allKeys := (Set new addAll: beforeDict keys; addAll: afterDict keys; yourself) sorted.
	allKeys do: [ :each |
		| before after diff |
		before := beforeDict at: each ifAbsent: [#(0 0 0)].
		after := afterDict at: each ifAbsent: [#(0 0 0)].
		diff := before with: after collect: [ :vBefore :vAfter | vAfter - vBefore].
		diff = #(0 0 0) ifFalse: [
			answer nextPutAll: each,'  ',diff printString; cr.
		].
	].
	StringHolder new contents: answer contents; openLabel: 'space diffs'.
	



]

{ #category : #'class analysis' }
SpaceTally >> computeSpaceUsage [

	results
		do: [ :entry |
			| class instanceSpaceAndCount |
			class := self class environment at: entry analyzedClassName.
			Smalltalk garbageCollectMost.
			instanceSpaceAndCount := self spaceForInstancesOf: class.
			entry 
				codeSize: class spaceUsed;
				instanceCount: instanceSpaceAndCount second;
				spaceForInstances: instanceSpaceAndCount first ]
		displayingProgress: 'Taking statistics...'
]

{ #category : #'class analysis' }
SpaceTally >> preAllocateResultsFor: classes [

	results := OrderedCollection new: classes size.
	classes do: [:cl | results add: (SpaceTallyItem analyzedClassName: cl name)].
	results := results asArray.

]

{ #category : #fileOut }
SpaceTally >> printSpaceAnalysis [	
	"SpaceTally new printSpaceAnalysis"

	^ self printSpaceAnalysis: 1 on: 'STspace.text'
]

{ #category : #fileOut }
SpaceTally >> printSpaceAnalysis: threshold on: fileName [
	"SpaceTally new printSpaceAnalysis: 1000 on: 'STspace.text1'"

	"sd-This method should be rewrote to be more coherent within the rest of the class 
	ie using preAllocate and spaceForInstanceOf:"

	"If threshold > 0, then only those classes with more than that number
	of instances will be shown, and they will be sorted by total instance space.
	If threshold = 0, then all classes will appear, sorted by name."

	FileStream newFileNamed: fileName do: [ :file |
		self printSpaceAnalysis: threshold onStream: file ]
]

{ #category : #fileOut }
SpaceTally >> printSpaceAnalysis: threshold onStream: stream [
	"If threshold > 0, then only those classes with more than that number
	of instances will be shown, and they will be sorted by total instance space.
	If threshold = 0, then all classes will appear, sorted by name."

	| totalCodeSpace totalInstCount totalInstSpace totalPercent classNameLength printRow |
	self systemWideSpaceTally.
	totalCodeSpace := totalInstCount := totalInstSpace := 0.
	classNameLength := 1.
	results do: [ :each |
		classNameLength := classNameLength max: each analyzedClassName size.
		totalCodeSpace := totalCodeSpace + each codeSize.
		totalInstCount := totalInstCount + each instanceCount.
		totalInstSpace := totalInstSpace + each spaceForInstances ].
	totalPercent := 0.0.

	printRow := [ :class :codeSpace :instanceCount :instanceSpace :percent |
		stream
			nextPutAll: (class padded: #right to: classNameLength + 1 with: $ );
			nextPutAll: (codeSpace padded: #left to: 12 with: $ );
			nextPutAll: (instanceCount padded: #left to: 12 with: $ );
			nextPutAll: (instanceSpace padded: #left to: 14 with: $ );
			nextPutAll: (percent padded: #left to: 8 with: $ );
			cr ].

	stream timeStamp.
	printRow valueWithArguments: { 'Class'. 'code space'. '# instances'. 'inst space'. 'percent' }.

	threshold > 0
		ifTrue: "If inst count threshold > 0, then sort by space"
			[results := results select: [ :s |
										s instanceCount >= threshold
										or: [s spaceForInstances > (totalInstSpace // 500) ] ].
			 results sort: [ :s :s2 |
						  s spaceForInstances > s2 spaceForInstances
						  or: [s spaceForInstances = s2 spaceForInstances
							  and: [s analyzedClassName < s2 analyzedClassName] ] ] ]
		ifFalse: "Otherwise sort by name"
			[results sort: [ :s :s2 | s analyzedClassName < s2 analyzedClassName]].

	results do: [ :s |
		| percent | 
		percent := s spaceForInstances * 100.0 / totalInstSpace.
		totalPercent := totalPercent + percent.
		printRow valueWithArguments: {
			s analyzedClassName.
			s codeSize printString.
			s instanceCount printString.
			s spaceForInstances asBytesDescription.
			percent printShowingDecimalPlaces: 1 } ].

	stream cr.
	printRow valueWithArguments: {
		'Total'.
		totalCodeSpace printString.
		totalInstCount printString.
		totalInstSpace printString.
		totalPercent printShowingDecimalPlaces: 1 }
]

{ #category : #fileOut }
SpaceTally >> printSpaceDifferenceFrom: fileName1 to: fileName2 [
	"For differential results, run printSpaceAnalysis twice with different fileNames,
	then run this method...
		SpaceTally new printSpaceAnalysis: 0 on: 'STspace.text1'.
			--- do something that uses space here ---
		SpaceTally new printSpaceAnalysis: 0 on: 'STspace.text2'.
		SpaceTally new printSpaceDifferenceFrom: 'STspace.text1' to: 'STspace.text2'
"
	| f coll1 coll2 item |
	f := FileStream readOnlyFileNamed: fileName1.
	coll1 := OrderedCollection new.
	[f atEnd] whileFalse: [coll1 add: f nextLine].
	f close.
	f := FileStream readOnlyFileNamed: fileName2.
	coll2 := OrderedCollection new.
	[f atEnd] whileFalse:
		[item := f nextLine.
		((coll1 includes: item) and: [(item endsWith: 'percent') not])
			ifTrue: [coll1 remove: item]
			ifFalse: [coll2 add: item]].
	f close.
	(StringHolder new contents: (String streamContents: 
			[:s | 
			s nextPutAll: fileName1; cr.
			coll1 do: [:x | s nextPutAll: x; cr].
			s cr; cr.
			s nextPutAll: fileName2; cr.
			coll2 do: [:x | s nextPutAll: x; cr]]))
		openLabel: 'Differential Space Analysis'.

]

{ #category : #accessing }
SpaceTally >> results [

	^ results
]

{ #category : #fileOut }
SpaceTally >> saveTo: aFileName [
	"| st |
	st := SpaceTally new.
	st spaceTally: (Array with: TextMorph with: Point).
	st saveTo: 'spaceTally2'"
	| s |
	(FileDirectory default fileExists: aFileName) ifTrue: [
		FileDirectory default deleteFileNamed: aFileName].
	s := FileDirectory default fileNamed: aFileName.
	results do: [:each | s nextPutAll: each analyzedClassName asString ; 
						nextPutAll: ' '; nextPutAll: each codeSize printString; 
						nextPutAll: ' '; nextPutAll: each instanceCount printString; 
						nextPutAll: ' '; nextPutAll: each spaceForInstances printString; cr].
	s close
]

{ #category : #'instance size' }
SpaceTally >> spaceForInstancesOf: aClass [
	"Answer a pair of the number of bytes consumed by all instances of the
	 given class, including their object headers, and the number of instances."

	| instances total |
	instances := aClass allInstances.
	instances isEmpty ifTrue: [^#(0 0)].
	total := 0.
	aClass isVariable
		ifTrue:
			[instances do:
				[:i| total := total + (aClass byteSizeOfInstanceOfSize: i basicSize)]]
		ifFalse:
			[total := instances size * aClass byteSizeOfInstance].
	^{ total. instances size }
]

{ #category : #'class analysis' }
SpaceTally >> spaceTally: classes [ 
	"Answer a collection of SpaceTallyItems representing the memory space (in bytes) consumed 	by the code and instances of each class in the system. Note that code sizes do not currently 	report memory consumed by class variables. "
	"((SpaceTally new spaceTally: (Array with: TextMorph with: Point)) asSortedCollection: [:a :b | a spaceForInstances > b spaceForInstances]) asArray"
	self preAllocateResultsFor: classes.
	Smalltalk garbageCollect.
	self computeSpaceUsage.
	^ results
		 sort: [ : a : b | a spaceForInstances > b spaceForInstances ] ;
		 yourself
]

{ #category : #'class analysis' }
SpaceTally >> systemWideSpaceTally [
	"Answer a collection of SpaceTallyItems representing the memory space (in bytes) consumed 	by the code and instances of each class in the system. Note that code sizes do not currently 	report memory consumed by class variables. "

	"(SpaceTally new systemWideSpaceTally asSortedCollection: [:a :b | a spaceForInstances > b spaceForInstances]) asArray"

	^self spaceTally: Smalltalk allClasses.


]
