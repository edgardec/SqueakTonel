"
An alternative default handler that uses the file-list services to process files.

"
Class {
	#name : #DefaultExternalDropHandler,
	#superclass : #Object,
	#category : #'System-Support'
}

{ #category : #'class initialization' }
DefaultExternalDropHandler class >> initialize [
	"initialize the receiver"
	ExternalDropHandler defaultHandler: self new
]

{ #category : #'class initialization' }
DefaultExternalDropHandler class >> unload [
	"initialize the receiver"
	ExternalDropHandler defaultHandler: nil
]

{ #category : #private }
DefaultExternalDropHandler >> chooseServiceFrom: aCollection [
	"private - choose a service from aCollection asking the user if  needed"
	^aCollection size = 1 
		ifTrue: [aCollection anyOne]
		ifFalse:[UIManager default 
			chooseFrom: (aCollection collect:[:each| each label])
			values: aCollection
			title: 'You dropped a file. Please choose a service:' translated withCRs].
]

{ #category : #'event handling' }
DefaultExternalDropHandler >> handle: dropStream in: pasteUp dropEvent: anEvent [ 
	"the file was just droped, let's do our job"
	| fileName services chosen |
	fileName := dropStream name.
	services := self servicesForFileNamed: fileName.

	"no service, default behavior"
	services isEmpty 
		ifTrue: [^UIManager default edit: dropStream contentsOfEntireFile].

	chosen := self chooseServiceFrom: services.
	chosen ifNotNil:[chosen performServiceFor: dropStream]
]

{ #category : #private }
DefaultExternalDropHandler >> servicesForFileNamed: aString [ 
	"private - answer a collection of file-services for the file named  
	aString"
	| allServices |
	allServices := FileServices itemsForFile: aString.
	^ allServices
		reject: [:svc | self unwantedSelectors includes: svc selector]
]

{ #category : #private }
DefaultExternalDropHandler >> unwantedSelectors [
	"private - answer a collection well known unwanted selectors "
	^ #(#removeLineFeeds: #addFileToNewZip: #compressFile: #putUpdate: )
]
