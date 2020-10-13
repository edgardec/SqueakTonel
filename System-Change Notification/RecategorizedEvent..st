Class {
	#name : #RecategorizedEvent,
	#superclass : #AbstractEvent,
	#instVars : [
		'oldCategory'
	],
	#category : #'System-Change Notification'
}

{ #category : #accessing }
RecategorizedEvent class >> changeKind [

	^#Recategorized
]

{ #category : #'instance creation' }
RecategorizedEvent class >> class: aClass category: cat oldCategory: oldName [

	^(self class: aClass category: cat) oldCategory: oldName
]

{ #category : #'instance creation' }
RecategorizedEvent class >> method: aMethod protocol: prot class: aClass oldProtocol: oldName [

	^(self method: aMethod protocol: prot class: aClass) oldCategory: oldName
]

{ #category : #'instance creation' }
RecategorizedEvent class >> selector: aSelector method: aMethod protocol: prot class: aClass oldProtocol: oldName [

	^(self method: aMethod protocol: prot class: aClass) 
		itemSelector: aSelector;
		oldCategory: oldName;
		yourself
]

{ #category : #accessing }
RecategorizedEvent class >> supportedKinds [

	^Array with: self classKind with: self methodKind
]

{ #category : #testing }
RecategorizedEvent >> isRecategorized [

	^true
]

{ #category : #accessing }
RecategorizedEvent >> oldCategory [

	^oldCategory
]

{ #category : #accessing }
RecategorizedEvent >> oldCategory: aCategoryName [

	oldCategory := aCategoryName
]

{ #category : #printing }
RecategorizedEvent >> printEventKindOn: aStream [

	aStream nextPutAll: 'Recategorized'
]
