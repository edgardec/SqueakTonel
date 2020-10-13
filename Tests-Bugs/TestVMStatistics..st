"
The VM statistics array is provided by the VM. Its size and contents vary for different VM implementations. This test should pass on any VM.
"
Class {
	#name : #TestVMStatistics,
	#superclass : #TestCase,
	#category : #'Tests-Bugs'
}

{ #category : #tests }
TestVMStatistics >> testVmStatisticsReportString [
	"Results of this test vary by VM implementation. Failure usually indicates
	an unchecked assumption about the array size."

	self shouldnt: [Smalltalk vmStatisticsReportString]
		raise: Error
		description: 'probable unchecked VM statistics array size'

]
