Class {
	#name : #BecomeTest,
	#superclass : #TestCase,
	#category : #'Tests-VM'
}

{ #category : #tests }
BecomeTest >> testBecome [
	"Test the two way become. Note. we cannot use string literals for this test"
	| a b c d |

	a := 'ab' copy.
	b := 'cd' copy.
	c := a.
	d := b.

	a become: b.

	self 
		assert: a = 'cd';
		assert: b = 'ab';
		assert: c = 'cd';
		assert: d = 'ab'.



]

{ #category : #tests }
BecomeTest >> testBecomeForward [
	"Test the forward become."
	| a b c d |

	a := 'ab' copy.
	b := 'cd' copy.
	c := a.
	d := b.

	a becomeForward: b.

	self 
		assert: a = 'cd';
		assert: b = 'cd';
		assert: c = 'cd';
		assert: d = 'cd'.



]

{ #category : #tests }
BecomeTest >> testBecomeForwardDontCopyIdentityHash [
	"Check that
		1. the argument to becomeForward: is NOT modified to have the receiver's identity hash.
		2. the receiver's identity hash is unchanged."

 	| a b hb |

	a := 'ab' copy.
	b := 'cd' copy.
	hb := b identityHash.

	a becomeForward: b copyHash: false.

	self 
		assert: a identityHash = hb;
		assert: b identityHash = hb.


]

{ #category : #tests }
BecomeTest >> testBecomeForwardHash [

	| a b c hb |

	a := 'ab' copy.
	b := 'cd' copy.
	c := a.
	hb := b hash.

	a becomeForward: b.

	self 
		assert: a hash = hb;
		assert: b hash = hb;
		assert: c hash = hb.



]

{ #category : #tests }
BecomeTest >> testBecomeForwardIdentityHash [
	"Check that
		1. the argument to becomeForward: is modified to have the receiver's identity hash.
		2. the receiver's identity hash is unchanged."

 	| a b ha |

	a := 'ab' copy.
	b := 'cd' copy.
	ha := a identityHash.

	a becomeForward: b.

	self 
		assert: a identityHash = ha;
		assert: b identityHash = ha.


]

{ #category : #tests }
BecomeTest >> testBecomeHash [

	| a b c d ha hb |

	a := 'ab' copy.
	b := 'cd' copy.
	c := a.
	d := b.
	ha := a hash.
	hb := b hash.

	a become: b.

	self 
		assert: a hash = hb;
		assert: b hash = ha;
		assert: c hash = hb;
		assert: d hash = ha.



]

{ #category : #tests }
BecomeTest >> testBecomeIdentityHash [
	| a b c d numberOfRetry newAIdentityHash newBIdentityHash oldAIdentityHash oldBIdentityHash |
	numberOfRetry := 0.
	
	[a := 'ab' copy.
	c := IdentitySet new: 1000.
	b := 'cd' copy.
	d := IdentitySet new: 1000.
	"Note: the sets are allocated with enough room to reduce probability that two different hash lead to same slot"
	"Note2: a & b creation are interleaved with c & d, because some VM allocate the same identityHash for two consecutively created objects"
	c add: a; add: b.
	d add: a.
	oldAIdentityHash := a identityHash.
	oldBIdentityHash := b identityHash.
	oldAIdentityHash = oldBIdentityHash and: [numberOfRetry < 10]]
		whileTrue: [numberOfRetry := numberOfRetry + 1].
	self assert: oldAIdentityHash ~= oldBIdentityHash description: 'The VM is spawning too many equal identityHash to be honest'.
	a become: b.
	newAIdentityHash := a identityHash.
	newBIdentityHash := b identityHash.
	self
		"The set c & d can still retrieve their elements because elements did not change their expected position"
		assert: (c includes: a);
		assert: (c includes: b);
		assert: (d includes: a);
		deny: (d includes: b);
		"Elements didn't change their expected position because identityHash did not change"
		assert: oldAIdentityHash = newAIdentityHash;
		assert: oldBIdentityHash = newBIdentityHash
]
