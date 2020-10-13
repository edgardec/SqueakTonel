Class {
	#name : #EtoysUnhandledError,
	#superclass : #UnhandledError,
	#category : #'Etoys-Squeakland-System-Exceptions Kernel'
}

{ #category : #'priv handling' }
EtoysUnhandledError >> devDefaultAction [

	Processor activeProcess
		debug: exception signalerContext
		title: exception description
		full: false
		contents: exception messageText

]
