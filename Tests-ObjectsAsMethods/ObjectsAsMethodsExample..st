Class {
	#name : #ObjectsAsMethodsExample,
	#superclass : #AbstractObjectsAsMethod,
	#category : #'Tests-ObjectsAsMethods'
}

{ #category : #'example methods' }
ObjectsAsMethodsExample >> add: a with: b [
	^a + b
]

{ #category : #'example methods' }
ObjectsAsMethodsExample >> answer42 [
	^42
]

{ #category : #'example methods' }
ObjectsAsMethodsExample >> run: oldSelector with: arguments in: aReceiver [
	^self perform: oldSelector withArguments: arguments
]
