Class {
	#name : #ImmX11,
	#superclass : #ImmAbstractPlatform,
	#category : #'Multilingual-ImmPlugin'
}

{ #category : #keyboard }
ImmX11 >> keyboardFocusForAMorph: aMorph [

	aMorph ifNil: [^ self].
	[
		| left bottom pos |
		pos := aMorph preferredKeyboardPosition.
		left := (pos x min: Display width max: 0) asInteger.
		bottom := (pos y min: Display height max: 0) asInteger.
		self setCompositionWindowPositionX: left y: bottom
	] on: Error
	do: [:ex |].

]

{ #category : #private }
ImmX11 >> setCompositionWindowPositionX: x y: y [

	<primitive: 'primSetCompositionWindowPosition' module: 'ImmX11Plugin'>

	^ nil

]
