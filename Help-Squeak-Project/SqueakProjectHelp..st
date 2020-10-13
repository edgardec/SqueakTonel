Class {
	#name : #SqueakProjectHelp,
	#superclass : #SqueakHelp,
	#category : #'Help-Squeak-Project'
}

{ #category : #accessing }
SqueakProjectHelp class >> bookName [ 
	^'The Project'
]

{ #category : #pages }
SqueakProjectHelp class >> extendingTheSystem [
	"This method was automatically generated. Edit it using:"
	"SqueakProjectHelp edit: #extendingTheSystem"
	^HelpTopic
		title: 'Extending The System'
		contents: 
'SqueakMap is an integrated catalog of external applications for Squeak.  It is accessible from the "Apps" menu.  This catalog does not host the projects, it merely documents the load scripts required to correctly bring them into the image.

Many SqueakMap packages use Installer, which defines several packages in its package-definitions protocol.  Any of these can be loaded with an expression like the following:

	Installer new merge: #openGL

Change #openGL to the selector name of the package you want to load.  The latest version of that package and all of its prerequisites will be merged into the image.  Merging a package is no different from loading it unless the package is already loaded, in which case it is upgraded to the latest version in a way that preserves any local changes you may already have made.

Other packages can be loaded through Metacello. If you come across a project providing either a MetacelloConfiguration or MetacelloBaseline, you can install Metacello through

	Installer ensureRecentMetacello

---------------

The source code for the Squeak, Pharo and Cuis virtual machines (VM) is generated from a package called ''VMMaker''.

MCHttpRepository
    location: ''http://source.squeak.org/VMMaker''
    user: ''''
    password: ''''

The source code for the VM is written in a subset of Smalltalk called ''Slang''.
It is translated to C.

The VMMaker.oscog fork generates the recent VM included in this release.

The generated VM code and the platform support code is at: http://opensmalltalk.org/	
See README file there.		

---------------

This remainder of this workspace documents load-scripts for packages that are not documented in either SqueakMap or Installer.

OCompletion
"Provides source code completion as you type"
(Installer ss project: ''OCompletion'')
      addPackage: ''OcompletionSqueakCompatibility'';
	addPackage: ''Ocompletion'';
	install.
(Smalltalk at: #ECToolSet) register.
(Smalltalk at: #ToolSet) default: (Smalltalk at: #ECToolSet).

Omnibrowser
"Including Refactoring engine"
(Installer ss project: ''MetacelloRepository'') install: ''ConfigurationOfOmniBrowser''.
((Smalltalk at: #ConfigurationOfOmniBrowser) project perform: #lastVersion) load: #( Dev ).

"No longer supported, use the Refactoring tools available on SqueakMap instead"


Pier CMS
"Pier CMS: http://www.piercms.com"
(Installer ss project: ''MetacelloRepository'') install: ''ConfigurationOfPier2''.
(Smalltalk at: #ConfigurationOfPier2) load.

(Installer lukas project: ''pier2'') install: ''Pier-Blog''.
(Installer lukas project: ''pier2'') install: ''Pier-Book''.
(Installer lukas project: ''pier2addons'') install: ''Pier-Setup''.
(Smalltalk at: #PRDistribution)  new register.

"The document model used is the one which later on lead to the Pharo Pillar document system"

Open Cobalt
"http://opencobalt.org (Best to run this from an image in an open cobalt directory)"
Installer ss project: ''TweakCore''; install: ''update''.
[Installer ss project: ''TweakExtras''; install: ''update'']
	on: (Smalltalk at: #CUnsynchronizedModification) do: [:ex | ex resume].
Installer cobalt project: ''Tweak'';
	answer: ''Would you like to conserve memory at all costs?'' with: true;
	answer: ''Password for interactive VNC connections?'' with: ''cobalt'';
	answer: ''Would you like to add the RFBServer to the World open menu?'' with: true;
	install: ''update''
!
]style[(9 309 19 252 6 126 8 130 9 141 21 135 95 109 68 61 25 173 11 47 226 2 11 292 8 480 11 547)Rcode://SMLoaderPlus open;FBitmap DejaVu Sans#14,FBitmap DejaVu Sans#14,Rcode://ToolSet browseClass: Installer category: ''package-definitions'';FBitmap DejaVu Sans#14,FBitmap DejaVu Sans#14,iFBitmap DejaVu Sans#14,FBitmap DejaVu Sans#14,uFBitmap DejaVu Sans#14,FBitmap DejaVu Sans#14,Rhttps://github.com/metacello/metacello;,FBitmap DejaVu Sans#14,,FBitmap DejaVu Sans#14,,FBitmap DejaVu Sans#14,,FBitmap DejaVu Sans#14,,FBitmap DejaVu Sans#14,buFBitmap DejaVu Sans#14,FBitmap DejaVu Sans#14,,FBitmap DejaVu Sans#14,buFBitmap DejaVu Sans#14,FBitmap DejaVu Sans#14,buFBitmap DejaVu Sans#14,FBitmap DejaVu Sans#14,buFBitmap DejaVu Sans#14,FBitmap DejaVu Sans#14!' readStream nextChunkText
]

{ #category : #accessing }
SqueakProjectHelp class >> pages [
	^#(extendingTheSystem squeakResourcesOnline squeakUserInterface workingWithSqueak)
]

{ #category : #pages }
SqueakProjectHelp class >> squeakResourcesOnline [
	"This method was automatically generated. Edit it using:"
	"SqueakProjectHelp edit: #squeakResourcesOnline"
	^(HelpTopic
		title: 'Squeak Resources Online'
		contents: 
'Web sites

Main site of Squeak
	http://www.squeak.org
Weekly Squeak
	http://news.squeak.org
Downloads for many versions
	http://www.squeak.org/downloads
Main site of OpenSmalltalk VM
	https://github.com/OpenSmalltalk/opensmalltalk-vm

Mailing lists

beginners
	This is the place to ask even the most basic questions. Don''t be afraid. Just ask. The community will help you get started with Squeak.
	http://lists.squeakfoundation.org/mailman/listinfo/beginners
	http://forum.world.st/Squeak-Beginners-f107673.html

squeak-dev
	This is the main Squeak mailing list. Join that list to be part in the community. Subscribe to the mail server or read on a forum.
	http://lists.squeakfoundation.org/mailman/listinfo/squeak-dev
	http://forum.world.st/Squeak-Dev-f45488.html

vm-beginners
	This is the entry point for people who want to learn more about how Squeak runs on your operating system. You may ask even basic questions. :-)
	http://lists.squeakfoundation.org/mailman/listinfo/vm-beginners
	http://forum.world.st/Smalltalk-VM-Beginners-f3068605.html

vm-dev
	This is the place where discussions about the OpenSmalltalk virtual machine happen. Join that list the be a part of the community.
	http://lists.squeakfoundation.org/mailman/listinfo/vm-dev
	http://forum.world.st/Squeak-VM-f104410.html

Books

Squeak By Example
	A beginners textbook, based on Squeak 3.9 and so a little out of date in some visual aspects and some details. Still a valuable resource. The content is maintained in github at
https://github.com/SquareBracketAssociates/SqueakByExample-english
but a prepared and ready to read pdf version can be found at
https://pdxscholar.library.pdx.edu/cgi/viewcontent.cgi?article=1112&context=compsci_fac

Other books
	Many books about Squeak and Smalltalk in general have been made available and are hosted at
http://stephane.ducasse.free.fr/FreeBooks.html!
]style[(11 19 2 21 1 15 22 1 27 2 31 32 49 2 13 1 1 11 135 2 60 2 51 2 10 2 132 61 2 44 2 14 145 63 2 58 2 6 134 57 2 44 2 5 2 17 2 177 66 62 87 2 11 94 46)b,I0i,I0,Rhttp://www.squeak.org;,I0,I0i,Rhttp://news.squeak.org;,I0,I0i,I0,Rhttp://www.squeak.org/downloads;,I0,Rhttps://github.com/OpenSmalltalk/opensmalltalk-vm;,I0,I0b,I0,,i,,b,Rhttp://lists.squeakfoundation.org/mailman/listinfo/beginners;,,Rhttp://forum.world.st/Squeak-Beginners-f107673.html;,,i,b,,Rhttp://lists.squeakfoundation.org/mailman/listinfo/squeak-dev;,,Rhttp://forum.world.st/Squeak-Dev-f45488.html;,,i,,Rhttp://lists.squeakfoundation.org/mailman/listinfo/vm-beginners;,,Rhttp://forum.world.st/Smalltalk-VM-Beginners-f3068605.html;,,i,,Rhttp://lists.squeakfoundation.org/mailman/listinfo/vm-dev;,,Rhttp://forum.world.st/Squeak-VM-f104410.html;,,b,,i,b,,Rhttps://github.com/SquareBracketAssociates/SqueakByExample-english;I1,,Rhttps://pdxscholar.library.pdx.edu/cgi/viewcontent.cgi?article=1112&context=compsci_fac;I1,,i,,Rhttp://stephane.ducasse.free.fr/FreeBooks.html;I1!' readStream nextChunkText)
			key: #squeakResourcesOnline;
			shouldStyle: false;
			yourself
]

{ #category : #pages }
SqueakProjectHelp class >> squeakUserInterface [
	"This method was automatically generated. Edit it using:"
	"SqueakProjectHelp edit: #squeakUserInterface"
	^(HelpTopic
		title: 'Squeak User Interface'
		contents: 
'The Squeak User Interface

The Squeak UI has some unusual elements that you may not have seen before. Here is a brief introduction to those elements.

1. Red button, Yellow Button; buttons on mice, trackpads and wheels - what do they do?

Smalltalk has been around a long time; since before most people had any idea that computers could have graphical screens or that devices such as mice existed. Smalltalk''s UI expects three button mice and to some extent still sticks with the ancient PARC tradition of naming them Red (left), Yellow (middle) and Blue (right). You''ll see these names in code referring to things like ''blueButtonActivity''.

Of course, not many mice used these days actually have the buttons colored, and quite a few have different numbers of buttons and even scroller wheels or trackpad surfaces; all of which can make it confusing to explain what button needs to be used. Laptops tend to have trackpads with perhaps a button, or two, or perhaps require a ctl or alt or cmd key to be pressed at the same time as the trackpad. To try to help work around the potential for confusion, think of the actions as <Select>, <Menu> and <Halo>.
 
a) <Select> is the fairly obvious ''select an item in a list'', or ''select a place in some text'', or press a screen button'' action. In many cases you can also hold down the button to drag the pointer to select a range of text, or double-click to perform some other action.
b) <Menu> will normally open a pop-up menu that is specific to the location of the pointer.
c) <Halo> normally displays the Morphic Halo (see below) that lets you perform many actions on the morph (a UI element)

In general on a Mac you can also hold the alt key down to get the <Menu> button action when simply pressing on a trackpad (or even one of the rare single-button mice) , or the cmd key for the Halo Button action. On a Windows laptop you can typically use the alt key for <Menu> and the ctl key for Halo. On the assorted unix systems out there you are on your own; the choice of window manager etc. can change anything.

In the Preference Browser you can ''swap mouse buttons'' to swap the <Menu> and <Halo> buttons if you prefer; this may feel more familiar for users of systems where a right button press opens menus.

2. Keyboard shortcuts

Squeak has a number of keyboard shortcuts available (which, like everything else are changeable by users) that can be found listed on the ''Command Key Mappings'' page. Some will seem very familiar and some will appear quite strange. Cmd-y, for example swaps the characters on the left and right of the text election; a surprisingly useful key for small tpyos ;-)

3. The Dock

Across the top of the screen lies the Dock; a mix of menu bar, tool bar and search interface. At the extreme left is the Squeak logo, which if clicked will open a menu that gives easy access to updating Squeak, checking your system configuration, and saving and/or quitting. The other headings at the left of the screen provide menus giving access to assorted tools and other facilities; you will probably mostly use the Tools and Apps items. To the right end of the Dock is the search interface, a quick way to search for message names and classes. Type a message (or a partial message, or a class name and press <Return> to see what it finds. There is also a clock and lastly a button that will expand the Squeak window to fill the screen - if possible it will take over the entire screen. Click on it again to return to the previous window size.

4. Menus

Squeak uses several sorts of menu.
a) the pull-down menus - like those that you see on the Dock.
b) pop-up menus that appear where the pointer is located (sometimes shifted to fit on-screen)
c) menus where some entries have an ellipsis (the ...) which tells you that clicking on the entry will open another menu
d) hierarchical menus where entries with a right-pointing triangle icon automatically open another menu, usually to the right of the original menu. As above, this may be modified to fit the new menu on the screen.
As with most GUIs these days clicking on a menu item will choose that action and clicking outside the menu will close the menu(s) and do nothing.

5. Projects

A project is an entire Squeak desktop full of windows and is akin to the desktop spaces used in some window systems. Projects can be used to change quickly from one task to another. An inactive project is represented by a project window, which shows a thumbnail of its state. Project windows are actually more like doors than windows, since you can enter the project just by clicking on them. Each project maintains its own set of windows and other information.

You can create a new project by choosing ''Create MVC Project'' or ''Create Morphic Project'' from the dock menu. The MVC projects use the older MVC type windows - the original windowing system. Note that not all tools work well - or at all - in MVC projects and you should generally use Morphic projects. The default project is a Morphic project.
To exit a project (and return to its parent project), choose ''previous project'' from the screen menu.

6. Morphic Halos

In a orphic project, pressing the <Halo> Button (see above!!) on a graphical object (e.g. a window) will surround it with a constellation of colored circles. These are called "halo handles." Additional clicks will cycle through the halos for the other graphical objects in the nesting structure. If you hold down the Shift key while <Halo>-clicking, the nested morphs will be traversed from innermost outward. Clicking Select or Menu will dismiss the halo. While the halo is up, letting the cursor linger over one of the halo handles for a few seconds will cause a balloon to pop up with the name of that handle. Three useful handles are the top-left "X" handle (delete), the bottom-right yellow handle (resize), and the brown handle (slide the object within its containing object). Halos allow complex graphical objects to be explored - or even disassembled (using the black halo handle). Usually no harm results from taking apart an object; you can just discard the pieces and create a new one.

7. Flaps

The Flaps are a sort of sliding menu - a drawer - containing tools etc as one way to access them. To enable Flaps, red-click on the desktop background to show the world menu, choose the "Flaps..." menu and "show shared tabs". Tabs labeled "Squeak", "Tools", "Supplies", etc., will appear around the edges of the Squeak desktop. Click on any tab to open the corresponding flap. Drag a tab to resize the flap and to relocate the tab. Bring up the halo on any tab and click on its menu handle to be presented with many options relating to the flap. Use the "Flaps..." menu, reached via the desktop menu, to control which flaps are visible and for other flap-related options and assistance.

8. Parts Bins

You can obtain new objects in many ways. The "Objects Catalog" (choose "objects'' from the world menu or open the objects flap) and several of the standard flaps (e.g. "Tools" and "Supplies") serve as "Parts Bins" the for new objects. Drag any icon you see in a Parts Bin and a fresh copy of the kind of object it represents will appear "in your hand"; click to deposit the new object anywhere you wish. You can also add your own objects to any of the flaps - just drag your object over the tab, wait for the flap to pop open, then drop the object at the desired position in the flap.
!
]style[(25 126 88 283 1 14 1 17 1 1008 1 59 1 137 1 492 25 52 1 86 20 73 5 126 13 421 5 5 4 130 1 282 10 156 1 81 1 415 1 19 13 221 16 675 16 49 1 91 15 843 7 691 13 47 15 523)b,,i,,b,,b,,b,,b,,b,,b,,i,,b,,i,,i,,i,,i,,i,,b,,i,,b,,b,,b,,i,,Rcode://(ProjectViewMorph newProjectViewInAWindowFor: MorphicProject new) openInWorld;,,i,,b,,Rcode://SystemWindow topWindow addHalo;,,i,,i,,Rcode://Project current world activateObjectsTool;,!' readStream nextChunkText)
			key: #squeakUserInterface;
			shouldStyle: false;
			yourself
]

{ #category : #pages }
SqueakProjectHelp class >> workingWithSqueak [
	"This method was automatically generated. Edit it using:"
	"SqueakProjectHelp edit: #workingWithSqueak"
	^(HelpTopic
		title: 'Working with Squeak'
		contents: 
'Take few minutes and get familiar with the image concept of the Squeak/Smalltalk system. This includes starting and quitting the image, learning where all the objects live, and understanding where your source code resides.

1. Starting and Quitting

Like most Smalltalks, the machine-executable portion is a relatively small program known as the virtual machine (VM).  The VM''s job is to provide services from the physical machine to the Smalltalk system; services like memory management; input from keyboards, mice, and networks; output to screens, files, and networks.  The Smalltalk system, including all data and code, is a system of objects built from the ground up, and interpreted by this virtual computer. This affords a Smalltalk system platform portability.

Smalltalk cannot run without the VM. The VM can''t do anything useful except process Smalltalk systems. They belong together like Rebo and Zooty.

To start the system
- On most OS you can double-click on the ''*.image'' file  and the OS file type handler will start the VM with that image file.
- On many OS, drag the ''*.image'' file to the VM executable application, typically named "Squeak" plus some version name such as "Squeak5.3".
- Where a command line terminal or shell is used, there are several command-line options for starting the system. Typically you can run ''squeak --help'' for some help.
By default, the system will open on the screen in a single OS hosted window, though there are options for headless usage.

To quit a Squeak session
- Choose ''quit'' from the Squeak-logo menu at the left of the menu bar (the Dock) at the top of the window. That will close the session and you will lose any work you did.
- If you ''save'', the image file will be overwritten and resume from that place the next time it''s launched. 
- In general you should not over-write the delivered image file but instead use the ''save as'' option to create your own work copy.

2. The Image File

Squeak is an environment built in its own objects from the ground up, including one or more end-user applications.  All of the objects in the system -- Classes, Dictionaries, Windows, Customers and other objects that make up the Squeak environment are stored in a binary ".image" file.  This is the "object-data file" loaded by the VM when Squeak is launched.

When an image is started, every object resumes exactly from where it was last saved.

3. The Sources File

Smalltalk is traditionally includes the source code in the running system. However, keeping multiple copies of the same source code in all images files is wasteful. Therefore, the source code itself is kept in a read-only .sources file and accessed by all images. The image files merely have pointers into this file, which is read on-the-fly to present original source code.

The code of the base system is stored in the file "SqueakV50.sources". This file does not change except between releases of Squeak. Normally this file should be placed in the folder containing the VM executable.

4. The Changes File

The purpose of Squeak is to develop new programs and systems.  Code changes to the running system are effective immediately.  But since multiple images can be running, they could not all update the .sources file safely.  Therefore, each image file is accompanied by a ".changes" file which contains source code changes for that and only that Smalltalk system..

The changes file is important for project work.  It keeps a sequential log of development activity for the purpose of recovering work performed since the last image-save.  Any of several events could lead to the need to recover work, including a power-outage or making an erroneous change to code required to keep the system running.

The changes file does not consume memory space, so Squeak is able to keep a complete history of all program changes.  This makes it easy to examine or even reinstate older versions of methods (see ''versions'' option in browser selector pane).  This encourages experimentation, since you can easily revert to the original versions of any set of methods.

In extreme cases where sources and/or changes files are not available, the system can still run, and will automatically decompile the bytecode methods in image memory, if necessary, into readable and editable versions of the original source code (only comments and temporary variable names are lost).

5. Transferring Code-Snippets Between Images

In addition to the ''save'' command that saves the entire state of the system, the code of individual methods, categories or classes may be ''filed out'' and then filed-in to another image.

6. Packages

The code of an entire project is encapsulated in a Package.  This allows users to share their code with other users.  Code of packages are delineated by the categories of their classes, and methods.  The Monticello browser is then used to wrap that code into a Package object which can be saved to a Monticello repository. Visit the Squeak Swiki for more info - http://wiki.squeak.org/squeak/1287

Some projects end up using the resources provided by several packages, resulting in a hierarchy of packages that make up a system.  The ''Installer'' class can be used to install such systems.!
]style[(224 24 98 15 611 18 90 18 236 19 173 6 165 6 178 9 39 17 449 19 591 19 1354 44 189 11 364 34 192),b,,i,,i,,i,,i,,b,,b,,b,,b,,b,,b,,b,,b,,Rhttp://wiki.squeak.org/squeak/1287;,!' readStream nextChunkText)
			key: #workingWithSqueak;
			shouldStyle: false;
			yourself
]
