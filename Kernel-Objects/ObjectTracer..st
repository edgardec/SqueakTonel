"
An ObjectTracer can be wrapped around another object, and then give you a chance to inspect it whenever it receives messages from the outside.  For instance...
	(ObjectTracer on: Display) flash: (50@50 extent: 50@50)
will give control to a debugger just before the message flash is sent.
Obviously this facility can be embellished in many useful ways.
See also the even more perverse subclass, ObjectViewer, and its example.

"
Class {
	#name : #ObjectTracer,
	#superclass : #ProtoObject,
	#instVars : [
		'tracedObject',
		'recursionFlag'
	],
	#category : #'Kernel-Objects'
}

{ #category : #'instance creation' }
ObjectTracer class >> on: anObject [
	^ self new xxxViewedObject: anObject
]

{ #category : #'very few messages' }
ObjectTracer >> doesNotUnderstand: aMessage [ 
	"Present a debugger before proceeding to re-send the message"

	"All external messages (those not caused by the re-send) get trapped here"
	Processor activeProcess
		debugWithTitle: 'Object Tracer (', self identityHash, ')'
		full: false
		contents: ('On an instance of\	{1} ({2})\\About to perform\	{3}\\Using the following arguments\	{4}' translated withCRs
			format: {
				thisContext objectClass: tracedObject.
				tracedObject identityHash.
				aMessage selector storeString.
				aMessage arguments printString}).
		
	^ aMessage sendTo: tracedObject
]

{ #category : #'very few messages' }
ObjectTracer >> xxxUnTrace [

	tracedObject become: self
]

{ #category : #'very few messages' }
ObjectTracer >> xxxViewedObject [
	"This message name must not clash with any other (natch)."
	^ tracedObject
]

{ #category : #'very few messages' }
ObjectTracer >> xxxViewedObject: anObject [
	"This message name must not clash with any other (natch)."
	tracedObject := anObject
]
