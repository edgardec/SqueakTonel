"
A global cache of web pages known to this Squeak image.  Since there is a single, global page cache, it is implemented entirely as class methods.

Once a page has an entry, keep it.  (url string -> A SqueakPage)  The SqueakPage has a thumbnail and other info, but may not have the contentsMorph.  The morph is purged when space is needed, and fetched from the server as needed.

See SqueakPage's comment for the stages of in/out.
"
Class {
	#name : #SqueakPageCache,
	#superclass : #Object,
	#classVars : [
		'GlobalPolicy',
		'PageCache'
	],
	#category : #'MorphicExtras-SqueakPage'
}

{ #category : #'cache access' }
SqueakPageCache class >> allURLs [
	"Answer a collection of URLs for all pages in the cache."

	^ PageCache keys


]

{ #category : #'cache access' }
SqueakPageCache class >> atURL: aURLString [
	"Answer the page corresponding to this URL. Evaluate the given block if there is no entry for the given URL."

	
	^ PageCache at: aURLString ifAbsent: [ | pg |
		pg := SqueakPage new.
		"stamp := Utilities authorInitialsPerSe ifNil: ['*']."
		"pg author: stamp."
		"Need to deal with inst vars if we turn out to be new!"
		"pg url: aURLString. 	done by atURL:put:"
		self atURL: aURLString put: pg.
		pg]

]

{ #category : #'cache access' }
SqueakPageCache class >> atURL: aURLString ifAbsent: failBlock [
	"Answer the page corresponding to this URL. Evaluate the given block if there is no entry for the given URL."

	self halt.  "use atURL:"

]

{ #category : #'cache access' }
SqueakPageCache class >> atURL: aURLString oldPage: aPage [
	"Bring in page and return the object.  First try looking up my url in the pageCache.  Then try the page (and install it, under its url).  Then start from scratch with the url."

	| myPage |
	(myPage := PageCache at: aURLString ifAbsent: [nil]) ifNotNil: [
		^ myPage].
	aPage url: aURLString.	"for consistancy"
	PageCache at: aPage url put: aPage.
	^ aPage
]

{ #category : #'cache access' }
SqueakPageCache class >> atURL: aURLString put: aSqueakPage [
	"Store the given page in the cache entry for the given URL."

	aSqueakPage url: aURLString.
	aSqueakPage contentsMorph isInMemory ifTrue: [
		aSqueakPage contentsMorph ifNotNil: [
			aSqueakPage contentsMorph setProperty: #SqueakPage 
				toValue: aSqueakPage]].
	PageCache at: aURLString put: aSqueakPage.

]

{ #category : #housekeeping }
SqueakPageCache class >> deleteUnreferencedPages [
	"Remove any pages that are not current referred to by any book or URL morph."
	"Details: Since unreferenced pages could refer to other pages, this process is iterated until no unreferenced pages can be found. It currently does not collect cycles."
	"SqueakPageCache deleteUnreferencedPages"

	| unreferenced |
	[
		Smalltalk garbageCollect.
		unreferenced := PageCache keys asSet.
		URLMorph allSubInstancesDo: [:m | unreferenced remove: m url ifAbsent: []].
		MorphObjectOut allInstancesDo: [:ticklish |
			unreferenced remove: ticklish url ifAbsent: []].
		unreferenced size = 0 ifTrue: [^ self].
		unreferenced do: [:url | PageCache removeKey: url ifAbsent: []]] repeat

]

{ #category : #'cache access' }
SqueakPageCache class >> doPagesInMemory: aBlock [
	"Evaluate aBlock for each page whose contentsMorph is in-memory.  Don't add or remove pages while in this loop."

	PageCache do: [:sqkPage |
		sqkPage isContentsInMemory ifTrue: [aBlock value: sqkPage]].
]

{ #category : #'cache access' }
SqueakPageCache class >> generateURL [
	"Generate an unused URL for an in-memory page."
	"SqueakPageCache generateURL"

	| sd |
	sd := ServerFile new on: 'file:./'.
	sd fileName: 'page1.sp'.
	^ SqueakPage new urlNoOverwrite: sd pathForFile

]

{ #category : #'cache access' }
SqueakPageCache class >> includesMorph: aPasteUp [

	PageCache do: [:squeakPage |
		squeakPage contentsMorph == aPasteUp ifTrue: [^ true]].
	^ false
]

{ #category : #'class initialization' }
SqueakPageCache class >> initialize [
	"SqueakPageCache initialize"

	GlobalPolicy := #neverWrite.
	PageCache := Dictionary new: 100.
		"forgets urls of pages, but ObjectOuts still remember them"

]

{ #category : #'cache access' }
SqueakPageCache class >> pageCache [

	^ PageCache
]

{ #category : #'cache access' }
SqueakPageCache class >> pageForMorph: aPasteUp [

	PageCache do: [:squeakPage |
		squeakPage contentsMorph == aPasteUp ifTrue: [^ squeakPage]].
	^ nil
]

{ #category : #'cache access' }
SqueakPageCache class >> purge [
	"Replace morphs with tombstones in all pages that are clean and not being shown.  Write any dirty ones first, if allowed to."

	| list |
	list := OrderedCollection new.
	GlobalPolicy == #neverWrite 
		ifTrue: [PageCache doPagesInMemory: [:aPage | list add: aPage prePurge]]
			"Writing only done by user's command"
		ifFalse: [
			PageCache doPagesInMemory: [:aPage | aPage write
					 list add: aPage prePurge]].
	list := list select: [:each | each notNil].
	"do bulk become:"
	(list collect: [:each | each contentsMorph])
		elementsExchangeIdentityWith:
			(list collect: [:pg | MorphObjectOut new xxxSetUrl: pg url page: pg])

]

{ #category : #'cache access' }
SqueakPageCache class >> purge: megs [
	"Replace morphs with tombstones in all pages that are clean and not being shown.  Do this until megs of new memory have been recovered.  Write any dirty ones first, if allowed to."

	| goal |
	goal := Smalltalk garbageCollect + (megs * 1000000) asInteger.
	PageCache doPagesInMemory: [:aPage | 
		GlobalPolicy == #neverWrite ifFalse: [aPage write].
		aPage purge.
		Smalltalk garbageCollect > goal ifTrue: [^ true]].	"got enough"
	^ false	"caller may want to tell the user to write out more pages"
]

{ #category : #housekeeping }
SqueakPageCache class >> releaseCachedStateOfPages [
	"Note: This shouldn't be necessary if we are doing a good job of releasing cached state as we go. If running this doesn't do very much, we're doing well!"
	"SqueakPageCache releaseCachedStateOfPages"

	| memBytes |
	memBytes := Smalltalk garbageCollect.
	PageCache do: [:pg |
		pg contentsMorph allMorphsDo: [:m | m releaseCachedState]].
	^ (Smalltalk garbageCollect - memBytes) printString, ' bytes recovered'

]

{ #category : #'cache access' }
SqueakPageCache class >> removeURL: aURLString [
	"Remove the cache entry for the given URL. Do nothing if it has no cache entry."

	PageCache removeKey: aURLString ifAbsent: [].

]

{ #category : #'cache access' }
SqueakPageCache class >> write [
	"Write out all dirty pages"
	GlobalPolicy == #neverWrite ifTrue: [^ self].
	self doPagesInMemory: [:aPage | aPage write].
]
