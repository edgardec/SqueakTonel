Class {
	#name : #KedamaFloatArray,
	#superclass : #Float32Array,
	#type : #words,
	#category : #'Etoys-StarSqueak'
}

{ #category : #arithmetic }
KedamaFloatArray >> * other [

	| result |
	other isNumber ifTrue: [
		result := KedamaFloatArray new: self size.
		^ self primMulScalar: self and: other into: result.
	].
	((other isMemberOf: WordArray) or: [other isMemberOf: KedamaFloatArray]) ifTrue: [	
		result := KedamaFloatArray new: self size.
		^ self primMulArray: self and: other into: result.
	].
	^ super * other.

]

{ #category : #arithmetic }
KedamaFloatArray >> *= other [

	other isNumber ifTrue: [
		^ self primMulScalar: self and: other asFloat into: self.
	].
	((other isMemberOf: WordArray) or: [other isMemberOf: KedamaFloatArray]) ifTrue: [	
		^ self primMulArray: self and: other into: self.
	].
	^ super *= other.

]

{ #category : #arithmetic }
KedamaFloatArray >> + other [

	| result |
	other isNumber ifTrue: [
		result := KedamaFloatArray new: self size.
		^ self primAddScalar: self and: other into: result.
	].
	((other isMemberOf: WordArray) or: [other isMemberOf: KedamaFloatArray]) ifTrue: [	
		result := KedamaFloatArray new: self size.
		^ self primAddArray: self and: other into: result.
	].
	^ super + other.

]

{ #category : #arithmetic }
KedamaFloatArray >> += other [

	other isNumber ifTrue: [
		^ self primAddScalar: self and: other into: self.
	].
	((other isMemberOf: WordArray) or: [other isMemberOf: KedamaFloatArray]) ifTrue: [	
		^ self primAddArray: self and: other into: self.
	].
	^ super += other.

]

{ #category : #arithmetic }
KedamaFloatArray >> - other [

	| result |
	other isNumber ifTrue: [
		result := KedamaFloatArray new: self size.
		^ self primSubScalar: self and: other into: result.
	].
	((other isMemberOf: WordArray) or: [other isMemberOf: KedamaFloatArray]) ifTrue: [	
		result := KedamaFloatArray new: self size.
		^ self primSubArray: self and: other into: result.
	].
	^ super - other.

]

{ #category : #arithmetic }
KedamaFloatArray >> -= other [

	other isNumber ifTrue: [
		^ self primSubScalar: self and: other into: self.
	].
	((other isMemberOf: WordArray) or: [other isMemberOf: KedamaFloatArray]) ifTrue: [	
		^ self primSubArray: self and: other into: self.
	].
	^ super -= other.

]

{ #category : #arithmetic }
KedamaFloatArray >> / other [

	| result |
	other isNumber ifTrue: [
		result := KedamaFloatArray new: self size.
		^ self primDivScalar: self and: other into: result.
	].
	((other isMemberOf: WordArray) or: [other isMemberOf: KedamaFloatArray]) ifTrue: [	
		result := KedamaFloatArray new: self size.
		^ self primDivArray: self and: other into: result.
	].
	^ super / other.

]

{ #category : #arithmetic }
KedamaFloatArray >> /= other [

	other isNumber ifTrue: [
		^ self primDivScalar: self and: other into: self.
	].
	((other isMemberOf: WordArray) or: [other isMemberOf: KedamaFloatArray]) ifTrue: [	
		^ self primDivArray: self and: other into: self.
	].
	^ super /= other.

]

{ #category : #arithmetic }
KedamaFloatArray >> \\ other [

	| result |
	other isNumber ifTrue: [
		result := KedamaFloatArray new: self size.
		^ self primRemScalar: self and: other into: result.
	].
	((other isMemberOf: WordArray) or: [other isMemberOf: KedamaFloatArray]) ifTrue: [	
		result := KedamaFloatArray new: self size.
		^ self primRemArray: self and: other into: result.
	].
	^ super \\ other.

]

{ #category : #arithmetic }
KedamaFloatArray >> eToysEQ: other [

	| result |
	result := ByteArray new: self size.
	other isNumber ifTrue: [
		^ self primEQScalar: self and: other into: result.
	].
	((other isMemberOf: WordArray) or: [other isMemberOf: KedamaFloatArray]) ifTrue: [	
		^ self primEQArray: self and: other into: result.
	].
	1 to: self size do: [:index |
		result at: index put: (self at: index) = (other at: index).
	].

]

{ #category : #arithmetic }
KedamaFloatArray >> eToysGE: other [

	| result |
	result := ByteArray new: self size.
	other isNumber ifTrue: [
		^ self primGEScalar: self and: other into: result.
	].
	((other isMemberOf: WordArray) or: [other isMemberOf: KedamaFloatArray]) ifTrue: [	
		^ self primGEArray: self and: other into: result.
	].
	^ super >= other.

]

{ #category : #arithmetic }
KedamaFloatArray >> eToysGT: other [

	| result |
	result := ByteArray new: self size.
	other isNumber ifTrue: [
		^ self primGTScalar: self and: other into: result.
	].
	((other isMemberOf: WordArray) or: [other isMemberOf: KedamaFloatArray]) ifTrue: [	
		^ self primGTArray: self and: other into: result.
	].
	^ super > other.

]

{ #category : #arithmetic }
KedamaFloatArray >> eToysLE: other [

	| result |
	result := ByteArray new: self size.
	other isNumber ifTrue: [
		^ self primLEScalar: self and: other into: result.
	].
	((other isMemberOf: WordArray) or: [other isMemberOf: KedamaFloatArray]) ifTrue: [	
		^ self primLEArray: self and: other into: result.
	].
	^ super <= other.

]

{ #category : #arithmetic }
KedamaFloatArray >> eToysLT: other [

	| result |
	result := ByteArray new: self size.
	other isNumber ifTrue: [
		^ self primLTScalar: self and: other into: result.
	].
	((other isMemberOf: WordArray) or: [other isMemberOf: KedamaFloatArray]) ifTrue: [	
		^ self primLTArray: self and: other into: result.
	].
	^ super < other.

]

{ #category : #arithmetic }
KedamaFloatArray >> eToysNE: other [

	| result |
	result := ByteArray new: self size.
	other isNumber ifTrue: [
		^ self primNEScalar: self and: other into: result.
	].
	((other isMemberOf: WordArray) or: [other isMemberOf: KedamaFloatArray]) ifTrue: [	
		^ self primNEArray: self and: other into: result.
	].
	1 to: self size do: [:index |
		result at: index put: (self at: index) ~= (other at: index).
	].

]

{ #category : #primitives }
KedamaFloatArray >> primAddArray: rcvr and: other into: result [

	<primitive: 'primitiveAddArrays' module:'KedamaPlugin2'>
	"^ KedamaPlugin2 doPrimitive: #primitiveAddArrays."

	1 to: rcvr size do: [:i |
		result at: i put: (rcvr at: i) + (other at: i)
	].
	^ result.

]

{ #category : #primitives }
KedamaFloatArray >> primAddScalar: rcvr and: other into: result [

	<primitive: 'primitiveAddScalar' module:'KedamaPlugin2'>
	"^ KedamaPlugin2 doPrimitive: #primitiveAddScalar."

	1 to: rcvr size do: [:i |
		result at: i put: (rcvr at: i) + other.
	].
	^ result.

]

{ #category : #primitives }
KedamaFloatArray >> primDivArray: rcvr and: other into: result [

	<primitive: 'primitiveDivArrays' module:'KedamaPlugin2'>
	"^ KedamaPlugin2 doPrimitive: #primitiveDivArrays."

	1 to: rcvr size do: [:i |
		result at: i put: (rcvr at: i) / (other at: i)
	].
	^ result.

]

{ #category : #primitives }
KedamaFloatArray >> primDivScalar: rcvr and: other into: result [

	<primitive: 'primitiveDivScalar' module:'KedamaPlugin2'>
	"^ KedamaPlugin2 doPrimitive: #primitiveDivScalar."

	1 to: rcvr size do: [:i |
		result at: i put: (rcvr at: i) / other.
	].
	^ result.

]

{ #category : #primitives }
KedamaFloatArray >> primMulArray: rcvr and: other into: result [

	<primitive: 'primitiveMulArrays' module:'KedamaPlugin2'>
	"^ KedamaPlugin2 doPrimitive: #primitiveMulArrays."

	1 to: rcvr size do: [:i |
		result at: i put: (rcvr at: i) * (other at: i)
	].
	^ result.

]

{ #category : #primitives }
KedamaFloatArray >> primMulScalar: rcvr and: other into: result [

	<primitive: 'primitiveMulScalar' module:'KedamaPlugin2'>
	"^ KedamaPlugin2 doPrimitive: #primitiveMulScalar."

	1 to: rcvr size do: [:i |
		result at: i put: (rcvr at: i) * other.
	].
	^ result.

]

{ #category : #primitives }
KedamaFloatArray >> primSubArray: rcvr and: other into: result [

	<primitive: 'primitiveSubArrays' module:'KedamaPlugin2'>
	"^ KedamaPlugin2 doPrimitive: #primitiveSubArrays."

	1 to: rcvr size do: [:i |
		result at: i put: (rcvr at: i) - (other at: i)
	].
	^ result.

]

{ #category : #primitives }
KedamaFloatArray >> primSubScalar: rcvr and: other into: result [

	<primitive: 'primitiveSubScalar' module:'KedamaPlugin2'>
	"^ KedamaPlugin2 doPrimitive: #primitiveSubScalar."

	1 to: rcvr size do: [:i |
		result at: i put: (rcvr at: i) - other.
	].
	^ result.

]
