"
The sole purpose of this class is to allow the Browser code pane to evaluate the class variables of the class whose method it is showing.  It does this by stuffing a pointer to the classpool dictionary of the class being shown into its own classpool.  It does this just around a doIt in the code pane.  An instance of FakeClasspool is then used as the receiver of the doIt.
"
Class {
	#name : #FakeClassPool,
	#superclass : #Object,
	#category : #'System-Tools'
}

{ #category : #initialize }
FakeClassPool class >> adopt: classOrNil [
	"Temporarily use the classPool and sharedPools of another class"
	classOrNil isBehavior
		ifFalse: [classPool := nil.
				sharedPools := nil]
		ifTrue: [classPool := classOrNil classPool.
				sharedPools := classOrNil sharedPools]

]
