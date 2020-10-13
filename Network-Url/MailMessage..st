"
I represent an Internet mail or news message.

	text - the raw text of my message
	body - the body of my message, as a MIMEDocument
	fields - a dictionary mapping lowercased field names into collections of MIMEHeaderValue's
	parts - if I am a multipart message, then this is a cache of my parts
"
Class {
	#name : #MailMessage,
	#superclass : #Object,
	#instVars : [
		'text',
		'body',
		'fields',
		'parts'
	],
	#category : #'Network-Url'
}

{ #category : #utilities }
MailMessage class >> dateStamp: aDateAndTime [
	"Return the given date and time formatted as a email Date: line"
	"The result conforms to RFC822 with a long year, e.g.  'Thu, 18 Feb 1999 20:38:51'"
	| d t |
	d := aDateAndTime asDate.
	t := aDateAndTime asTime.
	^	(d weekday copyFrom: 1 to: 3), ', ',
		(d printFormat: #(1 2 3 $  2 1 1)), ' ',
		"We are careful to avoid fractional seconds appearing in the result:"
		(Time fromSeconds: t asSeconds) print24
]

{ #category : #utilities }
MailMessage class >> dateStampNow [
	"Return the current date and time formatted as a email Date: line"
	^ self dateStamp: DateAndTime now
]

{ #category : #'instance creation' }
MailMessage class >> empty [
	"return a message with no text and no header"

	^self new
]

{ #category : #'instance creation' }
MailMessage class >> from: aString [
	"Initialize a new instance from the given string."

	^(self new) initializeFromString: aString
]

{ #category : #utilities }
MailMessage class >> generateSeparator [
	"generate a separator usable for making MIME multipart documents.  A leading -- will *not* be included"
	^'==CelesteAttachment' , (10000 to: 99999) atRandom asString , '=='.
]

{ #category : #preferences }
MailMessage class >> omittedHeaderFields [
	"Reply a list of fields to omit when displaying a nice simple message"

	"Note that heads of the form
		X-something: value
	are filtered programatically.  This is done since we don't want any of them
	and it is impossible to predict them in advance."

	^ #(
			'comments'
			'priority'
			'disposition-notification-to'
			'content-id'
			'received'
			'return-path'
			'newsgroups'
			'message-id'
			'path'
			'in-reply-to'
			'sender'
			'fonts'
			'mime-version'
			'status'
			'content-type'
			'content-transfer-encoding'
			'errors-to'
			'keywords'
			'references'
			'nntp-posting-host'
			'lines'
			'return-receipt-to'
			'precedence'
			'originator'
			'distribution'
			'content-disposition'
			'importance'
			'resent-to'
			'resent-cc'
			'resent-message-id'
			'resent-date'
			'resent-sender'
			'resent-from'
			'delivered-to'
			'user-agent'
			'content-class'
			'thread-topic'
			'thread-index'
			'list-help',
			'list-post',
			'list-subscribe',
			'list-id',
			'list-unsubscribe',
			'list-archive'
		)

]

{ #category : #'instance creation' }
MailMessage class >> replyAllFor: aMailMessage [
	
	^ self replyFor: aMailMessage excluding: {}
]

{ #category : #'instance creation' }
MailMessage class >> replyAllFor: aMailMessage excluding: ignoredEmailAddresses [ 
	
	| replySubject references replyReceivers ccReceivers |
	
	replyReceivers := MailAddressParser addressesIn: (aMailMessage fieldsNamed: 'to' separatedBy: ', ').
	replyReceivers := replyReceivers reject: [:m | 
		ignoredEmailAddresses includes: m ].
	replyReceivers addFirst: aMailMessage replyReceiver.
	
	replySubject := aMailMessage replySubject.
	references := aMailMessage references.
	
	ccReceivers := MailAddressParser addressesIn: aMailMessage cc.
	ccReceivers := ccReceivers reject: [:m |
		ignoredEmailAddresses includes: m ].

	^ self empty
		to: (replyReceivers joinSeparatedBy: ',');
		cc: (ccReceivers joinSeparatedBy: ',');
		subject: replySubject;
		setField: 'in-reply-to' toString: aMailMessage messageId;
		setField: 'references' toString: references;
		yourself
		
]

{ #category : #'instance creation' }
MailMessage class >> replyFor: aMailMessage [ 
	
	| replyReceiver replySubject references |
	replyReceiver := aMailMessage replyReceiver.
	replySubject := aMailMessage replySubject.
	references := aMailMessage references.

	^ self empty
		to: replyReceiver;
		subject: replySubject;
		setField: 'in-reply-to' toString: aMailMessage messageId;
		setField: 'references' toString: references;
		yourself
		
]

{ #category : #multipart }
MailMessage >> addAttachmentFrom: aStream withName: aName [
	"add an attachment, encoding with base64.  aName is the optional filename"
	| newPart |
	self makeMultipart.

	newPart := MIMEDocument contentType: (MIMEDocument guessTypeFromName: aName) content: ''.
	newPart setField: 'content-transfer-encoding' toString: 'base64'.
	newPart setField: 'content-disposition' toString: 'attachment'.
	
	aName ifNotNil: [
		| dispositionField contentTypeField |
		dispositionField := newPart fieldNamed: 'content-disposition' 
			ifAbsent: [self error: 'Should be initialized by now'].
		dispositionField parameterAt: 'filename' put: '"' , aName , '"'.
		
		contentTypeField := newPart fieldNamed: 'content-type' 
			ifAbsent: [self error: 'Should be initialized by now'].
		contentTypeField parameterAt: 'name' put: '"' , aName , '"'.].
	
	newPart content: aStream upToEnd.
	self body addPart: newPart.
]

{ #category : #'printing\/formatting' }
MailMessage >> asSendableText [
	
	^ self text
]

{ #category : #multipart }
MailMessage >> atomicParts [
	"Answer all of the leaf parts of this message, including those of multipart included messages"

	self body isMultipart ifFalse: [^ OrderedCollection with: self].
	^ self parts inject: OrderedCollection new into: [:col :part | col , part atomicParts]
]

{ #category : #multipart }
MailMessage >> attachmentSeparator [
	^(self fieldNamed: 'content-type' ifAbsent: [^nil]) parameters
		at: 'boundary' ifAbsent: [^nil]
]

{ #category : #multipart }
MailMessage >> attachments [

	^ self body parts select: [:p | 
		(p fieldNamed: 'content-disposition' ifAbsent: [nil])
			ifNil: [false]
			ifNotNilDo: [:headerValue | headerValue mainValue = 'attachment' ]]
]

{ #category : #accessing }
MailMessage >> bcc [

	^ self fieldsNamed: 'bcc' separatedBy: ', '
]

{ #category : #accessing }
MailMessage >> bcc: commaSeperatedListOfEmailAddresses [

	^ self setField: 'bcc' toString: commaSeperatedListOfEmailAddresses
]

{ #category : #accessing }
MailMessage >> body [
	"return just the body of the message"
	^body
]

{ #category : #'initialize-release' }
MailMessage >> body: newBody [
	
	self isMultipart 
		ifTrue: [self body parts at: 1 put: newBody]
		ifFalse: [body := newBody]
]

{ #category : #accessing }
MailMessage >> bodyText [
	"return the text of the body of the message"
	^ body asSendableBodyText
]

{ #category : #'printing\/formatting' }
MailMessage >> bodyTextFormatted [

	^ self body bodyTextFormatted

]

{ #category : #fields }
MailMessage >> canonicalFields [
	"Break long header fields and escape those containing high-ascii characters according to RFC2047"

	self rewriteFields:
		[ :fName :fValue | 
			(fName size + fValue size < 72 and: [fValue allSatisfy: [:c | c asciiValue <= 128]])
				ifFalse: [QEncodingMimeConverter mimeEncode: fName, ': ', fValue]]
		append: [].


]

{ #category : #accessing }
MailMessage >> cc [

	^ self fieldsNamed: 'cc' separatedBy: ', '
]

{ #category : #accessing }
MailMessage >> cc: commaSeperatedListOfEmailAddresses [

	^ self setField: 'cc' toString: commaSeperatedListOfEmailAddresses
]

{ #category : #'printing\/formatting' }
MailMessage >> cleanedHeader [
	"Reply with a cleaned up version email header.  First show fields people would normally want to see (in a regular order for easy browsing), and then any other fields not explictly excluded"

	| new priorityFields omittedFields |

	new := WriteStream on: (String new: text size).

	priorityFields := #('Date' 'From' 'Subject' 'To' 'Cc').
	omittedFields := MailMessage omittedHeaderFields.

	"Show the priority fields first, in the order given in priorityFields"
	priorityFields do: [ :pField |
		"We don't check whether the priority field is in the omitted list!"
		self headerFieldsNamed: pField do:
			[: fValue | new nextPutAll: pField, ': ', fValue decodeMimeHeader; cr]].

	"Show the rest of the fields, omitting the uninteresting ones and ones we have already shown"
	omittedFields := omittedFields, priorityFields.
	self fieldsFrom: (ReadStream on: text) do:
		[: fName : fValue |
		((fName beginsWith: 'x-') or:
			[omittedFields anySatisfy: [: omitted | fName sameAs: omitted]])
				ifFalse: [new nextPutAll: fName, ': ', fValue; cr]].

	^new contents
]

{ #category : #testing }
MailMessage >> containsViewableImage [
	^self body isJpeg | self body isGif | self body isPng
]

{ #category : #accessing }
MailMessage >> contentType [

	^ self body contentTypeHeaderValue
]

{ #category : #accessing }
MailMessage >> date [

	^ DateAndTime fromSeconds: self time + (Date newDay: 1 year: 1980) asSeconds
]

{ #category : #accessing }
MailMessage >> dateString [
	"Answer a date string for this message."

	^(Date fromSeconds: self time + (Date newDay: 1 year: 1980) asSeconds) 
		printFormat: #(2 1 3 47 1 2)
]

{ #category : #accessing }
MailMessage >> dateTime: aDateTime [

	self setField: 'date' toString: aDateTime asMailMessageString
]

{ #category : #multipart }
MailMessage >> decoderClass [
	| encoding |
	encoding := self fieldNamed: 'content-transfer-encoding' ifAbsent: [^ nil].
	encoding := encoding mainValue.
	encoding asLowercase = 'base64' ifTrue: [^ Base64MimeConverter].
	encoding asLowercase = 'quoted-printable' ifTrue: [^ QuotedPrintableMimeConverter].
	^ nil
]

{ #category : #'printing\/formatting' }
MailMessage >> excerpt [
	"Return a short excerpt of the text of the message"

	^ self bodyText withSeparatorsCompacted truncateWithElipsisTo: 60
]

{ #category : #fields }
MailMessage >> fieldNamed: aString ifAbsent: aBlock [
	| matchingFields |
	"return the value of the field with the specified name.  If there is more than one field, then return the first one"
	matchingFields := fields at: aString asLowercase ifAbsent: [ ^aBlock value ].
	^matchingFields first
]

{ #category : #accessing }
MailMessage >> fields [
	"return the internal fields structure.  This is private and subject to change!"
	^ fields
]

{ #category : #parsing }
MailMessage >> fieldsFrom: aStream do: aBlock [
	"Invoke the given block with each of the header fields from the given stream. The block arguments are the field name and value. The streams position is left right after the empty line separating header and body."

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
MailMessage >> fieldsNamed: aString ifAbsent: aBlock [
	"return a list of all fields with the given name"
	^fields at: aString asLowercase ifAbsent: aBlock
]

{ #category : #fields }
MailMessage >> fieldsNamed: aString  separatedBy: separationString [
	"return all fields with the specified name, concatenated together with separationString between each element.  Return an empty string if no fields with the specified name are present"
	| matchingFields |
	matchingFields := self fieldsNamed: aString ifAbsent: [ ^'' ].
	^String streamContents: [ :str |
		matchingFields
			do: [ :field | str nextPutAll: field mainValue ]
			separatedBy: [ str nextPutAll: separationString ]].

]

{ #category : #'printing\/formatting' }
MailMessage >> format [
	"Replace the text of this message with a formatted version."
	"NOTE: This operation discards extra header fields."

	text := self formattedText.
]

{ #category : #'printing\/formatting' }
MailMessage >> formattedText [
	"Answer a version of my text suitable for display.  This cleans up the header, decodes HTML, and things like that"

	
	^ self cleanedHeader asText, String cr , self bodyTextFormatted
]

{ #category : #accessing }
MailMessage >> from [

	^(self fieldNamed: 'from' ifAbsent: [ ^'' ]) mainValue
]

{ #category : #accessing }
MailMessage >> from: aString [
	
	| sanitizedMailAddress |
	sanitizedMailAddress := (MailAddressParser addressesIn: aString) first.
	^self setField: 'from' toString: sanitizedMailAddress
]

{ #category : #fields }
MailMessage >> hasFieldNamed: aString [
	^fields includesKey: aString asLowercase
]

{ #category : #parsing }
MailMessage >> headerFieldsNamed: fieldName do: aBlock [
	"Evalue aBlock once for each header field which matches fieldName.  The block is valued with one parameter, the value of the field"

	self fieldsFrom: (ReadStream on: text) do:
		[: fName : fValue |
			(fieldName sameAs: fName) ifTrue: [aBlock value: fValue]].

]

{ #category : #'initialize-release' }
MailMessage >> initialize [
	"initialize as an empty message"

	text := String cr.
	fields := Dictionary new.
	body := MIMEDocument contentType: 'text/plain' content: String cr.
	self dateTime: TimeStamp now.
]

{ #category : #'initialize-release' }
MailMessage >> initializeFromString: aString [ 
	"Parse aString to initialize myself."

	| parseStream contentType bodyText contentTransferEncoding |

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

	body := MIMEDocument contentType: contentType content: bodyText
]

{ #category : #multipart }
MailMessage >> isMultipart [

	^ self body isMultipart
]

{ #category : #multipart }
MailMessage >> makeMultipart [
	"if I am not multipart already, then become a multipart message with one part"

	| newBody |

	body isMultipart ifTrue: [ ^self ].

	"set up the new message part"
	newBody := MIMEDocument newMultipart.
	newBody addPart: body.
	
	self setField: 'mime-version' to: (MIMEHeaderValue fromMIMEHeader: '1.0').

	body := newBody.
]

{ #category : #accessing }
MailMessage >> messageId [

	^ (self fieldNamed: 'message-id' ifAbsent: [ ^'' ])  mainValue
]

{ #category : #accessing }
MailMessage >> messageId: aString [

	^ self setField: 'message-id' toString: aString
]

{ #category : #access }
MailMessage >> name [
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

{ #category : #multipart }
MailMessage >> parseParts [
	"private -- parse the parts of the message and store them into a collection"

	| parseStream msgStream messages separator |

	"If this is not multipart, store an empty collection"
	self body isMultipart ifFalse: [parts := #().  ^self].

	"If we can't find a valid separator, handle it as if the message is not multipart"
	separator := self attachmentSeparator.
	separator ifNil: [Transcript show: 'Ignoring bad attachment separater'; cr. parts := #(). ^self].

	separator := '--', separator withoutTrailingBlanks.
	parseStream := ReadStream on: self bodyText.

	msgStream := LimitingLineStreamWrapper on: parseStream delimiter: separator.
	msgStream limitingBlock: [:aLine |
		aLine withoutTrailingBlanks = separator or:			"Match the separator"
		[aLine withoutTrailingBlanks = (separator, '--')]].	"or the final separator with --"

	"Throw away everything up to and including the first separator"
	msgStream upToEnd.
	msgStream skipThisLine.

	"Extract each of the multi-parts as strings"
	messages := OrderedCollection new.
	[parseStream atEnd]
		whileFalse: 
			[messages add: msgStream upToEnd.
			msgStream skipThisLine].

	parts := messages collect: [:e | MailMessage from: e]
]

{ #category : #multipart }
MailMessage >> parseParts: bodyText [
	"private -- parse the parts of the message and store them into a collection"

	| parseStream msgStream messages separator |

	"If we can't find a valid separator, handle it as if the message is not multipart"
	separator := self attachmentSeparator.
	separator ifNil: [self error: 'Bad attachment separater'].

	separator := '--', separator withoutTrailingBlanks.
	parseStream := ReadStream on: bodyText.

	msgStream := LimitingLineStreamWrapper on: parseStream delimiter: separator.
	msgStream limitingBlock: [:aLine |
		aLine withoutTrailingBlanks = separator or:			"Match the separator"
		[aLine withoutTrailingBlanks = (separator, '--')]].	"or the final separator with --"

	"Throw away everything up to and including the first separator"
	msgStream upToEnd.
	msgStream skipThisLine.

	"Extract each of the multi-parts as strings"
	messages := OrderedCollection new.
	[parseStream atEnd]
		whileFalse: 
			[messages add: msgStream upToEnd.
			msgStream skipThisLine].

	^ messages collect: [:e | MIMEDocument from: e]
]

{ #category : #multipart }
MailMessage >> parts [

	^ self body parts
]

{ #category : #'printing\/formatting' }
MailMessage >> printOn: aStream [ 

	aStream nextPutAll: 'Text: ' , self excerpt
]

{ #category : #parsing }
MailMessage >> readDateFrom: aStream [
	"Parse a date from the given stream and answer nil if the date can't be parsed. The date may be in any of the following forms:
		<day> <monthName> <year>		(5 April 1982; 5-APR-82)
		<monthName> <day> <year>		(April 5, 1982)
		<monthNumber> <day> <year>		(4/5/82)
	In addition, the date may be preceded by the day of the week and an optional comma, such as:
		Tue, November 14, 1989"

	| day month year |
	self skipWeekdayName: aStream.
	aStream peek isDigit ifTrue: [day := Integer readFrom: aStream].
	[aStream peek isAlphaNumeric] whileFalse: [aStream skip: 1].
	aStream peek isLetter
		ifTrue:		"month name or weekday name"
			[month := WriteStream on: (String new: 10).
			 [aStream peek isLetter] whileTrue: [month nextPut: aStream next].
			 month := month contents.
			 day isNil ifTrue:		"name/number..."
				[[aStream peek isAlphaNumeric] whileFalse: [aStream skip: 1].
				 (aStream peek isDigit) ifFalse: [^nil].
				 day := Integer readFrom: aStream]]
		ifFalse:		"number/number..."
			[month := Date nameOfMonth: day.
			 day := Integer readFrom: aStream].
	[aStream peek isAlphaNumeric] whileFalse: [aStream skip: 1].
	(aStream peek isDigit) ifFalse: [^nil].
	year := Integer readFrom: aStream.
	^ Date newDay: day month: month year: year
]

{ #category : #parsing }
MailMessage >> readFrom: parseStream [
	
	| bodyText contentTransferEncoding contentType |
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
	contentTransferEncoding = 'base64' ifTrue: [
			bodyText := Base64MimeConverter mimeDecodeToChars: (ReadStream on: bodyText).
			bodyText := bodyText contents].
	contentTransferEncoding = 'quoted-printable' ifTrue: [
			bodyText := bodyText decodeQuotedPrintable].
	
	body := MIMEDocument contentType: contentType content: bodyText
]

{ #category : #parsing }
MailMessage >> readStringLineFrom: aStream [ 
	"Read and answer the next line from the given stream. Consume the carriage return but do not append it to the string."

	^aStream nextLine
]

{ #category : #accessing }
MailMessage >> references [

	^ (self hasFieldNamed: 'references')
		ifTrue: [(self fieldNamed: 'references' ifAbsent: [self error: 'Something changed the mail between the check and now']) 
					mainValue , ', ' , self messageId]
		ifFalse: [self messageId].
]

{ #category : #'printing\/formatting' }
MailMessage >> regenerateBodyFromParts [
	"regenerate the message body from the multiple parts"
	| bodyText |

	bodyText := String streamContents: [ :str |
		str cr.
		parts do: [ :part |
			str
				cr;
				nextPutAll: '--';
				nextPutAll: self attachmentSeparator;
				cr;
				nextPutAll: part text ].
	
		str
			cr;
			nextPutAll: '--';
			nextPutAll: self attachmentSeparator;
			nextPutAll: '--';
			cr ].

	body := MIMEDocument contentType: 'multipart/mixed' content: bodyText.
	text := nil.  "text needs to be reformatted"
]

{ #category : #'printing\/formatting' }
MailMessage >> regenerateText [
	"regenerate the full text from the body and headers"
	
	text := String streamContents: [ :str | | encodedBodyText |
		"first put the header"
		fields keysAndValuesDo: [ :fieldName :fieldValues |
			fieldValues do: [ :fieldValue |
				str
					nextPutAll: fieldName capitalized ;
					nextPutAll: ': ';
					nextPutAll: fieldValue asHeaderValue;
					cr ]. ].
	
		"skip a line between header and body"
		str cr.

		"put the body, being sure to encode it according to the header"
		encodedBodyText := body content.
		self decoderClass ifNotNil: [
			encodedBodyText := (self decoderClass mimeEncode: (ReadStream on: encodedBodyText)) upToEnd ].
		str nextPutAll: encodedBodyText ].
]

{ #category : #multipart }
MailMessage >> removeAttachment: aMIMEDocument [

	^ self body parts remove: aMIMEDocument ifAbsent: []
]

{ #category : #fields }
MailMessage >> removeFieldNamed: name [
	"remove all fields with the specified name"
	fields removeKey: name ifAbsent: []
]

{ #category : #accessing }
MailMessage >> replyReceiver [

	 ^ (self 
		fieldNamed: 'reply-to' 
		ifAbsent: [self 
			fieldNamed: 'from' 
			ifAbsent: [self error: 'there is a field missing in the original message']]) mainValue.
		
]

{ #category : #accessing }
MailMessage >> replySubject [

	 ^ (self subject asLowercase beginsWith: 're:')
		ifTrue: [self subject]
		ifFalse: ['Re: ' , self subject].
]

{ #category : #parsing }
MailMessage >> reportField: aString to: aBlock [
	"Evaluate the given block with the field name a value in the given field. Do nothing if the field is malformed."

	| s fieldName fieldValue |
	(aString includes: $:) ifFalse: [^self].
	s := ReadStream on: aString.
	fieldName := (s upTo: $:) asLowercase.	"fieldname must be lowercase"
	fieldValue := s upToEnd withBlanksTrimmed.
	fieldValue isEmpty ifFalse: [aBlock value: fieldName value: fieldValue].

]

{ #category : #fields }
MailMessage >> rewriteFields: aBlock append: appendBlock [
	"Rewrite header fields. The body is not modified.
	Each field's key and value is reported to aBlock. The block's return value is the replacement for the entire header line. Nil means don't change the line, empty means delete it. After all fields are processed, evaluate appendBlock and append the result to the header."

	| old new appendString |
	self halt: 'this method is out of date.  it needs to update body, at the very least.  do we really need this now that we have setField:to: and setField:toString: ?!'.
	old := ReadStream on: text.
	new := WriteStream on: (String new: text size).
	self fieldsFrom: old do: [ :fName :fValue | | result |
		result := aBlock value: fName value: fValue.
		result ifNil: [new nextPutAll: fName, ': ', fValue; cr]
			ifNotNil: [result isEmpty
				ifFalse: [new nextPutAll: result.
					result last = Character cr ifFalse: [new cr]]]].
	appendString := appendBlock value.
	appendString isEmptyOrNil ifFalse:
		[new nextPutAll: appendString.
		appendString last = Character cr ifFalse: [new cr]].
	new cr. "End of header"
	text := new contents, old upToEnd.

]

{ #category : #multipart }
MailMessage >> save [
	"save the part to a file"
	| fileName |
	fileName := self name ifNil: ['attachment' , Utilities dateTimeSuffix].
	(fileName includes: $.)
		ifFalse: [#(#isJpeg 'jpg' #isGif 'gif' #isPng 'png' #isPnm 'pnm')
				pairsDo: [:s :e | (self body perform: s)
						ifTrue: [fileName := fileName , FileDirectory dot , e]]].

	fileName := UIManager default saveFilenameRequest: 'File name for save?' initialAnswer: fileName.
	fileName ifNil: [^ nil].

	FileStream newFileNamed: fileName
		do: [:file | file nextPutAll: self bodyText]
]

{ #category : #testing }
MailMessage >> selfTest [
	"For testing only: Check that this instance is well formed and makes sense"
	
	self formattedText.

	[MailAddressParser addressesIn: self from] ifError:
		[ :err :rcvr | Transcript show: 'Error parsing From: (', self from, ') ', err].
	[MailAddressParser addressesIn: self to] ifError:
		[ :err :rcvr | Transcript show: 'Error parsing To: (', self to, ') ', err].
	[MailAddressParser addressesIn: self cc] ifError:
		[ :err :rcvr | Transcript show: 'Error parsing CC: (', self cc, ') ', err].

]

{ #category : #fields }
MailMessage >> setField: fieldName to: aFieldValue [
	"set a field.  If any field of the specified name exists, it will be overwritten"
	fields at: fieldName asLowercase put: (OrderedCollection with: aFieldValue).
	text := nil.
]

{ #category : #fields }
MailMessage >> setField: fieldName toString: fieldValue [
	^self setField: fieldName to: (MIMEHeaderValue forField: fieldName fromString: fieldValue)
]

{ #category : #access }
MailMessage >> setText: aString [ 

	text := aString withoutTrailingBlanks, String cr, String cr.
	self readFrom: text readStream.
	
]

{ #category : #parsing }
MailMessage >> skipWeekdayName: aStream [
	"If the given stream starts with a weekday name or its abbreviation, advance the stream to the first alphaNumeric character following the weekday name."

	| position name abbrev |
	aStream skipSeparators.
	(aStream peek isDigit) ifTrue: [^self].
	(aStream peek isLetter) ifTrue:
		[position := aStream position.
		 name := WriteStream on: (String new: 10).
		 [aStream peek isLetter] whileTrue: [name nextPut: aStream next].
		 abbrev := (name contents copyFrom: 1 to: (3 min: name position)).
		 abbrev := abbrev asLowercase.
		 (#('sun' 'mon' 'tue' 'wed' 'thu' 'fri' 'sat') includes: abbrev asLowercase)
			ifTrue:
				["found a weekday; skip to the next alphanumeric character"
				 [aStream peek isAlphaNumeric] whileFalse: [aStream skip: 1]]
			ifFalse:
				["didn't find a weekday so restore stream position"
				 aStream position: position]].
]

{ #category : #accessing }
MailMessage >> subject [

	^ (self fieldNamed: 'subject' ifAbsent: [ ^'' ])  mainValue
]

{ #category : #accessing }
MailMessage >> subject: aString [

	^self setField: 'subject' toString: aString
]

{ #category : #accessing }
MailMessage >> text [
	
	^ String streamContents: [ :str | | encodedBodyText |
		"first put the header"
		(fields associations , {'content-type' -> {self body contentTypeHeaderValue} })
				do: [ :assoc  | | fieldName fieldValues | 
					fieldName := assoc key.
					fieldValues := assoc value.
					fieldValues do: [ :fieldValue |
						str
							nextPutAll: fieldName capitalized ;
							nextPutAll: ': ';
							nextPutAll: fieldValue asHeaderValue;
							cr ]].
		
		 self body contentTransferEncodingHeaderValue 
			ifNotNil: [:headerValue |
				str
					nextPutAll: 'content-transfer-encoding' capitalized;
					nextPutAll: ': ';
					nextPutAll: headerValue asHeaderValue;
					cr  ].
		
		"skip a line between header and body"
		str cr.

		"put the body, being sure to encode it according to the header"
		encodedBodyText := body asSendableBodyText.
		str nextPutAll: encodedBodyText ].
]

{ #category : #accessing }
MailMessage >> time [
	| dateField |
	dateField := (self fieldNamed: 'date' ifAbsent: [ ^0 ]) mainValue.
	^ [self timeFrom: dateField] ifError: [:err :rcvr | Date today asSeconds].

]

{ #category : #parsing }
MailMessage >> timeFrom: aString [ 
	"Parse the date and time (rfc822) and answer the result as the number of seconds 
	since the start of 1980."

	| s t rawDelta delta plusOrMinus |
	s := ReadStream on: aString.

	"date part"
	t := ((self readDateFrom: s) ifNil: [Date today]) asSeconds.

	[s atEnd or: [s peek isAlphaNumeric]]
		whileFalse: [s next].

	"time part"
	s atEnd ifFalse: ["read time part (interpreted as local, regardless of sender's timezone)"
		(s peek isDigit) ifTrue: [t := t + (Time readFrom: s) asSeconds].
		].
	s skipSeparators.

	"Check for a numeric time zone offset"
	('+-' includes: s peek) ifTrue: 
		[plusOrMinus := s next.
		rawDelta := (s peek isDigit) ifTrue: [Integer readFrom: s] ifFalse: [0].
		delta := (rawDelta // 100 * 60 + (rawDelta \\ 100)) * 60.
		t := plusOrMinus = $+ ifTrue: [t - delta] ifFalse: [t + delta]].

	"We ignore text time zone offsets like EST, GMT, etc..."

	^ t - (Date newDay: 1 year: 1980) asSeconds

"MailMessage new timeFrom: 'Thu, 22 Jun 2000 14:17:47 -500'"
"MailMessage new timeFrom: 'Thu, 22 Jun 2000 14:17:47 --500'"
"MailMessage new timeFrom: 'on, 04 apr 2001 14:57:32'"
]

{ #category : #accessing }
MailMessage >> to [
	^self fieldsNamed: 'to' separatedBy: ', '
]

{ #category : #accessing }
MailMessage >> to: aString [

	| sanitizedMailAddresses |
	sanitizedMailAddresses := (MailAddressParser addressesIn: aString) withoutDuplicates.
	^self setField: 'to' toString: (sanitizedMailAddresses joinSeparatedBy: ', ')
]

{ #category : #'printing\/formatting' }
MailMessage >> viewBody [
	"open a viewer on the body of this message"
	self containsViewableImage
		ifTrue: [^ self viewImageInBody].
	(StringHolder new contents: self bodyTextFormatted;
		 yourself)
		openLabel: (self name
				ifNil: ['(a message part)'])
]

{ #category : #'printing\/formatting' }
MailMessage >> viewImageInBody [
	| stream image |
	stream := self body contentStream.
	image := Form fromBinaryStream: stream.
	(Project current world drawingClass withForm: image) openInWorld
]
