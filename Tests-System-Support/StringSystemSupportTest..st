Class {
	#name : #StringSystemSupportTest,
	#superclass : #TestCase,
	#category : #'Tests-System-Support'
}

{ #category : #tests }
StringSystemSupportTest >> testAsSimpleGetter [
	self 
		assert: #x: asSimpleGetter = #x ;
		assert: #x asSimpleGetter = #x ;
		assert: #x: asSimpleGetter isSymbol ;
		
		assert: 'x:' asSimpleGetter = #x ;
		assert: 'x' asSimpleGetter = #x ;
		assert: 'x:' asSimpleGetter isSymbol ;
		
		should: [#+ asSimpleSetter] raise: Error ;
		should: ['+' asSimpleSetter] raise: Error ;
		
		should: ['' asSimpleGetter] raise: Error ;
		should: [#'' asSimpleGetter] raise: Error ;
		should: [':' asSimpleGetter] raise: Error ;
		should: [#':' asSimpleGetter] raise: Error
]

{ #category : #tests }
StringSystemSupportTest >> testAsSimpleSetter [
	self 
		assert: #x asSimpleSetter = #x: ;
		assert: #x: asSimpleSetter = #x: ;
		assert: #x asSimpleSetter isSymbol ;

		assert: 'x' asSimpleSetter = #x: ;
		assert: 'x:' asSimpleSetter = #x: ;
		assert: 'x' asSimpleSetter isSymbol ;

		"should: [#'+:' asSimpleGetter] raise: Error ; --- We should not introduce that Symbol into the system..."
		should: ['+:' asSimpleGetter] raise: Error ;

		should: [':' asSimpleSetter] raise: Error ;
		should: [#':' asSimpleSetter] raise: Error ;		
		should: ['' asSimpleSetter] raise: Error ;
		should: [#'' asSimpleSetter] raise: Error 
]

{ #category : #tests }
StringSystemSupportTest >> testIsSimpleGetter [
	self 
		assert: #x isSimpleGetter ;
		deny: #x: isSimpleGetter ;
		deny: #+ isSimpleGetter ;
		
		deny: 'x' isSimpleGetter ;
		
		deny: '' isSimpleGetter ;
		deny: #'' isSimpleGetter ;
		deny: ':' isSimpleGetter ;
		deny: #':' isSimpleGetter
]

{ #category : #tests }
StringSystemSupportTest >> testIsSimpleSetter [
	self 
		assert: #x: isSimpleSetter ;
		deny: #x isSimpleSetter ;
		deny: #+ isSimpleSetter ;
		deny: #a:b: isSimpleSetter ;
		
		deny: 'x:' isSimpleSetter ;

		deny: '' isSimpleSetter ;
		deny: #'' isSimpleSetter ;
		deny: ':' isSimpleSetter ;
		deny: #':' isSimpleSetter
]
