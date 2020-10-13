"
A CogVMBaseImageTests is a set of tests of the Stack and Cog VMs designed to be run in a base Squeak, Pharo, Cuis or Newspeak image.  [CogVMTests is a name already used in the VMMaker.oscog package}.]

Instance Variables

"
Class {
	#name : #CogVMBaseImageTests,
	#superclass : #TestCase,
	#category : #'Tests-VM'
}

{ #category : #private }
CogVMBaseImageTests >> method0 [
	self testExpectedPCInSenderOf: thisContext.
	self testExpectedPCInSenderOf: thisContext shallowCopy
]

{ #category : #private }
CogVMBaseImageTests >> method1: arg [
	self testExpectedPCInSenderOf: thisContext.
	self testExpectedPCInSenderOf: thisContext shallowCopy
]

{ #category : #private }
CogVMBaseImageTests >> method2: arg1 with: arg2 [
	self testExpectedPCInSenderOf: thisContext.
	self testExpectedPCInSenderOf: thisContext shallowCopy
]

{ #category : #private }
CogVMBaseImageTests >> method3: arg1 with: arg2 with: arg3 [
	self testExpectedPCInSenderOf: thisContext.
	self testExpectedPCInSenderOf: thisContext shallowCopy
]

{ #category : #private }
CogVMBaseImageTests >> method8: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 with: arg7 with: arg8 [
	self testExpectedPCInSenderOf: thisContext.
	self testExpectedPCInSenderOf: thisContext shallowCopy
]

{ #category : #private }
CogVMBaseImageTests >> runTestPCMappingMethod [
	"Perform various sends, each of which will test that the PC of the current context matches what's expected.
	 See testExpectedPCInSenderOf:.
	 In the V3 bytecode set method8:with:with:with:with:with:with:with: should require the doubleExtendedDoAnythingBytecode."

	self method0.
	self method1: 'one'.
	self method2: 'two' with: 'three'.
	self method3: 'four' with: 'five' with: 'six'.
	self method8: 'eight' with: 'nine' with: 'ten' with: 'eleven' with: 'twelve' with: 'thirteen' with: 'fourteen' with: 'fifteen'.
	[self method0.
	 self method1: 'one'.
	 self method2: 'two' with: 'three'.
	 self method3: 'four' with: 'five' with: 'six'.
	 self method8: 'eight' with: 'nine' with: 'ten' with: 'eleven' with: 'twelve' with: 'thirteen' with: 'fourteen' with: 'fifteen'.
	 [self method0.
	  self method1: 'one'.
	  self method2: 'two' with: 'three'.
	  self method3: 'four' with: 'five' with: 'six'.
	  self method8: 'eight' with: 'nine' with: 'ten' with: 'eleven' with: 'twelve' with: 'thirteen' with: 'fourteen' with: 'fifteen'] value] value.
	self method0.
	self method1: 'one'.
	self method2: 'two' with: 'three'.
	self method3: 'four' with: 'five' with: 'six'

]

{ #category : #private }
CogVMBaseImageTests >> testExpectedPCInSenderOf: calleeContext [
	| selector pc method found is endPC |
	selector := calleeContext method selector.
	pc := calleeContext sender pc.
	method := calleeContext sender method.
	found := false.
	is := InstructionStream on: method.
	is pc: calleeContext sender startpc.
	endPC := calleeContext sender endPC.
	is scanFor:
		[:b|
		 is followingPc = pc ifTrue:
			[found := true.
			 self assert: selector equals: is selectorToSendOrSelf].
		 is pc >= endPC].
	self assert: found
]

{ #category : #tests }
CogVMBaseImageTests >> testPCMapping [
	"Test that pcs at sends are as expected since interally the JIT has to map from machine code pcs to bytecode pcs.
	 The method will be jitted on the second iteration.  Run 3 times to compare interpreter and JIT, which should agree."
	(self class compiledMethodAt: #runTestPCMappingMethod) voidCogVMState.
	3 timesRepeat: [self runTestPCMappingMethod]
]
