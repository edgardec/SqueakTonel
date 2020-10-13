"
This is the unit test for the class InstructionPrinter. Unit tests are a good way to exercise the functionality of your system in a repeatable and automatic manner. They are therefore recommended if you plan to release anything. For more information, see: 
	- http://www.c2.com/cgi/wiki?UnitTest
	- http://minnow.cc.gatech.edu/squeak/1547
	- the sunit class category
"
Class {
	#name : #InstructionPrinterTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'tt'
	],
	#category : #'KernelTests-Methods'
}

{ #category : #examples }
InstructionPrinterTest >> example1 [
	| ff|
	(1 < 2) ifTrue: [tt ifNotNil: [ff := 'hallo']].
	^ ff.
]

{ #category : #tests }
InstructionPrinterTest >> testInstructions [
	"just print all of methods of Object and see if no error accours"

	| printer |
	printer  := InstructionPrinter.
	Object methodDict do: [:method |
		String streamContents: [:stream | 
			(printer on: method) printInstructionsOn: stream]].

]
