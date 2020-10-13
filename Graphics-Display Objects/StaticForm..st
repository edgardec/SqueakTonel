"
An optimization for Nebraska - a StaticForm does not change once created so it may be cached on the remote end.
"
Class {
	#name : #StaticForm,
	#superclass : #Form,
	#category : #'Graphics-Display Objects'
}

{ #category : #testing }
StaticForm >> isStatic [

	^true
]
