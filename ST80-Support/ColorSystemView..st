Class {
	#name : #ColorSystemView,
	#superclass : #StandardSystemView,
	#category : #'ST80-Support'
}

{ #category : #displaying }
ColorSystemView >> displayDeEmphasized [ 
	"Display this view with emphasis off.
	If windowBits is not nil, then simply BLT if possible."
	bitsValid
		ifTrue: [self lock.
				windowBits displayAt: self windowOrigin]
		ifFalse: [super displayDeEmphasized]

]
