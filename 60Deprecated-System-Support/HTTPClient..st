Class {
	#name : #HTTPClient,
	#superclass : #Object,
	#classVars : [
		'BrowserSupportsAPI',
		'RunningInBrowser'
	],
	#category : #'60Deprecated-System-Support'
}

{ #category : #'class initialization' }
HTTPClient class >> browserSupportsAPI [
	^BrowserSupportsAPI == true
]

{ #category : #'class initialization' }
HTTPClient class >> browserSupportsAPI: aBoolean [
	BrowserSupportsAPI := aBoolean
]

{ #category : #utilities }
HTTPClient class >> composeMailTo: address subject: subject body: body [
	"HTTPClient composeMailTo: 'michael.rueger@squeakland.org' subject: 'test subject' body: 'message' "
	| mailTo |
	mailTo := WriteStream on: String new.
	mailTo nextPutAll: 'mailto:'.
	mailTo
		nextPutAll: address;
		nextPut: $?.
	subject isEmptyOrNil
		ifFalse: [mailTo nextPutAll: 'subject='; nextPutAll: subject; nextPut: $&].
	body isEmptyOrNil
		ifFalse: [mailTo nextPutAll: 'body='; nextPutAll: body].

	self httpGet: mailTo contents
]

{ #category : #'class initialization' }
HTTPClient class >> determineIfRunningInBrowser [
	"HTTPClient determineIfRunningInBrowser"

	RunningInBrowser := StandardFileStream isRunningAsBrowserPlugin

]

{ #category : #examples }
HTTPClient class >> exampleMailTo [
	"HTTPClient exampleMailTo"

	HTTPClient mailTo: 'm.rueger@acm.org' message: 'A test message from within Squeak'

]

{ #category : #examples }
HTTPClient class >> examplePostArgs [
	"HTTPClient examplePostArgs"

	| args result |
	args := Dictionary new
		at: 'arg1' put: #('val1');
		at: 'arg2' put: #('val2');
		yourself.
	result := HTTPClient httpPostDocument: 'http://www.squeaklet.com/cgi-bin/thrd.pl [^]' args: args.
	Transcript show: result content; cr; cr.


]

{ #category : #examples }
HTTPClient class >> examplePostMultipart [
	"HTTPClient examplePostMultipart"

	| args result |
	args := Dictionary new
		at: 'arg1' put: #('val1');
		at: 'arg2' put: #('val2');
		yourself.
	result := HTTPClient httpPostMultipart: 'http://www.squeaklet.com/cgi-bin/thrd.pl'  args: args.
	Transcript show: result content; cr; cr.


]

{ #category : #utilities }
HTTPClient class >> getDirectoryListing: dirListURL [
	"HTTPClient getDirectoryListing: 'http://www.squeakalpha.org/uploads' "
	| answer ftpEntries |
"	answer := self 
		httpPostDocument: dirListURL
		args: Dictionary new."
	"Workaround for Mac IE problem"
	answer := self httpGetDocument: dirListURL.
	answer isString
		ifTrue: [^self error: 'Listing failed: ' , answer]
		ifFalse: [answer := answer content].
	answer first == $<
		ifTrue: [self error: 'Listing failed: ' , answer].
	ftpEntries := answer findTokens: String crlf.
	^ ftpEntries 
		collect:[:ftpEntry | ServerDirectory parseFTPEntry: ftpEntry]
		thenSelect: [:entry | entry notNil]
]

{ #category : #'post\/get' }
HTTPClient class >> httpGet: url [
	| document |
	document := self httpGetDocument: url.
	^(document isString)
		ifTrue: [
			"strings indicate errors"
			document]
		ifFalse: [(RWBinaryOrTextStream with: document content) reset]
]

{ #category : #'post\/get' }
HTTPClient class >> httpGetDocument: url [
	| stream content | 
	^self shouldUsePluginAPI
		ifTrue: [
			stream := FileStream requestURLStream: url ifError: [self error: 'Error in get from ' , url printString].
			stream ifNil: [^''].
			stream position: 0.
			content := stream upToEnd.
			stream close.
			MIMEDocument content: content]
		ifFalse: [HTTPSocket httpGetDocument: url]
]

{ #category : #'post\/get' }
HTTPClient class >> httpPostDocument: url args: argsDict [
	^self httpPostDocument: url target: nil args: argsDict
]

{ #category : #'post\/get' }
HTTPClient class >> httpPostDocument: url target: target args: argsDict [
	| argString stream content |
	^self shouldUsePluginAPI
		ifTrue: [
			argString := argsDict
				ifNotNil: [argString := HTTPSocket argString: argsDict]
				ifNil: [''].
			stream := FileStream post: argString , ' ' target: target url: url , argString ifError: [self error: 'Error in post to ' , url printString].
			stream position: 0.
			content := stream upToEnd.
			stream close.
			MIMEDocument content: content]
		ifFalse: [HTTPSocket httpPostDocument: url  args: argsDict]
]

{ #category : #'post\/get' }
HTTPClient class >> httpPostMultipart: url args: argsDict [
	" do multipart/form-data encoding rather than x-www-urlencoded "

	^self shouldUsePluginAPI
		ifTrue: [self pluginHttpPostMultipart: url args: argsDict]
		ifFalse: [HTTPSocket httpPostMultipart: url args: argsDict accept: nil request: '']
]

{ #category : #testing }
HTTPClient class >> isRunningInBrowser [

	RunningInBrowser isNil
		ifTrue: [self determineIfRunningInBrowser].
	^RunningInBrowser
]

{ #category : #testing }
HTTPClient class >> isRunningInBrowser: aBoolean [
	"Override the automatic process.
	This should be used with caution.
	One way to determine it without using the primitive is to check for parameters typically only encountered when running as a plugin."

	RunningInBrowser := aBoolean
]

{ #category : #utilities }
HTTPClient class >> mailTo: address message: aString [
	HTTPClient shouldUsePluginAPI
		ifFalse: [^self error: 'You need to run inside a web browser.'].
	FileStream post: aString url: 'mailto:' , address ifError: [self error: 'Can not send mail']
]

{ #category : #private }
HTTPClient class >> pluginHttpPostMultipart: url args: argsDict [
	| mimeBorder argsStream crLf resultStream result |
	" do multipart/form-data encoding rather than x-www-urlencoded "

	crLf := String crlf.
	mimeBorder := '----squeak-', Time millisecondClockValue printString, '-stuff-----'.
	"encode the arguments dictionary"
	argsStream := WriteStream on: String new.
	argsDict associationsDo: [:assoc |
		assoc value do: [ :value | | fieldValue |
		"print the boundary"
		argsStream nextPutAll: '--', mimeBorder, crLf.
		" check if it's a non-text field "
		argsStream nextPutAll: 'Content-disposition: form-data; name="', assoc key, '"'.
		(value isKindOf: MIMEDocument)
			ifFalse: [fieldValue := value]
			ifTrue: [argsStream nextPutAll: ' filename="', value url pathForFile, '"', crLf, 'Content-Type: ', value contentType.
				fieldValue := (value content
					ifNil: [(FileStream fileNamed: value url pathForFile) contentsOfEntireFile]
					ifNotNil: [value content]) asString].
" Transcript show: 'field=', key, '; value=', fieldValue; cr. "
		argsStream nextPutAll: crLf, crLf, fieldValue, crLf.
	]].
	argsStream nextPutAll: '--', mimeBorder, '--'.
	resultStream := FileStream
		post: 
			('ACCEPT: text/html', crLf,
			'User-Agent: Squeak 3.1', crLf,
			'Content-type: multipart/form-data; boundary=', mimeBorder, crLf,
			'Content-length: ', argsStream contents size printString, crLf, crLf, 
			argsStream contents)
		url: url ifError: [^'Error in post ' url asString].
	"get the header of the reply"
	result := resultStream
		ifNil: ['']
		ifNotNil: [resultStream upToEnd].
	^MIMEDocument content: result
]

{ #category : #'post\/get' }
HTTPClient class >> requestURL: url target: target [
	^self shouldUsePluginAPI
		ifTrue: [FileStream requestURL: url target: target]
		ifFalse: [self error: 'Requesting a new URL target is not supported.']
]

{ #category : #testing }
HTTPClient class >> shouldUsePluginAPI [
	"HTTPClient shouldUsePluginAPI" 

	self isRunningInBrowser
		ifFalse: [^false].
	self browserSupportsAPI
		ifFalse: [^false].
	"The Mac plugin calls do not work in full screen mode"
	^((Smalltalk platformName = 'Mac OS')
		and: [DisplayScreen displayIsFullScreen]) not
]

{ #category : #'MorphicExtras-utilities' }
HTTPClient class >> tellAFriend: emailAddressOrNil url: urlForLoading name: projectName [
	| recipient subject body linkToInclude |
	recipient := emailAddressOrNil ifNil: ['RECIPIENT.GOESHERE'].
	subject := 'New/Updated Squeak project'.
	body := 'This is a link to the Squeak project ' , projectName , ': ' , String crlf.
	linkToInclude := urlForLoading.
	HTTPClient shouldUsePluginAPI
		ifTrue: [
			self composeMailTo: recipient subject: subject body: body , (linkToInclude copyReplaceAll: '%' with: '%25')]
		ifFalse: [FancyMailComposition new
				celeste: nil 
				to: recipient
				subject: subject
				initialText: body
				theLinkToInclude: linkToInclude;
				open].
]

{ #category : #utilities }
HTTPClient class >> uploadFileNamed: aFilename to: baseUrl user: user passwd: passwd [

	| fileContents remoteFilename |
	remoteFilename := (baseUrl endsWith: '/')
		ifTrue: [baseUrl , '/' , aFilename]
		ifFalse: [baseUrl , aFilename].
	fileContents := (StandardFileStream readOnlyFileNamed: aFilename) contentsOfEntireFile.
	HTTPSocket httpPut: fileContents to: remoteFilename user: user passwd: passwd
]
