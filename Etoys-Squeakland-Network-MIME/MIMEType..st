Class {
	#name : #MIMEType,
	#superclass : #Object,
	#instVars : [
		'main',
		'sub',
		'parameters'
	],
	#classVars : [
		'DefaultSuffixes',
		'StandardMIMEMappings'
	],
	#category : #'Etoys-Squeakland-Network-MIME'
}

{ #category : #'instance creation' }
MIMEType class >> contentTypeMultipart [
	^self main: 'multipart' sub: 'form-data'
]

{ #category : #'instance creation' }
MIMEType class >> contentTypeURLEncoded [
	^self main: 'application' sub: 'x-www-form-urlencoded'
]

{ #category : #'instance creation' }
MIMEType class >> defaultHTML [
	^self main: 'text' sub: 'html'
]

{ #category : #'instance creation' }
MIMEType class >> defaultStream [
	^self main: 'application' sub: 'octet-stream'
]

{ #category : #'class initialization' }
MIMEType class >> defaultSuffixes [
	"MIMEType defaultSuffixes"

	^DefaultSuffixes ifNil: [DefaultSuffixes := self initializeDefaultSuffixes]
]

{ #category : #'instance creation' }
MIMEType class >> defaultText [
	^self main: 'text' sub: 'plain'
]

{ #category : #'instance creation' }
MIMEType class >> forExtension: fileExtension [
	| mime |
	SmalltalkImage current platformName = 'Mac OS'
		ifTrue: 
			[mime := Smalltalk at: #MIMETypeMacResolver ifPresent: [:c | c getMIMETypeForFilename: 'a.',fileExtension]].
	mime ifNotNil: [^mime].
	^(self mimeMappings at: fileExtension asLowercase ifAbsent: [^nil]) first
]

{ #category : #'instance creation' }
MIMEType class >> forFileName: fileName [
	| ext type |
	ext := FileDirectory extensionFor: fileName.
	(ext = '' and: [SmalltalkImage current platformName = 'Mac OS'])
		 ifTrue: [type := (FileDirectory default getMacFileTypeAndCreator: fileName) at: 1.
			^self forExtension: type].
	^self forExtension: (FileDirectory extensionFor: fileName)
]

{ #category : #'instance creation' }
MIMEType class >> fromMIMEString: mimeString [
	| idx main rest sub parameters |
	idx := mimeString indexOf: $/.
	idx = 0
		ifTrue: [self error: 'Illegal mime type string "' , mimeString , '".'].
	main := mimeString copyFrom: 1 to: idx-1.
	rest := mimeString copyFrom: idx+1 to: mimeString size.
	idx := mimeString indexOf: $;.
	idx = 0
		ifTrue: [sub := rest]
		ifFalse: [
			sub := rest copyFrom: 1 to: idx.
			parameters := rest copyFrom: idx+1 to: rest size].
	 ^self
		main: main
		sub: sub
		parameters: parameters

]

{ #category : #accessing }
MIMEType class >> huntForDashAndRemove: aString [
	| n |
	(n := aString lastIndexOf: $-) > 0 ifTrue: [^aString copyFrom: n+1 to: aString size].
	^aString

]

{ #category : #'class initialization' }
MIMEType class >> initialize [
	"MIMEType initialize"

	self initializeStandardMIMETypes.  
	FileDirectory initializeStandardMIMETypes.
]

{ #category : #'class initialization' }
MIMEType class >> initializeDefaultSubTypeSuffixes [
	"MIMEType initializeDefaultSubTypeSuffixes"

	| defaultSuffixes |
	defaultSuffixes := Dictionary new: 43.
	defaultSuffixes
		at: 'jpeg' put: 'jpg';
		yourself.
	^defaultSuffixes
]

{ #category : #'class initialization' }
MIMEType class >> initializeDefaultSuffixes [
	"MIMEType initializeDefaultSubTypeSuffixes"
	"DefaultSuffixes := nil"

	| defaultSuffixes |
	defaultSuffixes := Dictionary new: 43.
	defaultSuffixes
		at: 'image/jpeg' put: 'jpg';
		at: 'audio/x-mpeg' put: 'mp3';
		at: 'video/x-mpeg' put: 'mpg';
		at: 'image/png' put: 'png';
		at: 'text/xml' put: 'xml';
		yourself.
	^defaultSuffixes
]

{ #category : #'class initialization' }
MIMEType class >> initializeStandardMIMETypes [
	"MIMEType initializeStandardMIMETypes"

	StandardMIMEMappings := Dictionary new.
	self standardMIMETypes keysAndValuesDo:[:extension :mimeStrings |
		StandardMIMEMappings
			at: extension asString asLowercase
			put: (mimeStrings collect: [:mimeString | MIMEType fromMIMEString: mimeString]).
	].
]

{ #category : #'instance creation' }
MIMEType class >> main: mainType sub: subType [
	^self new
		main: mainType;
		sub: subType
]

{ #category : #'instance creation' }
MIMEType class >> main: mainType sub: subType parameters: parameters [
	^self new
		main: mainType;
		sub: subType;
		parameters: parameters
]

{ #category : #accessing }
MIMEType class >> mimeMappings [
	^StandardMIMEMappings
]

{ #category : #accessing }
MIMEType class >> simpleSuffixForMimeType: mimeType [
	^(self defaultSuffixes at: mimeType ifAbsent: [self  huntForDashAndRemove: mimeType sub]) asSymbol
]

{ #category : #'class initialization' }
MIMEType class >> standardMIMETypes [
	"MIMEType standardMIMETypes"
	"We had to split this method because of the 256 literal limit in methods."
	| mimeTypes |
	mimeTypes := self standardMIMETypes2.
	mimeTypes
		at: 'adr' put: #('application/x-msaddr');
		at: 'jpe' put: #('image/jpeg');
		at: 'ttf' put: #('application/x-truetypefont');
		at: 'wiz' put: #('application/msword');
		at: 'xml' put: #('text/xml' 'text/html');
		at: 'ppz' put: #('application/vnd.ms-powerpoint');
		at: 'rpm' put: #('audio/x-pn-realaudio-plugin');
		at: 'rgb' put: #('image/x-rgb');
		at: 'mid' put: #('audio/midi' 'audio/x-midi');
		at: 'pnm' put: #('image/x-portable-anymap');
		at: 'bcpio' put: #('application/x-bcpio');
		at: 'pot' put: #('application/vnd.ms-powerpoint');
		at: 'o' put: #('application/octet-stream');
		at: 'vgp' put: #('video/x-videogram-plugin');
		at: 'ua' put: #('text/plain');
		at: 'zpa' put: #('application/pcphoto');
		at: 'pdf' put: #('application/pdf');
		at: 'class' put: #('application/octet-stream');
		at: 'ra' put: #('audio/x-realaudio');
		at: 'ips' put: #('application/ips');
		at: 'uu' put: #('application/octet-stream');
		at: 'sh' put: #('application/x-sh');
		at: 'ebk' put: #('application/x-expandedbook');
		at: 'pbm' put: #('image/x-portable-bitmap');
		at: 'ram' put: #('audio/x-pn-realaudio');
		at: 'tsv' put: #('text/tab-separated-values');
		at: 'dvi' put: #('application/x-dvi');
		at: 'lha' put: #('application/octet-stream');
		at: 'gif' put: #('image/gif');
		at: 'aif' put: #('audio/x-aiff');
		at: 'etx' put: #('text/x-setext');
		at: 'jfif-tbnl' put: #('image/jpeg');
		at: 'pps' put: #('application/vnd.ms-powerpoint');
		at: 'mp3' put: #('audio/mpeg' 'audio/x-mpeg');
		at: 'pgr' put: #('text/parsnegar-document');
		at: 'con' put: #('application/x-connector');
		at: 'viv' put: #('video/vnd.vivo');
		at: 'latex' put: #('application/x-latex');
		at: 'h' put: #('text/plain');
		at: 'ms' put: #('application/x-troff-ms');
		at: 'zip' put: #('application/zip');
		at: 'axs' put: #('application/olescript');
		at: 'gtar' put: #('application/x-gtar');
		at: 'fhc' put: #('image/x-freehand');
		at: 'asf' put: #('video/x-ms-asf');
		at: 'm3u' put: #('audio/x-mpeg');
		at: 'ai' put: #('application/postscript');
		at: 'movie' put: #('video/x-sgi-movie' 'video/x-sgi.movie');
		at: 'exe' put: #('application/octet-stream');
		at: 'htm' put: #('text/html' 'text/plain');
		at: 'a' put: #('application/octet-stream');
		at: 'mv' put: #('video/x-sgi-movie');
		at: 'fh4' put: #('image/x-freehand');
		at: 'avi' put: #('video/avi');
		at: 'tiff' put: #('image/tiff');
		at: 'mpga' put: #('audio/mpeg');
		at: 'mov' put: #('video/mov');
		at: 'html' put: #('text/html' 'text/plain');
		at: 'hqx' put: #('application/mac-binhex40' 'application/octet-stream');
		at: 'ras' put: #('image/x-cmu-rast');
		at: 'arc' put: #('application/octet-stream');
		at: 'dump' put: #('application/octet-stream');
		at: 'jfif' put: #('image/jpeg');
		at: 'dus' put: #('audio/x-dspeech');
		at: 'me' put: #('application/x-troff-me');
		at: 'mime' put: #('message/rfc822');
		at: 'gtaru' put: #('application/x-gtar');
		at: 'cdf' put: #('application/x-netcdf');
		at: 'xpm' put: #('image/x-xpixmap');
		at: 'jpg' put: #('image/jpeg');
		at: 'dot' put: #('application/msword');
		at: 'css' put: #('text/css' 'text/x-css');
		at: 'chat' put: #('application/x-chat');
		at: 'gz' put: #('application/gzip');
		at: 'mp2' put: #('audio/mpeg');
		at: 'cpt' put: #('application/mac-compactpro');
		at: 'wlt' put: #('application/x-mswallet');
		at: 'text' put: #('text/plain');
		at: 'wsrc' put: #('application/x-wais-source');
		at: 'xwd' put: #('image/x-xwindowdump');
		at: 'rm' put: #('audio/x-pn-realaudio');
		at: 'wrl' put: #('model/vrml');
		at: 'doc' put: #('application/ms-word-document' 'application/msword');
		at: 'ustar' put: #('audio/basic');
		at: 'js' put: #('application/x-javascript');
		at: 'rtx' put: #('application/rtf');
		at: 'aam' put: #('application/x-authorware-map');
		at: 'oda' put: #('application/oda');
		at: 'ppa' put: #('application/vnd.ms-powerpoint');
		at: 'xbm' put: #('image/x-xbitmap');
		at: 'cpio' put: #('application/x-cpio');
		at: 'sv4crc' put: #('application/x-sv4crc');
		at: 'mpg' put: #('video/mpg' 'video/mpeg' 'video/x-mpeg');
		at: 't' put: #('application/x-troff');
		at: 'txt' put: #('text/plain');
		at: 'sit' put: #('application/x-stuffit');
		at: 'wid' put: #('application/x-DemoShield');
		at: 'swf' put: #('application/x-shockwave-flash');
		at: 'lzh' put: #('application/octet-stream');
		at: 'au' put: #('audio/basic');
		at: 'java' put: #('text/plain');
		at: 'mpeg' put: #('video/mpeg' 'video/x-mpeg');
		at: 'qt' put: #('video/quicktime');
		at: 'pgm' put: #('image/x-portable-graymap');
		at: 'hdf' put: #('application/x-hdf');
		at: 'c' put: #('text/plain');
		at: 'cpp' put: #('text/plain');
		at: 'vgx' put: #('video/x-videogram');
		at: 'aifc' put: #('audio/x-aiff');
		at: 'tex' put: #('application/x.tex');
		at: 'wav' put: #('audio/wav' 'audio/x-wav');
		at: 'ivr' put: #('i-world/i-vrml');
		at: 'saveme' put: #('application/octet-stream');
		at: 'csh' put: #('application/x-csh');
		at: 'aas' put: #('application/x-authorware-map');
		at: 'tar' put: #('application/x-tar');
		at: 'vivo' put: #('video/vnd.vivo');
		yourself.
	^mimeTypes
]

{ #category : #'class initialization' }
MIMEType class >> standardMIMETypes2 [
	"MIMEType standardMimeTypes2"
	"We had to split this method because of the 256 literal limit in methods."
	| mimeTypes |
	mimeTypes := Dictionary new: 100.
	mimeTypes
		at: 'nc' put: #('application/x-netcdf');
		at: 'shar' put: #('application/x-shar');
		at: 'pgp' put: #('application/x-pgp-plugin');
		at: 'texi' put: #('application/x-texinfo');
		at: 'z' put: #('application/x-compress');
		at: 'aiff' put: #('audio/aiff' 'audio/x-aiff');
		at: 'bin' put: #('application/octet-stream');
		at: 'pwz' put: #('application/vnd.ms-powerpoint');
		at: 'rtc' put: #('application/rtc');
		at: 'asx' put: #('video/x-ms-asf');
		at: 'ief' put: #('image/ief');
		at: 'ps' put: #('application/postscript');
		at: 'xls' put: #('application/vnd.ms-excel');
		at: 'vrml' put: #('model/vrml');
		at: 'jpeg' put: #('image/jpeg');
		at: 'dwg' put: #('image/vnd');
		at: 'dms' put: #('application/octet-stream');
		at: 'tif' put: #('image/tiff');
		at: 'roff' put: #('application/x-troff');
		at: 'midi' put: #('audio/midi');
		at: 'eps' put: #('application/postscript');
		at: 'man' put: #('application/x-troff-man');
		at: 'sv4cpio' put: #('application/x-sv4cpio');
		at: 'tr' put: #('application/x-troff');
		at: 'dxf' put: #('image/vnd');
		at: 'rtf' put: #('text/rtf' 'application/rtf');
		at: 'frl' put: #('application/freeloader');
		at: 'xlb' put: #('application/vnd.ms-excel');
		at: 'pl' put: #('text/plain');
		at: 'snd' put: #('audio/basic');
		at: 'texinfo' put: #('application/x-texinfo');
		at: 'tbk' put: #('application/toolbook');
		at: 'ppm' put: #('image/x-portable-pixmap');
		at: 'cht' put: #('audio/x-dspeech');
		at: 'bmp' put: #('image/bmp');
		at: 'vgm' put: #('video/x-videogram');
		at: 'fh5' put: #('image/x-freehand');
		at: 'src' put: #('application/x-wais-source');
		at: 'm4' put: #('audio/x-mp4-audio');
		at: 'm4b' put: #('audio/x-quicktime-protected-b');
		at: 'm4p' put: #('audio/x-quicktime-protected');
		at: 'mp4v' put: #('video/x-mp4-video');
		at: 'm4v' put: #('video/x-mp4-video');
		at: 'mp4' put: #('video/x-mp4-video');
		at: 'wma' put: #('audio/x-ms-wma');
		at: 'wmv' put: #('video/x-ms-wmv');
		at: 'wm' put: #('video/x-ms-wm');
		at: 'png' put: #('image/png');
		yourself.
	^mimeTypes

]

{ #category : #accessing }
MIMEType class >> suffixForMimeType: mimeType [
	^self defaultSuffixes at: mimeType ifAbsent: [mimeType sub]
]

{ #category : #comparing }
MIMEType >> = anotherObject [
	anotherObject class == self class
		ifFalse: [^false].
	^self main = anotherObject main
		and: [self sub = anotherObject sub]
]

{ #category : #converting }
MIMEType >> asMIMEType [
	^self
]

{ #category : #comparing }
MIMEType >> beginsWith: aString [
	^self printString beginsWith: aString
]

{ #category : #comparing }
MIMEType >> hash [
	^self main hash bitXor: self sub hash
]

{ #category : #accessing }
MIMEType >> main [
	^main
]

{ #category : #accessing }
MIMEType >> main: mainType [
	main := mainType
]

{ #category : #accessing }
MIMEType >> parameters: params [
	parameters := params
]

{ #category : #printing }
MIMEType >> printOn: stream [
	stream
		nextPutAll: main; nextPut: $/ ; nextPutAll: sub
]

{ #category : #accessing }
MIMEType >> sub [
	^sub
]

{ #category : #accessing }
MIMEType >> sub: subType [
	sub := subType
]
