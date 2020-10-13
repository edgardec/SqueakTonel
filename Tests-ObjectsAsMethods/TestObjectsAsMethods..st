Class {
	#name : #TestObjectsAsMethods,
	#superclass : #TestCase,
	#category : #'Tests-ObjectsAsMethods'
}

{ #category : #running }
TestObjectsAsMethods >> setUp [
	SystemChangeNotifier uniqueInstance doSilently: [
		self class addSelector: #add:with: withMethod: ObjectsAsMethodsExample new.
		self class addSelector: #answer42 withMethod: ObjectsAsMethodsExample new.
		self class addSelector: #foo withMethod: AbstractObjectsAsMethod new ]
]

{ #category : #running }
TestObjectsAsMethods >> tearDown [
	SystemChangeNotifier uniqueInstance doSilently: [
		self class removeSelector: #add:with:.
		self class removeSelector: #answer42.
		self class removeSelector: #foo ]
]

{ #category : #tests }
TestObjectsAsMethods >> testAddNumbers [
	self assert: (self add: 3 with: 4) = 7.
	self assert: (self perform: #add:with: withArguments: #(3 4)) = 7.
]

{ #category : #tests }
TestObjectsAsMethods >> testAnswer42 [ 
	self assert: self answer42 = 42
]

{ #category : #tests }
TestObjectsAsMethods >> testDNU [ 
	self should: [self foo] raise: MessageNotUnderstood
]
