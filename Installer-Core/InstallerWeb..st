Class {
	#name : #InstallerWeb,
	#superclass : #InstallerWebBased,
	#classVars : [
		'WebSearchPath'
	],
	#category : #'Installer-Core'
}

{ #category : #'action report' }
InstallerWeb class >> canReportLine: line [
	^ ((line beginsWith: 'Installer install:') | (line beginsWith: 'Installer do:'))
]

{ #category : #instanciation }
InstallerWeb class >> initialize [
	
	WebSearchPath := nil
]

{ #category : #'action report' }
InstallerWeb >> action: line reportOn: report [
	
	self package: (line readStream upTo: $' ; upTo: $').

	self reportSection: line on: report.
	
 	url := self urlToDownload.
	
	self reportFor: line page: pageDataStream on: report 
]

{ #category : #'basic interface' }
InstallerWeb >> basicBrowse [
 
 	 self thing size > 0 
		ifTrue: [ self browse: url from: pageDataStream ]
		ifFalse: [ self logCR: 'NO DATA ',url,' was empty' ].
	 
]

{ #category : #'basic interface' }
InstallerWeb >> basicInstall [
 
 	 self thing size > 0 
		ifTrue: [ self install: url from: pageDataStream ]
		ifFalse: [ url ifNil: [ ^ self logCR: self package, ' not found on webSearchPath' ].
				  self logCR: '...',url,' was empty' ].
	 
]

{ #category : #'basic interface' }
InstallerWeb >> basicView [
 
 	 self thing size > 0 
		ifTrue: [ self view: url from: pageDataStream ]
		ifFalse: [ self logCR: 'NO DATA ',url,' was empty' ].
	 
]

{ #category : #'web install' }
InstallerWeb >> searchPath [
	"a search path item has the following format. prefix*suffix"

	^ WebSearchPath ifNil: [ WebSearchPath := OrderedCollection new ].
]

{ #category : #'web install' }
InstallerWeb >> thing [

	self logCR: 'searching for web package ''', self package, ''''.
 	url := self urlToDownload.
	url ifNil: [ self logCR: 'page ', self package, ' not found on path' ]
		ifNotNil: [ self logCR: 'found ',  url, ' ...'.   ].
	^ pageDataStream
]

{ #category : #'web install' }
InstallerWeb >> urlToDownload [
	"while we look for a url which returns what we are looking for, we get the data anyway"
	
	| delay |
	delay := 0.
	self searchPath do: [ :pathSpec |
		| potentialUrl readPathSpec retry |
		readPathSpec := pathSpec value readStream.
		potentialUrl := (readPathSpec upTo: $*), self package, (readPathSpec upToEnd ifNil: [ '' ]).
		[retry := false.
		pageDataStream := self urlGet: potentialUrl.
		self wasPbwikiSpeedWarning
			ifTrue: [
				retry := true.
				delay := delay + 5. 
				self logCR: 'PBWiki speed warning. Retrying in ', delay printString, ' seconds'.
				(Delay forSeconds: delay) wait]
			ifFalse: [ self hasPage ifTrue: [ pageDataStream reset. ^ potentialUrl ] ].
		retry ] whileTrue
	].
	^nil

]
