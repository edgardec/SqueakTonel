Class {
	#name : #SqueakToolsWorkspaceHelp,
	#superclass : #SqueakToolsHelp,
	#category : #'Help-Squeak-Project'
}

{ #category : #accessing }
SqueakToolsWorkspaceHelp class >> bookName [ 
	^'Workspace'
]

{ #category : #pages }
SqueakToolsWorkspaceHelp class >> openWorkspace [
	"This method was automatically generated. Edit it using:"
	"SqueakToolsWorkspaceHelp edit: #openWorkspace"
	^(HelpTopic
		title: 'Open a Workspace'
		contents: 
'You can open a Workspace window in any of the following ways:
		
- Keyboard Shortcut: while pointing at an empty part of the Squeak window, press alt-k (in Windows) or cmd-k (on a Mac) or ctrl-k (in Linux)
- World Menu: select "Workspace"
- Tools Flap: click on the Tools Flap. When it comes out, drag the Workspace icon out.
- Doit: select inside the following quote and doit: "Workspace open"!
]style[(15 9 184 10 176),Rcode://Workspace open;,,Rcode://ActiveWorld openWorldMenu;,!' readStream nextChunkText)
			key: #openWorkspace
]

{ #category : #accessing }
SqueakToolsWorkspaceHelp class >> pages [
	^#(workspace openWorkspace saveWorkspace)
]

{ #category : #pages }
SqueakToolsWorkspaceHelp class >> priority [

	^ 10
]

{ #category : #pages }
SqueakToolsWorkspaceHelp class >> saveWorkspace [
	^HelpTopic 
		title: 'Saving Workspace to a File'
		contents: 'You can save the text content of a Workspace to a file by choosing the workspace menu (from within the workspace), then ''more...'', then ''save contents to file...''.'
]

{ #category : #pages }
SqueakToolsWorkspaceHelp class >> workspace [
	^HelpTopic 
		title: 'What is a Workspace'
		contents: 'A Workspace is a window used as a scratchpad area where fragments of Smalltalk code can be entered, stored, edited, and evaluated.'
]
