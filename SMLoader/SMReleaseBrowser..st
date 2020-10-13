"
A browser for specific SqueakMap packages.

- Across the top:
	- version name text input (across the top)
	- parent release (uneditable text)

- Four lists across the width:
	- license single-select.
	- versions multi-select.
	- compatibility single-select.
	- maturity single-select.

X File to upload | elipsis.

- Load-script paragraph | Release notes paragraph.

- Buttons:
	- Save.
	- Cancel.


"
Class {
	#name : #SMReleaseBrowser,
	#superclass : #CodeHolder,
	#instVars : [
		'release',
		'loadScript',
		'smClient'
	],
	#category : #SMLoader
}

{ #category : #open }
SMReleaseBrowser class >> open [
	^ ToolBuilder open: self
]

{ #category : #open }
SMReleaseBrowser class >> openOn: aSMPackageRelease [
	^ ToolBuilder open: (self release: aSMPackageRelease)
]

{ #category : #'instance creation' }
SMReleaseBrowser class >> release: aSMPackageRelease [ 
	^ self new
		 setRelease: aSMPackageRelease ;
		 yourself
]

{ #category : #menu }
SMReleaseBrowser class >> yellowButtonMenuItems [
	"Returns the standard yellow button menu items"
	^super yellowButtonMenuItems, {
			{'update with loaded versions' translated. #updateLoadScript}.
		}
]

{ #category : #'as yet unclassified' }
SMReleaseBrowser >> aboutToStyle: aStyler [
	^ true.
]

{ #category : #toolbuilder }
SMReleaseBrowser >> annotation [
	^ String streamContents:
		[ : stream | stream
			 nextPutAll: 'last saved ' ;
			 print: release updated ]
]

{ #category : #toolbuilder }
SMReleaseBrowser >> buildCodePaneWith: aToolBuilder [ 
	^ (super buildCodePaneWith: aToolBuilder)
		 name: #content ;
		 yourself
]

{ #category : #toolbuilder }
SMReleaseBrowser >> buildWith: aToolBuilder [ 
	| windowSpec row2Top row3Top |
	row2Top := 0.1.
	row3Top := 0.5.
	windowSpec := self
		buildWindowWith: aToolBuilder
		specs: {(0 @ 0 corner: 0.5 @ 0.05) -> (self newVersionSpec: aToolBuilder).
			(0.0 @ 0.05 corner: 0.5@ row2Top) -> (self newAuthenticationPane: aToolBuilder).
			(0.5 @ 0 corner: 1.0 @ row2Top) -> (self newReleaseNotesPaneSpec: aToolBuilder).
			(0@row2Top corner: 0.25@row3Top) -> (self newLicenseListSpec: aToolBuilder).
			(0.25@row2Top corner: 0.50@row3Top) -> (self newSqueakVersionSpec: aToolBuilder).
		(0.50@row2Top corner: 0.75@row3Top) -> (self newCompatibilitySpec: aToolBuilder).
		(0.75@row2Top corner: 1.00@row3Top) -> (self newMaturitySpec: aToolBuilder).
		(0.0@row3Top corner: 1.00@1.00) -> (self buildCodePaneWith: aToolBuilder) }.
	^ aToolBuilder build: windowSpec
]

{ #category : #private }
SMReleaseBrowser >> closeWindow [
	self dependents do:
		[ : each | each isSystemWindow ifTrue: [ each delete ] ]
]

{ #category : #'model access' }
SMReleaseBrowser >> compatibilities [
	^ SMSqueakMap default compatibilityLevels subCategories
]

{ #category : #'model access' }
SMReleaseBrowser >> compatibility [
	^ release compatibility
]

{ #category : #'model access' }
SMReleaseBrowser >> compatibility: aSMCategory [ 
	release compatibility: aSMCategory.
	self changed: #compatibility
]

{ #category : #toolbuilder }
SMReleaseBrowser >> contents [
	^ self loadScript
]

{ #category : #'model access' }
SMReleaseBrowser >> contents: aText [
	self loadScript: aText.
	self changed: #contents
]

{ #category : #'user interface' }
SMReleaseBrowser >> defaultWindowColor [
	^ (Color r: 0.801 g: 0.801 b: 0.614)
]

{ #category : #private }
SMReleaseBrowser >> deleteInstallFile [
	FileDirectory default deleteFileNamed: release scriptName
]

{ #category : #private }
SMReleaseBrowser >> downloadUrl [
	^ self smAccount downloadsDirectory , '/' , release scriptName
]

{ #category : #private }
SMReleaseBrowser >> exampleLoadScript [
	"this is an example load script to offer the user rather than a blank view"
	
	^'"This is where you need to provide an install script; you may need to handle prerequisites first and then load the actual package(s) Take a look at http://wiki.squeak.org/squeak/6182 for more info, especially about creating a ''load latest version'' script"
	"Example to load a prerequisite package - "
	SMSqueakMap default
		installPackageNamed: ''myPackage''
		version: ''release name''.
	"Example to load myPackage if a certain class is not already in the image -"
	(Smalltalk hasClassNamed: #MyPackage)
		ifFalse:[SMSqueakMap default
			installPackageNamed: ''myPackage''
			version: ''release name''].
	"Or load several specifc mcz files -"
	#( ''MyPackagePartA-abc.1.mcz'' ''MyPackagePartB-abc.42.mcz'' ) do:
		[:each| (Installer repository: ''http://www.squeaksource.com/MyPackages'') install: each]'
]

{ #category : #'initialize-release' }
SMReleaseBrowser >> initialize [
	super initialize.
	smClient := SMClient new
]

{ #category : #toolbuilder }
SMReleaseBrowser >> labelString [
	^ String streamContents:
		[ : stream | stream nextPutAll: release package name.
		release version isEmptyOrNil ifFalse:
			[ stream
				 space ;
				 nextPutAll: release version ] ]
]

{ #category : #'model access' }
SMReleaseBrowser >> license [
	^ release license
]

{ #category : #'model access' }
SMReleaseBrowser >> license: aSMCategory [
	release license: aSMCategory.
	self changed: #license
]

{ #category : #'model access' }
SMReleaseBrowser >> licenses [
	"Answer the 'Licenses' subCagegories."
	^ SMSqueakMap default licenses subCategories
]

{ #category : #'model access' }
SMReleaseBrowser >> loadScript [
	"The Smalltalk code needed to install this release of this package."
	^ loadScript
		ifNil: [| scriptName |
			scriptName := release downloadFileName.
			loadScript := scriptName isEmptyOrNil
						ifFalse: [(scriptName asLowercase endsWith: '.st')
								ifTrue: [release contents]]
						ifTrue: [self exampleLoadScript]]
]

{ #category : #'model access' }
SMReleaseBrowser >> loadScript: aString [ 
	"The Smalltalk code needed to load this release of this package."
	loadScript := aString asString.
	self
		 changed: #loadScript ;
		 changed: #contents
]

{ #category : #private }
SMReleaseBrowser >> login [
	smClient login
]

{ #category : #private }
SMReleaseBrowser >> logout [
	smClient close.
	self
		 changed: #username ;
		 changed: #password
]

{ #category : #'model access' }
SMReleaseBrowser >> maturities [
	^ SMSqueakMap default maturityLevels subCategories
]

{ #category : #'model access' }
SMReleaseBrowser >> maturity [
	^ release maturity
]

{ #category : #'model access' }
SMReleaseBrowser >> maturity: aSMCategory [ 
	release maturity: aSMCategory.
	self changed: #maturity
]

{ #category : #toolbuilder }
SMReleaseBrowser >> newAuthenticationPane: aToolBuilder [ 
	^ aToolBuilder pluggablePanelSpec new
		 model: self ;
		 children:
		(OrderedCollection
			with:
				(aToolBuilder pluggableInputFieldSpec new
					 model: self ;
					 name: #username ;
					 help: 'Your SqueakMap Id.' ;
					 getText: #username ;
					 setText: #username: ;
					 frame: (0.02@0 corner: 0.38@1) ;
					 yourself)
			with:
				(aToolBuilder pluggableInputFieldSpec new
					 model: self ;
					 name: #password ;
 					 help: 'Your SqueakMap password.' ;
					 getText: #password ;
					 setText: #password: ;
					 frame: (0.40@0 corner: 0.75@1) ;
					 yourself)
			with:
				(aToolBuilder pluggableButtonSpec new
					 model: self ;
					 help: 'Save this release to the SqueakMap server and close the window.' ;
					 label: 'Save' ;
					 action: #save ;
					 frame: (0.77@0 corner: 0.98@1) ;
					 yourself)) ;
		 yourself
]

{ #category : #toolbuilder }
SMReleaseBrowser >> newCompatibilitySpec: aToolBuilder [
	^ aToolBuilder pluggableListSpec new
		 model: self ;
		 name: #compatibilities ;
		 help: 'Select the type of changes this release makes to the image.' ;
		 autoDeselect: false ;
		 list: #compatibilities ;
		 getSelected: #compatibility ;
		 setSelected: #compatibility: ;
		 yourself
]

{ #category : #toolbuilder }
SMReleaseBrowser >> newLicenseListSpec: aToolBuilder [ 
	^ aToolBuilder pluggableListSpec new
		 model: self ;
		 name: #licenses ;
		 help: 'Select the license for this release.' ;
		 autoDeselect: false ;
		 list: #licenses ;
		 getSelected: #license ;
		 setSelected: #license: ;
		 yourself
]

{ #category : #toolbuilder }
SMReleaseBrowser >> newMaturitySpec: aToolBuilder [
	^ aToolBuilder pluggableListSpec new
		 model: self ;
		 name: #maturities ;
		 help: 'Select the type of changes this release makes to the image.' ;
		 autoDeselect: false ;
		 list: #maturities ;
		 getSelected: #maturity ;
		 setSelected: #maturity: ;
		 yourself
]

{ #category : #toolbuilder }
SMReleaseBrowser >> newReleaseNotesPaneSpec: aToolBuilder [
	^ aToolBuilder pluggableTextSpec new
		model: self ;
		name: #note ;
		help: 'Notes about this release.' ;
		askBeforeDiscardingEdits: true ;
		getText: #note ;
		setText: #note: ;
		yourself
]

{ #category : #toolbuilder }
SMReleaseBrowser >> newSqueakVersionSpec: aToolBuilder [
	^ aToolBuilder pluggableListSpec new
		 model: self ;
		 name: #licenses ;
		 help: 'Select the image version for this release.' ;
		 autoDeselect: false ;
		 list: #squeakVersions ;
		 getSelected: #squeakVersion ;
		 setSelected: #squeakVersion: ;
		 yourself
]

{ #category : #toolbuilder }
SMReleaseBrowser >> newVersionSpec: aToolBuilder [ 
	^ aToolBuilder pluggableInputFieldSpec new
		 model: self ;
		 name: #version ;
		 help: 'Specify the version name of this release.' ;
		 getText: #version ;
		 setText: #version:
]

{ #category : #'model access' }
SMReleaseBrowser >> note [
	^ release note
]

{ #category : #'model access' }
SMReleaseBrowser >> note: aString [ 
	release note: aString.
	self changed: #note
]

{ #category : #toolbuilder }
SMReleaseBrowser >> okToChange [
	"Answer true so that merely selecting different categories doesn't cause a pop-up."
	^ true
]

{ #category : #'model access' }
SMReleaseBrowser >> parentRelease [
	^ release ifNotNil: [ release parentRelease ]
]

{ #category : #'model access' }
SMReleaseBrowser >> parentVersion [
	^ self parentRelease ifNotNil:
		[ : pr | pr version ]
]

{ #category : #'model access' }
SMReleaseBrowser >> password [
	"The SqueakMap password."
	^ smClient password
]

{ #category : #'model access' }
SMReleaseBrowser >> password: aString [
	"The SqueakMap username."
	smClient password: aString asString.
	self changed: #password
]

{ #category : #'initialize-release' }
SMReleaseBrowser >> postInitialize [
	(release downloadUrl endsWith: '.st') ifTrue:
		[ release ensureInCache ifTrue: [ self loadScript: release contents ] ]
]

{ #category : #private }
SMReleaseBrowser >> release [
	^ release
]

{ #category : #private }
SMReleaseBrowser >> representsSameBrowseeAs: anotherModel [
	^ release = anotherModel release
]

{ #category : #'initialize-release' }
SMReleaseBrowser >> save [
	"Save the release to SqueakMap."
	Cursor wait showWhile:
		[ self dependents do:
			[ : eachWidget | #(#username #password #note #version #content ) do:
				[ : eachName | eachWidget knownName = eachName ifTrue:
					[ eachWidget hasUnacceptedEdits ifTrue: [ eachWidget accept ] ] ] ].
		self validateCanSave.
		[ self
			 writeInstallFile ;
			 login.
		"Save without a downloadUrl so that SM will update its cache and we can also verify success before uploading the file."
		self savePackageRelease: nil.
		self loadScript isEmptyOrNil ifFalse:
			[ self uploadInstallFile.
			release package addRelease: release.
			"Now save with the correct downloadUrl."
			self
				 savePackageRelease: self downloadUrl ;
				 deleteInstallFile ] ] ensure: [ self logout ].
		release refreshInCache ].
	self closeWindow
]

{ #category : #private }
SMReleaseBrowser >> savePackageRelease: downloadUrlString [ 
	"We actually save the package-release to the users who is posting it, even if that is different than the owner."
	"Set sha1sum so it will be 'correct' until the next update from the SM server."
	| response |
	release
		 downloadUrl: downloadUrlString ;
		 sha1sum: nil.
	response := smClient save: release.
	(response isSuccess not or:
		[ #('error' 'failed' ) anySatisfy:
			[ : each | response content
				includesSubstring: each
				caseSensitive: false ] ]) ifTrue: [ self error: 'failed' ].
	release
		 removeFromLocalCache ;
		 addToLocalCache
]

{ #category : #'initialize-release' }
SMReleaseBrowser >> setRelease: aSMPackageRelease [
	release := aSMPackageRelease.
	self postInitialize
]

{ #category : #private }
SMReleaseBrowser >> smAccount [
	^ SMSqueakMap default accountForUsername: self username
]

{ #category : #'model access' }
SMReleaseBrowser >> squeakVersion [
	^ release squeakVersion
]

{ #category : #'model access' }
SMReleaseBrowser >> squeakVersion: aSMCategory [ 
	release squeakVersion: aSMCategory.
	self changed: #squeakVersion
]

{ #category : #'model access' }
SMReleaseBrowser >> squeakVersions [
	"Answer the squeak-versions subcategories."
	^ SMSqueakMap default squeakVersions subCategories
]

{ #category : #'model access' }
SMReleaseBrowser >> updateLoadScript [
	self loadScript: self loadScript withLoadedPackageVersions
]

{ #category : #private }
SMReleaseBrowser >> uploadInstallFile [
	| response |
	response := smClient uploadFileNamed: release scriptName.
	(#(200 302) includes: response code) ifFalse: [ self halt: 'non-successful response' ]
]

{ #category : #private }
SMReleaseBrowser >> userError: aString [
	UIManager default inform: aString
]

{ #category : #'model access' }
SMReleaseBrowser >> username [
	"The SqueakMap username."
	^ smClient username
]

{ #category : #'model access' }
SMReleaseBrowser >> username: aString [
	"The SqueakMap username."
	smClient username: aString asString.
	self changed: #username
]

{ #category : #private }
SMReleaseBrowser >> validateCanSave [
	"accept any changes in the text field morphs etc, then validate the input as best we can"
	self changed: #acceptChanges.
	self username isEmptyOrNil ifTrue: [ self userError: 'username required' ].
	self note isEmptyOrNil ifTrue: [ self userError: 'note required' ].
	self version isEmptyOrNil
		ifTrue: [ self userError: 'version required' ]
		ifFalse:
			[ (self version includes: $+) ifTrue: [ self userError: 'Plus sign not allowed in version name because it is reserved by HTTP.' ] ]
]

{ #category : #'model access' }
SMReleaseBrowser >> version [
	^ release ifNotNil: [ release version ]
]

{ #category : #'model access' }
SMReleaseBrowser >> version: aString [ 
	release ifNotNil: [ release version: aString asString ].
	self
		 changed: #version ;
		 changed: #labelString
]

{ #category : #private }
SMReleaseBrowser >> writeInstallFile [
	(FileDirectory default fileExists: release scriptName)
		ifTrue: [Warning signal: release scriptName , ' already exists and will be deleted.'].
	self deleteInstallFile.
	FileStream
		fileNamed: release scriptName
		do: [:stream | stream nextPutAll: self loadScript asString]
]
