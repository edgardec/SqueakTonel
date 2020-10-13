"
An EventMorph representing a media event, such as the playing of a sound or a movie clip.
"
Class {
	#name : #MediaEventMorph,
	#superclass : #EventMorph,
	#category : #'Etoys-Squeakland-Morphic-Mentoring'
}

{ #category : #menus }
MediaEventMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	"Add morph-specific items to the given menu which was invoked by the given hand.  This method provides is invoked both from the halo-menu and from the control-menu regimes."

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu addTranslatedList:
		#(( 'play' play 'play the event in isolation.')) translatedNoop
]

{ #category : #playing }
MediaEventMorph >> play [
	"Play my event in isolation, if possible."

	event play
]
