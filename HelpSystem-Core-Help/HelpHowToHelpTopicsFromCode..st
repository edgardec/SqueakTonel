Class {
	#name : #HelpHowToHelpTopicsFromCode,
	#superclass : #HelpHowToHelpTopics,
	#category : #'HelpSystem-Core-Help'
}

{ #category : #accessing }
HelpHowToHelpTopicsFromCode class >> bookName [
	^'Custom help from code'
]

{ #category : #pages }
HelpHowToHelpTopicsFromCode class >> overview [
	"This method was automatically generated. Edit it using:"
	"HelpHowToHelpTopicsFromCode edit: #overview"
	^HelpTopic
		title: 'Overview'
		contents: 
'Overview
	
The help system allows you to provide your own help books and help texts. You can open the help browser on any object that is able to understand #asHelpTopic.

This method returns the root node of the displayed topic hierarchy:

      HelpBrowser openOn: myObject

Typically the object does not convert itself to a help topic structure; rather it dispatches to a builder (see HelpBuilder and subclasses) that does all this. 
	
A much more convenient and reproducable way is to implement custom help classes. This allows you to implement and manage your help texts using the standard development and code management tools. These custom help classes are subclasses of "CustomHelp" and are automatically included into the standard help browser. !
]style[(387 11 280 10 65),LHelpBuilder Hierarchy;,,LCustomHelp Hierarchy;,!' readStream nextChunkText
]

{ #category : #accessing }
HelpHowToHelpTopicsFromCode class >> pages [
	^#(overview step1 step2 step3 step4 step5 step6 step7)
]

{ #category : #pages }
HelpHowToHelpTopicsFromCode class >> step1 [
	"This method was automatically generated. Edit it using:"
	"HelpHowToHelpTopicsFromCode edit: #step1"
	^HelpTopic 
		title: 'Step 1 - Create a class for the book'
		contents:
		'STEP 1 - CREATE A CLASS FOR THE BOOK
		
There is a predefined class CustomHelp which you have to subclass for a custom help book to show up as a book in the Help browser:
	
  CustomHelp subclass: #MyAppHelp
    	instanceVariableNames: ''''
	  classVariableNames: ''''
	  poolDictionaries: ''''
	  category: ''MyApp-Help'' 

Class methods on this class can reflect pages and if you want to provide nested help books just subclass your own help class to form a hierarchy. Any new subclass of MyAppHelp will then be a new book in your hierarchy.

The class category used should end with "-Help" so it is easy to recognize that it includes the help support of your project.'

]

{ #category : #pages }
HelpHowToHelpTopicsFromCode class >> step2 [
	"This method was automatically generated. Edit it using:"
	"HelpHowToHelpTopicsFromCode edit: #step2"
	^HelpTopic
		title: 'Step 2 - Provide a book name'
		contents:
	'STEP 2 - PROVIDE A BOOK NAME
	
Now implement the class method #bookName to return the name of your help book.

   bookName
	    ^''My App help''
	
By implementing this method the system knows how you would like to name your book and uses the given string as a label in the HelpBrowser later.'

]

{ #category : #pages }
HelpHowToHelpTopicsFromCode class >> step3 [
	"This method was automatically generated. Edit it using:"
	"HelpHowToHelpTopicsFromCode edit: #step3"
	^HelpTopic
		title: 'Step 3 - Implement pages using methods'
		contents:
	'STEP 3 - IMPLEMENT PAGES USING METHODS 

Implement a page by defining a method that returns an instance of HelpPage defining a page title and a help text displayed in the help browser. 

     firstPage
     	    ^HelpTopic
	           title: ''First Page'' 
                 contents: ''Hello world''

Define a new method for each page of your book. Please group the pages in a method category called "pages".
You can also define an icon for the specific page:

     secondPage
     	    ^HelpTopic
	           title: ''Second Page'' 
    	           icon: (HelpIcons iconNamed: #packageIcon)
                 contents: ''More to come''


Note: 
=====
Later we may add support for better help contents than just plain text (markup descriptions, active morphs, ...)  '

]

{ #category : #pages }
HelpHowToHelpTopicsFromCode class >> step4 [
	"This method was automatically generated. Edit it using:"
	"HelpHowToHelpTopicsFromCode edit: #step4"
	^HelpTopic
		title: 'Step 4 - Defining the page order'
		contents:
	'STEP 4 - DEFINING THE PAGE ORDER 

By implementing the class method #pages you return a collection of method selectors to define the order in which the pages appear in your book: 

     pages
     	    ^#(firstPage secondPage)

'

]

{ #category : #pages }
HelpHowToHelpTopicsFromCode class >> step5 [
	"This method was automatically generated. Edit it using:"
	"HelpHowToHelpTopicsFromCode edit: #step5"
	^HelpTopic
		title: 'Step 5 - Test your help'
		contents:
	'STEP 5 - TEST YOUR HELP
	
By using 
      
       HelpBrowser open

 
'

]

{ #category : #pages }
HelpHowToHelpTopicsFromCode class >> step6 [
	"This method was automatically generated. Edit it using:"
	"HelpHowToHelpTopicsFromCode edit: #step6"
	^HelpTopic
		title: 'Step 6 - Add more structure'
		contents:
	'STEP 6 - ADD MORE STRUCTURE

If you add a new subclass to your custom help class and repeating step 2 to 4 you can
profide new substructures (subbooks) since the help books are mapped to the 
class hierarchy. Example:
 
MyAppHelp subclass: #MyAppTutorial
    	instanceVariableNames: ''''
	  classVariableNames: ''''
	  poolDictionaries: ''''
	  category: ''MyApp-Help'' 

then implement a #bookName, the pages and a #pages method as before on this new 
class and reopen the help browser. 		
'

]

{ #category : #pages }
HelpHowToHelpTopicsFromCode class >> step7 [
	"This method was automatically generated. Edit it using:"
	"HelpHowToHelpTopicsFromCode edit: #step7"
	^HelpTopic
		title: 'Step 7 - Tips and Tricks'
		contents:
	'STEP 7 - TIPS AND TRICKS

Tip1:
          If you implement the #pages method you can also 
          use the name of a custom help class that should be 
          integrated between the specific pages:
 
              #pages
                   ^(firstPage MyAppTutorial secondPage)

Tip2:
          You can easily edit the help contents of a page by 
          using the #edit: message. For our example just evaluate:

			MyAppHelp edit: #firstPage
			
	     This will open a workspace with the help contents and 
	     when you accept it it will be saved back to the help 
	     method defining the topic.		  
		

'

]
