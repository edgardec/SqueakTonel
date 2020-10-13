Class {
	#name : #MacFileDirectoryTest,
	#superclass : #TestCase,
	#category : #'Tests-Files'
}

{ #category : #tests }
MacFileDirectoryTest >> testMacFileDirectory [
	"(self run: #testMacFileDirectory)"
	
	"This fails before the the fix if the Squeak directory is on the root
	directory like: 'HardDisk:Squeak'
	But should work both before and after the fix of John if there is several
	directories in the hieracry: HardDisk:User:Squeak"
	"If somebody can find a way to make the test failed all the time when the fix is not 
	present we should replace it"

	self assert: (FileDirectory default fullName) = (FileDirectory default fullNameFor: (FileDirectory default fullName))
]

{ #category : #tests }
MacFileDirectoryTest >> testMacIsAbsolute [
	"(self selector: #testMacIsAbsolute) run"
	
	
	self deny: (MacFileDirectory isAbsolute: 'Volumes').
	self assert: (MacFileDirectory isAbsolute: 'Volumes:Data:Stef').
	self deny: (MacFileDirectory isAbsolute: ':Desktop:test.st')
]

{ #category : #tests }
MacFileDirectoryTest >> testMakeAbsolute [

	self assert: (MacFileDirectory isAbsolute: (MacFileDirectory makeAbsolute: 'Data')).
	self assert: (MacFileDirectory isAbsolute: (MacFileDirectory makeAbsolute: ':Data')).

]
