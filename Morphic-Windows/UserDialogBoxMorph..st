"
A DialogBoxMorph is Morph used in simple yes/no/confirm dialogs. Strongly modal.
"
Class {
	#name : #UserDialogBoxMorph,
	#superclass : #DialogWindow,
	#category : #'Morphic-Windows'
}

{ #category : #utilities }
UserDialogBoxMorph class >> confirm: aString [
	"UserDialogBoxMorph confirm: 'Do you like chocolate?'"
	^self confirm: aString title: 'Please Confirm'
]

{ #category : #utilities }
UserDialogBoxMorph class >> confirm: aString orCancel: cancelBlock [
	"UserDialogBoxMorph confirm: 'Do you like chocolate?'"
	^self confirm: aString orCancel: cancelBlock at: nil
]

{ #category : #utilities }
UserDialogBoxMorph class >> confirm: aString orCancel: cancelBlock at: aPointOrNil [
	^self
		confirm: aString
		orCancel: cancelBlock
		title: 'Please Confirm'
		at: aPointOrNil
]

{ #category : #utilities }
UserDialogBoxMorph class >> confirm: aString orCancel: cancelBlock title: titleString at: aPointOrNil [
	
	(self new
		title: titleString;
		message: aString;
		createButton: 'Yes' translated value: true;
		createButton: 'No' translated  value: false;
		createButton: 'Cancel' translated value: nil;
		selectedButtonIndex: 1; "YES"
		registerKeyboardShortcuts;
		yourself) in: [:dialog |
			^ (aPointOrNil
				ifNil: [dialog getUserResponseAtHand]
				ifNotNil: [
					dialog preferredPosition: aPointOrNil.
					dialog getUserResponse])
						ifNil: [ cancelBlock value ]]
]

{ #category : #utilities }
UserDialogBoxMorph class >> confirm: aString title: titleString [
	"UserDialogBoxMorph confirm: 'Make your choice carefully' withCRs title: 'Do you like chocolate?'"
	^self confirm: aString title: titleString at: nil
]

{ #category : #utilities }
UserDialogBoxMorph class >> confirm: aString title: titleString at: aPointOrNil [
	"UserDialogBoxMorph confirm: 'Make your choice carefully' withCRs title: 'Do you like chocolate?'"
	^self new
		title: titleString;
		message: aString;
		createButton: 'Yes' translated value: true;
		createCancelButton: 'No' translated  value: false;
		selectedButtonIndex: 1; "YES"
		registerKeyboardShortcuts;
		getUserResponseAtHand
]

{ #category : #utilities }
UserDialogBoxMorph class >> confirm: aString title: titleString trueChoice: trueChoice falseChoice: falseChoice [
	"UserDialogBoxMorph confirm: 'Make your choice carefully' withCRs title: 'Do you like chocolate?' trueChoice: 'Oh yessir!' falseChoice: 'Not so much...'  "
	^self confirm: aString title: titleString trueChoice: trueChoice falseChoice: falseChoice at: nil
]

{ #category : #utilities }
UserDialogBoxMorph class >> confirm: aString title: titleString trueChoice: trueChoice falseChoice: falseChoice at: aPointOrNil [
	"UserDialogBoxMorph confirm: 'Make your choice carefully' withCRs title: 'Do you like chocolate?' trueChoice: 'Oh yessir!' falseChoice: 'Not so much...'"
	^self new
		title: titleString;
		message: aString;
		createButton: trueChoice translated value: true;
		createButton: falseChoice translated value: false;
		createCancelButton: 'Cancel' translated translated value: nil;
		selectedButtonIndex: 1;
		registerKeyboardShortcuts;
		preferredPosition: (aPointOrNil ifNil: [Project current world center]);
		getUserResponse
]

{ #category : #utilities }
UserDialogBoxMorph class >> confirm: aString title: titleString trueChoice: trueChoice falseChoice: falseChoice default: default triggerAfter: seconds at: aPointOrNil [
	"UserDialogBoxMorph confirm: 'I like hot java' title: 'What do you say?' trueChoice: 'You bet!' falseChoice: 'Nope' default: false triggerAfter: 12 at: 121@212"
	^self new
		title: titleString;
		message: aString;
		createButton: trueChoice translated value: true;
		createButton: falseChoice translated value: false;
		createCancelButton: 'Cancel' translated translated value: nil;
		selectedButtonIndex: (default ifTrue: [1] ifFalse: [2]);
		registerKeyboardShortcuts;
		preferredPosition: (aPointOrNil ifNil: [Project current world center]);
		getUserResponseAfter: seconds
]

{ #category : #utilities }
UserDialogBoxMorph class >> confirm: aString trueChoice: trueChoice falseChoice: falseChoice [
	"UserDialogBoxMorph confirm: 'Do you like chocolate?' trueChoice: 'Oh yessir!' falseChoice: 'Not so much...'  "
	^self confirm: aString title: 'Please confirm:' trueChoice: trueChoice falseChoice: falseChoice at: nil
]

{ #category : #utilities }
UserDialogBoxMorph class >> inform: aString [
	"UserDialogBoxMorph inform: 'Squeak is great!'"
	^self inform: aString title: 'Note' translated
]

{ #category : #utilities }
UserDialogBoxMorph class >> inform: aString title: titleString [
	"UserDialogBoxMorph inform: 'Squeak is great!' title: 'Will you look at this:'"
	^self inform: aString title: titleString at: nil
]

{ #category : #utilities }
UserDialogBoxMorph class >> inform: aString title: titleString at: aPointOrNil [
	"UserDialogBoxMorph inform: 'Squeak is great!' title: 'Will you look at this:'"
	
	^self new
		title: titleString;
		message: aString;
		createButton: 'OK' translated value: nil;
		getUserResponseAtHand
]

{ #category : #accessing }
UserDialogBoxMorph >> label [
	^ self message
]

{ #category : #accessing }
UserDialogBoxMorph >> label: aString [
	self message: aString.
]
