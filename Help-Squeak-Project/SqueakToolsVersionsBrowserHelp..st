Class {
	#name : #SqueakToolsVersionsBrowserHelp,
	#superclass : #SqueakToolsHelp,
	#category : #'Help-Squeak-Project'
}

{ #category : #accessing }
SqueakToolsVersionsBrowserHelp class >> bookName [
	<generated>
	^'Versions Browser'
]

{ #category : #pages }
SqueakToolsVersionsBrowserHelp class >> comparingVersions [
	<generated>
	"This method was automatically generated. Edit it using:"
	"SqueakToolsVersionsBrowserHelp edit: #comparingVersions"
	^(HelpTopic
		title: 'Comparing versions'
		contents: 
'The code pane shows the source for the selected version. If "diffing" is in effect, then differences betwen the selected version and the version before it are pointed out in the pane. Turn diffing on and off by choosing "toggle diffing" from the list pane menu, or hitting the "diffs" button, or hitting cmd-D when the cursor is over the list pane.

To get a comparison between the selected version and the current version, choose "compare to current" from the list pane menu or hit the "compare to current" button. (This is meaningless if the current version is selected, and is unnecessary if you''''re interested in diffs from between the current version and the next-most-recent version, since the standard in-pane "diff" feature will give you that.)

You can also compare the selected version with any other version using the "compare to version..." menu choice.!
]style[(13 337 19 496)b,,b,!' readStream nextChunkText)
			key: #comparingVersions;
			shouldStyle: false;
			yourself
]

{ #category : #accessing }
SqueakToolsVersionsBrowserHelp class >> defaultPage [

	^ #versionsBrowser
]

{ #category : #pages }
SqueakToolsVersionsBrowserHelp class >> notes [
	<generated>
	"This method was automatically generated. Edit it using:"
	"SqueakToolsVersionsBrowserHelp edit: #notes"
	^(HelpTopic
		title: 'Notes'
		contents: 
'If further versions of the method in question have been submitted elsewhere since you launched a particular Versions Browser, it will still stay nicely up-to-date if you''re in Morphic and have asked that smart updating be maintained; if you''re in mvc or in morphic but with smart-updating turned off, a versions browser is only brought up to date when you activate its window (and when you issue "revert" from within it, of course,) and you can also use the "update list" command to make certain the versions list is up to date.

The annotation pane in versions browsers shows information about the current version of the method in the image, not about the selected version.!
]style[(530 19 50 7 68),b,,i,!' readStream nextChunkText)
			key: #notes;
			shouldStyle: false;
			yourself
]

{ #category : #accessing }
SqueakToolsVersionsBrowserHelp class >> pages [
	<generated>
	^ #(versionsBrowser comparingVersions revertVersion privacyFeatures notes)
]

{ #category : #pages }
SqueakToolsVersionsBrowserHelp class >> privacyFeatures [
	<generated>
	"This method was automatically generated. Edit it using:"
	"SqueakToolsVersionsBrowserHelp edit: #privacyFeatures"
	^(HelpTopic
		title: 'Privacy features'
		contents: 
'To have the selected method deleted from the current change set permanently, hit the "remove from changes" button, or choose the corresponding command in the list pane menu. This is useful if you''ve put debugging code into a method, and now want to strip it out and cleanse your current change set of all memory of the excursion.!
]style[(35 294)b,!' readStream nextChunkText)
			key: #privacyFeatures;
			shouldStyle: false;
			yourself
]

{ #category : #pages }
SqueakToolsVersionsBrowserHelp class >> revertVersion [
	<generated>
	"This method was automatically generated. Edit it using:"
	"SqueakToolsVersionsBrowserHelp edit: #revertVersion"
	^(HelpTopic
		title: 'Reverting versions'
		contents: 
'To revert to an earlier version, select it (in the list pane) and then do any of the following:
* Choose "revert to this version" from the list pane menu;
* Hit the "revert" button;
* Type ENTER in the code pane;
* Type cmd-s (alt-s) in the code pane.!
]style[(32 64 155)b,,I1!' readStream nextChunkText)
			key: #revertVersion;
			shouldStyle: false;
			yourself
]

{ #category : #pages }
SqueakToolsVersionsBrowserHelp class >> versionsBrowser [
	<generated>
	"This method was automatically generated. Edit it using:"
	"SqueakToolsVersionsBrowserHelp edit: #versionsBrowser"
	^(HelpTopic
		title: 'What is a Versions Browser'
		contents: 
'The VersionsBrowser is a window that shows all implementations of a method or a class comment that have been ever installed in past or present. Inter alia, it allows you to compare certain versions or revert earlier versions.

Each entry in the list pane represents a version of the source code for the same method; the topmost entry is the current version, the next entry is the next most recent, etc.!
]style[(4 15 208 175)f1b,Rcode://VersionsBrowser browseMethod: VersionsBrowser >> #compareToOtherVersion;b,f1,!' readStream nextChunkText)
			key: #versionsBrowser;
			shouldStyle: false;
			yourself
]
