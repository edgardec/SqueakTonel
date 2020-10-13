Class {
	#name : #EtoysTheme,
	#superclass : #UserInterfaceTheme,
	#category : #'Etoys-UserInterfaceTheme'
}

{ #category : #'instance creation' }
EtoysTheme class >> create [
	"doIt: [self create apply.]"

	| themeName |
	themeName := 'Etoys'.
	^ (self named: themeName) in: [:theme |
		theme merge: (self named: 'Squeak') overwrite: true.
		theme name: themeName.

		theme set: #background for: #MorphicProject to: (SolidFillStyle color: (Color r: 0.9 g: 0.9 b: 1)).

		theme
			set: #standardListFont to: (TTCFont familyName: 'BitstreamVeraSans' pointSize: 15 emphasis: 0);
			set: #standardFlapFont to: (TTCFont familyName: 'BitstreamVeraSans' pointSize: 15 emphasis: TextEmphasis bold emphasisCode);

			set: #eToysButtonFont to: (TTCFont familyName: 'BitstreamVeraSans' pointSize: 15 emphasis: 0);
			set: #eToysFont to: (TTCFont familyName: 'BitstreamVeraSans' pointSize: 15 emphasis: TextEmphasis bold emphasisCode);
			set: #eToysCodeFont to: (TTCFont familyName: 'BitstreamVeraSans' pointSize: 15 emphasis: 0);
			set: #eToysTitleFont to: (TTCFont familyName: 'BitstreamVeraSans' pointSize: 32 emphasis: 0);
			set: #paintBoxButtonFont to: (TTCFont familyName: 'BitstreamVeraSans' pointSize: 12 emphasis: 0);
			set: #standardMenuFont to: (TTCFont familyName: 'BitstreamVeraSans' pointSize: 15 emphasis: 0);
			set: #standardButtonFont to: (TTCFont familyName: 'BitstreamVeraSans' pointSize: 15 emphasis: 0);
			set: #windowTitleFont to: (TTCFont familyName: 'BitstreamVeraSans' pointSize: 15 emphasis: TextEmphasis bold emphasisCode);
			set: #balloonHelpFont to: (TTCFont familyName: 'BitstreamVeraSans' pointSize: 15 emphasis: 0);
			set: #connectorsLabelFont to: (TTCFont familyName: 'BitstreamVeraSans' pointSize: 15 emphasis: 0);
			set: #standardCodeFont to: (TTCFont familyName: 'BitstreamVeraSans' pointSize: 15 emphasis: 0);
			set: #standardDefaultTextFont to: (TTCFont familyName: 'BitstreamVeraSans' pointSize: 15 emphasis: 0);
			set: #standardSystemFont to: (TTCFont familyName: 'BitstreamVeraSans' pointSize: 15 emphasis: 0).
		theme]
]
