
Namespace ted21

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
Const COLOR_METHOD := 9
Const COLOR_FUNCTION := 10
Const COLOR_CLASS := 11
Const COLOR_PROPERTY := 12
Const COLOR_STRUCT := 13
Const COLOR_LAMBDA := 14


Function Mx2TextHighlighter:Int( parent:TextDocument, text:String, colors:Byte[], tags:String[], sol:Int, eol:Int, state:Int )
'  print text
  
	Local i0 := sol
	
	Local icolor := 0
	Local itag := ""
	Local istart := sol
	Local preproc := False
	local id:string
	
	local showNext:int = 0
	local showStart:int
	local output:string = ""
	g_CodeKind = -1
	g_CodeText = ""
	g_CodeIcon = 0
	
	
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

		if color = COLOR_KEYWORD Then
			local idl:string = id.ToLower()
			
			'print idl
			
			if Mx2Fields.Find( idl ) > -1 Then
				color = COLOR_FIELD
			else	
				if Mx2Method.Find( idl ) > -1 then
					color = COLOR_METHOD
				else
					if Mx2Function.Find( idl ) > -1 then
						color = COLOR_FUNCTION
					else
						if Mx2Property.Find( idl ) > -1 then
							color = COLOR_PROPERTY
						else
							if Mx2Class.Find( idl ) > -1 then
								color = COLOR_CLASS
								showNext = 2
							else
								if Mx2Struct.Find( idl ) > -1 then
									color = COLOR_STRUCT
									showNext = 10
								else
									if Mx2Lambda.Find( idl ) > -1 then
										color = COLOR_LAMBDA
										showNext = 11
									else
									
										if Mx2ClassPrivate = idl then
											color = COLOR_CLASS
											output = "Private"
											g_CodeKind = NODEKIND_CLASSEXTRA
											showNext = False

										else
											if Mx2ClassPublic = idl then
												color = COLOR_CLASS
												g_CodeKind = NODEKIND_CLASSEXTRA
												output = "Public"
												showNext = False
											else
												if Mx2ClassProtected = idl then
													color = COLOR_CLASS
													g_CodeKind = NODEKIND_CLASSEXTRA
													output = "Protected"
													showNext = False
												else
													if Mx2ClassFriend = idl then
														color = COLOR_CLASS
														g_CodeKind = NODEKIND_CLASSEXTRA
														output = "Friend"
														showNext = False
													else
													end if
												end if
											end if
										end if
									end if
								end if
							end if
						end if
					end if
				end if
			end if
			
		end if
		
		select showNext
			case 2,5 'class,  field
				id = ""
				local pos:int = start+6
				while text.Mid( pos, 1 ) >= " "
					id += text.Mid( pos, 1 )
					pos += 1
				wend

			case 10 'struct
				id = ""
				local pos:int = start+7
				while text.Mid( pos, 1 ) >= " "
					id += text.Mid( pos, 1 )
					pos += 1
				wend
				'print "here " + id
				
		end select

		If color = icolor Continue
		
		For Local i := istart Until start
			colors[i] = icolor
			tags[i] = itag
		Next
		
		select showNext
			case 1'function
				'output = "Function:  " + tags[istart]
				output = tags[istart]
				g_CodeKind = NODEKIND_FUNCTION
				showNext = false
        
			case 2'class
				if id.Length = 0 then
					id = text.Slice( showStart, start )
				end If
            
				if tags[istart] = "" then    
					output = id
				else
					output = tags[istart]
				end if
        
				g_CodeKind = NODEKIND_CLASS
				showNext = False

			case 3 'method
				if id.Length = 0 then
					id = text.Slice( showStart, start )
				end if
            
				'output = "Method:  " + id
				output = id
				g_CodeKind = NODEKIND_METHOD
				showNext = false

			case 4 'property
				'output = "Property:  " + tags[istart]
				output = tags[istart]
				g_CodeKind = NODEKIND_PROPERTY
				showNext = false

			case 5 'field
				if id.Length = 0 then
					id = text.Slice( showStart, start )
				end if
            
				if tags[istart] = "" then    
					output = id
				else
					output = tags[istart]
				end if
				output = tags[istart]
				'        output = tags[istart]
				g_CodeKind = NODEKIND_FIELD
				showNext = false
				
'				print "field="+output

			case 6 'global
				'        output =  "Global:  " + tags[istart]
				output = tags[istart]
				g_CodeKind = NODEKIND_GLOBAL
				showNext = false

			Case 7 'operator
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
				if id.Length = 0 then
					id = text.Slice( showStart, start )
				end if
            
				'        output = "Method:  " + id
				output = id
				'        output = "Struct:  " + tags[istart]
				'        output = tags[istart]
				g_CodeKind = NODEKIND_STRUCT
				showNext = false

			case 11 'lambda
				'print "lambda "+text.Mid(start, 6)+" start="+start
				
				g_CodeKind = NODEKIND_LAMBDA

				local pos:int = start - 1
				
				while text.Mid( pos, 1 ) = " " or text.Mid( pos, 1 ) = "+" or text.Mid( pos, 1 ) = "-" or text.Mid( pos, 1 ) = "=" or text.Mid( pos, 1 )[0] = 9 or  text.Mid( pos, 1 )[0] = 95
					'print "<"+text.Mid( pos, 1 )+" "+text.Mid( pos, 1 )[0]
					pos -= 1
				Wend
				local nEnd:int = pos+1	
				while text.Mid( pos, 1 )[0] > 32 and text.Mid( pos, 1 )[0] <> 95 and text.Mid( pos, 1 ) <> "."
					'print ">"+text.Mid( pos, 1 )+" "+text.Mid( pos, 1 )[0]
					pos -= 1
				wend
				if text.Mid( pos, 1 ) = "." or text.Mid(pos, 1) = "~t" then pos += 1
				local txt:string = text.Mid(pos, nEnd - pos)
				'print ">"+txt+"<"
				if txt.Left(7) <> " Lambda" then
					output = txt
				end if

				showNext = false

		end Select
		
		'print tags[istart]
		select tags[istart]
			case "function"
				showNext = 1
        
			case "class"
				'print ">class"
				showNext = 2
			
			case "method"
				showStart = istart + 7
				showNext = 3
			
			case "property"
				showNext = 4
			
			case "field"
				'print ">field"
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
				'print "STRUCT"
				showStart = istart + 7
				showNext = 10
		
			case "lambda"
				showNext = 11

		end Select

		
		icolor = color
		itag = tag
		istart = start
		
	Wend
	
	For Local i := istart Until eol
		colors[i] = icolor
		tags[i] = itag
	Next
	
	if output <> "" Then
		g_CodeText = output
		g_CodeIcon = g_CodeKind
				
		'g_CodeKind = 1
    
		'print output+" "+istart+" "+eol

		'print output+" line="+parent.FindLine( istart )
		'print Parent
	end If
	
	'print "<--end"
	
	Return state

End
