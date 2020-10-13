Class {
	#name : #InstallerUpdateStream,
	#superclass : #Installer,
	#category : #'Installer-Core'
}

{ #category : #updates }
InstallerUpdateStream >> changesetNamesFromUpdates: startNumber through: stopNumber [
	"Answer the concatenation of summary strings for updates numbered in the given range"
	"self new changesetNamesFromUpdates: 7059 through: 7061"
	
	^ String streamContents: [:aStream |
		((ChangeSet changeSetsNamedSuchThat:
			[:aName | aName first isDigit
						and: [aName initialIntegerOrNil >= startNumber
						and: [aName initialIntegerOrNil <= stopNumber]]]) asArray
				sort: [:a :b | a name < b name])
					do: [:aChangeSet | aStream cr; nextPutAll: aChangeSet summaryString]]




]

{ #category : #updates }
InstallerUpdateStream >> loadUpdatesFromDisk [
	
	| updateDirectory updateNumbers |
	updateDirectory := self updateDirectoryOrNil.
	updateDirectory ifNil: [^ self].
	updateNumbers := updateDirectory fileNames
						collect: [:fn | fn initialIntegerOrNil]
						thenSelect: [:fn | fn notNil].
	
	self loadUpdatesFromDiskToUpdateNumber: updateNumbers max
		stopIfGap: false
		
	
]

{ #category : #updates }
InstallerUpdateStream >> loadUpdatesFromDiskToUpdateNumber: lastUpdateNumber stopIfGap: stopIfGapFlag [ 
	"To use this mechanism, be sure all updates you want to have considered 
	are in a folder named 'updates' which resides in the same directory as  
	your image. Having done that, simply evaluate:  
	 
	Installer new loadUpdatesFromDiskToUpdateNumber: 100020 stopIfGap: false  
	 
	and all numbered updates <= lastUpdateNumber not yet in the image will 
	be loaded in numerical order."
	
	"apparently does not use the updatelist too bad! and to rewrite - sd 7 March 2008"
	| previousHighest currentUpdateNumber done fileNames aMessage updateDirectory loaded |
	updateDirectory := self updateDirectoryOrNil.
	updateDirectory ifNil: [^ self].
	previousHighest := SystemVersion current highestUpdate.
	currentUpdateNumber := previousHighest.
	done := false.
	loaded := 0.
	[done]
		whileFalse: [currentUpdateNumber := currentUpdateNumber + 1.
			currentUpdateNumber > lastUpdateNumber
				ifTrue: [done := true]
				ifFalse: [fileNames := updateDirectory fileNamesMatching: currentUpdateNumber printString , '*'.
					fileNames size > 1
						ifTrue: [^ self inform: 'ambiguity -- two files both start with ' , currentUpdateNumber printString , '
(at this point it is probably best to remedy
the situation on disk, then try again.)'].
					fileNames size = 0
						ifTrue: [Transcript cr; show: 'gap in updates from disk for update number '; print: currentUpdateNumber; show: ' found...'.
							done := stopIfGapFlag]
						ifFalse: [ChangeSet
								newChangesFromStream: (updateDirectory readOnlyFileNamed: fileNames first)
								named: fileNames first.
							SystemVersion current registerUpdate: currentUpdateNumber.
							loaded := loaded + 1]]].
	aMessage := loaded = 0
				ifTrue: ['No new updates found.']
				ifFalse: [loaded printString , ' update(s) loaded.'].
	self inform: aMessage , '
Highest numbered update is now ' , (currentUpdateNumber - 1) printString , '.'
]

{ #category : #updates }
InstallerUpdateStream >> parseUpdateListContents: listContentString [
	"Parse the contents of an updates.list into {{releaseTag. {fileNames*}}*}, and return it."

	| sections releaseTag strm line fileNames |
	sections := OrderedCollection new.
	fileNames := OrderedCollection new: 1000.
	releaseTag := nil.
	strm := ReadStream on: listContentString.
	[strm atEnd] whileFalse:
		[line := strm nextLine.
		line size > 0 ifTrue:
			[line first = $#
				ifTrue: [releaseTag ifNotNil: [sections addLast: {releaseTag. fileNames asArray}].
						releaseTag := line allButFirst.
						fileNames resetTo: 1]
				ifFalse: [line first = $* ifFalse: [fileNames addLast: line]]]].
	releaseTag ifNotNil: [sections addLast: {releaseTag. fileNames asArray}].
	^ sections asArray

]

{ #category : #updates }
InstallerUpdateStream >> updateDirectoryOrNil [

	^ (FileDirectory default directoryNames includes: 'updates')
		ifTrue: [FileDirectory default directoryNamed: 'updates']
		ifFalse: [self inform: 'Error: cannot find "updates" folder'.
				nil]
]

{ #category : #updates }
InstallerUpdateStream >> writeList: listContents toStream: strm [
	"Write a parsed updates.list out as text.
	This is the inverse of parseUpdateListContents:"
	strm reset.
	listContents do:
		[:pair |
		| releaseTag fileNames | 
		releaseTag := pair first.  
		fileNames := pair last.
		strm nextPut: $#; nextPutAll: releaseTag; cr.
		fileNames do: [:fileName | strm nextPutAll: fileName; cr]].
	strm close
]
