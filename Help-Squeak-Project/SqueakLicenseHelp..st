Class {
	#name : #SqueakLicenseHelp,
	#superclass : #SqueakProjectHelp,
	#category : #'Help-Squeak-Project'
}

{ #category : #accessing }
SqueakLicenseHelp class >> bookName [ 
	^'License'
]

{ #category : #pages }
SqueakLicenseHelp class >> fontLicenseBitstreamVera [
	"This method was automatically generated. Edit it using:"
	"SqueakLicenseHelp edit: #fontLicenseBitstreamVera"
	^(HelpTopic
		title: 'Bitstream Vera License'
		readOnlyContents: 
'Bitstream Vera Fonts Copyright

The fonts have a generous copyright, allowing derivative works (as
long as "Bitstream" or "Vera" are not in the names), and full
redistribution (so long as they are not *sold* by themselves). They
can be be bundled, redistributed and sold with any software.

The fonts are distributed under the following copyright:

Copyright

Copyright (c) 2003 by Bitstream, Inc. All Rights Reserved. Bitstream
Vera is a trademark of Bitstream, Inc.

Permission is hereby granted, free of charge, to any person obtaining
a copy of the fonts accompanying this license ("Fonts") and associated
documentation files (the "Font Software"), to reproduce and distribute
the Font Software, including without limitation the rights to use,
copy, merge, publish, distribute, and/or sell copies of the Font
Software, and to permit persons to whom the Font Software is furnished
to do so, subject to the following conditions:

The above copyright and trademark notices and this permission notice
shall be included in all copies of one or more of the Font Software
typefaces.

The Font Software may be modified, altered, or added to, and in
particular the designs of glyphs or characters in the Fonts may be
modified and additional glyphs or characters may be added to the
Fonts, only if the fonts are renamed to names not containing either
the words "Bitstream" or the word "Vera".

This License becomes null and void to the extent applicable to Fonts
or Font Software that has been modified and is distributed under the
"Bitstream Vera" names.

The Font Software may be sold as part of a larger software package but
no copy of one or more of the Font Software typefaces may be sold by
itself.

THE FONT SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT
OF COPYRIGHT, PATENT, TRADEMARK, OR OTHER RIGHT. IN NO EVENT SHALL
BITSTREAM OR THE GNOME FOUNDATION BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, INCLUDING ANY GENERAL, SPECIAL, INDIRECT, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF THE USE OR INABILITY TO USE THE FONT
SOFTWARE OR FROM OTHER DEALINGS IN THE FONT SOFTWARE.

Except as contained in this notice, the names of Gnome, the Gnome
Foundation, and Bitstream Inc., shall not be used in advertising or
otherwise to promote the sale, use or other dealings in this Font
Software without prior written authorization from the Gnome Foundation
or Bitstream Inc., respectively. For further information, contact:
fonts at gnome dot org.

Copyright FAQ

  1. I don''t understand the resale restriction… What gives?

    Bitstream is giving away these fonts, but wishes to ensure its
    competitors can''t just drop the fonts as is into a font sale system
    and sell them as is. It seems fair that if Bitstream can''t make money
    from the Bitstream Vera fonts, their competitors should not be able to
    do so either. You can sell the fonts as part of any software package,
    however.

  2. I want to package these fonts separately for distribution and
    sale as part of a larger software package or system.  Can I do so?

    Yes. A RPM or Debian package is a "larger software package" to begin
    with, and you aren''t selling them independently by themselves.
    See 1. above.

  3. Are derivative works allowed?
    Yes!!

  4. Can I change or add to the font(s)?
    Yes, but you must change the name(s) of the font(s).

  5. Under what terms are derivative works allowed?

    You must change the name(s) of the fonts. This is to ensure the
    quality of the fonts, both to protect Bitstream and Gnome. We want to
    ensure that if an application has opened a font specifically of these
    names, it gets what it expects (though of course, using fontconfig,
    substitutions could still could have occurred during font
    opening). You must include the Bitstream copyright. Additional
    copyrights can be added, as per copyright law. Happy Font Hacking!!

  6. If I have improvements for Bitstream Vera, is it possible they might get
    adopted in future versions?

    Yes. The contract between the Gnome Foundation and Bitstream has
    provisions for working with Bitstream to ensure quality additions to
    the Bitstream Vera font family. Please contact us if you have such
    additions. Note, that in general, we will want such additions for the
    entire family, not just a single font, and that you''ll have to keep
    both Gnome and Jim Lyles, Vera''s designer, happy!! To make sense to add
    glyphs to the font, they must be stylistically in keeping with Vera''s
    design. Vera cannot become a "ransom note" font. Jim Lyles will be
    providing a document describing the design elements used in Vera, as a
    guide and aid for people interested in contributing to Vera.

  7. I want to sell a software package that uses these fonts: Can I do so?

    Sure. Bundle the fonts with your software and sell your software
    with the fonts. That is the intent of the copyright.

  8. If applications have built the names "Bitstream Vera" into them,
    can I override this somehow to use fonts of my choosing?

    This depends on exact details of the software. Most open source
    systems and software (e.g., Gnome, KDE, etc.) are now converting to
    use fontconfig (see www.fontconfig.org) to handle font configuration,
    selection and substitution; it has provisions for overriding font
    names and subsituting alternatives. An example is provided by the
    supplied local.conf file, which chooses the family Bitstream Vera for
    "sans", "serif" and "monospace".  Other software (e.g., the XFree86
    core server) has other mechanisms for font substitution.

***

TTFontDescription descriptionFullNamed: ''Bitstream Vera Sans''.
TTFontDescription descriptionFullNamed: ''Bitstream Vera Sans Bold''.
TTFontDescription descriptionFullNamed: ''Bitstream Vera Sans Bold Oblique''.
TTFontDescription descriptionFullNamed: ''Bitstream Vera Sans Mono''.
TTFontDescription descriptionFullNamed: ''Bitstream Vera Sans Mono Bold''.
TTFontDescription descriptionFullNamed: ''Bitstream Vera Sans Mono Bold Oblique''.
TTFontDescription descriptionFullNamed: ''Bitstream Vera Sans Mono Oblique''.
TTFontDescription descriptionFullNamed: ''Bitstream Vera Sans Oblique''.
TTFontDescription descriptionFullNamed: ''Bitstream Vera Serif''.
TTFontDescription descriptionFullNamed: ''Bitstream Vera Serif Bold''.!
]style[(30 319 9 2311 13 3174 22 21 20 21 1 26 20 21 1 34 20 21 1 26 20 21 1 31 20 21 1 39 20 21 1 34 20 21 1 29 20 21 1 22 20 21 1 27 1)b,,b,,b,,c000000125,c125000125n,,c000000125,,c125000125n,,c000000125,,c125000125n,,c000000125,,c125000125n,,c000000125,,c125000125n,,c000000125,,c125000125n,,c000000125,,c125000125n,,c000000125,,c125000125n,,c000000125,,c125000125n,,c000000125,,c125000125n,!' readStream nextChunkText)
			key: #fontLicenseBitstreamVera;
			shouldStyle: false;
			yourself
]

{ #category : #pages }
SqueakLicenseHelp class >> licenseChange [

	^(HelpTopic
		title: 'License Details and History'
		readOnlyContents: 
'On 23 September 1996, Apple Computer Inc. released Squeak V1.1 under the "Squeak License" (SqL).

On May 8, 2006 Apple agreed to relicense original Squeak V1.1 under the Apple Public Source License.

On October 12, 2006 Apple granted permission to relicense under Apache license 2.0.

In 2006, VPRI began to collect "Distribution Agreements" for all contributors to Squeak since V1.1 up to V3.8, asking them to relicense their contributions, which were originally licensed under SqL, to the MIT license. This was a great effort on behalf of many and VPRI has 100s of signed documents agreeing to this.

Do you want to contribute source to Squeak? All new contributions since 4.0 must be under the MIT license. When you make your code available, please state explicitly in some form such as the description on a web site or email announcement that your contribution is under the MIT license. (It doesn''t have to be exclusive; you can release it under difference licenses at the same time.)

Have you contributed source to Squeak? If you believe you have, but have not sent in an agreement to allow your submission(s) to be licensed under the MIT license then please see http://netjam.org/squeak/contributors. There you can find a list of known contributors and a PDF of the agreement with instructions. The snail mail address is found in the agreement PDF file.

Also there are a few people for which we are lacking full contact information. If you think you can help please also visit the link above and see if you can identify any of the unknown developer initials or any of the developers for whom we do not have a current email address.!
]style[(603 43 344 38 141 37 433),b,,b,,Rhttp://netjam.org/squeak/contributors;,!' readStream nextChunkText)
			key: #licenseChange
]

{ #category : #pages }
SqueakLicenseHelp class >> noteOnResources [
	"This method was automatically generated. Edit it using:"
	"SqueakLicenseHelp edit: #noteOnResources"
	^(HelpTopic
		title: 'Note on Resources'
		contents: 
'Squeak provides several resources (such as icons or sounds) that may come with an extra license if the MIT license does not cover the particular artistic work. If such resources are materialized in source code (such as MenuIcons class >> #fugueBroomIconContents), we note the particular license in method comments.

In general, we are eager to only use extra licenses that share the spirit of the MIT license. Creative Commons falls in this category. Visit https://creativecommons.org/share-your-work/ to learn more.!
]style[(82 13 8 11 31 13 61 42 37 15 97 16 31 44 15)f1,f1i,f1,f1b,f1,f1i,f1,Rcode://MenuIcons class >> #fugueBroomIconContents;,f1,f1i,f1,f1b,f1,Rhttps://creativecommons.org/share-your-work/;,!' readStream nextChunkText)
			key: #noteOnResources;
			shouldStyle: false;
			yourself
]

{ #category : #pages }
SqueakLicenseHelp class >> officialLicense [
	"This method was automatically generated. Edit it using:"
	"SqueakLicenseHelp edit: #officialLicense"
	^ (HelpTopic
		title: 'Official License'
		contents: (MessageSend receiver: Smalltalk selector: #license))
		key: #officialLicense
]

{ #category : #accessing }
SqueakLicenseHelp class >> pages [
	^#( officialLicense licenseChange fontLicenseBitstreamVera noteOnResources)
]
