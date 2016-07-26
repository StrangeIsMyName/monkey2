
Namespace ted2

Using std.chartype

Const COLOR_NONE := 0
Const COLOR_IDENT := 1
Const COLOR_KEYWORD := 2
Const COLOR_STRING := 3
Const COLOR_NUMBER := 4
Const COLOR_COMMENT := 5
Const COLOR_PREPROC := 6
Const COLOR_OTHER := 7
Const COLOR_FIELD := 8


Function Mx2TextHighlighter:Int( text:String, colors:Byte[], tags:String[], sol:Int, eol:Int, state:Int )
'  print text
  
	Local i0 := sol
	
	Local icolor := 0
	Local itag := ""
	Local istart :=sol
	Local preproc := False
	local id:string
	
	local showNext:int = 0
	local showStart:int
	local output:string = ""
	g_CodeKind = -1
	g_CodeText = ""
	
	
	If state > -1 then icolor = COLOR_COMMENT
	
	
	While i0 < eol
    id = ""
		Local start := i0
		Local chr := text[i0]
		i0 += 1
		If IsSpace( chr ) Continue
		
		If chr = 35 And istart = sol then
			preproc = True
			If state = -1 then icolor = COLOR_PREPROC
			Continue
		Endif
		
		If preproc Then
      if  (IsAlpha( chr ) Or chr = 95) Then
        While i0 < eol And (IsAlpha( text[i0] ) Or IsDigit( text[i0] )  Or text[i0] = 95)
          i0 += 1
        Wend
        
        Local id := text.Slice( start, i0 )
        
        Select id.ToLower()
          Case "rem"
            state += 1
            icolor = COLOR_COMMENT
            itag = ""
          Case "end"
            If state > -1 then 
              state -= 1
              icolor = COLOR_COMMENT
              itag = ""
            Endif
        End
        
        Exit
        
      Else
        output = "----"
      endif
      
		Endif

		If state > -1 Or preproc then Exit
		
		Local color := icolor
		Local tag := itag
		
		If chr = 39 then
			i0 = eol
			color = COLOR_COMMENT
			tag = ""
			
		Else If chr = 34
			While i0 < eol And text[i0] <> 34
				i0 += 1
			Wend
			If i0 < eol then i0 += 1
			
			color = COLOR_STRING
			tag = ""
			
		Else If IsAlpha( chr ) Or chr = 95 then
			While i0 < eol And (IsAlpha( text[i0] ) Or IsDigit( text[i0] )  Or text[i0] = 95)
				i0 += 1
			Wend
			
			id = text.Slice( start, i0 )
			
			If preproc And istart = sol then
				Select id.ToLower()
          Case "rem"				
            state += 1
          Case "end"
            state = Max( state-1, -1 )
				End
				
				icolor = COLOR_COMMENT
				itag = ""
				
				Exit
			Else
				color = COLOR_IDENT
				tag = id
				
				If Mx2Keywords.Contains( id.ToLower() ) then
					color = COLOR_KEYWORD
					tag = id.ToLower()
				endif
			
			Endif
			
		Else If IsDigit( chr ) then 
			While i0 < eol And IsDigit( text[i0] )
				i0 += 1
			Wend
			
			color = COLOR_NUMBER
			tag = ""
			
		Else If chr = 36 And i0 < eol And IsHexDigit( text[i0] ) then
			i0 += 1
			While i0 < eol And IsHexDigit( text[i0] )
				i0 += 1
			Wend
			
			color = COLOR_NUMBER
			tag = ""
			
		Else
			color = COLOR_NONE
			tag = ""
			
		Endif

		if color = COLOR_KEYWORD and Mx2Fields.Find( id.ToLower() ) > -1 Then
			color = COLOR_FIELD
		end if
		
		If color = icolor Continue
		
		For Local i := istart Until start
			colors[i] = icolor
			tags[i] = itag
		Next
		
		select showNext
      case 1'function
'        output = "Function:  " + tags[istart]
        output = tags[istart]
        g_CodeKind = NODEKIND_FUNCTION
        showNext = false
        
      case 2'class 
'        output = "Class:  " + tags[istart]
        output = tags[istart]
        g_CodeKind = NODEKIND_CLASS
        showNext = false

      case 3 'method
        if id.Length = 0 then
          id = text.Slice( showStart, start )
        end if
            
'        output = "Method:  " + id
        output = id
        g_CodeKind = NODEKIND_METHOD
        showNext = false

      case 4 'property
'        output = "Property:  " + tags[istart]
        output = tags[istart]
        g_CodeKind = NODEKIND_PROPERTY
        showNext = false

      case 5 'field
'        output = "Field:  " + tags[istart]
        output = tags[istart]
        g_CodeKind = NODEKIND_FIELD
        showNext = false

      case 6 'global
'        output =  "Global:  " + tags[istart]
        output = tags[istart]
        g_CodeKind = NODEKIND_GLOBAL
        showNext = false

      case 7 'operator
        if id.Length = 0 then
          id = text.Slice( showStart, start )
        end if
            
        output = id

'        output = "Operator:  " + tags[istart]
'        output = tags[istart]
        g_CodeKind = NODEKIND_OPERATOR
        showNext = false

      case 8 'const
'        output =  "Const:  " + tags[istart]
        output = tags[istart]
        g_CodeKind = NODEKIND_CONST
        showNext = false

      case 9 'enum
'        output = "Enum:  " + tags[istart]
        output = tags[istart]
        g_CodeKind = NODEKIND_ENUM
        showNext = false

      case 10 'struct
'        output = "Struct:  " + tags[istart]
        output = tags[istart]
        g_CodeKind = NODEKIND_STRUCT
        showNext = false

		end Select
		
		'print tags[istart]
		select tags[istart]
      case "function"
        showNext = 1
        
      case "class"
        showNext = 2

      case "method"
        showStart = istart + 7
        showNext = 3

      case "property"
        showNext = 4

      case "field"
        showNext = 5

      case "global"
        showNext = 6

      case "operator"
        showNext = 7

      case "const"
        showNext = 8

      case "enum"
        showNext = 9

      case "struct"
        showNext = 10


		end select

		
		icolor = color
		itag = tag
		istart = start
		
'		print itag+" "+icolor
	
	Wend
	
	For Local i := istart Until eol
		colors[i] = icolor
		tags[i] = itag
	Next
	
	if output <> "" Then
    g_CodeText = output
    'g_CodeKind = 1
    
'    print output+" "+istart+" "+eol
	end if
	
	'print "<--end"
	
	Return state

End
