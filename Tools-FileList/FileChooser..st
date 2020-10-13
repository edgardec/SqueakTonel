"
This class provides a simple ""modal"" dialog box to choose a file, with a directory tree, a file list, and open and cancel buttons. It is meant to be an improvement of FileList2 modalFileSelector. 

An applictaion can customize the user interface in a straightforward way. Creation of the file choser is done in several steps by calling various helper methods.. 

The order of the method calls when creating a customized file chooser are important. The UI must be created before methods that change the attributes of the UI can be called. You can either start by creating the default UI, and them modify the morphs in the file chooser (there are methods to access the buttons and the panes).

You can also build a completely custom UI, by writing your own methods for creating the layout etc. One way to do this is to subclass FileChooser and override the methods you want to change, andother way is to supply your own morphic view to the file chooser. This must be an instance of MorphicModel or a subclass of it, because the file chooser uses the model functionality.

There are two varieties of the UI, one that is supposed to be like a dialog box (uses colors from the menu preferences in class Preference), and one is using a system window. The way a system window works turns out to be somehat different from how a plain Morphic Model works, and this is why there are separate methods for creating the dialog box UI and the system window UI.

On the class side, there are examples that shows differents ways to use this class.

On the to do list is adding support for a file save dialog box, with a directory tree and a text input field for typing a file name.

(Mikael Kindborg, 050815)

"
Class {
	#name : #FileChooser,
	#superclass : #FileList2,
	#instVars : [
		'view',
		'caption',
		'captionMorph',
		'captionBox',
		'cancelButton',
		'okButton',
		'buttonPane',
		'captionPane',
		'directoryPane',
		'filePane',
		'showShortFileNames'
	],
	#category : #'Tools-FileList'
}

