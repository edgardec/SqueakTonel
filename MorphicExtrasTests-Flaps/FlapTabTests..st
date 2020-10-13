"
A FlapTabTests is here to test infinite recursion bug when extent: message is sent to some flap tabs see 
http://bugs.squeak.org/view.php?id=6486 
for report.

Instance Variables
We inherit cases which can be filled with morphs that need to be deleted at the end of the test.


"
Class {
	#name : #FlapTabTests,
	#superclass : #TestCase,
	#category : #'MorphicExtrasTests-Flaps'
}

{ #category : #tests }
FlapTabTests >> testFlapTabRecusion [
	| a b tab |
	"This float is 466.7005813953488"
	a := (16r1D2B3594D65359 asFloat timesTwoPower: -44).
	b := 105.
	self deny: a + b - a = b.

	tab := Flaps newFlapTitled: 'Test' onEdge: #top.
	tab left: a.

	self
		should: [tab extent: b asPoint]
		notTakeMoreThanMilliseconds: 10

]
