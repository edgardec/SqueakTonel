Class {
	#name : #SAXDriver,
	#superclass : #LazyAttributeListSAXDriver,
	#category : #'XML-Parser'
}

{ #category : #'handling tokens' }
SAXDriver >> handleStartTag: elementName attributes: attributeList namespaces: namespaces [
	"Same as super, but will create and pass and empty Dictionary as attributeList if it is empty."

	| localName namespace namespaceURI |
	attributeList ifNotNil: [
		(attributeList includesKey: 'xml:lang') ifTrue: [
			languageEnvironment := LanguageEnvironment localeID: (LocaleID isoString: (attributeList at: 'xml:lang')) ] ].

	self usesNamespaces ifFalse: [
		"call the handler"
		self saxHandler
			checkEOD; 
			startElement: elementName namespaceURI: nil namespace: nil attributeList: (attributeList ifNil: [ Dictionary new ]).
		^self ].
	
	self scope enterScope.
	"declare any namespaces"
	namespaces ifNotNil: [
		namespaces keysAndValuesDo: [:ns :uri |
			self scope declareNamespace: ns uri: uri] ].

	self splitName: elementName into: [:ns :ln |
		namespace := ns.
		localName := ln].

	namespaceURI := self scope 
		namespaceURIOf: namespace
		ifAbsent: [self parseError: 'Start tag ' , elementName , ' refers to undefined namespace ' , namespace asString].

	attributeList ifNotNil: [
		self validatesAttributes ifTrue: [
			self scope validateAttributes: attributeList ] ].
	"call the handler"
	self saxHandler
		checkEOD; 
		startElement: localName namespaceURI: namespaceURI namespace: namespace attributeList: (attributeList ifNil: [ Dictionary new ])
]
