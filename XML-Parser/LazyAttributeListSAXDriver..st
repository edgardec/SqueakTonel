Class {
	#name : #LazyAttributeListSAXDriver,
	#superclass : #XMLTokenizer,
	#instVars : [
		'saxHandler',
		'scope',
		'useNamespaces',
		'validateAttributes',
		'languageEnvironment'
	],
	#category : #'XML-Parser'
}

{ #category : #'handling tokens' }
LazyAttributeListSAXDriver >> handleCData: aString [
	self saxHandler
		checkEOD; 
		characters: aString
]

{ #category : #'handling tokens' }
LazyAttributeListSAXDriver >> handleComment: aString [
	self saxHandler
		checkEOD; 
		comment: aString
]

{ #category : #'handling tokens' }
LazyAttributeListSAXDriver >> handleEndDocument [
	self saxHandler endDocument
]

{ #category : #'handling tokens' }
LazyAttributeListSAXDriver >> handleEndTag: elementName [
	| namespace localName namespaceURI qualifiedName |

	self usesNamespaces
		ifTrue: [
			self splitName: elementName into: [:ns :ln |
				namespace := ns.
				localName := ln].

			"ensure our namespace is defined"
			namespace
				ifNil: [
					namespace := self scope defaultNamespace.
					qualifiedName := namespace , ':' , elementName]
				ifNotNil: [
					namespaceURI := self scope namespaceURIOf: namespace.
					namespaceURI
						ifNil: [self parseError: 'Start tag ' , elementName , ' refers to undefined namespace ' , namespace asString].
					qualifiedName := elementName].

			"call the handler"
			self saxHandler
				checkEOD; 
				endElement: localName namespace: namespace namespaceURI: namespaceURI qualifiedName: qualifiedName.
			self scope leaveScope]
		ifFalse: [
			"call the handler"
			self saxHandler
				checkEOD; 
				endElement: elementName namespace: nil namespaceURI: nil qualifiedName: elementName]
]

{ #category : #'handling tokens' }
LazyAttributeListSAXDriver >> handlePCData: aString [
	self languageEnvironment
		ifNotNil: [aString applyLanguageInformation: self languageEnvironment].
	self saxHandler
		checkEOD; 
		characters: aString
]

{ #category : #'handling tokens' }
LazyAttributeListSAXDriver >> handlePI: piTarget data: piData [
	self saxHandler
		checkEOD; 
		processingInstruction: piTarget data: piData
]

{ #category : #'handling tokens' }
LazyAttributeListSAXDriver >> handleStartDocument [
	self saxHandler startDocument
]

{ #category : #'handling tokens' }
LazyAttributeListSAXDriver >> handleStartTag: elementName attributes: attributeList namespaces: namespaces [

	| localName namespace namespaceURI |
	attributeList ifNotNil: [
		(attributeList includesKey: 'xml:lang') ifTrue: [
			languageEnvironment := LanguageEnvironment localeID: (LocaleID isoString: (attributeList at: 'xml:lang')) ] ].

	self usesNamespaces ifFalse: [
		"call the handler"
		self saxHandler
			checkEOD; 
			startElement: elementName namespaceURI: nil namespace: nil attributeList: attributeList.
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
		startElement: localName namespaceURI: namespaceURI namespace: namespace attributeList: attributeList
]

{ #category : #'handling tokens' }
LazyAttributeListSAXDriver >> handleWhitespace: aString [
	self saxHandler
		checkEOD; 
		ignorableWhitespace: aString
]

{ #category : #'handling tokens' }
LazyAttributeListSAXDriver >> handleXMLDecl: attributes namespaces: namespaces [
	self saxHandler
		checkEOD; 
		documentAttributes: attributes.
	self usesNamespaces
		ifTrue: [
			namespaces keysAndValuesDo: [:ns :uri |
				self scope declareNamespace: ns uri: uri]]
]

{ #category : #initialization }
LazyAttributeListSAXDriver >> initialize [
	super initialize.
	useNamespaces := false.
	validateAttributes := false
]

{ #category : #accessing }
LazyAttributeListSAXDriver >> languageEnvironment [
	^languageEnvironment
]

{ #category : #accessing }
LazyAttributeListSAXDriver >> saxHandler [
	^saxHandler
]

{ #category : #accessing }
LazyAttributeListSAXDriver >> saxHandler: aHandler [
	saxHandler := aHandler
]

{ #category : #namespaces }
LazyAttributeListSAXDriver >> scope [
	scope ifNil: [scope := XMLNamespaceScope new].
	^scope
]

{ #category : #namespaces }
LazyAttributeListSAXDriver >> splitName: aName into: twoArgsBlock [
	"Split the name into namespace and local name (the block arguments).
	Handle both qualified and unqualified names using the default name space"

	| i ns ln |
	i := aName lastIndexOf: $:.
	i = 0
		ifTrue: [
			ns := nil.
			ln := aName]
		ifFalse: [
			ns := aName copyFrom: 1 to: (i - 1).
			ln := aName copyFrom: i+1 to: aName size].
	twoArgsBlock value: ns value: ln
]

{ #category : #accessing }
LazyAttributeListSAXDriver >> useNamespaces: aBoolean [
	useNamespaces := aBoolean
]

{ #category : #testing }
LazyAttributeListSAXDriver >> usesNamespaces [
	^useNamespaces
]

{ #category : #testing }
LazyAttributeListSAXDriver >> validatesAttributes [
	^validateAttributes
]