{ #category : #examples }
FileChooser class >> example1 [
	"Open file chooser with the standard dialog box UI."
	"FileChooser example1"
	| fc stream |
	fc := FileChooser new.
	fc initializeAsDialogBox.
	stream := fc open.
	stream inspect.
]

{ #category : #examples }
FileChooser class >> example2 [
	"Open file chooser with a system window UI."
	"FileChooser example2"
	| fc stream |
	fc := FileChooser new.
	fc initializeAsSystemWindow.
	stream := fc open.
	stream inspect.
]

{ #category : #examples }
FileChooser class >> example3 [
	"Open file chooser with a system window UI that has a caption pane and shows only picture files."
	"FileChooser example3"
	| fc stream |
	fc := FileChooser new.
	fc initializeAsSystemWindowWithCaptionPane.
	fc setCaption: 'Select a picture file' translated.
	fc setSuffixes: {'png' . 'gif' . 'bmp' . 'jpg' . 'jpeg' }.
	stream := fc open.
	stream ifNotNil: [(Form fromBinaryStream: stream) asMorph openInHand].
]

{ #category : #examples }
FileChooser class >> example4 [
	"Open file chooser with a customized dialog box UI. The order of the messages is important. In general, call the initialize method first, then modify things, and finally call open."
	"FileChooser example4"
	| fc stream |
	fc := FileChooser new.
	fc initializeAsDialogBox.
	fc setDirectory: FileDirectory root.
	fc setSuffixes: {'png' . 'gif' . 'bmp' . 'jpg' . 'jpeg' }.
	fc setCaption: 'Select a picture file' translated.
	fc morphicView 
		borderColor: Color black; 
		borderWidth: 2;
		color: Color white.
	fc setPaneColor: Color gray muchLighter.
	fc captionPane color: Color orange muchLighter.
	fc okButton color: Color green muchLighter.
	fc cancelButton color: Color blue muchLighter.
	fc morphicView position: 20@20.
	stream := fc open.
	stream ifNotNil: [(Form fromBinaryStream: stream) asMorph openInHand].
]

{ #category : #'instance creation' }
FileChooser class >> new [
	"Superclass may attempt to initialize to a specific default directory. Bypass
	that behavior."

	^ self basicNew initialize
]

{ #category : #'ui creation' }
FileChooser >> addFullPanesTo: aMorph from: aCollection [
	aCollection do: [ :each |
		| frame |
		frame := LayoutFrame 
			fractions: each second 
			offsets: each third.
		aMorph addMorph: each first fullFrame: frame.
	]
]

{ #category : #accessing }
FileChooser >> buttonPane [
	^buttonPane
]

{ #category : #accessing }
FileChooser >> cancelButton [
	^cancelButton
]

{ #category : #accessing }
FileChooser >> caption [
	^caption
]

{ #category : #accessing }
FileChooser >> captionPane [
	^captionPane
]

{ #category : #'ui creation' }
FileChooser >> centerMorphicView [
	self morphicView
		fullBounds;
		position: Display extent - self morphicView extent // 2.

]

{ #category : #'ui creation' }
FileChooser >> createCancelButton [
	cancelButton := SimpleButtonMorph new.
	cancelButton
		label: 'Cancel' translated;
		color: Color transparent;
		borderColor: Color black;
		borderWidth: 1.
	cancelButton 
		on: #mouseUp 
		send: #cancelHit
		to: self.
	^cancelButton

]

{ #category : #'ui creation' }
FileChooser >> createDialogBoxButtonPane [
	"Create buttons suitable for a MorphicModel file chooser."

	buttonPane := AlignmentMorph new.
	buttonPane
		layoutPolicy: ProportionalLayout new;
		color: Color transparent;
		borderWidth: 0.
	self createOkButton.
	self createCancelButton.
	buttonPane addMorph: self cancelButton
		fullFrame: (LayoutFrame fractions: (0 @ 0 corner: 0.49 @ 1.0)
				offsets: (0 @ 0 corner: 0 @ 0)).
	buttonPane addMorph: self okButton
		fullFrame: (LayoutFrame fractions: (0.51 @ 0 corner: 1.0 @ 1.0)
				offsets: (0 @ 0 corner: 0 @ 0)).
	^buttonPane
]

{ #category : #'ui creation' }
FileChooser >> createDialogBoxCaptionPane [
	"Create a morph to hold the caption string. The caption is created in setCaption:"

	| icon frame |
	captionPane := AlignmentMorph new.
	captionPane
		color: Color transparent;
		layoutPolicy: ProportionalLayout new.

	"You can change the caption later by calling setCaption:"
	self setCaption: 'Please select a file' translated.
	self setCaptionFont: Preferences windowTitleFont.
	icon := SketchMorph new.
	icon form: MenuIcons openIcon.
	captionPane addMorph: icon.
	frame := LayoutFrame new.
	frame
		leftFraction: 0;
		topFraction: 0.5;
		leftOffset: icon form width // 2;
		topOffset: (icon form width // 2) negated.
	icon layoutFrame: frame.
	^captionPane
]

{ #category : #'ui creation' }
FileChooser >> createDialogBoxLayout [
	"Create a layout suitable for a MorphicModel file chooser."

	| inset insetNeg captionTop captionBottom buttonsBottom buttonsTop contentTop contentBottom |

	inset := 6.
	insetNeg := inset negated.
	captionTop := 0.
	captionBottom := 33.
	contentTop := captionBottom + inset.
	contentBottom := -30 - inset - inset.
	buttonsTop := contentBottom + inset.
	buttonsBottom := insetNeg.

	self addFullPanesTo: self morphicView
		from: {
				{
					(self captionPane).
					(0 @ 0 corner: 1 @ 0).
					(0 @ captionTop corner: 0 @ captionBottom)
				}.
				{
					(self buttonPane).
					(0 @ 1 corner: 1 @ 1).
					(inset @ buttonsTop corner: insetNeg @ buttonsBottom)
				}.
				{
					(self directoryPane).
					(0 @ 0 corner: 0.5 @ 1).
					(inset @ contentTop corner: insetNeg @ contentBottom)
				}.
				{
					(self filePane).
					(0.5 @ 0 corner: 1 @ 1).
					(inset @ contentTop corner: insetNeg @ contentBottom)
				}
			}
]

{ #category : #'ui creation' }
FileChooser >> createDialogBoxMorphicView [
	| m |
	m := MorphicModel new
		layoutPolicy: ProportionalLayout new;
		color: (Color r: 0.9 g: 0.9 b: 0.9);
		borderColor: Color gray;
		borderWidth: 1;
		layoutInset: 0;
		extent: 600@400.
	self setMorphicView: m.
	^m
]

{ #category : #'ui creation' }
FileChooser >> createDialogBoxUI [
	"This method creates UI components and a layout that are suitable for a MorphicModel. Also centers the morphic view in the world. Note that the order of the method calls are important if you modify this."

	self
		createDialogBoxMorphicView;
		createDialogBoxCaptionPane;
		createDialogBoxButtonPane;
		createDirectoryPane;
		createFilePane;
		createDialogBoxLayout;
		centerMorphicView.
	^self morphicView
]

{ #category : #'ui creation' }
FileChooser >> createDirectoryPane [
	directoryPane := self morphicDirectoryTreePane.
	directoryPane borderWidth: 0.
	^directoryPane
]

{ #category : #'ui creation' }
FileChooser >> createFilePane [
	filePane := self morphicFileListPane.
	filePane borderWidth: 0.
	^filePane
]

{ #category : #'ui creation' }
FileChooser >> createOkButton [
	okButton := SimpleButtonMorph new.
	okButton 
		label: 'Open' translated;
		color: Color transparent;
		borderColor: Color black;
		borderWidth: 1.
	okButton 
		on: #mouseUp 
		send: #okHit
		to: self.
	^okButton
]

{ #category : #'ui creation' }
FileChooser >> createSystemWindowButtonPane [
	"Create buttons suitable for a SystemWindow file chooser."

	self optionalButtonSpecs: self okayAndCancelServices.
	buttonPane := self optionalButtonRow.
	okButton := buttonPane firstSubmorph.
	cancelButton := buttonPane firstSubmorph.
	^buttonPane
]

{ #category : #'ui creation' }
FileChooser >> createSystemWindowCaptionPane [
	"Create a morph to hold the caption string. The caption is created in setCaption:"

	captionPane := AlignmentMorph new.
	captionPane
		color: Color transparent;
		layoutPolicy: ProportionalLayout new.
	"You can change the caption later by calling setCaption:"
	self setCaption: 'Please select a file' translated.
	^captionPane
]

{ #category : #'ui creation' }
FileChooser >> createSystemWindowLayout [
	"Create a layout suitable for a SystemWindow file chooser."

	| buttonsHeight |

	buttonsHeight := 33.

	self addFullPanesTo: self morphicView
		from: {
				{
					(self buttonPane).
					(0 @ 0 corner: 1 @ 0).
					(0 @ 0 corner: 0 @ buttonsHeight)
				}.
				{
					(self directoryPane).
					(0 @ 0 corner: 0.5 @ 1).
					(0 @ buttonsHeight corner: 0 @ 0)
				}.
				{
					(self filePane).
					(0.5 @ 0 corner: 1 @ 1).
					(0 @ buttonsHeight corner: 0 @ 0)
				}
			}
]

{ #category : #'ui creation' }
FileChooser >> createSystemWindowLayoutWithCaptionPane [

	| buttonsHeight captionHeight |

	buttonsHeight := 33.
	captionHeight := 28.

	self addFullPanesTo: self morphicView
		from: {
				{
					(self captionPane). 
					(0 @ 0 corner: 1 @ 0). 
					(0 @ 0 corner: 0 @ captionHeight)
				}.
				{
					(self buttonPane).
					(0 @ 0 corner: 1 @ 0).
					(0 @ captionHeight corner: 0 @ (captionHeight + buttonsHeight))
				}.
				{
					(self directoryPane).
					(0 @ 0 corner: 0.5 @ 1).
					(0 @ (captionHeight + buttonsHeight) corner: 0 @ 0)
				}.
				{
					(self filePane).
					(0.5 @ 0 corner: 1 @ 1).
					(0 @ (captionHeight + buttonsHeight) corner: 0 @ 0)
				}
			}
]

{ #category : #'ui creation' }
FileChooser >> createSystemWindowMorphicView [
	| m |
	m := SystemWindow labelled: 'Please select a file' translated. "self directory pathName."
	"m deleteCloseBox."
	self setMorphicView: m.
]

{ #category : #'ui creation' }
FileChooser >> createSystemWindowUI [
	"This method creates UI components and a layout that are suitable for a SystemWindow. Note that the order of the method calls are important."

	self
		createSystemWindowMorphicView;
		createSystemWindowButtonPane;
		createDirectoryPane;
		createFilePane;
		createSystemWindowLayout.
	^self morphicView
]

{ #category : #'ui creation' }
FileChooser >> createSystemWindowUIWithCaptionPane [
	self
		createSystemWindowMorphicView;
		createSystemWindowCaptionPane;
		createSystemWindowButtonPane;
		createDirectoryPane;
		createFilePane;
		createSystemWindowLayoutWithCaptionPane.
	^self morphicView
]

{ #category : #accessing }
FileChooser >> directory [
	^super directory
]

{ #category : #accessing }
FileChooser >> directoryPane [
	^directoryPane
]

{ #category : #updating }
FileChooser >> fileNameFormattedFrom: entry sizePad: sizePad [ 
	"If the short file list flag is false, we send this on to the superclass."

	| nameStr |
	showShortFileNames 
		ifFalse: [^super fileNameFormattedFrom: entry sizePad: sizePad].

	"Otherwise, just show the name of the file in the file list."
	nameStr := (entry isDirectory)
					ifTrue: [entry name, self folderString]
					ifFalse: [entry name].
	^nameStr
]

{ #category : #accessing }
FileChooser >> filePane [
	^filePane
]

{ #category : #initialization }
FileChooser >> initializeAsDialogBox [
	self initializeBasicParameters.
	self createDialogBoxUI.
	self morphicView
		useRoundedCorners;
		color: (Color r: 0.9 g: 0.9 b: 0.9);
		adoptPaneColor: (Color r: 0.6 g: 0.7 b: 1).
	self 
		setCaptionColor: Color transparent;
		setButtonColor: (Color r: 0.9 g: 0.9 b: 0.9).

]

{ #category : #initialization }
FileChooser >> initializeAsSystemWindow [
	self initializeBasicParameters.
	self createSystemWindowUI.
]

{ #category : #initialization }
FileChooser >> initializeAsSystemWindowWithCaptionPane [
	self initializeBasicParameters.
	self createSystemWindowUIWithCaptionPane.
]

{ #category : #initialization }
FileChooser >> initializeBasicParameters [
	self showShortFileNames: true.
	self setDirectory: FileDirectory default.
]

{ #category : #accessing }
FileChooser >> morphicView [
	^view
]

{ #category : #accessing }
FileChooser >> okButton [
	^okButton
]

{ #category : #open }
FileChooser >> open [
	| model |
	self postOpen. "Funny name in this context, should be renamed, but whatever..."
	self morphicView openInWorld.
	UserInterfaceTheme current applyTo: self morphicView allMorphs.
	model := self morphicView model.
	FileChooser modalLoopOn: self morphicView.
	^ model getSelectedFile.

]

{ #category : #'ui creation' }
FileChooser >> setButtonColor: aColor [
	self okButton  color: aColor.
	self cancelButton  color: aColor.

]

{ #category : #'ui creation' }
FileChooser >> setCaption: aString [ 
	| frame |
	caption ifNil: 
			[caption := StringMorph new.
			self captionPane addMorph: caption].
	caption contents: aString.
	frame := LayoutFrame new.
	frame
		leftFraction: 0.5;
		topFraction: 0.5;
		leftOffset: caption width negated // 2;
		topOffset: caption height negated // 2.
	caption layoutFrame: frame
]

{ #category : #'ui creation' }
FileChooser >> setCaptionColor: aColor [ 
	self captionPane color: aColor
]

{ #category : #'ui creation' }
FileChooser >> setCaptionFont: aFont [
	self caption font: aFont.
	self setCaption: self caption contents asString.


]

{ #category : #initialization }
FileChooser >> setDirectory: aDir [
	^super directory: aDir
]

{ #category : #initialization }
FileChooser >> setMorphicView: aMorphicModel [
	view := aMorphicModel.
	self modalView: view.
	view model: self.
]

{ #category : #'ui creation' }
FileChooser >> setPaneColor: aColor [
	self morphicView 
		color: aColor;
		adoptPaneColor: aColor.


]

{ #category : #initialization }
FileChooser >> setSuffixes: aList [
	self fileSelectionBlock:  [:entry :myPattern |
			entry isDirectory
				ifTrue:
					[false]
				ifFalse:
					[aList includes: (FileDirectory extensionFor: entry name asLowercase)]]
]

{ #category : #initialization }
FileChooser >> showShortFileNames: aBoolean [ 
	showShortFileNames := aBoolean
]

{ #category : #updating }
FileChooser >> updateButtonRow [
	"Prevent updating of the the button row."
]
