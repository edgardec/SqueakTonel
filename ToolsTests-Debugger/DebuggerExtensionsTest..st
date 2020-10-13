Class {
	#name : #DebuggerExtensionsTest,
	#superclass : #TestCase,
	#category : #'ToolsTests-Debugger'
}

{ #category : #'tests - canonical argument names' }
DebuggerExtensionsTest >> testBooleansGeneralise [
	self assert: Boolean name equals: true canonicalArgumentName.
	self assert: Boolean name equals: false canonicalArgumentName
]

{ #category : #'tests - canonical argument names' }
DebuggerExtensionsTest >> testByteStringsGeneralise [
	self assert: String name equals: ByteString new canonicalArgumentName
]

{ #category : #'tests - canonical argument names' }
DebuggerExtensionsTest >> testClassesGeneralise [
	self assert: Class name equals: Class new canonicalArgumentName.
	self assert: Class name equals: 1 class canonicalArgumentName.
	self assert: Class name equals: true class canonicalArgumentName
]

{ #category : #'tests - canonical argument names' }
DebuggerExtensionsTest >> testCollectionsGeneralise [
	"ArrayedCollection and subclasses answer 'Array' "
	self assert: Array name equals: Array new canonicalArgumentName.
	"Otherwise answer the more general 'Collection' "
	self assert: Collection name equals: OrderedCollection new canonicalArgumentName.
	self assert: Collection name equals: LinkedList new canonicalArgumentName
]

{ #category : #'tests - canonical argument names' }
DebuggerExtensionsTest >> testFloatsGeneralise [
	self assert: Number name equals: 1.0 canonicalArgumentName
]

{ #category : #'tests - canonical argument names' }
DebuggerExtensionsTest >> testFractionsGeneralise [
	self assert: Number name equals: (1 / 2) canonicalArgumentName
]

{ #category : #'tests - canonical argument names' }
DebuggerExtensionsTest >> testIntegersDontGeneralise [
	self assert: Integer name equals: 1 canonicalArgumentName
]

{ #category : #'tests - canonical argument names' }
DebuggerExtensionsTest >> testLargeNegativeIntegersGeneralise [
	self assert: Integer name equals: LargeNegativeInteger initializedInstance canonicalArgumentName
]

{ #category : #'tests - canonical argument names' }
DebuggerExtensionsTest >> testLargePositiveIntegersGeneralise [
	self assert: Integer name equals: LargePositiveInteger initializedInstance canonicalArgumentName
]

{ #category : #'tests - canonical argument names' }
DebuggerExtensionsTest >> testOtherObjectsDontGeneralise [
	self assert: Behavior name equals: Behavior new canonicalArgumentName.
	self assert: UndefinedObject name equals: nil canonicalArgumentName
]

{ #category : #'tests - canonical argument names' }
DebuggerExtensionsTest >> testScaledDecimalsGeneralise [
	self assert: Number name equals: 2.00s2 canonicalArgumentName
]

{ #category : #'tests - canonical argument names' }
DebuggerExtensionsTest >> testStringsDontGeneralise [
	self assert: String name equals: String new canonicalArgumentName
]

{ #category : #'tests - canonical argument names' }
DebuggerExtensionsTest >> testWideStringsGeneralise [
	self assert: String name equals: WideString new canonicalArgumentName
]
