Class {
	#name : #InstallerUrl,
	#superclass : #InstallerInternetBased,
	#category : #'Installer-Core'
}

{ #category : #'action report' }
InstallerUrl class >> canReportLine: line [
	^ ((line beginsWith: 'Installer installUrl:') and: 
		[ | ext |
		 ext :=  (line readStream upToAll: '''.') copyAfterLast: $..
		 (#( 'cs' 'st' 'mcz' 'sar') includes: ext) not ])
]

{ #category : #'action report' }
InstallerUrl >> action: line reportOn: report [ 
 
	url :=  line readStream upTo: $' ; upTo: $'.
  	
	self reportSection: line on: report.

	(pageDataStream := self urlGet: self urlToDownload) 
		ifNil: [ self error: 'unable to contact host' ].
	 	
	self reportFor: line page: pageDataStream on: report 
]

{ #category : #'as yet unclassified' }
InstallerUrl >> addPackage: aPackageName [
	super addPackage: aPackageName.
	(self url endsWith: '/') ifFalse: [self url: self url, '/'].
]

{ #category : #'basic interface' }
InstallerUrl >> basicBrowse [
 	"(Installer debug url: 'http://installer.pbwiki.com/f/Installer.st') browse.".
	
	self browse: self urlToDownload from: self urlThing.
	
	

]

{ #category : #'basic interface' }
InstallerUrl >> basicInstall [ 
 	 
	self install: self urlToDownload from: self urlThing.
	^ pageDataStream 

]

{ #category : #'basic interface' }
InstallerUrl >> basicView [
 	 "(Installer debug url: 'http://installer.pbwiki.com/f/Installer.st') view.".
	
	self view: self urlToDownload from: self urlThing.
	
	

]

{ #category : #accessing }
InstallerUrl >> fileInSource [

"
(Installer url: 'http://www.squeaksource.com/Sake/Sake-Core-kph.47.mcz') bootstrap.
"


| pkg splitPos repo getFileName fileName |

useFileIn := true.

splitPos := url lastIndexOf: $/. 

pkg := url copyFrom: splitPos + 1 to: url size.
repo := url copyFrom: 1 to: splitPos.

getFileName := [ :pkgName | pkgName , ((HTTPSocket httpGet: repo) upToAll: pkgName; upTo: $") ].
 
fileName := getFileName value: pkg.

url := repo,fileName.

self install
]

{ #category : #url }
InstallerUrl >> urlThing [
 	| retry delay |
	
	self logCR: 'retrieving ', self urlToDownload , ' ...'.
	
	delay := 0.
	[retry := false.
	pageDataStream := self urlGet: self urlToDownload.
	self wasPbwikiSpeedWarning ifTrue: [
		retry := true. delay := delay + 5.
		self logCR: 'PBWiki speed warning. Retrying in ', delay printString, ' seconds'.
		(Delay forSeconds: delay) wait ].
	retry ] whileTrue.
		
	pageDataStream ifNil: [ self error: 'unable to contact host' ].
	 
	^ pageDataStream
	
]

{ #category : #url }
InstallerUrl >> urlToDownload [

	^ (self url, (self package ifNil: [ '' ])) asUrl asString.
	
 
]
