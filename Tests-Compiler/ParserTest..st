Class {
	#name : #ParserTest,
	#superclass : #TestCase,
	#category : #'Tests-Compiler'
}

{ #category : #'tests - pragmas' }
ParserTest >> testRegressionPragmasParsing [

	self 
		shouldnt: [Parser new 
					parse: 'methodHeader
							<first>'
					class: ParserTest] 
		raise: SyntaxErrorNotification
]

{ #category : #'tests - pragmas' }
ParserTest >> testRegressionPragmasParsingClosingToken [

	self 
		should: [Parser new 
					parse: 'methodHeader
							<first''>'''
					class: ParserTest] 
		raise: SyntaxErrorNotification
]

{ #category : #'tests - pragmas' }
ParserTest >> testRegressionPragmasParsingIsTooPossessive [
	"The parser might interpret angle bracket literals as opening pragmas"
	
	self 
		shouldnt: [Parser new 
					parse: 'methodHeader
							''<'' asciiValue'
					class: ParserTest] 
		raise: SyntaxErrorNotification.
		
	self 
		shouldnt: [Parser new 
					parse: 'methodHeader
							#< asciiValue'
					class: ParserTest] 
		raise: SyntaxErrorNotification.
		
	self 
		shouldnt: [Parser new 
					parse: 'methodHeader
							$< asciiValue'
					class: ParserTest] 
		raise: SyntaxErrorNotification
]
