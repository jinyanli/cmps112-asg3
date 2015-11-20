#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/smalltalk/bin/gst -f

execname := '$RCSfile: hzip.st,v $' =~ '.*: (.*),v.*' at: 1.
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
      ifFalse: [ 
         self digits ifTrue:[
            ((self asInteger) = 256) ifTrue:[ ^ 'EOF']ifFalse:[
               ^ 'x', 
               ((self asInteger printStringRadix: 16) copyFrom: 4 )
            ]
        ]
        ifFalse:[
           ^ 'x0', 
           ((self asInteger printStringRadix: 16) copyFrom: 4)
        ]
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

Object subclass: BitStream [
   |bitIndex byte myStream|
   BitStream class >> new: fileStream [
      |result|
      result := super new.
      result init: fileStream.
      ^result
   ]
   init: fileStream [
      myStream := fileStream.
      bitIndex := 1.
   ]
   nextBit [
      bitIndex = 1 ifTrue: [
         byte := myStream next.
         bitIndex := 9.
      ].
      bitIndex := bitIndex - 1.
      ^byte value bitAt: bitIndex
   ]
   atEnd [
      ^bitIndex = 1 and: [myStream atEnd]
   ]
]

freqtable := ZeroArray new: 257.
encodetable := ZeroArray new: 257.
freqtable at:256 put:1.
encodetable at:256 put:'0'.

Object subclass: Leaf [
   |char count leafNode|
   char [ ^ char ]
   count [ ^ count ]
   leafNode [ ^ leafNode ]

   Leaf class >> new [
      self shouldNotImplement
   ]

   Leaf class >> new: aChar count: aCount leaf: aLeaf[
      |result|
      result := super new.
      result setChar: aChar andCount: aCount andLeaf: aLeaf.
      ^result
   ]

   setChar: aChar andCount: aCount andLeaf: aLeaf[
      char := aChar.
      count := aCount.
      leafNode := aLeaf.
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

   depthFirst: visitor prefix: string [
      visitor value: char value: string.
   ]

   postOrder: visitor [
      visitor value: char value: leafNode.
   ]
]


Leaf subclass: Tree [
   |left right|

   Tree class >> new: aChar count: aCount [
      self shouldNotImplement
   ]

   Tree class >> new: aChar count: aCount left: aLeft right: aRight 
   leaf: aLeaf[
      |result|
      result := super new: aChar count: aCount leaf: aLeaf.
      result setLeft: aLeft andRight: aRight.
      ^ result
   ]

   setLeft: aLeft andRight: aRight [
      left := aLeft.
      right := aRight.
   ]

   left  [ ^ left]
   right [ ^ right]

   printOn: aStream [
      (self printBase: aStream) << ',' << left << ',' << right << ')'.
   ]

   depthFirst: visitor prefix: string [ 
      left depthFirst: visitor prefix: string, '0'.
      right depthFirst: visitor prefix: string, '1'.
	  
   ]
   
   postOrder: visitor [
      left postOrder: visitor.
      right postOrder: visitor.
      visitor value: char value: leafNode.
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
         myStream nextPutByte: currentByte.
         self clearByte.

   ]
   writeBit: bit [
      currentByte := currentByte bitAt: bitIndex put: bit.
      bitIndex := bitIndex - 1.
      bitIndex = 0 ifTrue: [
        self flushByte].
   ]
   
   writeByte: byte [
      myStream nextPutByte: byte.
   ]
]

|infile infile2 outfile outfilename argcount|

dFlag := false.
cFlag := false.
tFlag := false.
uFlag := false.

argcount:=0.

Smalltalk arguments: '-d -t -c -u'
do: [:opt :arg |
  
   
   (opt = $d) ifTrue: [
   stdout <<'-d option is set'<<nl.
    ].
    
   (opt = $t) ifTrue: [
   tFlag := true.
   stdout <<'-t option is set'<<nl.
    ].

  (opt = $c) ifTrue: [
   cFlag := true.
   stdout <<'-c option is set'<<nl.
   ].

  (opt = $u) ifTrue: [
   uFlag := true.
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

uFlag ifTrue:[
   infile2 close.
   "outBytes := OutBits new: outfile."
	stack := OrderedCollection new.
   "randomjunk := 1."
	fileBits := BitStream new: infile.
   "
   outfileStream := stdout.
   outfile~=nil ifTrue:[
      outfileStream := outfile.
   ].
   outBytes := OutBits new: outfileStream.
   "
  

	[fileBits atEnd] whileFalse: [
   
		determineBit := fileBits nextBit.

	   determineBit = 0 ifTrue: [
         byteValue := 0.
         1 to: 8 do:[:i | 
            byteBit := fileBits nextBit.

            byteValue := byteValue bitAt: i put: byteBit.
         ].
         byteValue = 0 ifTrue: [
            scbit := fileBits nextBit.
            scbit = 1 ifTrue:[
               byteValue := 256.
            ].
         ].
         stack add: (Leaf new: byteValue count: -1 leaf:true).

	   ]
	   ifFalse:[
         
		   stack size > 1 ifTrue: [
            |leftchild rightchild|
         
            leftchild := stack removeLast.
            rightchild := stack removeLast.
            newtree := ( Tree new: -1
                          count: -1
                          left: rightchild right: leftchild
                          leaf: false).
            stack add: newtree.
            ] ifFalse: [
               decodingtree:=stack removeLast.

               decodingtree depthFirst: [:char :string |
                  string ~= '' ifTrue: [
                     encodetable at: char put: string.
                  ]
               ] prefix: ''.

               [fileBits atEnd] whileFalse: [
                  tempBit := fileBits nextBit asString.
                  findIt := 0.
      
                  [findIt = 0 ]whileTrue:[
                     
                     0 to: 256 do:[:i | 
                        tempValue := encodetable at: i.

                           tempValue = tempBit ifTrue:[
                              findIt := 1.
                              i = 256 ifTrue:[
                                 [fileBits atEnd] whileFalse:[
                                    fileBits nextBit asString.
                                 ]. 
                              ]ifFalse:[
                                 stdout << i asCharacter.
                                 "outBytes writeByte: i."
                                 "
                                 8 to: 1 do: [:index |
                                    currentBit := i bitAt: index.
                                    currentBit = 1 ifTrue: [
                                       outBytes writeBit: 1.
                                    ] ifFalse: [
                                       outBytes writeBit: 0.
                                    ].
                                    
                                 ]. 
                                 "
                              ].
                           ].
                     ].
                     findIt = 0 ifTrue:[
                     tempBit1 := fileBits nextBit asString.
                     tempBit := tempBit, tempBit1.
                     ].

                  ].
               ].
            ].
         ].

    ].
	
].

tFlag | cFlag ifTrue:[
	[infile atEnd not] whileTrue: [
	   |ordChar|
	   ordChar := infile next asInteger.
	   freqtable incr: ordChar.
	].

	freqtable keysAndValuesDo: [:key :count |
	   (count notNil and: [count > 0]) ifTrue: [
		  queue add: (Leaf new: key count: count leaf: true).
	   ]
	].

	[queue size >1 ] whileTrue: [
      
	   |leftchild rightchild|
	   leftchild := queue removeFirst.
	   rightchild := queue removeFirst.
	   newtree := ( Tree new: (leftchild char) +  (rightchild char)
						  count: (leftchild count) +  (rightchild count)
						  left: leftchild right: rightchild
                    leaf: false).
	   queue add: newtree.
	].
	decodingtree:=queue removeFirst.


	decodingtree depthFirst: [:char :string |
      string ~= '' ifTrue: [
         encodetable at: char put: string.
      ]

	] prefix: ''.
   
   
   tFlag ifTrue:[
        stdout <<nl<< '------------decoding tree--------------' << nl.
        stdout << decodingtree << nl.

        stdout <<nl<< '------------encoding table-------------' << nl.
        encodetable keysAndValuesDo: [:key :count |
        (count notNil and: [count > 0]) ifTrue: [
           stdout <<  key asCharacter visible << '     '
                  << (freqtable at: key) <<'    '<<count
                  << nl.
        ].
       ].
   ].




   cFlag  ifTrue:[ 
      outfileStream := stdout.
      outfile~=nil ifTrue:[
         outfileStream := outfile.
      ].
       stdout <<nl<< 'cFlag= '<<cFlag 
             <<' have output file'<< nl.

       outBytes := OutBits new: outfileStream.
       
       decodingtree postOrder: [:char :leafNode|
         leafNode = true ifTrue: [
            outBytes writeBit: 0.
            1 to: 8 do: [:i |
               currentBit := char bitAt: i.
               currentBit = 1 ifTrue: [
                  outBytes writeBit: 1.
               ] ifFalse: [
                  outBytes writeBit: 0.
               ].
               
            ].  
            char asInteger = 256 ifTrue: [
               outBytes writeBit: 1.
            ].
            char asInteger = 0 ifTrue: [
               outBytes writeBit: 0.
            ].
         ] ifFalse: [
            outBytes writeBit: 1.
         ].
       ].
       outBytes writeBit: 1.
       
       [infile2 atEnd not] whileTrue: [
         |ordChar2|
         ordChar2 := infile2 next asInteger.
         code:= (encodetable at: ordChar2). 
         1 to: (code size) by: 1 do: [:index |
           bit:= ((code at: index) asInteger) - 48.
           outBytes writeBit: bit.
            "stdout <<bit."
         ].
       ].

      eof:= (encodetable at: 256).
      1 to: (eof size) by: 1 do: [:index |
            bit:= ((eof at: index) asInteger) - 48.
            outBytes writeBit: bit.].     
      outBytes flushByte.
   ].
].

infile close.
