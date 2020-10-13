"
RecentMessagesTest uses me to show how it behaves when recent submissions contain references to methods in classes no longer in the image.
"
Class {
	#name : #FakeObjectOut,
	#superclass : #Object,
	#category : #'Tests-System-Support'
}

{ #category : #'error handling' }
FakeObjectOut >> doesNotUnderstand: aMessage [
	^ aMessage sendTo: self class 
]

{ #category : #testing }
FakeObjectOut >> isInMemory [
	^ false.
]
