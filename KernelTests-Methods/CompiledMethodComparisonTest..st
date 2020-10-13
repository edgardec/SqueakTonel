Class {
	#name : #CompiledMethodComparisonTest,
	#superclass : #LongTestCase,
	#category : #'KernelTests-Methods'
}

{ #category : #tests }
CompiledMethodComparisonTest >> testHash [
	<timeout: 120>
	
	| ai |
	ai := CompiledMethod allInstances.
	"We assume here that if two CompiledMethods are equal then they have the same size and header."
	(ai groupBy: [ :method | { method size. method header } ]) values
		replace: [ :each | each asArray ];
		do: [ :methods |
			1 to: methods size do: [ :i |
				i to: methods size do: [ :j |
					(methods at: i) = (methods at: j) ifTrue: [
						self assert: (methods at: i) hash equals: (methods at: i) hash ] ] ] ]
		displayingProgress: 'Testing hashes'.
	self assert: (ai collect: [ :cm | cm hash ] as: Set) size * 2 >= ai asSet size
]
