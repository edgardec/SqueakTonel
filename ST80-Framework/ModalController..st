"
I am a controller that puts the poor user into a mode by not relinquishing control. However, I do pass control onto my underlings. Some underling is expected to end the mode by sending me 'close'. Watch out Larry Tesler, the mode lives on...

"
Class {
	#name : #ModalController,
	#superclass : #Controller,
	#instVars : [
		'modeActive'
	],
	#category : #'ST80-Framework'
}

{ #category : #scheduling }
ModalController >> close [
	"This is how we leave the mode." 

	modeActive := false.

]

{ #category : #scheduling }
ModalController >> closeAndUnscheduleNoTerminate [
	"Erase the receiver's view and remove it from the collection of scheduled views, but do not terminate the current process."

	ScheduledControllers unschedule: self.
	view erase.
	view release.
]

{ #category : #'basic control sequence' }
ModalController >> controlInitialize [

	modeActive := true.
	^ super controlInitialize

]

{ #category : #'control defaults' }
ModalController >> isControlActive [

	^ modeActive

]

{ #category : #'control defaults' }
ModalController >> isControlWanted [

	^ modeActive

]
