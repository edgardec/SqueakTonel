"
I generate a pseudo-random UUID by asking Random for a 128 bit value.

See https://tools.ietf.org/html/rfc4122.html#section-4.4 for reference.
"
Class {
	#name : #UUIDGenerator,
	#superclass : #Object,
	#classVars : [
		'Default',
		'TheRandom',
		'TheSemaphore'
	],
	#category : #'Network-UUID'
}

{ #category : #'instance creation' }
UUIDGenerator class >> default [
	^ Default ifNil: [Default := self new]

]

{ #category : #'class initialization' }
UUIDGenerator class >> initialize [
	TheRandom := Random new.
	TheSemaphore := Semaphore forMutualExclusion.
	Smalltalk addToStartUpList: self
]

{ #category : #'class initialization' }
UUIDGenerator class >> resetDefault [
	Default := nil.
]

{ #category : #'class initialization' }
UUIDGenerator class >> startUp [
	"Reseed the random"
	TheSemaphore critical: [TheRandom seed: nil].
]

{ #category : #'instance creation' }
UUIDGenerator >> fillRandomly: aUUID [

	TheSemaphore critical: [
		TheRandom nextBytes: 16 "128 bit" into: aUUID startingAt: 1].
]

{ #category : #'instance creation' }
UUIDGenerator >> generateBytes: aUUID forVersion: aVersion [
	| versionID fixedValue |
	
	aVersion = 4 ifFalse: [^ self error: 'Unsupported version'].

	self fillRandomly: aUUID.
	versionID := ((aUUID at: 7) bitAnd: 16r0F) bitOr: 16r40. "Version 4"
	fixedValue := ((aUUID at: 9) bitAnd: 16r3F) bitOr: 16r80. "Fixed 8..b value"
	aUUID
		at: 7 put: versionID;
		at: 9 put: fixedValue.
]
