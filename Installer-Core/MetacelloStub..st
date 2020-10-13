"
MetacelloStub is a loose reference to the class Metacello in its host repository.  It's kept at both its real name, #MetacelloStub, as well as the name #Metacello.  This is done to allow Squeak to respond to messages sent to Metacello (e.g., as referenced in external installation scripts), without the need to ship with Metacello pre-installed.
"
Class {
	#name : #MetacelloStub,
	#superclass : #Object,
	#category : #'Installer-Core'
}

{ #category : #overriding }
MetacelloStub class >> doesNotUnderstand: aMessage [
	"Handle any messages sent to Metacello class, too."
	Installer ensureRecentMetacello.
	^ aMessage sendTo: (Smalltalk classNamed: #Metacello)
]

{ #category : #'initialize-release' }
MetacelloStub class >> initialize [
	Smalltalk
		at: #Metacello
		ifAbsentPut: [ self ]
]

{ #category : #overriding }
MetacelloStub class >> isMetacelloConfig [
	"Sent during Metacello's bootstrap initialization to all classes in the system.  Respond false."
	^ false
]

{ #category : #overriding }
MetacelloStub class >> new [
	Installer ensureRecentMetacello.
	^ (Smalltalk at: #Metacello) new
]
