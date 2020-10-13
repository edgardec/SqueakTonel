Class {
	#name : #BehaviorTest,
	#superclass : #TestCase,
	#category : #'KernelTests-Classes'
}

{ #category : #tests }
BehaviorTest >> sampleMessageWithFirstArgument: firstArgument "This is a comment intended to explain arg1"
   andInterleavedCommentBeforeSecondArgument: secondArgument [

	"This method is here to test a few utilities like formalParametersAt:"
	
	| thisIsAnUnusedTemp |
	thisIsAnUnusedTemp := self.
	^thisIsAnUnusedTemp
]

{ #category : #tests }
BehaviorTest >> testAllSelectors [

	self assert: ProtoObject allSelectors = ProtoObject selectors asIdentitySet.
	self assert: Object allSelectors = (Object selectors union: ProtoObject selectors) asIdentitySet.
]

{ #category : #tests }
BehaviorTest >> testAllSelectorsBelow [

	self assert: (Object allSelectorsBelow: ProtoObject) = Object selectors asIdentitySet.
	self assert: (Object allSelectorsBelow: nil) = (Object selectors union: ProtoObject selectors) asIdentitySet
]

{ #category : #tests }
BehaviorTest >> testBehaviorSubclasses [
	"self run: #testBehaviorSubclasses"
	
	| b b2 |
	b := Behavior new.
	b superclass: OrderedCollection.
	b methodDictionary: MethodDictionary new.

	b2 := Behavior new.
	b2 superclass: b.
	b2 methodDictionary: MethodDictionary new.
	
	self assert: (b subclasses includes: b2).
	self deny: (b subclasses includes: b).
	
	self assert: (b withAllSubclasses includes: b).
	
	self assert: (b allSubclasses includes: b2).
]

{ #category : #tests }
BehaviorTest >> testBehaviornewnewShouldNotCrash [

	Behavior new new.
	"still not working correctly but at least does not crash the image"
	
]

{ #category : #tests }
BehaviorTest >> testBinding [
	self assert: Object binding value = Object.
	self assert: Object binding key = #Object.
	
	self assert: Object class binding value = Object class.
	
	"returns nil for Metaclasses... like Encoder>>#associationFor:"
	
	self assert: Object class binding key = nil.
]

{ #category : #tests }
BehaviorTest >> testChange [
	"self debug: #testChange"

	| behavior model |
	behavior := Behavior new.
	behavior superclass: Model.
	behavior setFormat: Model format.
	model := Model new.
	model primitiveChangeClassTo: behavior new.
	Utilities
		useAuthorInitials: self className
		during: [ behavior compile: 'thisIsATest  ^ 2' ].
	self assert: model thisIsATest = 2.
	self should: [Model new thisIsATest] raise: MessageNotUnderstood.



]

{ #category : #tests }
BehaviorTest >> testFormalParameterNames [
	| method |
	method := #sampleMessageWithFirstArgument:andInterleavedCommentBeforeSecondArgument:.
	self assert: (self class formalParametersAt: method) size = 2.
	self assert: (self class formalParametersAt: method) asArray = #('firstArgument' 'secondArgument').
	CurrentReadOnlySourceFiles cacheDuring: [
		Object selectorsDo: [:e |
			self assert: (Object formalParametersAt: e) size = e numArgs]].
]

{ #category : #tests }
BehaviorTest >> testWhichMethodsStoreInto [
	ClassForBehaviorTest withAllSubclassesDo: [:eachTestClass |
		{eachTestClass. eachTestClass class} do: [:eachTestClassOrMetaclass |
			
			eachTestClassOrMetaclass allInstVarNames do: [:iv |
				self assert: ((eachTestClassOrMetaclass whichMethodsStoreInto: iv)
						collect: [:eachMethod | eachMethod selector]) sorted
					= (eachTestClassOrMetaclass whichSelectorsStoreInto: iv) sorted.
				self assert: ((eachTestClassOrMetaclass whichMethodsStoreInto: iv)
						allSatisfy: [:eachMethod | eachMethod methodClass = eachTestClassOrMetaclass]) ].
				
			eachTestClassOrMetaclass allClassVarNames do: [:cv |
				self assert: ((eachTestClassOrMetaclass whichMethodsStoreInto: cv)
						collect: [:eachMethod | eachMethod selector]) sorted
					= (eachTestClassOrMetaclass whichSelectorsStoreInto: cv) sorted.
				self assert: ((eachTestClassOrMetaclass whichMethodsStoreInto: cv)
						allSatisfy: [:eachMethod | eachMethod methodClass = eachTestClassOrMetaclass]) ]]]
]

{ #category : #tests }
BehaviorTest >> testWhichSelectorStoreInto [
	self assert: (ClassForBehaviorTest whichSelectorsStoreInto: 'iv1') sorted = #(#initialize #iv1: #reset ).
	self assert: (ClassForBehaviorTest whichSelectorsStoreInto: 'iv2') sorted = #(#iv2: #reset ).
	self assert: (ClassForBehaviorTest whichSelectorsStoreInto: 'CV1') sorted =  #(#initialize).
	self assert: (ClassForBehaviorTest whichSelectorsStoreInto: 'CV2') sorted =  #().
	
	self assert: (SubClassForBehaviorTest whichSelectorsStoreInto: 'iv1') sorted = #(#resetIV1 ).
	self assert: (SubClassForBehaviorTest whichSelectorsStoreInto: 'iv2') sorted = #(#iv2: ).
	self assert: (SubClassForBehaviorTest whichSelectorsStoreInto: 'CV1') sorted =  #().
	self assert: (SubClassForBehaviorTest whichSelectorsStoreInto: 'CV2') sorted =  #().
	
	self assert: (ClassForBehaviorTest class whichSelectorsStoreInto: 'CV1') sorted =  #(#initialize).
	self assert: (ClassForBehaviorTest class whichSelectorsStoreInto: 'CV2') sorted =  #(#initialize).
	self assert: (ClassForBehaviorTest class whichSelectorsStoreInto: 'civ1') sorted =  #(#civ1).
	
	self assert: (SubClassForBehaviorTest class whichSelectorsStoreInto: 'CV1') sorted =  #().
	self assert: (SubClassForBehaviorTest class whichSelectorsStoreInto: 'CV2') sorted =  #().
	self assert: (SubClassForBehaviorTest class whichSelectorsStoreInto: 'civ1') sorted =  #(#install).
]
