Class {
	#name : #ContextCompilationTest,
	#superclass : #TestCase,
	#category : #'Tests-Compiler'
}

{ #category : #tests }
ContextCompilationTest >> testVariablesAndOffsetsDo [

	"ContextCompilationTest new testVariablesAndOffsetsDo"
	| contextClasses |
	contextClasses := thisContext class withAllSuperclasses, thisContext class allSubclasses asArray.
	contextClasses do:
		[:class|
		class variablesAndOffsetsDo:
			[:var :offset|
			self assert: offset < 0.
			self assert: (class instVarNameForIndex: offset negated) == var]].

	InstructionStream withAllSuperclasses, InstructionStream allSubclasses asArray do:
		[:class|
		(contextClasses includes: class) ifFalse:
			[class variablesAndOffsetsDo:
				[:var :offset|
				(InstructionStream instVarNames includes: var) ifFalse:
					[self assert: offset > 0.
					 self assert: (class instVarNameForIndex: offset) == var]]]]
]
