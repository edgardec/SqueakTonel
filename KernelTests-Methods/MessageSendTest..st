Class {
	#name : #MessageSendTest,
	#superclass : #TestCase,
	#category : #'KernelTests-Methods'
}

{ #category : #tests }
MessageSendTest >> testNumArgs [
	self
		 assert:
			(MessageSend
				receiver: Dictionary new
				selector: #at:put:) numArgs = 2 ;
		 assert:
			(MessageSend
				receiver: 3
				selector: #sqrt) numArgs = 0
]
