"
Search feature is based upon a custom mantis query ceveloped and maintained by Ken Causey <ken@kencausey.com>

Installer mantis bugsAll select: [ :ea | ea status = 'testing' ].
"
Class {
	#name : #InstallerMantis,
	#superclass : #InstallerWebBased,
	#instVars : [
		'ma',
		'bug',
		'desc',
		'date',
		'array',
		'data',
		'status'
	],
	#classVars : [
		'Fixes',
		'Status'
	],
	#category : #'Installer-Core'
}

{ #category : #'action report' }
InstallerMantis class >> canReportLine: line [
	^ line beginsWith: 'Installer mantis fixBug:'
]

{ #category : #accessing }
InstallerMantis class >> fixesApplied [

	^ Fixes ifNil: [ Fixes := OrderedCollection new ].
]

{ #category : #'instance creation' }
InstallerMantis class >> host: host [

	^self new	ma: host; 
			markers: '&quot;fix begin&quot;...&quot;fix test&quot;...&quot;fix end&quot;'; 
			yourself.

]

{ #category : #'instance creation' }
InstallerMantis class >> initialize [

	Status := Dictionary new
		at: '10' put: 'new';
		at: '20' put: 'feedback';
		at: '30' put: 'acknowledged';
		at: '40' put: 'confirmed';
		at: '50' put: 'assigned';
		at: '60' put: 'pending';
		at: '70' put: 'testing';
		at: '80' put: 'resolved';
		at: '90' put: 'closed';
		yourself 
]

{ #category : #accessing }
InstallerMantis >> = other [
	self == other ifTrue: [ ^ true ].
	self species = other species ifFalse: [ ^ false ].
	^ array = other array
]

{ #category : #'action report' }
InstallerMantis >> action: line reportOn: report [
	
	| param mantis |
	mantis := Installer mantis.
	param :=  line readStream upTo: $: ; upTo: $..
	
	mantis setBug: ((param readStream upTo: $'; atEnd)
		 ifTrue: [  param ]
		 ifFalse: [ param readStream upTo: $'; upTo: $' ]).
	
	self reportSection: line on: report.
	report nextPutAll: (mantis replaceEntitiesIn: mantis markersBegin readStream).
	self reportFor: line page: mantis maScript on: report.
	report nextPutAll: (mantis replaceEntitiesIn: mantis markersEnd readStream); cr.
	
]

{ #category : #accessing }
InstallerMantis >> array [

	^ array
]

{ #category : #'public interface' }
InstallerMantis >> browseFile: aFileName [

	^ self browse: aFileName from: (self maThing: aFileName date: nil)
]

{ #category : #accessing }
InstallerMantis >> bug [
	
	^ bug ifNil: [ 
		
		date := ((self dataAtName: 'Updated') replaceAll: $  with: $T) asDateAndTime. 
		desc := (self dataAtName: 'Summary').
		bug := (self dataAtName: 'Id'). 
		self statusInit.
 	]
]

{ #category : #'public interface' }
InstallerMantis >> bug: aBugNo [

	| page |
	self setBug: aBugNo.
	
	page := self maPage.
	date := ((self maRead: page field: 'Date Updated') value replaceAll: $  with: $T) asDateAndTime.
	status := (self maRead: page field: 'Status') value.
"	
Installer mantis bug: 7235 
"
]

{ #category : #'public interface' }
InstallerMantis >> bug: aBugNo browse: aFileName [

	 self setBug: aBugNo.
	^ self browseFile: aFileName
]

{ #category : #'public interface' }
InstallerMantis >> bug: aBugNo fix: aFileName [

	^ self bug: aBugNo fix: aFileName date: nil
]

{ #category : #'public interface' }
InstallerMantis >> bug: aBugNo fix: aFileName date: aDate [
 
	| |
	self setBug: aBugNo.
	self ditchOldChangeSetFor: aFileName.
	self install: aFileName from: (self maThing: aFileName date: aDate).
		
	^ date
]

{ #category : #'public interface' }
InstallerMantis >> bug: aBugNo retrieve: aFileName [

	 self setBug: aBugNo.
	^ (self maStreamForFile: aFileName) contents
]

{ #category : #'public interface' }
InstallerMantis >> bug: aBugNo view: aFileName [
	"Installer mantis bug: 6089 browse: 'TTFSpeedUp-dgd.1.cs'"
	
	 self setBug: aBugNo.
	^ self view: aFileName from: (self maThing: aFileName date: nil)
]

{ #category : #'public interface' }
InstallerMantis >> bugFiles: aBugNo [
 	"provide a list of files associated with the bug in id order"
	"
	Installer mantis bugFiles: 6660.
	"
	self setBug: aBugNo; files
]

{ #category : #'public interface' }
InstallerMantis >> bugFilesView: aBugNo [
 	"provide a list of files associated with the bug in id order"
	"
	Installer mantis bugFiles: 6660.
	"
	self setBug: aBugNo; viewFiles
]

{ #category : #'public interface' }
InstallerMantis >> bugScript: aBugNo [

	^ (self setBug: aBugNo) script
	
	

]

{ #category : #'action report' }
InstallerMantis >> bugsAll [

	^ array ifNil: [
		
		array := ( self bugsSqueak ,  (self dataGetFrom: '/installer_export.php') ) asSet sorted: [ :a :b | a date > b date ]
		
	].

"

Installer mantis bugsAll

"
	

]

{ #category : #search }
InstallerMantis >> bugsClosed [

	^ array ifNil: [ array := self dataGetFrom: '/installer_export.php?closed' ]
]

{ #category : #search }
InstallerMantis >> bugsRelease: version [

	^self bugsAll select: [ :ea | (ea status = 'resolved') and: [ ea fixedIn = version ]]
]

{ #category : #search }
InstallerMantis >> bugsSqueak [

	^ array ifNil: [ array := self dataGetFrom: '/installer_export.php?project=Squeak' ]
	
"
Installer mantis bugsSqueak.
Installer mantis bugsAll.
Installer mantis bugsClosed.

"
]

{ #category : #search }
InstallerMantis >> bugsTesting: version [

	^self bugsAll select: [ :ea | ea status = 'testing' and: [ ea fixedIn = version ]]
]

{ #category : #search }
InstallerMantis >> category [

	^ self dataAtName: 'Category'
	
 "
s bugs collect: [ :ea | ea category ]
"
]

{ #category : #search }
InstallerMantis >> dataAtName: key [
	
	^ array at: (self dataNames indexOf: key)
]

{ #category : #search }
InstallerMantis >> dataAtName: key put: v [
	
	^ array at: (self dataNames indexOf: key) put: v
]

{ #category : #search }
InstallerMantis >> dataClosed [

	^ array ifNil: [ array := self dataGetFrom: '/installer_export.php?closed' ]
]

{ #category : #'public interface' }
InstallerMantis >> dataGetFrom: aPath [

	| rs line first col row out |
		
	rs := HTTPSocket httpGet: ma, aPath.
	
	rs isString ifTrue: [ ^ ProtocolClientError signal: 'notFound' ].
	
	first := true.
	
	out := OrderedCollection new.
	
	[ rs atEnd ] whileFalse: [ 
		
		line := rs nextLine readStream.
		col := 1.
		row := Array new: 9.
		[ (line atEnd or: [ col > 9 ]) ] whileFalse: [ row at: col put: (line upTo: $|). col := col + 1 ].	

		rs next.
		[ out add: (self class new in: self row: row) ] ifError: []
		
	 ].
		
	^ out
"
self reset.
self getBugsList 
"
]

{ #category : #'public interface' }
InstallerMantis >> dataNames [

	^ #(Id Project Category Assigned Updated Status Severity FixedIn Summary)
]

{ #category : #accessing }
InstallerMantis >> date [ 

	^ date 
]

{ #category : #accessing }
InstallerMantis >> date: anObject [

	date := anObject ifNotNil: [anObject asDate ]
]

{ #category : #accessing }
InstallerMantis >> desc [
	 
	^ desc
]

{ #category : #accessing }
InstallerMantis >> desc: anObject [

	desc := anObject
]

{ #category : #'public interface' }
InstallerMantis >> ensureFix [

	| fixesAppliedNumbers |
	
	fixesAppliedNumbers := self fixesApplied collect: [ :fixDesc | fixDesc asInteger ].
	(fixesAppliedNumbers includes: bug) ifFalse: [ self fixBug ]
]

{ #category : #'public interface' }
InstallerMantis >> ensureFix: aBugNo [

	^self ensureFix: aBugNo date: nil
]

{ #category : #'public interface' }
InstallerMantis >> ensureFix: aBugNo date: aDate [

	self setBug: aBugNo.
	self date: aDate.
	
	self ensureFix.
]

{ #category : #'public interface' }
InstallerMantis >> ensureFixes: aBugNos [

	aBugNos do: [ :bugNo | self ensureFix: bugNo ].
]

{ #category : #'public interface' }
InstallerMantis >> files [
 	"provide a list of files associated with the bug in id order"
	"
	Installer mantis bugFiles: 6660.
	"
	^self maFiles associations 
		sort: [ :a :b | a value asInteger < b value asInteger ];
		replace: [ :a | a key ]
]

{ #category : #'public interface' }
InstallerMantis >> fixBug [

 	self install: self maUrl from: self maScript.
	self maCheckDateAgainst: date.
		
	self fixesAppliedNumbers in: [ :fixed |
		(fixed isEmpty or: [ (fixed includes: bug asInteger) not]) 
		ifTrue: [ self fixesApplied add: (bug asString, ' ', desc) ]].

	
	

]

{ #category : #'public interface' }
InstallerMantis >> fixBug: aBugNo [ 

	^ self fixBug: aBugNo date: nil.
	

]

{ #category : #'public interface' }
InstallerMantis >> fixBug: aBugNo date: aDate [

	self setBug: aBugNo.
 	self date: aDate.
	self fixBug.
	

]

{ #category : #search }
InstallerMantis >> fixedIn [

	^ self dataAtName: 'FixedIn'

]

{ #category : #'public interface' }
InstallerMantis >> fixesApplied [

	^ Fixes ifNil: [ Fixes := OrderedCollection new ].
]

{ #category : #'public interface' }
InstallerMantis >> fixesAppliedNumbers [
	^ self fixesApplied collect: [ :fixDesc | fixDesc asInteger ]. 
]

{ #category : #accessing }
InstallerMantis >> getView [

	"Installer mantis viewBug: 5639."
	| page text | 
	
	page := self maPage.
 
	text := String streamContents: [ :str |	
			
		#('Bug ID' 'Category' 'Severity' 'Reproducibility' 'Date Submitted' 
			'Date Updated' 'Reporter' 'View Status' 'Handler' 
			'Priority' 'Resolution' 'Status' 'Product Version' 'Summary' 'Description' 'Additional Information' ) 
				do: [ :field |
						| f |
						f := self maRead: page field: field.
			str nextPutAll: f key; nextPutAll: ': '; nextPutAll: f value; cr.
		].
	
	str nextPutAll: 'Notes: '; cr.
		(self maReadNotes: page) do: [ :note | str nextPutAll: note; cr; cr ].
		
		str nextPutAll: 'Files: '; nextPutAll: self maFiles keys asArray printString.
	].
 	^ text	

]

{ #category : #accessing }
InstallerMantis >> hash [

	^ array hash
]

{ #category : #'public interface' }
InstallerMantis >> in: parent row: dataRow [

	self ma: parent ma.
	self markers: parent markers.
	self setArray: dataRow.
]

{ #category : #'public interface' }
InstallerMantis >> justFixBug: aBugNo [

	^self class skipLoadingTests: true during: [ self fixBug: aBugNo date: nil ]
]

{ #category : #'public interface' }
InstallerMantis >> justFixBug: aBugNo date: d [

	^self class skipLoadingTests: true during: [ self fixBug: aBugNo date: d ]
]

{ #category : #accessing }
InstallerMantis >> ma [

	^ ma
]

{ #category : #accessing }
InstallerMantis >> ma: aUrl [

	ma := aUrl last = $/ ifTrue: [ aUrl ] ifFalse: [ aUrl, '/' ]
]

{ #category : #utils }
InstallerMantis >> maCheckDateAgainst: okDate [

	(okDate notNil and: [date < okDate asDate ]) 
		ifTrue: [ self notify: 'bug ', self bug asString, ' updated on ', date printString ].
 
]

{ #category : #mantis }
InstallerMantis >> maFiles [
 	| file files bugPage id  | 
 	files := Dictionary new.
 	bugPage := self maPage.
	 [ 
		id := bugPage upToAll: 'href="file_download.php?file_id='; upTo: $&. 
 		file := bugPage upToAll: 'amp;type=bug"' ; upTo: $<.
 		((file size > 1) and: [file first = $>]) ifTrue: [ files at: file copyWithoutFirst put: id ].
 		id notEmpty ] whileTrue.

	^files 
]

{ #category : #mantis }
InstallerMantis >> maPage [
  	"  self mantis bug: 5251."

	| page |
	page :=  self httpGet: self maUrl.
 	date := ((self maRead: page field: 'Date Updated') value copyUpTo: $ ).
	date isEmpty ifTrue: [ ^self error: bug asString, ' not found' ].
	date := date asDate.
 	^page reset
]

{ #category : #mantis }
InstallerMantis >> maRead: page field: fieldKey [

	 | value |
 
	value := page upToAll: ('!-- ', fieldKey, ' -->'); upToAll: '<td'; upTo: $>; upToAll: '</td>'.
	
	page upTo: $<.
	
	page peek = $t ifTrue: [ value := page upToAll: 'td'; upTo: $>; upToAll: '</td>' ].
	  
	^Association key: fieldKey value: (self removeHtmlMarkupFrom: value withBlanksTrimmed readStream) contents
]

{ #category : #mantis }
InstallerMantis >> maReadNotes: page [ 

	 |  notes note  |
 
	notes := OrderedCollection new.

	[ page upToAll: 'tr class="bugnote"'; upTo: $>.
	  page atEnd ]
		
	whileFalse: [ 
		note := (self removeHtmlMarkupFrom: (page upToAll: '</tr>') readStream) contents.
		note := note withBlanksCondensed.
		note replaceAll: Character lf with: Character cr.
		notes add: note  
	].
	
	^notes
]

{ #category : #mantis }
InstallerMantis >> maScript [ 

	^self extractFromHtml: self maPage option: #last

]

{ #category : #mantis }
InstallerMantis >> maStreamForFile: aFileName [

	| fileId  |

 	fileId :=  self maFiles at: aFileName ifAbsent: [ self error: aFileName, ' not found' ].

 	^ self httpGet: (self ma, 'file_download.php?file_id=' , fileId , '&type=bug').
	 
]

{ #category : #mantis }
InstallerMantis >> maThing: aFileName date: aDate [
 
	self logCR: 'obtaining ', aFileName, '...'.

	pageDataStream := self maStreamForFile: aFileName.

	self maCheckDateAgainst: aDate.

	^ pageDataStream
	
]

{ #category : #mantis }
InstallerMantis >> maUrl [
 
	^ url := self ma, 'view.php?id=', bug asString
 
]

{ #category : #mantis }
InstallerMantis >> maUrlFor: maBugNo [
 
	^ url := self ma, 'view.php?id=', maBugNo asString 
 
]

{ #category : #accessing }
InstallerMantis >> printOn: stream [

	super printOn: stream.
	
	(array ifNil: [ ^ self ]) printOn: stream.
]

{ #category : #search }
InstallerMantis >> project [

	^ self dataAtName: 'Project'

]

{ #category : #'public interface' }
InstallerMantis >> report [

	"Installer mantis viewBug: 5639."
	| page text | 
	
	page := self maPage.
 
	text := String streamContents: [ :str |	
			
		#('Bug ID' 'Category' 'Severity' 'Reproducibility' 'Date Submitted' 
			'Date Updated' 'Reporter' 'View Status' 'Handler' 
			'Priority' 'Resolution' 'Status' 'Product Version' 'Summary' 'Description' 'Additional Information' ) 
				do: [ :field |
						| f |
						f := self maRead: page field: field.
			str nextPutAll: f key; nextPutAll: ': '; nextPutAll: f value; cr.
		].
	
	str nextPutAll: 'Notes: '; cr.
		(self maReadNotes: page) do: [ :note | str nextPutAll: note; cr; cr ].
		
		str nextPutAll: 'Files: '; nextPutAll: self maFiles keys asArray printString.
	].
 	^ text	

]

{ #category : #'public interface' }
InstallerMantis >> script [

 	^ self maScript contents.
	 
	
	

]

{ #category : #'public interface' }
InstallerMantis >> selectCategoryCollections [

	^ self select: [ :ea | ea category = 'Collections' ]
]

{ #category : #'public interface' }
InstallerMantis >> setArray: dataRow [

	(array := dataRow) ifNotNil: [ self bug ].
]

{ #category : #mantis }
InstallerMantis >> setBug: stringOrNumber [

	| newBug |
	
	(newBug := stringOrNumber asInteger) = bug ifTrue: [ ^ self ].
	
	self logCR: 'Installer accessing bug: ' , stringOrNumber asString.

 	bug := newBug.
	
 	stringOrNumber = bug ifTrue: [ desc := ''. ^ self ].

	desc := stringOrNumber withoutLeadingDigits  
]

{ #category : #accessing }
InstallerMantis >> status [ 

	^ status
]

{ #category : #accessing }
InstallerMantis >> statusInit [

	status ifNil: [ status := Status at: (self dataAtName: 'Status').
		self dataAtName:'Status' put: status.
	].

	
]

{ #category : #search }
InstallerMantis >> summary [

	^ self dataAtName: 'Summary'
]

{ #category : #'action report' }
InstallerMantis >> validChangeSetName: aFileName [

	| csn prefix |

	csn := super validChangeSetName: aFileName.
	prefix := 'M' , self bug asInteger asString.

	csn := csn replaceAll: ('-', prefix) with: ''.
	csn := csn replaceAll: (prefix,'-') with: ''.
	csn := csn replaceAll: prefix with: ''.
	
	^ prefix, '-', csn 	
	
]

{ #category : #'public interface' }
InstallerMantis >> view [
	
	^ Workspace new contents: self report; openLabel: ('Mantis ', bug printString).

]

{ #category : #'public interface' }
InstallerMantis >> viewBug: aBugNo [

	self setBug: aBugNo; view
]

{ #category : #'public interface' }
InstallerMantis >> viewFile: aFileName [
	"Installer mantis bug: 6089 browse: 'TTFSpeedUp-dgd.1.cs'"
	
	^ self view: aFileName from: (self maThing: aFileName date: nil)
]

{ #category : #'public interface' }
InstallerMantis >> viewFiles [
	
	^ self files do: [ :ea | self viewFile: ea ].
]
