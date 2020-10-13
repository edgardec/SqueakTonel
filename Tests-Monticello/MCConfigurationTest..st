"
A MCConfigurationTest verifies reading and writing configuration maps as stored on a SqueakSource server. It tests the original MCConfiguration, as well as the extended MCConfigurationExtended that supports versioning of configurations maps. Compatability tests ensure that configurations saved in the new format can be used with existing images that support only the original format.
"
Class {
	#name : #MCConfigurationTest,
	#superclass : #TestCase,
	#instVars : [
		'sampleMcmFileContents',
		'sampleMcmStorageArray',
		'sampleMcmStorageArrayExtended',
		'sampleMcmFileContentsExtended',
		'sampleMcmFileContentsWithHistory'
	],
	#category : #'Tests-Monticello'
}

{ #category : #running }
MCConfigurationTest >> sampleMcmFileContents [
	"Contents of an MCM file with multiple repositories and dependencies, as saved in
	the original MCM file storage format"

	"MCConfigurationTest new sampleMcmFileContents"

	^ '(
name ''update.V3-dtl.464''
repository (''http://source.squeak.org/trunk'')
repository (''http://www.squeaksource.com/TrunkUpdateStreamV3'')
dependency (''Kernel'' ''Kernel.V3-dtl.1319'' ''18bad077-f877-4b68-bcfd-04716bdd807d'')
dependency (''Compiler'' ''Compiler.V3-dtl.419'' ''353d296d-24a6-49f2-9b44-e8f8e216ec35'')
dependency (''Collections'' ''Collections.V3-dtl.882'' ''9c3d454c-d010-49b7-b52d-c82a89ad9c71'')
dependency (''Monticello'' ''Monticello-nice.716'' ''a1f8545a-b4f8-4bae-b349-e8bbba23816e'')
dependency (''Files'' ''Files-pre.183'' ''c7d0c859-2531-464e-87d8-3b580249731b'')
dependency (''Sound'' ''Sound-dtl.68'' ''c7b5a141-2b1b-4d24-ab88-0a96dd78600b'')
)
'

]

{ #category : #running }
MCConfigurationTest >> sampleMcmFileContentsExtended [
	"Contents of an MCM file with multiple repositories and dependencies, as saved in
	the extended MCM file storage format"

	"MCConfigurationTest new sampleMcmFileContentsExtended"

	^ '(
name ''update.V3-dtl.464''
repository (''http://source.squeak.org/trunk'')
repository (''http://www.squeaksource.com/TrunkUpdateStreamV3'')
dependency (''Kernel'' ''Kernel.V3-dtl.1319'' ''18bad077-f877-4b68-bcfd-04716bdd807d'')
dependency (''Compiler'' ''Compiler.V3-dtl.419'' ''353d296d-24a6-49f2-9b44-e8f8e216ec35'')
dependency (''Collections'' ''Collections.V3-dtl.882'' ''9c3d454c-d010-49b7-b52d-c82a89ad9c71'')
dependency (''Monticello'' ''Monticello-nice.716'' ''a1f8545a-b4f8-4bae-b349-e8bbba23816e'')
dependency (''Files'' ''Files-pre.183'' ''c7d0c859-2531-464e-87d8-3b580249731b'')
dependency (''Sound'' ''Sound-dtl.68'' ''c7b5a141-2b1b-4d24-ab88-0a96dd78600b'')
mcmVersion ''2''
id ''891fc3c1-a046-4f61-81f3-49444f8d7906''
authorInitials ''dtl''
timeStamp ''2020-04-10T15:00:06.887746-04:00''
comment ''A comment describing this version of the configuration map''
)
'

]

{ #category : #running }
MCConfigurationTest >> sampleMcmFileContentsWithHistory [
	"Contents of an MCM file with multiple repositories and dependencies and two
	prior versions in its history."

	"MCConfigurationTest new sampleMcmFileContentsWithHistory"

	^ '(
name ''update.V3-dtl.464''
repository (''http://source.squeak.org/trunk'')
repository (''http://www.squeaksource.com/TrunkUpdateStreamV3'')
dependency (''Kernel'' ''Kernel.V3-dtl.1319'' ''18bad077-f877-4b68-bcfd-04716bdd807d'')
dependency (''Compiler'' ''Compiler.V3-dtl.419'' ''353d296d-24a6-49f2-9b44-e8f8e216ec35'')
dependency (''Collections'' ''Collections.V3-dtl.882'' ''9c3d454c-d010-49b7-b52d-c82a89ad9c71'')
dependency (''Monticello'' ''Monticello-nice.716'' ''a1f8545a-b4f8-4bae-b349-e8bbba23816e'')
dependency (''Files'' ''Files-pre.183'' ''c7d0c859-2531-464e-87d8-3b580249731b'')
dependency (''Sound'' ''Sound-dtl.68'' ''c7b5a141-2b1b-4d24-ab88-0a96dd78600b'')
mcmVersion ''2''
id ''891fc3c1-a046-4f61-81f3-49444f8d7906''
authorInitials ''dtl''
timeStamp ''2020-04-10T15:00:06-04:00''
comment ''A comment describing this version of the configuration map''
Xname ''update.V3-dtl.464''
Xrepository (''http://source.squeak.org/trunk'')
Xrepository (''http://www.squeaksource.com/TrunkUpdateStreamV3'')
Xdependency (''Kernel'' ''Kernel.V3-dtl.1319'' ''18bad077-f877-4b68-bcfd-04716bdd807d'')
Xdependency (''Compiler'' ''Compiler.V3-dtl.419'' ''353d296d-24a6-49f2-9b44-e8f8e216ec35'')
Xdependency (''Collections'' ''Collections.V3-dtl.882'' ''9c3d454c-d010-49b7-b52d-c82a89ad9c71'')
Xdependency (''Monticello'' ''Monticello-nice.716'' ''a1f8545a-b4f8-4bae-b349-e8bbba23816e'')
Xdependency (''Files'' ''Files-pre.183'' ''c7d0c859-2531-464e-87d8-3b580249731b'')
Xdependency (''Sound'' ''Sound-dtl.68'' ''9c3d454c-d010-49b7-b52d-c82a89ad9c71'')
XmcmVersion ''2''
Xid ''d5bf283d-56f9-462d-9434-5cd8f074ab6d''
XauthorInitials ''dtl''
XtimeStamp ''2020-04-10T15:00:08.887746-04:00''
Xcomment ''A comment describing the prior version of the configuration map''
Xname ''update.V3-dtl.464''
Xrepository (''http://source.squeak.org/trunk'')
Xrepository (''http://www.squeaksource.com/TrunkUpdateStreamV3'')
Xdependency (''Kernel'' ''Kernel.V3-dtl.1319'' ''18bad077-f877-4b68-bcfd-04716bdd807d'')
Xdependency (''Compiler'' ''Compiler.V3-dtl.419'' ''353d296d-24a6-49f2-9b44-e8f8e216ec35'')
Xdependency (''Collections'' ''Collections.V3-dtl.882'' ''9c3d454c-d010-49b7-b52d-c82a89ad9c71'')
Xdependency (''Monticello'' ''Monticello-nice.716'' ''a1f8545a-b4f8-4bae-b349-e8bbba23816e'')
Xdependency (''Files'' ''Files-pre.183'' ''c7d0c859-2531-464e-87d8-3b580249731b'')
Xdependency (''Sound'' ''Sound-dtl.68'' ''c7b5a141-2b1b-4d24-ab88-0a96dd78600b'')
)
'
]

{ #category : #running }
MCConfigurationTest >> sampleMcmStorageArray [
	"Array scanned from an MCM file with multiple repositories and dependencies in
	the original MCM file storage format"

	"MCConfigurationTest new sampleMcmStorageArray"

	^ #(#name 'update.V3-dtl.464' #repository #('http://source.squeak.org/trunk') #repository #('http://www.squeaksource.com/TrunkUpdateStreamV3') #dependency #('Kernel' 'Kernel.V3-dtl.1319' '18bad077-f877-4b68-bcfd-04716bdd807d') #dependency #('Compiler' 'Compiler.V3-dtl.419' '353d296d-24a6-49f2-9b44-e8f8e216ec35') #dependency #('Collections' 'Collections.V3-dtl.882' '9c3d454c-d010-49b7-b52d-c82a89ad9c71') #dependency #('Monticello' 'Monticello-nice.716' 'a1f8545a-b4f8-4bae-b349-e8bbba23816e') #dependency #('Files' 'Files-pre.183' 'c7d0c859-2531-464e-87d8-3b580249731b') #dependency #('Sound' 'Sound-dtl.68' 'c7b5a141-2b1b-4d24-ab88-0a96dd78600b'))
]

{ #category : #running }
MCConfigurationTest >> sampleMcmStorageArrayExtended [
	"An extended format MCM array with no prior versions"

	"MCConfigurationTest new sampleMcmStorageArrayExtended"

	^ self sampleMcmStorageArray,
		# ( #mcmVersion '2'
			#id '891fc3c1-a046-4f61-81f3-49444f8d7906'
			#authorInitials 'dtl'
			#timeStamp '2020-04-10T15:00:06.887746-04:00'
			#comment 'A comment describing this version of the configuration map' )

]

{ #category : #running }
MCConfigurationTest >> setUp [

	sampleMcmStorageArray := self sampleMcmStorageArray.
	sampleMcmFileContents := self sampleMcmFileContents.
	sampleMcmStorageArrayExtended := self sampleMcmStorageArrayExtended.
	sampleMcmFileContentsExtended := self sampleMcmFileContentsExtended.
	sampleMcmFileContentsWithHistory := self sampleMcmFileContentsWithHistory.

]

{ #category : #'tests - basic format' }
MCConfigurationTest >> testCopyForEditForBasic [

	| array mcm forEdit |
	array := MCScanner scan: sampleMcmFileContents readStream.
	mcm := MCConfiguration fromArray: array.
	self assert: MCConfiguration equals: mcm class.
	forEdit := mcm copyForEdit.
	self assert: MCConfigurationExtended equals: forEdit class.
	self assert: 'update.V3-dtl.464' equals: forEdit name.
	self assert: 2 equals: forEdit repositories size.
	self assert: 6 equals: forEdit dependencies size.
	self assert: (forEdit instVarNamed: #log) isNil.
	self assert: '2' equals: forEdit mcmVersion.
	self assert: forEdit authorInitials isNil.
	self assert: forEdit timeStamp isNil.
	self assert: forEdit comment isNil.
	self assert: 1 equals: forEdit priorVersions size.
	self assert: forEdit priorVersions first == mcm.

]

{ #category : #'tests - extended format' }
MCConfigurationTest >> testCopyForEditForExtended [

	| input array mcm forEdit |
	input := sampleMcmFileContentsWithHistory.
	array := MCScanner scan: input readStream.
	mcm := MCConfiguration fromArray: array.
	self assert: MCConfigurationExtended equals: mcm class.
	forEdit := mcm copyForEdit.
	self assert: MCConfigurationExtended equals: forEdit class.
	self assert: 'update.V3-dtl.464' equals: forEdit name.
	self assert: 2 equals: forEdit repositories size.
	self assert: 6 equals: forEdit dependencies size.
	self assert: (forEdit instVarNamed: #log) isNil.
	self assert: '2' equals: forEdit mcmVersion.
	self assert: forEdit authorInitials isNil. "to be set when saved"
	self assert: forEdit timeStamp isNil. "to be set when saved"
	self assert: mcm comment equals: forEdit comment. "assume user may want to edit existing comment"
	self assert: 3 equals: forEdit priorVersions size.
	self assert: forEdit priorVersions first == mcm.

]

{ #category : #'tests - extended format' }
MCConfigurationTest >> testExtendedFromArray [

	| mcm |
	mcm := MCConfiguration fromArray: sampleMcmStorageArrayExtended.
	self assert: MCConfigurationExtended equals: mcm class.
	self assert: 'update.V3-dtl.464' equals: mcm name.
	self assert: 2 equals: mcm repositories size.
	self assert: 6 equals: mcm dependencies size.
	self assert: (mcm instVarNamed: #log) isNil.
	self assert: '2' equals: mcm mcmVersion.
	self assert: 'dtl' equals: mcm authorInitials.
	self assert: '2020-04-10T15:00:06.887746-04:00' equals: mcm timeStamp.
	self assert: 'A comment describing this version of the configuration map' equals: mcm comment.
	self assert: mcm priorVersions isEmpty.

]

{ #category : #'tests - extended format' }
MCConfigurationTest >> testExtendedFromStorageString [

	| array mcm |
	array := MCScanner scan: sampleMcmFileContentsExtended readStream.
	mcm := MCConfiguration fromArray: array.
	self assert: MCConfigurationExtended equals: mcm class.
	self assert: 'update.V3-dtl.464' equals: mcm name.
	self assert: 2 equals: mcm repositories size.
	self assert: 6 equals: mcm dependencies size.
	self assert: (mcm instVarNamed: #log) isNil.
	self assert: '2' equals: mcm mcmVersion.
	self assert: 'dtl' equals: mcm authorInitials.
	self assert: '2020-04-10T15:00:06.887746-04:00' equals: mcm timeStamp.
	self assert: 'A comment describing this version of the configuration map' equals: mcm comment.
	self assert: mcm priorVersions isEmpty.

]

{ #category : #'tests - extended format' }
MCConfigurationTest >> testExtendedToStorageString [

	| mcm strm |
	mcm := MCConfiguration fromArray: sampleMcmStorageArrayExtended.
	self assert: MCConfigurationExtended equals: mcm class.
	strm := '' writeStream.
	MCMcmWriter fileOut: mcm on: strm.
	strm cr. "trailing line terminator matches sample string"
	self assert: sampleMcmFileContentsExtended equals: strm contents.

]

{ #category : #'tests - extended format' }
MCConfigurationTest >> testExtendedToStorageStringWithHistory [

	| input array mcm strm |
	input := sampleMcmFileContentsWithHistory.
	array := MCScanner scan: input readStream.
	mcm := MCConfiguration fromArray: array.
	self assert: MCConfigurationExtended equals: mcm class.
	strm := '' writeStream.
	MCMcmWriter fileOut: mcm on: strm.
	strm cr. "trailing line terminator matches sample string"
	self assert: sampleMcmFileContentsWithHistory equals: strm contents.

]

{ #category : #'tests - basic format' }
MCConfigurationTest >> testFromArray [

	| mcm |
	mcm := MCConfiguration fromArray: sampleMcmStorageArray.
	self assert: MCConfiguration equals: mcm class.
	self assert: 'update.V3-dtl.464' equals: mcm name.
	self assert: 2 equals: mcm repositories size.
	self assert: 6 equals: mcm dependencies size.
	self assert: (mcm instVarNamed: #log) isNil.

]

{ #category : #'tests - backward compatability' }
MCConfigurationTest >> testFromExtendedArray [
	"Ensure backward compatibility"
	| mcm |
	mcm := MCConfiguration oldVersionOfFromArray: sampleMcmStorageArrayExtended.
	self assert: MCConfiguration equals: mcm class.
	self assert: 'update.V3-dtl.464' equals: mcm name.
	self assert: 2 equals: mcm repositories size.
	self assert: 6 equals: mcm dependencies size.
	self assert: (mcm instVarNamed: #log) isNil.

]

{ #category : #'tests - backward compatability' }
MCConfigurationTest >> testFromExtendedStorageString [
	"Ensure backward compatibility"
	| array mcm |
	array := MCScanner scan: sampleMcmFileContentsWithHistory readStream.
	mcm := MCConfiguration oldVersionOfFromArray: array.
	self assert: MCConfiguration equals: mcm class.
	self assert: 'update.V3-dtl.464' equals: mcm name.
	self assert: 2 equals: mcm repositories size.
	self assert: 6 equals: mcm dependencies size.
	self assert: (mcm instVarNamed: #log) isNil.

]

{ #category : #'tests - basic format' }
MCConfigurationTest >> testFromStorageString [

	| array mcm |
	array := MCScanner scan: sampleMcmFileContents readStream.
	mcm := MCConfiguration fromArray: array.
	self assert: MCConfiguration equals: mcm class.
	self assert: 'update.V3-dtl.464' equals: mcm name.
	self assert: 2 equals: mcm repositories size.
	self assert: 6 equals: mcm dependencies size.
	self assert: (mcm instVarNamed: #log) isNil.

]

{ #category : #'tests - basic format' }
MCConfigurationTest >> testToStorageString [

	| mcm strm |
	mcm := MCConfiguration fromArray: sampleMcmStorageArray.
	self assert: MCConfiguration equals: mcm class.
	strm := '' writeStream.
	MCMcmWriter fileOut: mcm on: strm.
	strm cr. "trailing line terminator matches sample string"
	self assert: sampleMcmFileContents equals: strm contents.

]

{ #category : #'tests - extended format' }
MCConfigurationTest >> testVersionHistory [
	"Each instance of MCConfigurationExtended has a possibly empty list of prior
	versions. Rather than modifying an instance of a configuration, the prior
	instance can be saved in the history list, with the current version saved as
	a new instance with history."

	| array mcm firstVersion thirdVersion secondVersion |
	mcm := MCConfiguration fromArray: sampleMcmStorageArrayExtended.
	self assert: mcm priorVersions isEmpty.
	array := sampleMcmStorageArrayExtended, "current version"
				sampleMcmStorageArrayExtended, "prior version"
				sampleMcmStorageArrayExtended,
				sampleMcmStorageArray. "oldest (original) version"
	mcm := MCConfiguration fromArray: array.

	self assert: 3 equals: mcm priorVersions size.
	firstVersion := MCConfiguration fromArray: sampleMcmStorageArray.
	self assert: firstVersion equals: mcm priorVersions last.

	secondVersion := mcm priorVersions second.
	self assert: 1 equals: secondVersion priorVersions size.
	self assert: firstVersion equals: secondVersion priorVersions first.

	thirdVersion := mcm priorVersions first.
	self assert: 2 equals: thirdVersion priorVersions size.
	self assert: secondVersion equals: thirdVersion priorVersions first.
	self assert: firstVersion equals: thirdVersion priorVersions second.

]
