( : myword Int :arg1  String :arg2 args )
: :arg1
  ' 2dup , ' is-of-type , ' not , ' if execute
                                       ' lit , " In word '" , ' prints , 
                                       ' this-word-name execute ' prints ,
                                       ' lit , " ': " , ' prints ,
                                       ' swap ,
                                       ' dup ,
                                       ' . , 
                                       ' lit , "  (" , ' prints ,
                                        ' .hex ,
                                        ' lit , " ) should have a type " , ' prints , 
                                        ' .RED[ ,
                                        ' >class-name , ' @ , ' prints , ' cr ,
                                        ' ]NOCOL. ,
                                        ' .R ,
                                        ' .S ,
                                        ' exit ,
' else execute ' drop ,
                                       ' then execute ; IMMEDIATE


( arg2 arg1 type2 )
: :arg2
  ' 2over , ' swap , ' 2dup , ' is-of-type , ' not ,
  ' if execute
       ' lit , " In word '" , ' prints ,
       ' this-word-name execute ' prints ,
       ' lit , " ': second argument " , ' prints ,
       ' swap ,
       ' dup ,
       ' . , 
       ' lit , "  (" , ' prints ,
       ' .hex ,
       ' lit , " ) should have a type " , ' prints , 
       ' .RED[ ,
       ' >class-name , ' @ , ' prints , ' cr ,
       ' ]NOCOL. ,
       ' .R ,
       ' .S ,
       ' exit ,
       ' else execute ' drop ,
              ' then execute
  ' drop , ; IMMEDIATE


: ::
  cell% allot ! ( parent-classinf offset -- )

  inbuf word drop 0 inbuf create ' docol @ ,
  ' lit , over , ' :arg1 execute
  ' lit , dup ,
  ' + , ' exit ,
  cell% +
;
