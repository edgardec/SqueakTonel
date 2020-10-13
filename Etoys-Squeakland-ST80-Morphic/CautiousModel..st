"
A model for a morphic world view which will ask for confirmation before being closed, unless the corresponding preference is set to false. 
"
Class {
	#name : #CautiousModel,
	#superclass : #WorldViewModel,
	#category : #'Etoys-Squeakland-ST80-Morphic'
}

{ #category : #updating }
CautiousModel >> okToChange [
	Preferences cautionBeforeClosing ifFalse: [^ true].
	Sensor leftShiftDown ifTrue: [^ true].

	Beeper beep.
	^ self confirm: 'Warning!
If you answer "yes" here, this
window will disappear and
its contents will be lost!
Do you really want to do that?'

"CautiousModel new okToChange"
]
