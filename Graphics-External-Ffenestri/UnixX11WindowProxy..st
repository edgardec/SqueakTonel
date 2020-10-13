Class {
	#name : #UnixX11WindowProxy,
	#superclass : #HostWindowProxy,
	#category : #'Graphics-External-Ffenestri'
}

{ #category : #'as yet unclassified' }
UnixX11WindowProxy class >> isActiveHostWindowProxyClass [
"Am I active?"
	^Smalltalk platformName = 'unix' 
]

{ #category : #'window decorations' }
UnixX11WindowProxy >> defaultWindowType [
]
