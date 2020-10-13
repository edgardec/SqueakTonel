Class {
	#name : #SqueakToolsPreferenceBrowserHelp,
	#superclass : #SqueakToolsHelp,
	#category : #'Help-Squeak-Project'
}

{ #category : #accessing }
SqueakToolsPreferenceBrowserHelp class >> bookName [
	<generated>
	^'Preference Browser'
]

{ #category : #accessing }
SqueakToolsPreferenceBrowserHelp class >> defaultPage [

	^ #preferenceBrowser
]

{ #category : #pages }
SqueakToolsPreferenceBrowserHelp class >> localAndGlobal [
	<generated>
	"This method was automatically generated. Edit it using:"
	"SqueakToolsPreferenceBrowserHelp edit: #localAndGlobal"
	^(HelpTopic
		title: 'Local and global preferences'
		contents: 
'Some preferences can be local instead of global. When a preference is set as global, its value will apply to whatever project you are in. A local preference will only be valid in the project that you set it in.!
]style[(24 5 181),b,!' readStream nextChunkText)
			key: #localAndGlobal;
			shouldStyle: false;
			yourself
]

{ #category : #accessing }
SqueakToolsPreferenceBrowserHelp class >> pages [
	<generated>
	^ #(preferenceBrowser localAndGlobal savingAndLoading)
]

{ #category : #pages }
SqueakToolsPreferenceBrowserHelp class >> preferenceBrowser [
	<generated>
	"This method was automatically generated. Edit it using:"
	"SqueakToolsPreferenceBrowserHelp edit: #preferenceBrowser"
	^(HelpTopic
		title: 'What is the Preference Browser'
		contents: 
'Many aspects of the system are governed by the settings of various preferences. The Preference Browser lists all of them and allows you to adjust them.

Click on any of the categories shown in the list on the left to see all the preferences in that category. Alternatively, type into the search box at the top of the window and all preferences matching whatever you typed will appear in the category "search results".

To find out more about any a particular preference, just select it and its help text will appear. The "more" button at the end of the help text opens up a menu with some more expert-oriented options.!
]style[(84 18 186 10 121 16 183),Rcode://PreferenceBrowser open;b,,b,,b,!' readStream nextChunkText)
			key: #preferenceBrowser;
			shouldStyle: false;
			yourself
]

{ #category : #pages }
SqueakToolsPreferenceBrowserHelp class >> savingAndLoading [
	<generated>
	"This method was automatically generated. Edit it using:"
	"SqueakToolsPreferenceBrowserHelp edit: #savingAndLoading"
	^(HelpTopic
		title: 'Saving and loading'
		contents: 
'The Save button allows you to quickly save your current settings in your image so they can be restored later using the Load button. This is useful to make some experiments and revert them later.

To carry your settings to another Squeak image, you might want to use the Save to disk and Load from disk buttons. The former option will store all your settings in a file named ''my.prefs'' in your Squeak''s current directory.!
]style[(4 4 111 4 147 12 5 14 92 26 1),b,,b,,b,,b,,Rcode://FileList open;,!' readStream nextChunkText)
			key: #savingAndLoading;
			shouldStyle: false;
			yourself
]
