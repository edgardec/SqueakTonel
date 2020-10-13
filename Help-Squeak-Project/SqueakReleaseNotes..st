Class {
	#name : #SqueakReleaseNotes,
	#superclass : #SqueakProjectHelp,
	#category : #'Help-Squeak-Project'
}

{ #category : #accessing }
SqueakReleaseNotes class >> asHelpTopic [

	^ DirectoryBasedHelpTopic new
		directoryEntry: (FileDirectory default entryAt: 'release-notes' ifAbsent: []);
		sortBlock: [:t1 :t2 | t1 title >= t2 title];
		title: self bookName
]

{ #category : #accessing }
SqueakReleaseNotes class >> bookName [ 
	^'Release Notes'
]
