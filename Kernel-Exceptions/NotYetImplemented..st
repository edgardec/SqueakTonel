"
Sent by #notYetImplemented.  Better than the age-old behavior of opening a notifier window, because this can be caught and handled.

"
Class {
	#name : #NotYetImplemented,
	#superclass : #NotImplemented,
	#instVars : [
		'receiverClass',
		'selector',
		'context'
	],
	#category : #'Kernel-Exceptions'
}

{ #category : #signaling }
NotYetImplemented class >> signal [
	"Call only from #notYetImplemented.  Find the context that sent #nYI... this is the method that needs to be implemented."
	| ctxt ex |
	ctxt := thisContext sender sender.
	ex := self new.
	ex receiverClass: ctxt receiver class selector: ctxt selector.
	ex messageText: ctxt printString.
	ex signal.
		
]

{ #category : #accessing }
NotYetImplemented >> receiverClass [
	^receiverClass
]

{ #category : #initialize }
NotYetImplemented >> receiverClass: cls selector: sel [
	receiverClass := cls.
	selector := sel.
]

{ #category : #accessing }
NotYetImplemented >> selector [
	^selector
]
