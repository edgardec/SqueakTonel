"
A Uniform Resource Locator.  It specifies the location of a document on the Internet.  The base class is abstract; child classes break different types of URLs down in ways appropriate for that type.
"
Class {
	#name : #Url,
	#superclass : #Object,
	#instVars : [
		'fragment'
	],
	#classVars : [
		'SchemeRegistry'
	],
	#category : #'Network-Url'
}

{ #category : #parsing }
Url class >> absoluteFromFileNameOrUrlString: aString [
	"Return a URL from and handle Strings without schemes
	as local relative FileUrls instead of defaulting to a HttpUrl
	as absoluteFromText: does."

	^(Url schemeNameForString: aString)
		ifNil: [aString asUrlRelativeTo: FileDirectory default asUrl]
		ifNotNil: [Url absoluteFromText: aString]
]

{ #category : #parsing }
Url class >> absoluteFromText: aString [
	"Return a URL from a string and handle
	a String without a scheme as a HttpUrl."

	"Url absoluteFromText: 'http://chaos.resnet.gatech.edu:8000/docs/java/index.html?A%20query%20#part'" 
	"Url absoluteFromText: 'msw://chaos.resnet.gatech.edu:9000/testbook?top'"
	"Url absoluteFromText: 'telnet:chaos.resnet.gatech.edu'"
	"Url absoluteFromText: 'file:/etc/passwd'"

	| remainder index scheme fragment newUrl |
	"trim surrounding whitespace"
	remainder := aString withBlanksTrimmed.	

	"extract the fragment, if any"
	index := remainder indexOf: $#.
	index > 0 ifTrue: [
		fragment := remainder copyFrom: index + 1 to: remainder size.
		remainder := remainder copyFrom: 1 to: index - 1].

	"choose class based on the scheme name, and let that class do the bulk of the parsing"
	scheme := self schemeNameForString: remainder.
	newUrl := (self urlClassForScheme: scheme) new privateInitializeFromText: remainder.
	newUrl privateFragment: fragment.
	^newUrl
]

{ #category : #parsing }
Url class >> combine: baseURL withRelative: relURL [ 
	"Take two URL as string form, combine them and return the corresponding URL in string form"

	^((self absoluteFromText: baseURL) newFromRelativeText: relURL) asString
]

{ #category : #'class initialization' }
Url class >> initialize [

	SchemeRegistry := Dictionary new
		at: 'browser' put: BrowserUrl;
		at: 'file' put: FileUrl;
		at: 'ftp' put: FtpUrl;
		at: 'http' put: HttpUrl;
		at: 'https' put: HttpUrl;
		at: 'mailto' put: MailtoUrl;
		at: nil put: HttpUrl;
		yourself
]

{ #category : #'class initialization' }
Url class >> registerUrlClass: aClass forScheme: aString [
	SchemeRegistry at: aString put: aClass.
]

{ #category : #parsing }
Url class >> schemeNameForString: aString [
	"Get the scheme name from a string, or return nil if it's not specified. 
	Used in internal parsing routines - an outsider may as well use asUrl. 
	Return scheme in lowercases."
	
	"Url schemeNameForString: 'http://www.yahoo.com'"
	"Url schemeNameForString: '/etc/passwed'"
	"Url schemeNameForString: '/etc/testing:1.2.3'"

	| index schemeName |
	index := aString indexOf: $: ifAbsent: [^ nil].
	schemeName := aString first: index - 1.
	(schemeName allSatisfy: [:each | each isLetter]) ifFalse: [^ nil].
	^ schemeName asLowercase
]

{ #category : #parsing }
Url class >> urlClassForScheme: scheme [
	^ SchemeRegistry at: scheme ifAbsent: [GenericUrl].
]

{ #category : #downloading }
Url >> activate [
	"spawn an external handler for this URL"
	
]

{ #category : #converting }
Url >> asText [
	^self asString asText
]

{ #category : #converting }
Url >> asURI [
	^self asString asURI
]

{ #category : #converting }
Url >> asUrl [
	^self
]

{ #category : #converting }
Url >> asUrlRelativeTo: aUrl [
	^self
]

{ #category : #accessing }
Url >> authority [
	^''
]

{ #category : #converting }
Url >> downloadUrl [
	^self asString
]

{ #category : #fragment }
Url >> fragment [
	^fragment
]

{ #category : #downloading }
Url >> hasContents [
	"whether this URL can download contents to be displayed; if not, it fundamentally requires an outside application to deal with it.  For example, mailto: and telnet: urls"
	^false
]

{ #category : #classification }
Url >> hasRemoteContents [
	"Return true if the receiver describes some remotely accessible content.
	Typically, this should only return if we could retrieve the contents
	on an arbitrary place in the outside world using a standard browser.
	In other words: If you can get to it from the next Internet Cafe, 
	return true, else return false."
	^false
]

{ #category : #parsing }
Url >> newFromRelativeText: aString [
	"return a URL relative to the current one, given by aString.  For instance, if self is 'http://host/dir/file', and aString is '/dir2/file2', then the return will be a Url for 'http://host/dir2/file2'"

	"if the scheme is the same, or not specified, then use the same class"

	| newSchemeName remainder fragmentStart newFragment newUrl bare |

	bare := aString withBlanksTrimmed.
	newSchemeName := Url schemeNameForString: bare.
	(newSchemeName isNil not and: [ newSchemeName ~= self schemeName ]) ifTrue: [
		"different scheme -- start from scratch"
		^Url absoluteFromText: aString ].

	remainder := bare.

	"remove the fragment, if any"
	fragmentStart := remainder indexOf: $#.
	fragmentStart > 0 ifTrue: [
		newFragment := remainder copyFrom: fragmentStart+1 to: remainder size. 
		remainder := remainder copyFrom: 1 to: fragmentStart-1].

	"remove the scheme name"
	newSchemeName ifNotNil: [
		remainder := remainder copyFrom: (newSchemeName size + 2) to: remainder size ].

	"create and initialize the new url"
	newUrl := self class new privateInitializeFromText: remainder  relativeTo: self.


	"set the fragment"
	newUrl privateFragment: newFragment.


	^newUrl
]

{ #category : #printing }
Url >> printOn: aStream [
	^self subclassResponsibility
]

{ #category : #fragment }
Url >> privateFragment: aString [
	fragment := aString
]

{ #category : #parsing }
Url >> privateInitializeFromText: aString [
	^self subclassResponsibility
]

{ #category : #parsing }
Url >> privateInitializeFromText: aString relativeTo: aUrl [
	"initialize from the given string, as a relative URL.  aString will have had the scheme name removed, if it was present to begin with.  If it was, then the scheme name was the same as the receiver's scheme name"

	"by default, just do regular initialization"
	^self privateInitializeFromText: aString
]

{ #category : #downloading }
Url >> retrieveContents [
	"return a MIMEObject with the object's contents, or nil if the object could not be retrieved"
	^nil
]

{ #category : #downloading }
Url >> retrieveContentsForBrowser: aBrowser [
	"return a MIMEObject with the object's contents, or nil if the object could not be retrieved.  Since aBrowser is specified, this could do browser specific things"
	^self retrieveContents
]

{ #category : #classification }
Url >> scheme [
	"return a string with the scheme of this URL.  For instance, HTTP"
	^self subclassResponsibility
]

{ #category : #classification }
Url >> schemeName [
	"return a lowercase string with the scheme of this URL.  For instance, 'http'"
	^self subclassResponsibility
]

{ #category : #printing }
Url >> toText [
	self deprecated: 'Use Url>>asText instead'.
	^ self asString.
]

{ #category : #fragment }
Url >> withFragment: newFragment [
	"return a URL which is the same except that it has a different fragment"
	^self copy privateFragment: newFragment; yourself
]

{ #category : #fragment }
Url >> withoutFragment [
	"return a URL which is identical to the receiver except that it has no fragment associated with it"
	^self withFragment: nil
]
