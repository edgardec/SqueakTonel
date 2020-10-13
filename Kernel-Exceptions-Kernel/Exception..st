"
This is the main class used to implement the exception handling system (EHS).  It plays two distinct roles:  that of the exception, and that of the exception handler.  More specifically, it implements the bulk of the protocols laid out in the ANSI specification - those protocol names are reflected in the message categories.

Exception is an abstract class.  Instances should neither be created nor trapped.  In most cases, subclasses should inherit from Error or Notification rather than directly from Exception.

In implementing this EHS, The Fourth Estate Inc. incorporated some ideas and code from Craig Latta's EHS.  His insights were crucial in allowing us to implement BlockClosure>>valueUninterruptably (and by extension, #ensure: and #ifCurtailed:), and we imported the following methods with little or no modification:

Context>>terminateTo:
Context>>terminate
Context>>receiver:
Context>>answer:

Thanks, Craig!
"
Class {
	#name : #Exception,
	#superclass : #Object,
	#instVars : [
		'messageText',
		'tag',
		'signalContext',
		'handlerContext',
		'outerContext'
	],
	#category : #'Kernel-Exceptions-Kernel'
}

{ #category : #exceptionSelector }
Exception class >> , anotherException [
	"Create an exception set."

	^ExceptionSet new
		add: self;
		add: anotherException;
		yourself
]

{ #category : #exceptionSelector }
Exception class >> handles: exception [
	"Determine whether an exception handler will accept a signaled exception."

	^ exception isKindOf: self
]

{ #category : #exceptionInstantiator }
Exception class >> signal [
	"Signal the occurrence of an exceptional condition."

	^ self new signal
]

{ #category : #exceptionInstantiator }
Exception class >> signal: signalerText [
	"Signal the occurrence of an exceptional condition with a specified textual description."

	^ self new signal: signalerText
]

{ #category : #'debug support' }
Exception >> canSearchForSignalerContext [
	"This method is /only/ to support the debugger's catching of exceptions in stepIntoBlock."
	^signalContext isContext
]

{ #category : #'priv handling' }
Exception >> defaultAction [
	"The default action taken if the exception is signaled."

	self subclassResponsibility
]

{ #category : #defaults }
Exception >> defaultResumeValue [
	"Answer the value that by default should be returned if the exception is resumed"
	^nil
]

{ #category : #defaults }
Exception >> defaultReturnValue [
	"Answer the value that by default should be returned if the exception is returned"
	^nil
]

{ #category : #printing }
Exception >> description [
	"Return a textual description of the exception."

	| desc mt |
	desc := self class name asString.
	^(mt := self messageText) == nil
		ifTrue: [desc]
		ifFalse: [desc, ': ', mt]
]

{ #category : #handling }
Exception >> isNested [
	"Determine whether the current exception handler is within the scope of another handler for the same exception."

	^ handlerContext nextHandlerContext canHandleSignal: self
]

{ #category : #'priv handling' }
Exception >> isResumable [
	"Determine whether an exception is resumable."

	^ true
]

{ #category : #printing }
Exception >> messageText [
	"Return an exception's message text."
	^ messageText ifNil: [ String empty ]
]

{ #category : #signaling }
Exception >> messageText: signalerText [
	"Set an exception's message text."

	messageText := signalerText
]

{ #category : #handling }
Exception >> outer [
	"Evaluate the enclosing exception action and return to here instead of signal if it resumes (see #resumeUnchecked:)."

	| prevOuterContext |
	self isResumable ifTrue: [
		prevOuterContext := outerContext.
		outerContext := thisContext contextTag.
	].
	self pass.

]

{ #category : #handling }
Exception >> pass [
	"Yield control to the enclosing exception action for the receiver."

	handlerContext nextHandlerContext handleSignal: self
]

{ #category : #printing }
Exception >> printDetailsOn: aStream [
	"Allow applications to optionally print extra details without overriding a base package."
]

{ #category : #printing }
Exception >> printOn: stream [

	stream nextPutAll: self description
]

{ #category : #'priv handling' }
Exception >> privHandlerContext: aContextTag [

	handlerContext := aContextTag
]

{ #category : #handling }
Exception >> rearmHandlerDuring: aBlock [
"Make the current error handler re-entrant while it is running aBlock. Only works in a closure-enabled image"

	^ handlerContext rearmHandlerDuring: aBlock
]

{ #category : #printing }
Exception >> receiver [

	^ self signalerContext receiver
]

{ #category : #handling }
Exception >> resignalAs: replacementException [
	"Signal an alternative exception in place of the receiver."

	self resumeUnchecked: replacementException signal
]

{ #category : #handling }
Exception >> resume [
	"Return from the message that signaled the receiver."

	self resume: self defaultResumeValue
]

{ #category : #handling }
Exception >> resume: resumptionValue [
	"Return resumptionValue as the value of the signal message."

	self isResumable ifFalse: [IllegalResumeAttempt signal].
	self resumeUnchecked: resumptionValue
]

{ #category : #handling }
Exception >> resumeUnchecked: resumptionValue [
	"Return resumptionValue as the value of #signal, unless this was called after an #outer message, then return resumptionValue as the value of #outer."

	| ctxt |
	outerContext ifNil: [
		signalContext return: resumptionValue
	] ifNotNil: [
		ctxt := outerContext.
		outerContext := ctxt tempAt: 1. "prevOuterContext in #outer"
		ctxt return: resumptionValue
	].

]

{ #category : #handling }
Exception >> retry [
	"Abort an exception handler and re-evaluate its protected block."

	handlerContext restart
]

{ #category : #handling }
Exception >> retryUsing: alternativeBlock [
	"Abort an exception handler and evaluate a new block in place of the handler's protected block."

	handlerContext restartWithNewReceiver: alternativeBlock

]

{ #category : #handling }
Exception >> return [
	"Return nil as the value of the block protected by the active exception handler."

	self return: self defaultReturnValue
]

{ #category : #handling }
Exception >> return: returnValue [
	"Return the argument as the value of the block protected by the active exception handler."

	handlerContext return: returnValue
]

{ #category : #handling }
Exception >> searchFrom: aContext [
	" Set the context where the handler search will start. "

	signalContext := aContext contextTag
]

{ #category : #signaling }
Exception >> signal [
	"Ask ContextHandlers in the sender chain to handle this signal.  The default is to execute and return my defaultAction."

	signalContext := thisContext contextTag.
	^ thisContext nextHandlerContext handleSignal: self
]

{ #category : #signaling }
Exception >> signal: signalerText [
	"Signal the occurrence of an exceptional condition with a specified textual description."

	self messageText: signalerText.
	^ self signal
]

{ #category : #handling }
Exception >> signalerContext [
	"Find the first sender of signal(:)"

	^ signalContext findContextSuchThat: [:ctxt |
		(ctxt receiver == self or: [ctxt receiver == self class]) not]
]

{ #category : #exceptionDescription }
Exception >> tag [
	"Return an exception's tag value."

	^tag == nil
		ifTrue: [self messageText]
		ifFalse: [tag]
]

{ #category : #exceptionBuilder }
Exception >> tag: t [
	"This message is not specified in the ANSI protocol, but that looks like an oversight because #tag is specified, and the spec states that the signaler may store the tag value."

	tag := t
]
