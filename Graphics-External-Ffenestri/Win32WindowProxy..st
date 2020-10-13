Class {
	#name : #Win32WindowProxy,
	#superclass : #HostWindowProxy,
	#category : #'Graphics-External-Ffenestri'
}

{ #category : #'as yet unclassified' }
Win32WindowProxy class >> isActiveHostWindowProxyClass [
"Am I active?"
	^Smalltalk platformName  = 'Win32'
]

{ #category : #'window decorations' }
Win32WindowProxy >> defaultWindowType [
]
