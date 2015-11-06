#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/smalltalk/bin/gst -f
"Jinyan Li jli134 cmps112 asg3"

execname := '$RCSfile: cmdline.st,v $' =~ '.*: (.*),v.*' at: 1.
nl := Character nl.


Character extend [
   isPrint [
      ^ (Character space <= self) & (self >= $!)
   ]
   digits[
         ^ (self asInteger) > 15
         ]
   visible [
        "stdout << (self asInteger)."
      self isPrint ifTrue: [^' ', self asString]
                   ifFalse: [ self digits
                      ifTrue:[
                           ^ 'x', ((self asInteger printStringRadix: 16) copyFrom: 4 to: 5)]
                      ifFalse:[^ 'x0', ((self asInteger printStringRadix: 16) copyFrom: 4 to: 4)]

                     ]             
   ]
]

Object subclass: ZeroArray [
   |theArray|

   ZeroArray class >> new [
      self shouldNotImplement.
   ]

   ZeroArray class >> new: size [
      |result|
      result := super new.
      result init: size.
      ^ result
   ]

   init: size [
      theArray := Array new: size.
   ]

   size [
      ^ theArray size.
   ]

   at: index [
      ^ theArray at: index + 1.
   ]

   at: index put: value [
      ^ theArray at: index + 1 put: value.
   ]

   incr: index [
      (self at: index) isNil
         ifTrue: [ self at: index put: 0].
      self at: index put: (self at: index) + 1.
   ]

   keysAndValuesDo: aBlock [
      (0 to: (self size) - 1) do: [:index |
         aBlock value: index value: (self at: index).
      ]
   ]
]
Smalltalk arguments: '-d -t -c -u'
do: [:opt :arg |
   'option: ' display.
   opt display.
   
   (opt = $d) ifTrue: [
   ' -d' display.
   ' ' display.].
   (opt = $t) ifTrue: [
   ' -t' display.
   ' ' display.].

  (opt = $c) ifTrue: [
   ' -c' display.
   ' ' display.].

  (opt = $u) ifTrue: [
   ' -u' display.
   ' ' display.].

   ' ' displayNl.
].


freqtable := ZeroArray new: 256.

[stdin atEnd not] whileTrue: [
   |ordChar|
   ordChar := stdin next asInteger.
   freqtable incr: ordChar.
].

freqtable keysAndValuesDo: [:key :value |
   (value notNil and: [value > 0]) ifTrue: [
      stdout <<  key asCharacter visible << '     ' << value
             << nl.
   ]
].
