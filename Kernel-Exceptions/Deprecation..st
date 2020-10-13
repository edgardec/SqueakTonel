"
This Warning is signalled by methods which are deprecated.

The use of Object>>#deprecatedExplanation: aString and Object>>#deprecated: aBlock explanation: aString is recommended.

Idiom: Imagine I want to deprecate the message #foo.

foo
	^ 'foo'

I can replace it with:

foo
	self deprecatedExplanation: 'The method #foo was not good. Use Bar>>newFoo instead.'
	^ 'foo'

Or, for certain cases such as when #foo implements a primitive, #foo can be renamed to #fooDeprecated.

fooDeprecated
	^ <primitive>

foo
	^ self deprecated: [self fooDeprecated] explanation: 'The method #foo was not good. Use Bar>>newFoo instead.'

"
Class {
	#name : #Deprecation,
	#superclass : #Warning,
	#classVars : [
		'ShowDeprecationWarnings'
	],
	#category : #'Kernel-Exceptions'
}

{ #category : #preferences }
Deprecation class >> showDeprecationWarnings [
	<preference: 'Show deprecation warnings' category: 'debug' description: 'Warn the user when a deprecated method is used.' type: #Boolean>
	^ ShowDeprecationWarnings ifNil: [false]
]

{ #category : #preferences }
Deprecation class >> showDeprecationWarnings: aBoolean [
	ShowDeprecationWarnings := aBoolean.
]

{ #category : #'instance creation' }
Deprecation class >> signalForContext: context message: messageString explanation: explanationString [

	 | message |
	message := context method reference, ' has been deprecated', messageString, '.'.
	explanationString ifNotEmpty: [message := message, ' ', explanationString].
	self signal: message.
]

{ #category : #accessing }
Deprecation class >> suppressed [

	^ self showDeprecationWarnings not
]

{ #category : #accessing }
Deprecation class >> suppressed: aBoolean [

	self showDeprecationWarnings: aBoolean not.
	super suppressed: aBoolean.
]
