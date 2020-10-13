"
I test the random number generator implemented by Random. Whenever its implementation changes, I'll have to be updated to match the new implementation.
Instead of adding methods to Random to access the internal state, I use reflection (#instVarNamed:).
"
Class {
	#name : #RandomTest,
	#superclass : #ClassTestCase,
	#category : #'KernelTests-Numbers'
}

{ #category : #helpers }
RandomTest >> assertFirstValuesAre: expectedValues finalStatesAre: expectedFinalStates withSeed: seed [
	"Verify that the first generated numbers with the given seed are the same as in expectedValues. Also check that the state of the generator matches expectedFinalStates after the last number was generated."

	| random states |
	random := Random seed: seed.
	expectedValues do: [ :each |
		self assert: each equals: random nextValue ].
	states := random instVarNamed: #states.
	self
		assert: expectedFinalStates
		equals: states.
	self
		assert: expectedValues size \\ states size + 1
		equals: (random instVarNamed: #index)

]

{ #category : #helpers }
RandomTest >> assertInitialStateIs: expectedInitialState withSeed: seed [
	"Verify that the initial values of the states variable match the given values for the given seed."

	| random |
	random := Random basicNew.
	random initializeStatesWith: seed.
	self
		assert: expectedInitialState
		equals: (random instVarNamed: #states)
]

{ #category : #tests }
RandomTest >> testExpectedValuesAndFinalStates [
	"The numbers here were generated with a modified version of dcmt. http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/DC/dc.html ." 

	self
		assertFirstValuesAre: #(791793822 321208675 533452018 916714539 223319369 1012473888 519521402 691227136 655932023 762631845 263546831 924338090 559722895 178321509 916222900 335844726 321863848 695515717 112692096 738657692 395570358 340088260 887167633 1009518587 243735024 275847384 769544812 100974653 906270421 342913954 97518663 1067659127 901766500 960849649 913009938 458031838 820147509 822604220 642364166 55274442 357680755 991571674 13914935 857799117 66453038 971120160 398083276 373288317 684827868 674731247)
		finalStatesAre: #(635250399 668117719 848992573 251038832 98606638 713392708 276649431 1832634 607491210 416789795 914892960 325580685 799306927 249385527 318375379 748373901 904063250 170318087)
		withSeed: 1.
	self
		assertFirstValuesAre: #(687305094 702568716 681618148 361497334 56139518 745675778 952599938 953942824 73974730 564274490 1060767469 886737457 1039805902 722013528 64171798 764123925 432128359 274234212 668956319 716744939 309797615 780783289 301460951 535739904 224961890 114117836 193753287 1031006106 336541050 154594855 533038119 881775175 158057306 77776036 493306911 605604566 1048063493 584525301 1022642202 864508130 413151089 57876224 191759976 1008496211 868455235 165567279 536395892 455845625 913969488 1031304391)
		finalStatesAre: #(1042729719 217432604 1069856876 162320335 202162581 218490242 297015026 68487684 898813855 71972347 874350418 438504195 940031925 17654607 153301097 316080480 107798001 361001990)
		withSeed: 16rFFFFFFFF.
	self
		assertFirstValuesAre: #(508754231 328289850 498391260 573176063 453719461 935895611 435707860 570185280 1062441194 1069509491 70217464 149146838 858549983 755358687 617299553 468867114 401402744 731268746 224918805 447062722 290392391 137004397 311801760 320322691 258212560 536704035 950550708 555923010 982471103 981495169 294632011 175884018 503667308 154136572 291636083 607893878 617073742 310910219 169050729 996306290 695080363 165230559 945376911 612064901 884146961 873827275 491094423 292583589 257673098 606271793)
		finalStatesAre: #(650871495 911703262 863344052 176605894 655312644 446078144 11879373 102580040 573515471 123917283 104253098 1042658978 222575135 487008331 309368251 253108077 333913878 249510222)
		withSeed: 36rSqueak
]

{ #category : #tests }
RandomTest >> testInitialStates [
	"The numbers here were generated with a modified version of dcmt. http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/DC/dc.html ." 

	self
		assertInitialStateIs: #(1 738691430 491934885 961690497 64984499 171432612 446538473 482277108 305861910 321062125 1021787430 989754889 231135540 639897334 889001601 577497588 377121465 745575081)
		withSeed: 1.
	self
		assertInitialStateIs: #(1073741823 266459757 720566430 20126452 56152695 937338158 159797905 1043117473 406704525 811309125 915542797 222137334 82370074 761921770 934153467 57368396 980436236 43660082)
		withSeed: 16rFFFFFFFF.
	self
		assertInitialStateIs: #(664399324 1024531762 951500119 549828849 614037886 888424945 697907173 598650154 380912181 737669773 997432646 1017772356 307774789 986202438 417447953 558454367 229264988 682340290)
		withSeed: 36rSqueak.
	
		
]

{ #category : #tests }
RandomTest >> testNext [
	"Generate some float values, and see if they are in the [0,1) interval. Also check that the smallest and the largest values are small/large enough."

	| random min max |
	min := Float infinity.
	max := Float negativeInfinity.
	random := Random seed: 112629.
	100000 timesRepeat: [
		| next | 
		next := random next.
		next < min ifTrue: [ min := next ].
		next > max ifTrue: [ max := next ].
		self assert: next >= 0.0 description: [ 'Generated value ', next asString, ' should be non-negative.' ].
		self assert: next < 1.0 description: [ 'Generated value ', next asString, ' should be less than 1.0.' ] ].
	self assert: max > 0.9999 description: 'The largest generated value should be greater than 0.9999.'.
	self assert: min < 0.0001 description: 'The smallest generated value should be less than 0.0001.'
]

{ #category : #tests }
RandomTest >> testNextInt [
	"Generate many integer values from a small range, and see if they are distributed equally on that range. This is not an exact test, but it's good enough to find obvious errors in the generator."

	| random |
	random := Random seed: 1234567812345678.
	#(
		2 100000
		3 200000
		10 300000
		100 400000
	) groupsDo: [ :bucketCount :runs |
		| buckets |
		buckets := Array new: bucketCount withAll: 0.
		runs timesRepeat: [
			| next | 
			next := random nextInt: bucketCount.
			buckets at: next put: (buckets at: next) + 1 ].
		buckets do: [ :each | 
			self assert: (each / (runs / bucketCount) between: 0.95 and: 1.05) ] ]
]

{ #category : #tests }
RandomTest >> testNextIntLarge [
	"Generate many 1281-bit integers and see if their bits are equally distributed. This is not an exact test, but it's good enough to find obvious errors in the generator."

	<timeout: 15>
	| random bits bitCounts maxValue runs |
	random := Random seed: 1234567812345678.
	bits := 1281.
	bitCounts := Array new: bits withAll: 0.
	maxValue := 1 << bits.
	runs := 20000.
	runs timesRepeat: [
		| value |
		value := (random nextInt: maxValue) - 1.
		1 to: bits do: [ :bitIndex |
			bitCounts at: bitIndex put: (bitCounts at: bitIndex) + (value bitAt: bitIndex) ] ].
	bitCounts do: [ :each |
		self assert: ((each / (runs / 2)) between: 0.95 and: 1.05) ]
	
]

{ #category : #tests }
RandomTest >> testRoll [

	| random result |
	random := Random seed: 14482.
	
	"Roll the default die (d6)"
	100 timesRepeat: [
		result := random roll: 'd'.
		self assert: result >= 1 description: [ 'Rolled value ', result asString, ' should be 1 or more.' ].
		self assert: result <= 6 description: [ 'Rolled value ', result asString, ' should be 6 or less.' ] ].
	100 timesRepeat: [
		result := random roll: '1d'.
		self assert: result >= 1 description: [ 'Rolled value ', result asString, ' should be 1 or more.' ].
		self assert: result <= 6 description: [ 'Rolled value ', result asString, ' should be 6 or less.' ] ].
	
	"Roll a d20"
	100 timesRepeat: [
		result := random roll: '1d20'.
		self assert: result >= 1 description: [ 'Rolled value ', result asString, ' should be 1 or more.' ].
		self assert: result <= 20 description: [ 'Rolled value ', result asString, ' should be 20 or less.' ] ].
	
	"Roll a d% (d100)"
	1000 timesRepeat: [
		result := random roll: '1d%'.
		self assert: result >= 1 description: [ 'Rolled value ', result asString, ' should be 1 or more.' ].
		self assert: result <= 100 description: [ 'Rolled value ', result asString, ' should be 100 or less.' ] ].
	1000 timesRepeat: [
		result := random roll: 'd%'.
		self assert: result >= 1 description: [ 'Rolled value ', result asString, ' should be 1 or more.' ].
		self assert: result <= 100 description: [ 'Rolled value ', result asString, ' should be 100 or less.' ] ].
	
	"Roll multiple dice"
	100 timesRepeat: [
		result := random roll: '2d2'.
		self assert: result >= 2 description: [ 'Rolled value ', result asString, ' should be 2 or more.' ].
		self assert: result <= 4 description: [ 'Rolled value ', result asString, ' should be 4 or less.' ] ].
	100 timesRepeat: [
		result := random roll: '1d2+1d2'.
		self assert: result >= 2 description: [ 'Rolled value ', result asString, ' should be 2 or more.' ].
		self assert: result <= 4 description: [ 'Rolled value ', result asString, ' should be 4 or less.' ] ].
	
	"Roll some d1s"
	result := random roll: '10d1'.
	self assert: result = 10 description: [ 'Rolled value ', result asString, 'should be 10.' ].
	result := random roll: '10d1-5d1'.
	self assert: result = 5 description: [ 'Rolled value ', result asString, 'should be 5.' ].
	
	"Roll a constant value"
	result := random roll: '5'.
	self assert: result = 5 description: [ 'Rolled value ', result asString, 'should be 5.' ].
	result := random roll: '5+3+2'.
	self assert: result = 10 description: [ 'Rolled value ', result asString, 'should be 10.' ].
	
	"Roll die and add constant value"
	result := random roll: '1d1+3'.
	self assert: result = 4 description: [ 'Rolled value ', result asString, 'should be 4.' ].
]
