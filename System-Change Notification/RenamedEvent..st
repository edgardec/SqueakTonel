Class {
	#name : #RenamedEvent,
	#superclass : #AbstractEvent,
	#instVars : [
		'newName',
		'oldName'
	],
	#category : #'System-Change Notification'
}

{ #category : #accessing }
RenamedEvent class >> changeKind [

	^#Renamed
]

{ #category : #'instance creation' }
RenamedEvent class >> class: aClass category: cat oldName: oldName newName: newName [

	^(self class: aClass category: cat) oldName: oldName; newName: newName
]

{ #category : #'instance creation' }
RenamedEvent class >> classCategoryRenamedFrom: anOldClassCategoryName to: aNewClassCategoryName [

	^(self classCategory: anOldClassCategoryName) oldName: anOldClassCategoryName; newName: aNewClassCategoryName
]

{ #category : #accessing }
RenamedEvent class >> supportedKinds [
	"All the kinds of items that this event can take."
	
	^ Array with: self classKind with: self categoryKind with: self protocolKind
]

{ #category : #testing }
RenamedEvent >> isRenamed [

	^true
]

{ #category : #accessing }
RenamedEvent >> newName [
	^ newName
]

{ #category : #accessing }
RenamedEvent >> newName: aName [

	newName := aName
]

{ #category : #accessing }
RenamedEvent >> oldName [

	^oldName
]

{ #category : #accessing }
RenamedEvent >> oldName: aName [

	oldName := aName
]

{ #category : #printing }
RenamedEvent >> printEventKindOn: aStream [

	aStream nextPutAll: 'Renamed'
]
