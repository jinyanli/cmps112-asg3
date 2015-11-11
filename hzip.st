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
   |char count isleaf|
   
   char [ ^ char ]
   count [ ^ count ]
   isleaf [^ isleaf]
   
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
      isleaf:=true.
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
   
   postorder: visitor [
      visitor  value:char value: isleaf.
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
      isleaf:=false.
   ]

   left  [ ^ left]
   right [ ^ right]

   printOn: aStream [
      (self printBase: aStream) << ',' << left << ',' << right << ')'.
   ]

   inorder: visitor prefix: string [
      left inorder: visitor prefix: string, '0'.
      right inorder: visitor prefix: string, '1'.
   ]
   
   postorder: visitor[      
      left postorder: visitor .
      right postorder: visitor .  
      visitor value: char value:isleaf.
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
]


"main function"

"var to hold pipline for input stream"
|infile infile2 outfile outfilename argcount|

dFlag := false.
cFlag := false.
tFlag := false.
uFlag := false.

argcount:=0.

"parse the options and filename"Smalltalk arguments: '-d -t -c -u'
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


"build frequency table"
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
[queue size >1 ] whileTrue: [
   |leftchild rightchild|
   
   leftchild := queue removeFirst.
   rightchild := queue removeFirst.
   newtree := ( Tree new: (leftchild char)
                      count: (leftchild count) +  (rightchild count)
                      left: leftchild right: rightchild).
   queue add: newtree.
].
decodingtree:=queue removeFirst.

"stdout << nl << 'build encode table' << nl."
decodingtree inorder: [:char :string |
   encodetable at: char put: string.
   "stdout <<  char asCharacter visible<<'    '<< (freqtable at: char) 
               <<'        ' << string << nl."
] prefix: ''.

"convert decoding tree in binary"
binarytree:=''.
decodingtree postorder: [:char :isleaf |
   isleaf  ifFalse:[binarytree:=binarytree,'1'.]
                ifTrue:[
                   bin:=''.
                   char = 256
                        ifTrue:[bin:='000000001']
                        ifFalse:[
                           char=0 ifTrue:[bin:='000000000']
                                  ifFalse:[
                                     8 to:1 by: -1 do:[:i|
                                     bin:=bin,((char bitAt:i) printString).
                                   ]
                        ].               
                 ].
                 binarytree:=(binarytree,'0',bin).
              ].
].

"decoding tree and table is printed to stdout"
tFlag ifTrue:[
     stdout <<nl<< '------------decoding tree--------------' << nl.
     stdout << decodingtree << nl<<nl.
     stdout <<'binary decoding tree: '<<nl<<binarytree << nl.

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

outfile~=nil ifTrue:[
    stdout <<nl<< 'cFlag= '<<cFlag 
          <<' have output file'<< nl.

   "output binary decoding tree"   
   outBytes := OutBits new: outfile.    
   1 to: (binarytree size) by: 1 do: [:index |
         bit:= ((binarytree at: index) asInteger) - 48.
         outBytes writeBit: bit.
         ].

   "output encoded data" 
   [infile2 atEnd not] whileTrue: [
      |ordChar2|
       ordChar2 := infile2 next asInteger.
       code:= (encodetable at: ordChar2). 
       1 to: (code size) by: 1 do: [:index |
         bit:= ((code at: index) asInteger) - 48.
         outBytes writeBit: bit.
         "stdout <<bit."].
       ].

   eof:= (encodetable at: 256).
   1 to: (eof size) by: 1 do: [:index |
         bit:= ((eof at: index) asInteger) - 48.
         outBytes writeBit: bit.].     
   outBytes flushByte.
]ifFalse:[
   stdout <<nl<< 'cFlag ='<<cFlag
              <<' no output file'<< nl.
          
   stdout <<nl<< '----------encoded input in binary----------' << nl.
   stdout <<binarytree.   
     [infile2 atEnd not] whileTrue: [
           |ordChar2|
           ordChar2 := infile2 next asInteger.
           code:= (encodetable at: ordChar2).
           stdout <<code. 
        ].
      eof:= (encodetable at: 256).
      stdout<<eof.
  ].    
].
  

stdout<<nl.
infile close.
