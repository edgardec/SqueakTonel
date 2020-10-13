Class {
	#name : #InstallerWebSqueakMap,
	#superclass : #InstallerWebBased,
	#instVars : [
		'wsm'
	],
	#category : #'Installer-Core'
}

{ #category : #websqueakmap }
InstallerWebSqueakMap >> basicAvailablePackages [

	| html id name pkgs | 
	pkgs := Dictionary new.
	html := self httpGet: (self wsm, 'packagesbyname').
	
	[ id := html upToAll: '/package/'; upToAll: '">'.
	name := html upTo: $<.
	(id notEmpty and: [ name notEmpty ])] 
		whileTrue: [ pkgs at: name put: id ].

	^ pkgs	
	
]

{ #category : #'basic interface' }
InstallerWebSqueakMap >> basicInstall [
	
	| it |
	it := self wsmThing.
	self install: it from: it asUrl retrieveContents contentStream.

	
]

{ #category : #'basic interface' }
InstallerWebSqueakMap >> basicVersions [

	| pkgAndVersion packageId packageName packageVersion versions |
	pkgAndVersion := self packageAndVersionFrom: self package .
	packageName := pkgAndVersion first.
	packageVersion := pkgAndVersion last.
	packageVersion isEmpty ifTrue: [ packageVersion := #latest ].
	packageId := self availablePackages at: packageName.
	versions := (self wsmReleasesFor: packageId) keys asSet.
	versions remove: #latest.
	^ versions collect: [ :version | self copy package: (packageName,'(', version ,')'); yourself ]. 
]

{ #category : #'basic interface' }
InstallerWebSqueakMap >> basicView [
	
	| it |
	it := self wsmThing.
	self view: it from: (self httpGet: it).

	
]

{ #category : #searching }
InstallerWebSqueakMap >> packagesMatching: aMatch [
	^ (self availablePackages
		select: [ :p | ( aMatch) match: p ]) 
		collect: [ :p | self copy package: p ; yourself ]
]

{ #category : #websqueakmap }
InstallerWebSqueakMap >> wsm [
	
	^ wsm
]

{ #category : #websqueakmap }
InstallerWebSqueakMap >> wsm: aUrl [
 
	wsm := aUrl last = $/ ifTrue: [ aUrl ] ifFalse: [ aUrl, '/' ]
]

{ #category : #websqueakmap }
InstallerWebSqueakMap >> wsmDownloadUrl [ 
	| pkgAndVersion packageId packageName packageVersion releaseAutoVersion
 	downloadPage |

	pkgAndVersion := self packageAndVersionFrom: self package.
	packageName := pkgAndVersion first.
	packageVersion := pkgAndVersion last.
	packageVersion isEmpty ifTrue: [ packageVersion := #latest ].

	packageId := self availablePackages at: packageName.
	releaseAutoVersion := (self wsmReleasesFor: packageId) at: packageVersion.
					 
	downloadPage := self httpGet: (self wsm,'packagebyname/', packageName,'/autoversion/', releaseAutoVersion,'/downloadurl') asUrl asString.
				 		 
	^ downloadPage contents
	

]

{ #category : #websqueakmap }
InstallerWebSqueakMap >> wsmReleasesFor: packageId [

	| html autoVersion version releases |
	releases := Dictionary new.
	html := self httpGet: (self wsm, '/package/', packageId ).
	[releases at: #latest put: autoVersion.
	autoVersion := html upToAll: '/autoversion/'; upTo: $".
	version := html upTo: $-; upTo: $<.
	(autoVersion notEmpty and: [version notEmpty ])] 
		whileTrue: [ releases at: version put: autoVersion ].
	^ releases
	
]

{ #category : #websqueakmap }
InstallerWebSqueakMap >> wsmThing [

	| downloadUrl |
	self logCR: 'finding ', self package, ' from websqueakmap(', self wsm, ') ...'.
	downloadUrl := self wsmDownloadUrl.
	self logCR: 'found at ', downloadUrl asString, ' ...'.
	^ downloadUrl
	
]
