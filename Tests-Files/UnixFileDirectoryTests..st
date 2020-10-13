"
Just some simply unit tests for UnixFileDirectory

Instance Variables:

"
Class {
	#name : #UnixFileDirectoryTests,
	#superclass : #TestCase,
	#category : #'Tests-Files'
}

{ #category : #tests }
UnixFileDirectoryTests >> testCheckNameFixErrors [

	| directory bigName maxLength |
	"Do not use #on:, it will use the default directory class, which 
	 might be different on this platform."
	directory := UnixFileDirectory new setPathName: '.'.
	self assert: ('abc' = (directory checkName: 'abc' fixErrors: false)).
	self assert: ('abc' = (directory checkName: 'abc' fixErrors: true)).
	
	"These test the superclass implementation."
	self should: [directory checkName: '' fixErrors: false] raise: Error.
	self should: [directory checkName: '' fixErrors: true] raise: Error.
	maxLength := directory class maxFileNameLength.
	bigName := String streamContents: [:s | maxLength + 1 timesRepeat: [s nextPut: $1]].
	self should: [directory checkName: bigName fixErrors: false] raise: Error.
	"#contractTo: seems a little odd, but it is what #checkName:fixErrors: uses"
	self assert: ((bigName contractTo: maxLength)  = (directory checkName: bigName fixErrors: true)).
	
	"UnixFileDirectory specific tests"
	"UnixFileDirectory will turn / into #, if told to fix errors."
	self assert: ('a#b#c' = (directory checkName: 'a/b/c' fixErrors: true)).
	"And it will raise an error if it does not fix errors."
	self should: [(directory checkName: 'a/b/c' fixErrors: false)] raise: Error
]
