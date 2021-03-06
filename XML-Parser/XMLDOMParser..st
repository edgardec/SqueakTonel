Class {
	#name : #XMLDOMParser,
	#superclass : #SAXHandler,
	#instVars : [
		'entity',
		'stack',
		'incremental'
	],
	#category : #'XML-Parser'
}

{ #category : #examples }
XMLDOMParser class >> addressBookXMLWithDTD [
	"XMLDOMParser addressBookXMLWithDTD"
	^self parseDocumentFrom: XMLTokenizer addressBookXMLWithDTD readStream useNamespaces: true
]

{ #category : #accessing }
XMLDOMParser class >> driverClass [

	^LazyAttributeListSAXDriver
]

{ #category : #'file reader services' }
XMLDOMParser class >> fileReaderServicesForFile: fullName suffix: suffix [

	" some known suffixes "
	^ ((#('xml' 'xsl' 'xhtml' 'sif' 'rss' 'atom' '*') includes: suffix) 
	or: [self looksLikeXML: fullName])
		ifFalse: [#()]
		ifTrue: [{self serviceExplore}]
]

{ #category : #'initialize-release' }
XMLDOMParser class >> initialize [
	"register the receiver in the global registries"
	self environment
		at: #FileServices
		ifPresent: [:cl | cl registerFileReader: self]
]

{ #category : #'file reader services' }
XMLDOMParser class >> looksLikeXML: fullName [

	[ | sample |
	FileStream readOnlyFileNamed: fullName do: 
		[:stream | 
			stream isBinary ifTrue: [^ false].
			sample := (stream next: 20) withBlanksTrimmed].
	 ^ sample first = $< 
		and: [ (#( $! $? $: $_ ) includes: sample second)
			or: [sample second isLetter]]
	] on: Error do: [^ false "backstop"]
]

{ #category : #'instance creation' }
XMLDOMParser class >> parseDocumentFrom: aStream [
	^self parseDocumentFrom: aStream useNamespaces: false
]

{ #category : #'instance creation' }
XMLDOMParser class >> parseDocumentFrom: aStream useNamespaces: aBoolean [
	^(super parseDocumentFrom: aStream useNamespaces: aBoolean) document
]

{ #category : #'file reader services' }
XMLDOMParser class >> serviceExplore [

	^ SimpleServiceEntry 
		provider: [:fullName | 
			(FileStream readOnlyFileNamed: fullName do: 
			[:file | self parseDocumentFrom: file useNamespaces: true]) explore]
		label: 'explore XML'
		selector: #value:
		description: 'read and parse the file and explore its XML structure'
		buttonLabel: 'explore'
]

{ #category : #'initialize-release' }
XMLDOMParser class >> unload [
	"Unload the receiver from global registries"
	self environment
		at: #FileServices
		ifPresent: [:cl | cl unregisterFileReader: self]
]

{ #category : #content }
XMLDOMParser >> characters: aString [
	| newElement |
	newElement := XMLStringNode string: aString.
	self top addContent: newElement.

]

{ #category : #private }
XMLDOMParser >> defaultNamespace [
	^self top
		ifNotNil: [self top namespace]
]

{ #category : #content }
XMLDOMParser >> documentAttributes: attributeList [
	self document version: (attributeList at: 'version' ifAbsent: [nil]).
	self document encoding: (attributeList at: 'encoding' ifAbsent: [nil]).
	self document requiredMarkup: (attributeList at: 'requiredMarkup' ifAbsent: [nil]).

]

{ #category : #parsing }
XMLDOMParser >> domDocument [
	[self startDocument; parseDocument]
		ensure: [self driver stream close].
	^document
]

{ #category : #content }
XMLDOMParser >> endDocument [
	self pop.
	super endDocument
]

{ #category : #content }
XMLDOMParser >> endElement: elementName [
	| currentElement |
	currentElement := self pop.
	currentElement name = elementName
		ifFalse: [self driver errorExpected: 'End tag "', elementName , '" doesn''t match "' , currentElement name , '".']
]

{ #category : #content }
XMLDOMParser >> endElement: localName namespace: namespace namespaceURI: uri qualifiedName: qualifiedName [
	| currentElement |
	currentElement := self pop.
	(currentElement namespace isNil
		or: [currentElement namespace = self defaultNamespace])
		ifTrue: [
			currentElement localName = localName
				ifFalse: [self driver errorExpected: 'End tag "', localName , '" doesn''t match "' , currentElement localName  , '".']]
		ifFalse: [
			currentElement qualifiedName = qualifiedName
				ifFalse: [self driver errorExpected: 'End tag "', qualifiedName , '" doesn''t match "' , currentElement qualifiedName  , '".']]
]

{ #category : #accessing }
XMLDOMParser >> incremental [
	^incremental
]

{ #category : #accessing }
XMLDOMParser >> incremental: aBoolean [
	incremental := aBoolean
]

{ #category : #initialize }
XMLDOMParser >> initialize [
	super initialize.
	stack := OrderedCollection new.
	incremental := false
]

{ #category : #parsing }
XMLDOMParser >> nextEntity [
	| currentTop |
	currentTop := self top.
	[self driver nextEntity isNil
		or: [self top ~~ currentTop]] whileTrue.
	^entity
]

{ #category : #parsing }
XMLDOMParser >> nextEntityStart [
	[self driver nextEntity.
	self stack isEmpty] whileTrue.
	^entity
]

{ #category : #private }
XMLDOMParser >> pop [
	| oldTop |
	oldTop := self stack removeLast.
	entity := oldTop.
	^oldTop
]

{ #category : #content }
XMLDOMParser >> processingInstruction: piName data: dataString [
	| newElement |
	newElement := XMLPI target: piName data: dataString.
	self top addElement: newElement
]

{ #category : #private }
XMLDOMParser >> push: anObject [
	self stack add: anObject.
	entity := anObject

]

{ #category : #private }
XMLDOMParser >> stack [
	^stack
]

{ #category : #content }
XMLDOMParser >> startDocument [
	self document: XMLDocument new.
	self push: self document 
]

{ #category : #content }
XMLDOMParser >> startElement: elementName attributeList: attributeList [
	| newElement |
	newElement := XMLElement named: elementName attributes: attributeList.
	self incremental
		ifFalse: [self stack isEmpty
			ifFalse: [self top addElement: newElement]].
	self push: newElement
]

{ #category : #content }
XMLDOMParser >> startElement: localName namespaceURI: namespaceUri namespace: namespace attributeList: attributeList [
	| newElement |
	"newElement := namespace = self defaultNamespace
		ifTrue: [XMLElement named: localName namespace: nil uri: nil attributes: attributeList]
		ifFalse: [XMLElement named: localName namespace: namespace uri: namespaceUri attributes: attributeList]."
	newElement := XMLElement named: localName namespace: namespace uri: namespaceUri attributes: attributeList.
	self incremental
		ifFalse: [self stack isEmpty
			ifFalse: [self top addElement: newElement]].
	self push: newElement
]

{ #category : #private }
XMLDOMParser >> top [
	^self stack isEmpty
		ifTrue: [nil]
		ifFalse: [self stack last]
]
