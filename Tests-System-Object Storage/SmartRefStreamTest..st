Class {
	#name : #SmartRefStreamTest,
	#superclass : #ReferenceStreamTest,
	#category : #'Tests-System-Object Storage'
}

{ #category : #helper }
SmartRefStreamTest >> put: anObject [
	
	| s |
	s := RWBinaryOrTextStream on: (ByteArray new: 500).
	 (self streamClass on: s)
		nextPutObjOnly: anObject;
		close.
	^ s contents
]

{ #category : #constants }
SmartRefStreamTest >> streamClass [
	^ SmartRefStream
]
