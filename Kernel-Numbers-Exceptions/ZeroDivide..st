"
ZeroDivide may be signaled when a mathematical division by 0 is attempted.
"
Class {
	#name : #ZeroDivide,
	#superclass : #ArithmeticError,
	#instVars : [
		'dividend'
	],
	#category : #'Kernel-Numbers-Exceptions'
}

{ #category : #exceptionInstantiator }
ZeroDivide class >> dividend: argument [
	^self new dividend: argument; yourself
]

{ #category : #signaling }
ZeroDivide class >> signalWithDividend: aDividend [

	^(self dividend: aDividend) signal
]

{ #category : #exceptionDescription }
ZeroDivide >> dividend [
	"Answer the number that was being divided by zero."

	^dividend
]

{ #category : #exceptionBuilder }
ZeroDivide >> dividend: argument [
	"Specify the number that was being divided by zero."

	dividend := argument
]

{ #category : #exceptionDescription }
ZeroDivide >> isResumable [
	"Determine whether an exception is resumable."

	^true
]
