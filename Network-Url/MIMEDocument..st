"
a MIME object, along with its type and the URL it was found at (if any)

Design decisions:
- The API for using the content of the MIME object inside Squeak returns Strings 
in Squeak encoding. The serializing methods return the content serialized according 
to the content-type and content-transfer-encoding --pre
"
Class {
	#name : #MIMEDocument,
	#superclass : #Object,
	#instVars : [
		'mainType',
		'subType',
		'content',
		'fields',
		'url',
		'parts'
	],
	#classVars : [
		'MIMEdatabase'
	],
	#category : #'Network-Url'
}

{ #category : #'instance creation' }
MIMEDocument class >> content: aString [
	^self contentType: self defaultContentType  content: aString
]

{ #category : #'instance creation' }
MIMEDocument class >> contentType: aString content: content [
	"create a MIMEObject with the given content-type and content"
	"MIMEDocument contentType: 'text/plain' content: 'This is a test'"
	
	| ans |
	
	ans := self new.

	ans contentTypeHeaderValue: (MIMEHeaderValue fromMIMEHeader: aString).

	(ans isPlaintext or: [ans isHTML])
		ifTrue:  [ans content: (self tryToDecodeBody: content as: ans charset)]
		ifFalse: [ans isMultipart
					ifTrue: [| separator |
						separator := ans attachmentSeparator asLowercase.
						separator ifNil: [self error: 'Bad attachment separater'].

						separator := '--', separator withoutTrailingBlanks.
						ans addAllParts: (self parseParts: content withSeparator:separator).]
					ifFalse: [ans content: content]].
		
	^ ans

]

{ #category : #'instance creation' }
MIMEDocument class >> contentType: aString  content: content  url: aUrl [
	"create a MIMEObject with the given content-type and content"
	"MIMEObject contentType: 'text/plain' content: 'This is a test'"
	
	| ans |
	ans := self contentType: aString content: content.
	ans privateUrl: aUrl asUrl.
	^ans

]

{ #category : #'content-types' }
MIMEDocument class >> contentTypeBinaryData [
	^'application/octet-stream'
]

{ #category : #'content-types' }
MIMEDocument class >> contentTypeFormData [
	^'application/x-www-form-urlencoded'
]

{ #category : #'content-types' }
MIMEDocument class >> contentTypeHtml [
	^'text/html'
]

{ #category : #'content-types' }
MIMEDocument class >> contentTypeMultipart [
	^'multipart/form-data'
]

{ #category : #'content-types' }
MIMEDocument class >> contentTypeMultipartAlternative [
	^'multipart/alternative'
]

{ #category : #'content-types' }
MIMEDocument class >> contentTypeMultipartMixed [
	^'multipart/mixed'
]

{ #category : #'content-types' }
MIMEDocument class >> contentTypePlainText [
	^'text/plain'
]

{ #category : #'content-types' }
MIMEDocument class >> contentTypeXml [
	^'text/xml'
]

{ #category : #'content-types' }
MIMEDocument class >> defaultContentType [
	^ self contentTypeBinaryData
]

{ #category : #'initialize-release' }
MIMEDocument class >> defaultMIMEdatabase [
	| d |
	(d := Dictionary new)
	at: 'html' put: 'text/html';
	at: 'htm' put: 'text/html';
	at: 'xml' put: 'text/xml';
	at: 'txt' put: 'text/plain';
	at: 'c' put: 'text/plain';
	at: 'gif' put: 'image/gif';
	at: 'jpg' put: 'image/jpeg';
	at: 'jpeg' put: 'image/jpeg';
	at: 'gif' put: 'image/gif';
	at: 'png' put: 'image/png';
	at: 'pnm' put: 'image/pnm';
	at: 'xbm' put: 'image/x-xbitmap';
	at: 'mid' put: 'audio/midi';
	at: 'doc' put: 'application/ms-word-document'.
	^d
]

{ #category : #'initialize-release' }
MIMEDocument class >> extendedMIMEdatabase [
	| d |
	(d := self defaultMIMEdatabase) 
		 at: 'hqx' put: 'application/mac-binhex40';
		 at: 'cpt' put: 'application/mac-compactpro';
		 at: 'pdf' put: 'application/pdf';
		 at: 'ps' put: 'application/postscript';
		 at: 'ai' put: 'application/postscript';
		 at: 'eps' put: 'application/postscript';
		 at: 'rtf' put: 'text/rtf';
		 at: 'ics' put: 'text/calendar';
		 at: 'bin' put: 'application/octet-stream';
		 at: 'dms' put: 'application/octet-stream';
		 at: 'lha' put: 'application/octet-stream';
		 at: 'lzh' put: 'application/octet-stream';
		 at: 'exe' put: 'application/octet-stream';
		 at: 'class' put: 'application/octet-stream';
		 at: 'zip' put: 'application/zip';
		 at: 'gtar' put: 'application/x-gtar';
		 at: 'swf' put: 'application/x-shockwave-flash';
		 at: 'sit' put: 'application/x-stuffit';
		 at: 'tar' put: 'application/x-tar';
		 at: 'au' put: 'audio/basic';
		 at: 'snd' put: 'audio/basic';
		 at: 'mid' put: 'audio/midi';
		 at: 'midi' put: 'audio/midi';
		 at: 'mpga' put: 'audio/mpeg';
		 at: 'mp2' put: 'audio/mpeg';
		 at: 'mp3' put: 'audio/mpeg';
		 at: 'aiff' put: 'audio/x-aiff';
		 at: 'aif' put: 'audio/x-aiff';
		 at: 'aifc' put: 'audio/x-aiff';
		 at: 'rm' put: 'audio/x-pn-realaudio';
		 at: 'ram' put: 'audio/x-pn-realaudio';
		 at: 'rpm' put: 'audio/x-pn-realaudio-plugin';
		 at: 'ra' put: 'audio/x-realaudio';
		 at: 'wav' put: 'audio/x-wav';
		 at: 'css' put: 'text/css';
		 at: 'mpeg' put: 'video/mpeg';
		 at: 'mpg' put: 'video/mpeg';
		 at: 'mpe' put: 'video/mpeg';
		 at: 'qt' put: 'video/quicktime';
		 at: 'mov' put: 'video/quicktime';
		 at: 'avi' put: 'video/x-msvideo';
		 at: 'movie' put: 'video/x-sgi-movie'.
	^ d
]

{ #category : #'instance creation' }
MIMEDocument class >> fromPartString: aString [
	"This method allows for easy creation of MIME documents 
	representing parts in a multipart MIME document"
	
	^ self new initializeFromString: aString
]

{ #category : #'content-types' }
MIMEDocument class >> guessTypeFromExtension: ext [
	"guesses a content type from the extension"
	| extension |
	extension := ext asString.
	(extension includes: $.) ifTrue: [ ^self defaultContentType].

	MIMEdatabase ifNil: [self resetMIMEdatabase].
	^ MIMEdatabase at: extension ifAbsent: [self defaultContentType].
]

{ #category : #'content-types' }
MIMEDocument class >> guessTypeFromName: url [
	"guesses a content type from the url"
	| extension |
	extension := url asString.
	(extension includes: $.) ifFalse: [ ^self defaultContentType].

	extension := (extension findTokens: '.') last asLowercase.

	MIMEdatabase ifNil: [self resetMIMEdatabase].
	^ MIMEdatabase at: extension ifAbsent: [self defaultContentType].

]

{ #category : #'content-types' }
MIMEDocument class >> linkExtension: ext toType: mimeType [
	MIMEdatabase at: ext asString put: mimeType asString
]

{ #category : #'instance creation' }
MIMEDocument class >> newMultipart [

	| ans |
	
	ans := self new.

	ans contentTypeHeaderValue: (MIMEHeaderValue fromMIMEHeader: self contentTypeMultipartMixed).
	ans contentTypeHeaderValue parameterAt: 'boundary' put: MailMessage generateSeparator.

	^ ans
]

{ #category : #'instance creation' }
MIMEDocument class >> parseParts: bodyText withSeparator: separator [
	"private -- parse the parts of the message and store them into a collection"

	| parseStream msgStream messages  normalizedSeparator |
	
	parseStream := ReadStream on: bodyText.
	
	msgStream := LimitingLineStreamWrapper on: parseStream delimiter: separator.
	normalizedSeparator := separator asLowercase.
	msgStream limitingBlock: [:aLine | | normalizedLine |
		normalizedLine := aLine withoutTrailingBlanks asLowercase.
		normalizedLine = normalizedSeparator or:	"Match the separator"
		[normalizedLine = ('--',normalizedSeparator)] or:	"or -- and the separator"	
		[normalizedLine = (normalizedSeparator, '--')]].	"or the final separator with --"

	"Throw away everything up to and including the first separator"
	msgStream upToEnd.
	msgStream skipThisLine.

	"Extract each of the multi-parts as strings"
	messages := OrderedCollection new.
	[parseStream atEnd]
		whileFalse: 
			[messages add: msgStream upToEnd.
			msgStream skipThisLine].

	^ messages collect: [:e | MIMEDocument fromPartString: e]
]

{ #category : #'initialize-release' }
MIMEDocument class >> readMIMEdatabaseFrom: someStream [
	| d line tokens stream |
	"type/subtype    extension"
	"white spaces are separators"
	"apache conf file format: mime.types"

	"must normalize line endings"
	stream := ReadStream on: someStream contentsOfEntireFile withSqueakLineEndings.

	d := Dictionary new.
	[(line := stream nextLine) isNil not]
		whileTrue: [tokens := line findTokens: ' 	'.
			(tokens size = 2 and: [line first ~= $#])
				ifTrue: [d at: tokens second put: tokens first]].
	^d
]

{ #category : #'initialize-release' }
MIMEDocument class >> resetMIMEdatabase [
	MIMEdatabase := self extendedMIMEdatabase
]

{ #category : #'instance creation' }
MIMEDocument class >> tryToDecodeBody: content as: encodingName [

	^ [(MultiByteBinaryOrTextStream 
		with: content 
		encoding: encodingName) contents]
			on: InvalidUTF8 , NoConverterFound do: [(MultiByteBinaryOrTextStream 
										with: content 
										encoding: 'latin1') contents]
]

{ #category : #'instance creation' }
MIMEDocument class >> tryToEncodeBody: content as: encodingName [

	^ content convertToEncoding: encodingName
]

{ #category : #parts }
MIMEDocument >> addAllParts: MIMEDocuments [

	parts addAll: MIMEDocuments
]

{ #category : #parts }
MIMEDocument >> addPart: aMIMEDocument [

	parts add: aMIMEDocument
]

{ #category : #serializing }
MIMEDocument >> asSendableBodyText [

	| sendableBodyText |
	sendableBodyText := self isMultipart
		ifTrue: [self sendableMultipartBodyText]
		ifFalse: [(self isPlaintext or: [self isHTML]) 
					ifTrue: [self class tryToEncodeBody: self contents as: self charset]
					ifFalse: [self contents]].
	
	^ (self hasFieldNamed: 'content-transfer-encoding')
		ifFalse: [sendableBodyText]
		ifTrue: [ | transferEncoding |
			transferEncoding := self contentTransferEncoding.
			(MimeConverter forEncoding: transferEncoding) mimeEncode: sendableBodyText readStream ]  
]

{ #category : #serializing }
MIMEDocument >> asSendablePartText [

	^ String streamContents: [ :str | | |
		"first put the header"
		fields keysAndValuesDo: [ :fieldName :fieldValues |
			fieldValues do: [ :fieldValue |
				str
					nextPutAll: fieldName capitalized ;
					nextPutAll: ': ';
					nextPutAll: fieldValue asHeaderValue;
					cr ]. ].
			
		str cr.
			
		str nextPutAll: self asSendableBodyText].
]

{ #category : #accessing }
MIMEDocument >> attachmentFileName [

	^ (self fieldNamed: 'content-disposition' ifAbsent: [^ ''])
		parameterAt: 'filename' ifAbsent: ['']  
]

{ #category : #accessing }
MIMEDocument >> attachmentSeparator [
	^(self fieldNamed: 'content-type' ifAbsent: [^nil]) parameters
		at: 'boundary' ifAbsent: [^nil]
]

{ #category : #serializing }
MIMEDocument >> bodyTextFormatted [
	"Answer a version of the text in my body suitable for display.  This will parse multipart forms, decode HTML, and other such things"

	self isMultipart ifTrue: [
		self isMultipartAlternative ifTrue: [
			"it's multipart/alternative.  search for a part that we can display, biasing towards simpler formats"
			#('text/plain' 'text/html') do: [ :format |
				self parts do: [ :part |
					part contentType = format ifTrue: [ ^ part bodyTextFormatted ] ] ].

			"couldn't find a desirable part to display; just display the first part"
			^self parts first bodyTextFormatted ].

		"not alternative parts.  put something for each part"
		^Text streamContents: [ :str |
			self parts do: [ :part |
				((#('text' 'multipart') includes: part mainType) or: 
					[ part contentType = 'message/rfc822'])
				ifTrue: [
					"try to inline the message part"
					str nextPutAll: part bodyTextFormatted. ]
				ifFalse: [ 
					|descript |
					str cr.
					descript := part name ifNil: [ 'attachment' ].
					str nextPutAll: (Text string: '[', descript, ']'  attribute: (TextMessageLink message: part)). ] ] ]. ].


	"check for HTML"
	(self contentType = 'text/html') ifTrue: [
		Smalltalk at: #HtmlParser ifPresent: [ :htmlParser |
			^(htmlParser parse: (ReadStream on: self content)) formattedText].
		Smalltalk at: #HtmlReadWriter ifPresent: [:html |
			^ self content asTextFromHtml]
	].

	"check for an embedded message"
	self contentType = 'message/rfc822' ifTrue: [
		^(MailMessage from: self content) formattedText ].

	"nothing special--just return the text"
	^self content.

]

{ #category : #accessing }
MIMEDocument >> charset [

	^ self contentTypeHeaderValue parameterAt: #charset ifAbsent: ['us-ascii']
]

{ #category : #accessing }
MIMEDocument >> charset: aString [

	^ self contentTypeHeaderValue parameterAt: #charset put: aString
]

{ #category : #testing }
MIMEDocument >> containsViewableImage [

	^ self isJpeg or: [self isGif or: [self isPng]]
]

{ #category : #accessing }
MIMEDocument >> content [
	"Answer the receiver's raw data."
	
	^ content
]

{ #category : #accessing }
MIMEDocument >> content: aString [
	content := aString
]

{ #category : #accessing }
MIMEDocument >> contentStream [
	"Answer a RWBinaryOrTextStream on the contents."

	^ (RWBinaryOrTextStream with: self content) reset
]

{ #category : #accessing }
MIMEDocument >> contentTransferEncoding [

	^ self contentTransferEncodingHeaderValue mainValue
]

{ #category : #accessing }
MIMEDocument >> contentTransferEncodingHeaderValue [

	^ self fieldNamed: 'content-transfer-encoding' ifAbsent: [nil]
]

{ #category : #accessing }
MIMEDocument >> contentType [

	^ self contentTypeHeaderValue mainValue
]

{ #category : #accessing }
MIMEDocument >> contentTypeHeaderValue [

	^ self fieldNamed: 'content-type' ifAbsent: [self error: 'MIMEDocument requires a content-type field']
]

{ #category : #accessing }
MIMEDocument >> contentTypeHeaderValue: aMIMEHeaderValue [

	^ self setField: 'content-type' to: aMIMEHeaderValue
]

{ #category : #accessing }
MIMEDocument >> contents [
	"Compatibility with stream protocol"
	^self content
]

{ #category : #fields }
MIMEDocument >> fieldNamed: aString ifAbsent: aBlock [
	| matchingFields |
	"return the value of the field with the specified name.  If there is more than one field, then return the first one"
	matchingFields := fields at: aString asLowercase ifAbsent: [ ^aBlock value ].
	^matchingFields first
]

{ #category : #fields }
MIMEDocument >> fieldsFrom: aStream do: aBlock [
	"Invoke the given block with each of the header fields from the given stream. The block arguments are the field name and value. The streams position is left right after the empty line separating header and body.
	Duplicate of code in MailMessage"

	| savedLine line s |
	savedLine := aStream nextLine.
	[aStream atEnd] whileFalse: [
		line := savedLine.
		(line isEmpty) ifTrue: [^self].  "quit when we hit a blank line"
		[savedLine := aStream nextLine.
		 savedLine notNil and: [savedLine notEmpty] and: [savedLine first isSeparator]] whileTrue: [
			"lines starting with white space are continuation lines"
			s := ReadStream on: savedLine.
			s skipSeparators.
			line := line, ' ', s upToEnd].
		self reportField: line withBlanksTrimmed to: aBlock].

	"process final header line of a body-less message"
	(savedLine isEmpty) ifFalse: [self reportField: savedLine withBlanksTrimmed to: aBlock].

]

{ #category : #fields }
MIMEDocument >> hasFieldNamed: aString [
	^fields includesKey: aString asLowercase
]

{ #category : #testing }
MIMEDocument >> initialize [

	parts := OrderedCollection new.
	fields := Dictionary new.
	self setField: 'content-type' toString: self class defaultContentType.
]

{ #category : #'initialize-release' }
MIMEDocument >> initializeFromString: aString [
	"This can only be used for MIME documents which are not multipart."

	| parseStream contentType bodyText contentTransferEncoding text |

	text := aString withoutTrailingBlanks, String cr, String cr.
	parseStream := ReadStream on: text.
	contentType := 'text/plain'.
	contentTransferEncoding := nil.
	fields := Dictionary new.

	"Extract information out of the header fields"
	self fieldsFrom: parseStream do: 
		[:fName :fValue | 
		"NB: fName is all lowercase"

		fName = 'content-type' ifTrue: [contentType := fValue asLowercase].
		fName = 'content-transfer-encoding' ifTrue: [contentTransferEncoding := fValue asLowercase].

		(fields at: fName ifAbsentPut: [OrderedCollection new: 1])
			add: (MIMEHeaderValue forField: fName fromString: fValue)].

	"Extract the body of the message"
	bodyText := parseStream upToEnd.
	bodyText := (MimeConverter forEncoding: contentTransferEncoding) 
		mimeDecode: (ReadStream on: bodyText) as: String.
	bodyText := self class tryToDecodeBody: bodyText as: self charset.
	
	self isMultipart
		ifTrue: [parts := self class parseParts: bodyText withSeparator: self attachmentSeparator]
		ifFalse: [content := bodyText]
	
]

{ #category : #testing }
MIMEDocument >> isGif [
	^ self mainType = 'image'
		and: [self subType = 'gif']
]

{ #category : #testing }
MIMEDocument >> isHTML [

	^ self mainType = 'text' and: [self subType = 'html']
]

{ #category : #testing }
MIMEDocument >> isJpeg [
	^ self mainType = 'image'
		and: [self subType = 'jpeg' | (self subType = 'jpg')]
]

{ #category : #testing }
MIMEDocument >> isMultipart [
	^self mainType = 'multipart'
]

{ #category : #testing }
MIMEDocument >> isMultipartAlternative [
	"whether the document is in a multipart format where the parts are alternates"
	^ self contentType = 'multipart/alternative'

]

{ #category : #testing }
MIMEDocument >> isPlaintext [

	^ self mainType = 'text' and: [self subType = 'plain']
]

{ #category : #testing }
MIMEDocument >> isPng [
	^ self mainType = 'image'
		and: [self subType = 'png']
]

{ #category : #testing }
MIMEDocument >> isPnm [
	^ self mainType = 'image'
		and: [self subType = 'pnm']
]

{ #category : #accessing }
MIMEDocument >> mainType [
	^ (self contentType splitBy: '/') first
]

{ #category : #accessing }
MIMEDocument >> name [
	"return a default name for this part, if any was specified.  If not, return nil"
	| type nameField disposition |

	"try in the content-type: header"
	type := self fieldNamed: 'content-type' ifAbsent: [nil].
	(type notNil and: [(nameField := type parameters at: 'name' ifAbsent: [nil]) notNil])
		ifTrue: [^ nameField].

	"try in content-disposition:"
	disposition := self fieldNamed: 'content-disposition' ifAbsent: [nil].
	(disposition notNil and: [(nameField := disposition parameters at: 'filename' ifAbsent: [nil]) notNil])
		ifTrue: [^ nameField].

	"give up"
	^ nil
]

{ #category : #accessing }
MIMEDocument >> parameterizedContentTransferEncoding [

	^ self contentTransferEncoding asHeaderValue
]

{ #category : #accessing }
MIMEDocument >> parameterizedContentType [
	
	^ self contentTypeHeaderValue asHeaderValue
	
	
]

{ #category : #accessing }
MIMEDocument >> parts [

	^ parts

]

{ #category : #printing }
MIMEDocument >> printOn: aStream [
	aStream nextPutAll: self class name;
		nextPutAll: ' (';
		nextPutAll: self contentType;
		nextPutAll: ', '.
	self content
		ifNotNil: [aStream
			nextPutAll: self content size printString;
			nextPutAll: ' bytes)']
		ifNil: [aStream nextPutAll: 'unknown size)'].
]

{ #category : #private }
MIMEDocument >> privateContent: aString [
	content := aString
]

{ #category : #private }
MIMEDocument >> privateMainType: aString [

	self contentTypeHeaderValue mainValue: (aString , '/' , self subType)
]

{ #category : #private }
MIMEDocument >> privateSubType: aString [

	self contentTypeHeaderValue mainValue: (self mainType , '/' , aString)
]

{ #category : #private }
MIMEDocument >> privateUrl: aUrl [
	url := aUrl
]

{ #category : #fields }
MIMEDocument >> reportField: aString to: aBlock [
	"Evaluate the given block with the field name a value in the given field. Do nothing if the field is malformed.
	Duplicate of code in MailMessage"

	| s fieldName fieldValue |
	(aString includes: $:) ifFalse: [^self].
	s := ReadStream on: aString.
	fieldName := (s upTo: $:) asLowercase.	"fieldname must be lowercase"
	fieldValue := s upToEnd withBlanksTrimmed.
	fieldValue isEmpty ifFalse: [aBlock value: fieldName value: fieldValue].

]

{ #category : #interactions }
MIMEDocument >> save [
	"save the part to a file"
	| fileName file |
	fileName := self name
				ifNil: ['attachment' , Utilities dateTimeSuffix].
	(fileName includes: $.) ifFalse: [
		#(isJpeg 'jpg' isGif 'gif' isPng 'png' isPnm 'pnm') pairsDo: [ :s :e |
			(self perform: s) ifTrue: [fileName := fileName, '.', e]
		]
	].
	fileName := UIManager default request: 'File name for save?' initialAnswer: fileName.
	fileName isEmpty
		ifTrue: [^ nil].
		
	
	file := FileStream newFileNamed: fileName.
	self contentTransferEncoding = 'base64' ifTrue: [file binary].
	file nextPutAll: self contents.
	file close
]

{ #category : #serializing }
MIMEDocument >> sendableMultipartBodyText [

	^ String streamContents: [ :str |
		str cr.
		parts do: [ :part |
			str
				cr;
				nextPutAll: '--';
				nextPutAll: self attachmentSeparator;
				cr;
				nextPutAll: part asSendablePartText ].
	
		str
			cr;
			nextPutAll: '--';
			nextPutAll: self attachmentSeparator;
			nextPutAll: '--';
			cr ]
]

{ #category : #fields }
MIMEDocument >> setField: fieldName to: aFieldValue [
	"set a field.  If any field of the specified name exists, it will be overwritten"
	fields at: fieldName asLowercase put: (OrderedCollection with: aFieldValue).
]

{ #category : #fields }
MIMEDocument >> setField: fieldName toString: fieldValue [
	^self setField: fieldName to: (MIMEHeaderValue forField: fieldName fromString: fieldValue)
]

{ #category : #accessing }
MIMEDocument >> subType [
	^ (self contentType splitBy: '/') second
]

{ #category : #accessing }
MIMEDocument >> text [
	"Compatibility with MailMessage protocol"
	^self contents
]

{ #category : #accessing }
MIMEDocument >> type [
	"Deprecated. Use contentType instead."

	^ self contentType
]

{ #category : #interactions }
MIMEDocument >> view [
	
	self containsViewableImage
		ifTrue: [^ self viewImage].
	(StringHolder new contents: self bodyTextFormatted;
		 yourself)
		openLabel: (self name ifNil: ['(a message part)'])
]

{ #category : #interactions }
MIMEDocument >> viewImage [
	| stream image |
	stream := self contentStream.
	image := Form fromBinaryStream: stream.
	(Project current world drawingClass withForm: image) openInWorld
]

{ #category : #converting }
MIMEDocument >> withUrl: newUrl [
	"return an identical document except that the URL has been modified"
	^MIMEDocument contentType: self contentType  content: self content url: newUrl
]
