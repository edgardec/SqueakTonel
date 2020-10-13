Class {
	#name : #SqueakTutorialsCommandKey,
	#superclass : #SqueakTutorials,
	#category : #'Help-Squeak-Project'
}

{ #category : #accessing }
SqueakTutorialsCommandKey class >> bookName [ 
	^'Command Key Mappings'
]

{ #category : #pages }
SqueakTutorialsCommandKey class >> commandKeyMappings [
	"This method was automatically generated. Edit it using:"
	"SqueakTutorialsCommandKey edit: #commandKeyMappings"
	^(HelpTopic
		title: 'Command Key Mappings'
		contents: 
'Lower-case command keys
(use with Cmd key on Mac and Alt key on other platforms)
a	Select all
b	Browse it (selection is a class name or cursor is over a class-list or message-list)
c	Copy selection
d	Do it (selection is a valid expression)
e	Exchange selection with prior selection
f	Find text with a dialog
g	Find the current selection again
j	Repeat the last selection replacement
i	Inspect it
k	Set font
l	Cancel text edit
m	Implementors of it
n	Senders of it
o	Spawn current method
p	Print it (selection is a valid expression)
q	Query symbol (toggle all possible completion for a given prefix)
s	Save (i.e. accept)
t	Finds a Transcript (when cursor is over the desktop)
u	Toggle alignment
v	Paste
w	Select/Delete preceding word (over text);  Close-window (over morphic desktop)
x	Cut selection
y	Swap characters
z	Undo

Note: for Do it, Senders of it, etc., a null selection will be expanded to a word or to the current line in an attempt to do what you want.  Also note that Senders/Implementors of it will find the outermost keyword selector in a large selection, as when you have selected a bracketed expression or an entire line.  Finally note that the same cmd-m and cmd-n (and cmd-v for versions) work in the message pane of most browsers.

Upper-case command keys
	(use with Shift-Cmd, or Ctrl on Mac
	or Shift-Alt on other platforms; sometimes Ctrl works too)
A	Advance argument
B	Browse it in this same browser (in System browsers only)
C	Compare the selected text to the clipboard contents
D	Debug-It
E	Method strings containing it
F	Insert ''ifFalse:''
G	fileIn from it (a file name)
H	Move cursor to top/home of text
I	Inspect via Object Explorer
J	Again many (apply the previous text command repeatedly until the end of the text)
K	Set style
L	Opens a FileList, bringing forward on that already exists if appropriate
M	Select current type-in
N	References to it (selection is a class name, or cursor is over a class-list or message-list)
O	Open single-message browser (in message lists)
P	Make project link
R	opens a Recent Submissions browser
S	Pretty-print a method in the current browser
T	Insert ''ifTrue:''
U	Convert linefeeds to carriage returns in selection
V	Paste author''s initials
W	Selectors containing it (in text); show-world-menu (when issued with cursor over desktop)
X	Force selection to lowercase
Y	Force selection to uppercase
Z	Redo

Other special keys
Backspace			Backward delete character
Shift-Bksp			Backward select or delete word
Del					Forward delete character
Shift-Del			Forward delete word
Esc					Pop up the context menu
Shift+Esc			Pop up the World Menu
Cmd+Esc			Close the active window
Ctrl+Esc			Present a list of open windows
Cmd+\				Send the active window to the back
Tab					Insert a tab char in a single-line selection or insert a tab at the beginning of each line in a multi-line selection
Shift-Tab			Remove a tab from the beginning of each line in the selection
Shift-Cmd-_	(underscore) condense selection into one line

Cursor keys
left, right,
up, down			Move cursor left, right, up or down
Ctrl-left				Move cursor left one word
Ctrl-right			Move cursor right one word
Home				Move cursor to begin of line or begin of text
End					Move cursor to end of line or end of text
PgUp, Ctrl-up		Move cursor up one page
PgDown, Ctrl-Dn	Move cursor down one page

Note all these keys can be used together with Shift to define or enlarge the selection. You cannot however shrink that selection again, as in some other systems.

Other Cmd-key combinations (not available on all platforms)
Return		Insert return followed by as many tabs as the previous line
			(with a further adjustment for additional brackets in that line)
Space		Select the current word as with double clicking

Enclose the selection in a kind of bracket.  Each is a toggle.
	(not available on all platforms)
Ctrl-(	Toggle enclosure within parentheses
Cmd-[	Toggle enclosure within brackets
Crtl-{	Toggle enclosure within curly braces
Ctrl-''	Toggle enclosure within double-quotes
Cmd-''	Toggle enclosure within single-quotes

Note also that you can double-click just inside any of the above delimiters, or at the beginning or end of a line, to select the text enclosed.

Text Emphasis
	(not available on all platforms)
Cmd-1	type the first method argument
Cmd-2	type the second method argument
Cmd-3	type the third method argument
Cmd-4	type the fourth method argument
Cmd-5	for future use
Cmd-6	color, action-on-click, link to class comment, link to method, url
		Brings up a menu.  To remove these properties, select
		more than the active part and then use command-0.
Cmd-7	bold
Cmd-8	italic
Cmd-9	negative kern (letters 1 pixel closer)
Cmd-0	make plain (removes all emphasis and kerning)
Cmd--	underlined
Cmd-=	struck out

Docking Bar
Ctrl-<n> opens the n-th (where n is between 0 and 7) menu if such exists, otherwise it moves the keyboard focus to the Search Bar. Currently this means:
Ctrl-0	Activates Search Bar or Scratch Pad
Ctrl-1	Squeak menu
Ctrl-2	Projects menu
Ctrl-3	Tools menu
Ctrl-4	Apps menu
Ctrl-5	Extras menu
Ctrl-6	Windows menu
Ctrl-7	Help menu	
!' readStream nextChunkText)
			key: #commandKeyMappings;
			shouldStyle: false
]

{ #category : #accessing }
SqueakTutorialsCommandKey class >> pages [
	^# (commandKeyMappings)
]

{ #category : #testing }
SqueakTutorialsCommandKey class >> usesCodeStyling [
	"I don't want the help browser to use code based styling on my content - I show a simep llist of key mappings which really don't need it"
	^false
]
