#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/smalltalk/bin/gst -f
"Jinyan Li jli134 cmps112 asg3"

execname := '$RCSfile: cmdline.st,v $' =~ '.*: (.*),v.*' at: 1.
nl := Character nl.
queue := SortedCollection new.
|decodingtree|

FileStream extend [
   nl := Character nl.
   catFile [
      |count textline|
      count := 0.
      [self atEnd not] whileTrue: [
         count := count + 1.
         textline :=self nextLine.
         count asString size to: 5 do: [:skip| stdout << ' '].
         
         stdout << count << ': ' << textline << nl.
      ]
   ]
]

Character extend [
   isPrint [
      ^ (Character space < self) & (self <= $~)
   ]
   digits[
         ^ (self asInteger) > 15
         ]
   visible [
        "stdout << (self asInteger)."
      self isPrint ifTrue: [^' ', self asString, ' ']             
                   ifFalse: [ self digits
                      ifTrue:[((self asInteger) = 256) ifTrue:[ ^ 'EOF']ifFalse:[
                           ^ 'x', ((self asInteger printStringRadix: 16) copyFrom: 4 )]
                             ]
                      ifFalse:[
                             
                             ^ 'x0', ((self asInteger printStringRadix: 16) copyFrom: 4)]
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

freqtable := ZeroArray new: 257.
encodetable := ZeroArray new: 257.
freqtable at:256 put:1.
encodetable at:256 put:1.
"
freqtable := ZeroArray new: 256.
encodetable := ZeroArray new: 256.
"
Object subclass: Leaf [
   |char count|
   char [ ^ char ]
   count [ ^ count ]

   Leaf class >> new [
      self shouldNotImplement
   ]

   Leaf class >> new: aChar count: aCount [
      |result|
      result := super new.
      result setChar: aChar andCount: aCount.
      ^result
   ]

   setChar: aChar andCount: aCount [
      char := aChar.
      count := aCount.
   ]

   <= other [
      ^ (count < other count)
      | ((count = other count) & (char <= other char))
   ]

   printBase: aStream [
      ^ aStream << self class << '(' << char << ',' << count
   ]

   printOn: aStream [
      (self printBase: aStream) << ')'.
   ]

   inorder: visitor prefix: string [
      visitor value: char value: string.
   ]

]


Leaf subclass: Tree [
   |left right|

   Tree class >> new: aChar count: aCount [
      self shouldNotImplement
   ]

   Tree class >> new: aChar count: aCount left: aLeft right: aRight [
      |result|
      result := super new: aChar count: aCount.
      result setLeft: aLeft andRight: aRight.
      ^ result
   ]

   setLeft: aLeft andRight: aRight [
      left := aLeft.
      right := aRight.
   ]

   printOn: aStream [
      (self printBase: aStream) << ',' << left << ',' << right << ')'.
   ]

   inorder: visitor prefix: string [
      left inorder: visitor prefix: string, '0'.
      right inorder: visitor prefix: string, '1'.
   ]

]


Object subclass: OutBits [
   |bitIndex currentByte myStream|
   OutBits class >> new [
      self shouldNotImplement.
   ]
   OutBits class >> new: fileStream [
      |result|
      result := super new.
      result init: fileStream.
      ^result
   ]
   clearByte [
      bitIndex := 8.
      currentByte := 0.
   ]
   init: fileStream [
      myStream := fileStream.
      self clearByte.
   ]
   flushByte [

      currentByte = 8 ifFalse: [
         stdout <<'flushByte: '<< currentByte asCharacter<<Character nl.
         myStream nextPutByte: currentByte.
         self clearByte.
      ]
   ]
   writeBit: bit [
      currentByte := currentByte bitAt: bitIndex put: bit.
      "stdout <<'writeBit: '<< currentByte<<Character nl."
      bitIndex := bitIndex - 1.
      bitIndex = 0 ifTrue: [
       "stdout <<'writeBit: flushByte' <<Character nl."
        self flushByte].
   ]
]


"main function"

"var to hold pipline for input stream"
|infile infile2 outfile decodingTreeFlag outfilename argcount|

argcount:=0.

"parse the options and filename"Smalltalk arguments: '-d -t -c -u'
do: [:opt :arg |
  
   
   (opt = $d) ifTrue: [
   stdout <<'-d option is set'<<nl.
    ].
    
   (opt = $t) ifTrue: [
   decodingTreeFlag := 1.
   stdout <<'-t option is set'<<nl.
    ].

  (opt = $c) ifTrue: [
   stdout <<'-c option is set'<<nl.
   ].

  (opt = $u) ifTrue: [
   stdout <<'-u option is set'<<nl.
   ].
  
  (arg ~= nil) ifTrue: [
    
     argcount = 0 
        ifTrue:[
          stdout <<'input filename: ' << arg <<nl.
          infile := FileStream open: arg
                    mode: FileStream read.
          infile2 := FileStream open: arg
                    mode: FileStream read.]
        ifFalse:[
           stdout <<'output filename: ' << arg <<nl.
            outfile := FileStream open: arg
                       mode: FileStream write.].
  
     argcount := argcount + 1.
   ].
].

"
Smalltalk arguments size = 0 
   ifTrue: [stdout <<'require input file'<<nl.]
   ifFalse:[
        stdout <<'input filename: ' << (Smalltalk arguments at: 1) <<nl.
        infile := FileStream open: (Smalltalk arguments at: 1)
                              mode: FileStream read.
        stdout <<'output filename: ' << (Smalltalk arguments at: 2) <<nl.
    ].
"

[infile atEnd not] whileTrue: [
   |ordChar|
   ordChar := infile next asInteger.
   freqtable incr: ordChar.
].

"stdout <<  'freqtable at:256  '<<(freqtable at: 256)<< nl.
"
freqtable keysAndValuesDo: [:key :count |
   (count notNil and: [count > 0]) ifTrue: [
      queue add: (Leaf new: key count: count).
      "stdout <<  key asCharacter visible << '     ' << count
             << nl."
   ]
].




"stdout <<'output from sortedCollection'<< nl.
queue do: [:item| stdout << item << nl.]."

"stdout << nl << '----bulid tree-----' << nl."
[queue notEmpty] whileTrue: [
   |leftchild rightchild|
   
   leftchild := queue removeFirst.

   (queue notEmpty) ifTrue: [
                      rightchild := queue removeFirst.
              
                      newtree := ( Tree new: 0 
                        count: (leftchild count) +  (rightchild count)
                        left: leftchild right: rightchild).
                
                      queue add: newtree.
                      
                      "stdout << newtree << nl."]
                   
                    ifFalse:[
                      decodingtree:=leftchild.
                      "stdout << leftchild << nl."
                      ].
].


"stdout << nl << 'encode' << nl."
decodingtree inorder: [:char :string |
   encodetable at: char put: string.
   "stdout <<  char asCharacter visible<<'    '<< (freqtable at: char) 
               <<'        ' << string << nl."
] prefix: ''.

"decoding tree and table is printed to stdout"
decodingTreeFlag = 1 ifTrue:[
     stdout <<nl<< '------------decoding tree--------------' << nl.
     stdout << decodingtree << nl.

     stdout <<nl<< '------------encoding table-------------' << nl.
     encodetable keysAndValuesDo: [:key :count |
     (count notNil and: [count > 0]) ifTrue: [
        stdout <<  key asCharacter visible << '     '
               << (freqtable at: key) <<'    '<<count
               << nl.
     ]
    ].
].

stdout << '----------encoded input----------' << nl.
[infile2 atEnd not] whileTrue: [
   |ordChar2|
   ordChar2 := infile2 next asInteger.
   stdout << (encodetable at: ordChar2).
].

stdout<<nl.
infile close.
