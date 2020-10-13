Class {
	#name : #ModifiedEvent,
	#superclass : #AbstractEvent,
	#instVars : [
		'oldItem'
	],
	#category : #'System-Change Notification'
}

{ #category : #accessing }
ModifiedEvent class >> changeKind [

	^#Modified
]

{ #category : #'instance creation' }
ModifiedEvent class >> classDefinitionChangedFrom: oldClass to: newClass [
	^ ModifiedClassDefinitionEvent classDefinitionChangedFrom: oldClass to: newClass
]

{ #category : #'instance creation' }
ModifiedEvent class >> methodChangedFrom: oldMethod to: newMethod selector: aSymbol inClass: aClass [
	| instance |
	instance := self method: newMethod selector: aSymbol class: aClass.
	instance oldItem: oldMethod.
	^ instance
]

{ #category : #'instance creation' }
ModifiedEvent class >> methodChangedFrom: oldMethod to: newMethod selector: aSymbol inClass: aClass requestor: requestor [
	| instance |
	instance := self method: newMethod selector: aSymbol class: aClass requestor: requestor.
	instance oldItem: oldMethod.
	^ instance
]

{ #category : #accessing }
ModifiedEvent class >> supportedKinds [
	"All the kinds of items that this event can take."
	
	^ Array with: self classKind with: self methodKind with: self categoryKind with: self protocolKind
]

{ #category : #testing }
ModifiedEvent >> isModified [

	^true
]

{ #category : #accessing }
ModifiedEvent >> oldItem [
	^ oldItem
]

{ #category : #'private-accessing' }
ModifiedEvent >> oldItem: anItem [
	oldItem := anItem
]

{ #category : #printing }
ModifiedEvent >> printEventKindOn: aStream [

	aStream nextPutAll: 'Modified'
]

{ #category : #printing }
ModifiedEvent >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: ' oldItem: ';
		print: oldItem.
]
