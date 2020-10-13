Class {
	#name : #SqueakTutorialsOnImage,
	#superclass : #SqueakTutorials,
	#category : #'Help-Squeak-Project'
}

{ #category : #accessing }
SqueakTutorialsOnImage class >> bookName [ 
	^'The Squeak Image'
]

{ #category : #accessing }
SqueakTutorialsOnImage class >> pages [
	^# (theImage)
]

{ #category : #pages }
SqueakTutorialsOnImage class >> theImage [
	"This method was automatically generated. Edit it using:"
	"SqueakTutorialsOnImage edit: #theImage"
	^(HelpTopic
		title: 'Working with the Squeak Image'
		contents: 
'Working with the ecosystem of objects in a Smalltalk image.
		
The basic tool for this is called an Inspector. Whenever you have an expression, like "3 + 4", you press cmd-i to "inspect it", which opens an inspector on the result. This works in any text area. Try for example inspecting "self" in a class browser, and you will inspect the underlying class object (which the browser shows a high-level view of).

In the Inspector you see the objects referenced by this object (via instance variables or indexed fields) in the left panel. Select any of them and choose "inspect" from the context menu (or press cmd-i again). This way you can inspect all the objects in the system.

A more modern tool than the Inspector (which was around 40 years ago already) is the Object Explorer. It presents you a tree view of an object and its "children", which again are the instance variables and indexed fields of the object. Open it with cmd-shift-i (or "explore" in the context menu).

You can also do the reverse. If you choose "objects pointing to this value" you get an inspector showing all the objects that directly point to this object. Similarly there is a "reverse explorer", which you can open by selecting "explore pointers".

There are two roots to all the objects in the system:

        Smalltalk specialObjectsArray

which basically holds everything the Virtual Machine needs to know about, and in turn almost every object in the whole image, and

        thisContext

which is the current execution context, holding onto temporary objects. When a garbage collection is performed, any object not reachable form either of these two roots is removed from memory.

An "interesting" global object to explore is

        Project current

which holds your current workspace, in particular

        Project current world

, the root of all morphs in the world. And of course

        Smalltalk

itself is the dictionary that holds all global objects, including all classes (unless they are defined in a non-global environment).

There is also a low-level way to enumerate all objects in memory. "self someObject" will return the very first object in memory (which happens to be the nil object), and "anObject nextObject" will return the next one:

        | object count |
        count := 0.
        object := self someObject.
        [0 == object]
                whileFalse: [count := count + 1.
                        object := object nextObject].
        count

Interestingly, this also finds objects that are due to be garbage-collected. For example, if you accidentally closed a text window, there is a good chance its contents will still be in memory, and can be retrieved using an expression like

        ByteString allInstances last: 10

This makes use of the someInstance/nextInstance methods, which are similar to someObject/nextObject, but restricted to instances of one class only.
!
]style[(59 2838)bi,!' readStream nextChunkText)
			key: #theImage;
			shouldStyle: false
]

{ #category : #testing }
SqueakTutorialsOnImage class >> usesCodeStyling [
	^ false
]
