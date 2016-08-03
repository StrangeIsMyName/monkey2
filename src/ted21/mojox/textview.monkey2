
Namespace mojox


global g_CodeKind:byte
global g_CodeIcon:int
global g_CodeText:String


Alias TextHighlighter:Int( parent:TextDocument, text:String, colors:Byte[], tags:String[], sol:Int, eol:Int, state:Int )





Class TextDocument



	Field LinesModified:Void( first:Int, removed:Int, inserted:Int )

	Field TextChanged:Void()
	
	Field CodeClicked:void( line:int, txt:string )
	
	field CursorMoved:void()
	
	Field Code:CodeTreeView
	
	
	
	
	Method New()
		_lines.Push( New Line )
		
		Code = new CodeTreeView
		Code.NodeClicked = Lambda( tnode:CodeTreeView.Node, event:MouseEvent )
	
			CodeClicked( tnode.Line, tnode.Label )
'			print "TextDocument clicked line=" + tnode.Line
		end 
	End

	


	Property Text:String()
		Return _text
	Setter( text:String )
		text = text.Replace( "~r~n", "~n" )
		text = text.Replace( "~r", "~n" )
	
		ReplaceText( 0, _text.Length, text )
	End



	Property CursorChar:int()
		return _text.Mid(_cursorPos, 1)[0]
	end
	
	
	
	Property CursorLine:int()
		return 	FindLine( _cursorPos ) + 1
	End



	property CursorColumn:Int()
		Return _cursorPos - StartOfLine( FindLine( _cursorPos ) )
	End



	property SelectedIndex:Int()
		Return Code.SelectedIndex
	Setter( selectedIndex:int )
		Code.SelectedIndex = selectedIndex
	End



	property CursorCodeLine:Int()
		return _lines[ FindLine( _cursorPos ) ].line
	End



	Property CursorPos:int()
		Return _cursorPos
	Setter( cursorPos:int )
		if _cursorPos <> cursorPos then
			_cursorPos = cursorPos
			CursorMoved()
		end if
	End



	Property ShowHighlightLine:Bool()
		Return _showHighlightLine
	Setter( showHighlightLine:Bool )
		_showHighlightLine = showHighlightLine
	End



	Property ShowHidden:bool()
		Return _showHidden
	Setter( showHidden:bool )
		_showHidden = showHidden
	End



	Property TextLength:Int()
		Return _text.Length
	End


	
	Property LineCount:Int()
		Return _lines.Length
	End


	
	Property Colors:Byte[]()
		Return _colors.Data
	End



	Property Tags:String[]()
		Return _tags.Data
	End



	method GetDebugLine:int( line:int )
		If line >= 0 And line < _lines.Length Return _lines[ line ].debug
		Return -1
	End


	method GetCodeJumpLine:int( line:int )
		If line >= 0 And line < _lines.Length Return _lines[ line ].line
		Return 0
	End


	method GetCodeJumpIcon:int( line:int )
		If line >= 0 And line < _lines.Length Return _lines[ line ].icon
		Return 0
	End


	
	Property TextHighlighter:TextHighlighter()
		Return _highlighter
	Setter( textHighlighter:TextHighlighter )
		_highlighter = textHighlighter
	End


	
	Method LineState:Int( line:Int )
		If line >= 0 And line < _lines.Length Return _lines[line].state
		Return -1
	End


	
	Method LineLength:int( line:int )
		If line < 0 Return 0

		If line < _lines.Length Return _lines[line].eol

		return 0
	end Method
	


	Method StartOfLine:Int( line:Int )
		If line <= 0 Return 0
		If line < _lines.Length Return _lines[line - 1].eol + 1
		Return _text.Length
	End

	
	
	Method EndOfLine:Int( line:Int )
		If line < 0 Return 0
		If line < _lines.Length Return _lines[line].eol
		Return _text.Length
	End


	
	Method FindLine:Int( index:Int )
		If index <= 0 then Return 0
		If index >= _text.Length Return _lines.Length-1
		
		Local min := 0
		local max := _lines.Length - 1
		
		Repeat
			Local line := (min+max)/2
			If index > _lines[line].eol
				min = line+1
			Else If max - min<2
				Return min
			Else
				max = line
			Endif
		Forever

		Return 0
	End



	Method GetLine:String( line:Int )
		Return _text.Slice( StartOfLine( line ), EndOfLine( line ) )
	End


	
	Method AppendText( text:String )
		ReplaceText( _text.Length, _text.Length, text )
	End

	
	method DebugToggle( line:int )
		If line <= 0 Return
'		If line<_lines.Length Return _lines[line-1].eol+1
'		Return _text.Length

'    print line+" "+_lines[line].debug
		_lines.Data[line].debug = not _lines[line].debug
	End



	Method GetLineTabs:int( line:Int )
		local text := _text.Slice( StartOfLine( line ), EndOfLine( line ) )
		
		local pos:int = 0
		
		while text.Mid(pos, 1) <= " "
			pos += 1
		Wend
		
		return pos	
	End



	Method ReplaceText( anchor:Int, cursor:Int, text:String )
		Local min := Min( anchor, cursor )
		Local max := Max( anchor, cursor )
		
		Local eols1 := 0
		local eols2 := 0
		
		For Local i := min Until max
			If _text[i] = 10 eols1 += 1
		Next
		For Local i := 0 Until text.Length
			If text[i] = 10 eols2 += 1
		Next
		
		Local dlines := eols2 - eols1
		Local dchars := text.Length - (max - min)
		
		Local line0 := FindLine( min )
		Local line := line0
		Local eol := StartOfLine( line ) - 1
		
'		Print "eols1="+eols1+", eols2="+eols2+", dlines="+dlines+", dchars="+dchars+" text="+text.Length
		
		'Move data!
		'
		Local oldlen:=_text.Length
		_text=_text.Slice( 0,min )+text+_text.Slice( max )
		
		_colors.Resize( _text.Length )
		_tags.Resize( _text.Length )

		Local p:=_colors.Data.Data
		libc.memmove( p + min + text.Length, p + max , oldlen-max )
		libc.memset( p + min , 0 , text.Length )
		
		'Update lines
		'
		If dlines >= 0
		
			_lines.Resize( _lines.Length + dlines )

			Local i := _lines.Length
			While i > line + eols2 + 1
				i -= 1
				_lines.Data[i].eol = _lines[i-dlines].eol+dchars
				_lines.Data[i].state = _lines[i-dlines].state
				_lines.Data[i].debug = _lines[i-dlines].debug

				_lines.Data[i].line = _lines[i-dlines].line
				_lines.Data[i].icon = _lines[i-dlines].icon
			Wend
		
		Endif

		For Local i := 0 Until eols2+1
			eol = _text.Find( "~n",eol+1 )
			If eol = -1 then eol = _text.Length
			_lines.Data[line + i].eol = eol
			_lines.Data[line + i].state = -1
			if line > 0 then
				_lines.Data[line + i].line = _lines.Data[line].line
			end if	
			_lines.Data[line + i].icon = 0

		Next
		
		If dlines < 0 then

			Local i := line+eols2+1
			While i < _lines.Length+dlines
				_lines.Data[i].eol = _lines[i-dlines].eol+dchars
				_lines.Data[i].state = _lines[i-dlines].state
				_lines.Data[i].debug = _lines[i-dlines].debug

				_lines.Data[i].line = _lines[i-dlines].line
				_lines.Data[i].icon = _lines[i-dlines].icon
				i += 1
			Wend

			_lines.Resize( _lines.Length+dlines )
		Endif

		If _highlighter <> Null Then
'      if line = 0 then Code.New
			'print "- start highlighing - startline="+line
			if line = 0 Then
				Code.RemoveAllChildren()
			else 	
				Code.RemoveChildrenFromLine( line )
			end if	
				
		
			'update highlighting
			'
			Local state := -1
			If line state = _lines[line-1].state
			
			local jumpline:int = -1
			
			For Local i := 0 Until eols2 + 1
				state = _highlighter( self, _text, _colors.Data, _tags.Data, StartOfLine( line ), EndOfLine( line ), state )
				_lines.Data[line].state = state
				_lines.Data[line].icon = 0
				
'				print "1 "+line+" "+jumpline
				
				if g_CodeKind > -1 Then
					'print "1>"+GetLineTabs(line)
'					print "A   line="+line+" "+g_CodeText+" kind="+g_CodeKind+" index="+Code.IndexCount

					jumpline = Code.IndexCount'line
					Code.AddNode( g_CodeText, g_CodeKind, line, GetLineTabs(line) )
					_lines.Data[line].icon = g_CodeIcon
				Endif

				_lines.Data[line].line = jumpline
				
				line += 1
			Next

			jumpline = line
'			local changed:int = false
			While line < _lines.Length 'And state<>_lines[line].state
				state = _highlighter( self, _text, _colors.Data, _tags.Data, StartOfLine( line ), EndOfLine( line ), state )
				_lines.Data[line].state = state
				_lines.Data[line].icon = 0
				
'				print "2 "+line

				if g_CodeKind > -1 Then
					'print "2>"+GetLineTabs(line)
					
'					print "B   line="+line+" "+g_CodeText+" kind="+g_CodeKind+" index="+Code.IndexCount

					jumpline = Code.IndexCount'line
					Code.AddNode( g_CodeText, g_CodeKind, line, GetLineTabs(line) )
					_lines.Data[line].icon = g_CodeIcon
'					changed = true
				Endif

				_lines.Data[line].line = jumpline
				
				line += 1
			Wend
'			if changed Then
'				print "changed"
'				Code.ModifyKind( null, NODEKIND_FUNCTION, true )
'			end if
		Endif
		
'		Print "lines="+_lines.Length+", chars="+_text.Length

		LinesModified( line0,eols1+1,eols2+1 )
		
		TextChanged()
		CursorMoved()
	End 
  
#rem	
	Method ReplaceText( anchor:Int,cursor:Int,text:String )
		Local min:=Min( anchor,cursor )
		Local max:=Max( anchor,cursor )
		
		Local eols1:=0,eols2:=0
		For Local i:=min Until max
			If _text[i]=10 eols1+=1
		Next
		For Local i:=0 Until text.Length
			If text[i]=10 eols2+=1
		Next
		
		Local dlines:=eols2-eols1
		Local dchars:=text.Length-(max-min)
		
		Local line0:=FindLine( min )
		Local line:=line0
		Local eol:=StartOfLine( line )-1
		
'		Print "eols1="+eols1+", eols2="+eols2+", dlines="+dlines+", dchars="+dchars+" text="+text.Length
		
		'Move data!
		'
		Local oldlen:=_text.Length
		_text=_text.Slice( 0,min )+text+_text.Slice( max )
		
		_colors.Resize( _text.Length )
		Local p:=_colors.Data.Data
		libc.memmove( p + min + text.Length, p + max , oldlen-max )
		libc.memset( p + min , 0 , text.Length )
		
		'Update lines
		'
		If dlines>=0
		
			_lines.Resize( _lines.Length+dlines )

			Local i:=_lines.Length
			While i>line+eols2+1
				i-=1
				_lines.Data[i].eol=_lines[i-dlines].eol+dchars
				_lines.Data[i].state=_lines[i-dlines].state
			Wend
		
		Endif

		For Local i:=0 Until eols2+1
			eol=_text.Find( "~n",eol+1 )
			If eol=-1 eol=_text.Length
			_lines.Data[line+i].eol=eol
			_lines.Data[line+i].state=-1
		Next
		
		If dlines<0

			Local i:=line+eols2+1
			While i<_lines.Length+dlines
				_lines.Data[i].eol=_lines[i-dlines].eol+dchars
				_lines.Data[i].state=_lines[i-dlines].state
				i+=1
			Wend

			_lines.Resize( _lines.Length+dlines )
		Endif

		If _highlighter<>Null
		
			'update highlighting
			'
			Local state:=-1
			If line state=_lines[line-1].state
			
			For Local i:=0 Until eols2+1
				state=_highlighter( _text,_colors.Data,StartOfLine( line ),EndOfLine( line ),state )
				_lines.Data[line].state=state
				line+=1
			Next
			
			While line<_lines.Length 'And state<>_lines[line].state
				state=_highlighter( _text,_colors.Data,StartOfLine( line ),EndOfLine( line ),state )
				_lines.Data[line].state=state
				line+=1
			End
		Endif
		
'		Print "lines="+_lines.Length+", chars="+_text.Length

		LinesModified( line0,eols1+1,eols2+1 )
		
		TextChanged()
	End
	
	#rem
		_lines.Resize( _lines.Length+dlines )
		
		
		'eols1=eols deleted, eols2=eols inserted, dchars=delta chars
		
		
		Local oldlen:=Text.Length
		_text=_text.Slice( 0,min )+text+_text.Slice( max )
		
		_colors.Resize( _text.Length )
		
		Local p:=Varptr( _colors.Data[0] )
		libc.memmove( p+min+text.Length,p+max,oldlen-max )
		libc.memset( p+min,0,text.Length )
		
		UpdateEols()
		
		If eols1>eols2
			LinesDeleted( FindLine( min ),eols1-eols2 )
		Else If eols2>eols1
			LinesInserted( FindLine( min ),eols2-eols1 )
		Endif
		
		TextChanged()
	End
	#end
#end

	
	Method HighlightLine( line:Int )
#rem	
		Return
	
		If _highlighter=Null Return
		
		If _lines[line].state<>-1 Return
	
		Local sol:=StartOfLine( line )
		Local eol:=EndOfLine( line )
		If eol>sol
			Local colors:=_colors.Data
			_highlighter( _text,colors,sol,eol )
		Endif
		
		_lines.Data[line].state=0
#end
	End


	
Private


	
	Struct Line
		Field eol:Int
		Field state:Int
		field debug:int
		
		field icon:Int
		field line:int
	End
	
	Field _text:String
	
	field _cursorPos:Int
	
	Field _lines := New Stack<Line>
	Field _colors := New Stack<Byte>
	Field _tags := New Stack<String>
	Field _highlighter:TextHighlighter

	field _showHidden:bool = false
	field _showHighlightLine:bool = false

'	Field _codeLine := New Stack<Int>
'	Field _codeKind := New Stack<Byte>
'	Field _codeText := New Stack<String>

	
	#rem
	'not very efficient - scans entire document and recalcs all EOLs.
	'
	Method UpdateEols()
	
		_nlines=1
		Local eol:=-1
		
		Repeat
			eol=_text.Find( "~n",eol+1 )
			If eol=-1 Exit
			_nlines+=1
		Forever
		
		_eols.Resize( _nlines )
		
		Local line:=0
		Repeat
			eol=_text.Find( "~n",eol+1 )
			If eol=-1
				_eols.Data[line].eol=_text.Length
				Exit
			Endif
			
			_eols.Data[line].eol=eol
			line+=1
		Forever
		
		'invalidate all line coloring
		'
		_colors.Resize( _text.Length )
		
		For Local i:=0 Until _nlines
			Local sol:=StartOfLine( i )
			If sol>=_colors.Length Exit
			_colors[ sol ]=-1
		Next
		
'		Print "lines="+_nlines
'		For Local i:=0 Until _nlines
'			Print "eol="+_eols[i]
'		Next
	End
	
	#end
	
End




Class TextView Extends View

	Field CursorMoved:Void()

	Field FieldEntered:Void()
	
	Field FieldTabbed:Void()

	Field _icons:Image
	
	
	
	

'	Field DebugClicked:Void()


	Method New()
		Layout = "fill"
	
		Style = Style.GetStyle( "mojo.TextView" )

		_doc = New TextDocument
		
		
'		_textColors=New Color[]( New Color( 0,0,0,1 ),New Color( 0,0,.5,1 ),New Color( 0,.5,0,1 ),New Color( .5,0,0,1 ),New Color( .5,0,.5,1 ) )
'		_textColors=New Color[]( New Color( 1,1,1,1 ),New Color( 0,1,0,1 ),New Color( 1,1,0,1 ),New Color( 0,.5,1,1 ),New Color( 0,1,.5,1 ) )
		_textColors = New Color[]( New Color( 1,1,1,1 ) ,New Color( 0,1,0,1 ), New Color( 1,1,0,1 ), New Color( 0.1,0.3,0.6, 1 ), New Color( 0,1,.5,1 ) )
	End


	
'	Method New( doc:TextDocument )
'		Self.New()
	
'		_doc = doc
'	End


	
	Property Document:TextDocument()
		Return _doc
	Setter( doc:TextDocument )
		_doc = doc
		
		_cursor = Clamp( _cursor, 0, _doc.TextLength )
		_anchor = _cursor
		
		UpdateCursor()
	End


	
	method GetDebugState:int( line:int )
 		return _doc.GetDebugLine( line )
	end
	


	method GetCodeJump:int( line:int )
 		return _doc.GetCodeJumpLine( line )
	end
	


	method GetCodeIcon:int( line:int )
 		return _doc.GetCodeJumpIcon( line )
	end


	
	Property TextColors:Color[]()
		Return _textColors
	Setter( textColors:Color[] )
		_textColors=textColors
	End


	
	Property SelectionColor:Color()
		Return _selColor
	Setter( selectionColor:Color )
		_selColor=selectionColor
	End


	
	Property CursorColor:Color()
		Return _cursorColor
	Setter( cursorColor:Color )
		_cursorColor=cursorColor
	End


	
	Property BlockCursor:Bool()
		Return _blockCursor
	Setter( blockCursor:Bool )
		_blockCursor=blockCursor
	End



	Property ShowInvisibles:Bool()
		Return _showInvisibles
	Setter( showInvisibles:Bool )
		_showInvisibles = showInvisibles
	End



	Property Text:String()
		Return _doc.Text
	Setter( text:String )
		_doc.Text=text
	End


	
	Property ReadOnly:Bool()
		Return _readOnly
	Setter( readOnly:Bool )
		_readOnly=readOnly
	End


	
	Property TabsStop:Int()
		Return _tabStop
	Setter( tabStop:Int )
		_tabStop=tabStop
		_tabSpaces=" "
		For Local i:=1 Until tabStop
			_tabSpaces+=" "
		Next
	End


	
	Property Cursor:Int()
		Return _cursor
	Setter( cursor:int )
		_cursor = cursor
		UpdateCursor()
	End


	
	Property Anchor:Int()
		Return _anchor
	End


	
	Property CursorColumn:Int()
		Return Column( _cursor )
	End


	
	Property CursorRow:Int()
		Return Row( _cursor )
	End


	
	Property CursorRect:Recti()
		Return _cursorRect
	End


	
	Property LineHeight:Int()
		Return _charh
	End


	
	Property CanUndo:Bool()
		Return Not _readOnly And Not _undos.Empty
	End


	
	Property CanRedo:Bool()
		Return Not _readOnly And Not _redos.Empty
	End


	
	Property CanCut:Bool()
		Return Not _readOnly And _anchor<>_cursor
	End


	
	Property CanCopy:Bool()
		Return _anchor<>_cursor
	End


	
	Property CanPaste:Bool()
		Return Not _readOnly And Not App.ClipboardTextEmpty
	End


	
	Property Container:View() Override
		If Not _scroller
		
			_scroller = New ScrollView
			_scroller.ContentView = Self
			
			CursorMoved += Lambda()
				_scroller.EnsureVisible( CursorRect - New Vec2i( _gutterw, 0 ) )
			End
			
		Endif
		
		Return _scroller
	End


	
	Method Clear()
		SelectAll()
		ReplaceText( "" )
	End


	
	Method SelectText( anchor:Int, cursor:Int )
		_anchor = Clamp( anchor, 0, _doc.TextLength )
		_cursor = Clamp( cursor, 0, _doc.TextLength )
		UpdateCursor()
	End


	
	Method ReplaceText( text:String )
		Local undo := New UndoOp
		undo.text = _doc.Text.Slice( Min( _anchor, _cursor ), Max( _anchor, _cursor ) )
		undo.anchor = Min( _anchor, _cursor )
		undo.cursor = undo.anchor + text.Length
		_undos.Push( undo )
		
		ReplaceText( _anchor, _cursor, text )
	End


	
	'non-undoable
	Method ReplaceText( anchor:Int, cursor:Int, text:String )
		_redos.Clear()
	
		_doc.ReplaceText( anchor, cursor,text )
		_cursor = Min( anchor, cursor ) + text.Length
		_anchor = _cursor
		
		UpdateCursor()
	End
	


	Method Undo()
		If _readOnly Return
	
		If _undos.Empty Return
		
		Local undo := _undos.Pop()

		Local text := undo.text
		Local anchor := undo.anchor
		Local cursor := undo.cursor
		
		undo.text = _doc.Text.Slice( anchor, cursor )
		undo.cursor = anchor + text.Length
		
		_redos.Push( undo )
		
		_doc.ReplaceText( anchor, cursor, text )
		_cursor = anchor + text.Length
		_anchor = _cursor
		
		UpdateCursor()
	End


	
	Method Redo()
		If _readOnly Return
		
		If _redos.Empty Return

		Local undo := _redos.Pop()
		
		Local text := undo.text
		Local anchor := undo.anchor
		Local cursor := undo.cursor
		
		undo.text = _doc.Text.Slice( anchor, cursor )
		undo.cursor = anchor + text.Length
		
		_undos.Push( undo )
		
		_doc.ReplaceText( anchor, cursor, text )
		_cursor = anchor + text.Length
		_anchor = _cursor
		
		UpdateCursor()
	End


	
	Method SelectAll()
		SelectText( 0, _doc.TextLength )
	End


	
	Method Cut()
		If _readOnly Return
		Copy()
		ReplaceText( "" )
	End


	
	Method Copy()
		Local min := Min( _anchor, _cursor )
		Local max := Max( _anchor, _cursor )
		Local text := _doc.Text.Slice( min, max )
		App.ClipboardText = text
	End

	Method ColorUnderCursor:int()
		return _doc.Colors[_cursor]
	End

	Method TagUnderCursor:String()
		return _doc.Tags[_cursor]
	End

	
	
 	Method ExpandGutterSelect( p:Vec2i )
 		If p.y < 0 then Return
		
		Local line := p.y / _charh
		If line > _doc.LineCount Return
		
		local length1:int = _doc.LineLength( line - 1)
		local length2:int = _doc.LineLength( line )
		
		local length:int = length2 - length1 - 1
		if length < 0 then length = 0
		
		if length < 1 then Return
		
		local cursor:int = _cursor
		
		if _cursorOld = _cursor Then
'      print " cursor clicked click="+_clickedCount

			Local text := _doc.Text.Slice( _cursor, _cursor + length )
			local alpha := "abcdefghijklmnopqrstuvwxyz.#'0123456789"
			local chr:String
			local k:Int = 0
      
			if _clickedCount = 0 Then
				chr = text.Mid(0, 1)
				chr = chr.ToLower()
				if alpha.Find( chr ) = -1 Then
 '           print " eat space"
            
					k = 0
					repeat
						k += 1
						chr = text.Mid(k, 1)
						chr = chr.ToLower()
					until alpha.Find( chr ) > -1
					_cursor += k
					_clickedStart = _cursor
				else  
					_clickedCount = 1
				end if
			end if
      
			select _clickedCount
				case 1
				'          print " eat alpha cursor="+_cursor+" clickedStart="+_clickedStart
					_anchor = _clickedStart
					k = _anchor - _cursor
					repeat
						k += 1
						chr = text.Mid(k, 1)
						chr = chr.ToLower()
					until k >= length or alpha.Find( chr ) = -1
					_cursor += k
				case 2
				'          print " eat line"
					_cursor += length
				case 3
					_clickedCount = 0
					_clickedStart = _cursor
			end select
      
			_clickedCount += 1
		Else
			_clickedCount = 0
			_clickedStart = _cursor
		end If
		
		_cursorOld = cursor
	end Method
 
 
  
	Method ExpandSelect( p:Vec2i )
		if p.y < 0 Return

		Local line := p.y / _charh
		If line > _doc.LineCount Return
		
		local length1:int = _doc.LineLength( line - 1)
		local length2:int = _doc.LineLength( line )
		
		local length:int = length2 - length1 - 1
		if length < 0 then length = 0
		
		if length < 1 then Return
		
		local storedCursor:int = _cursor

		'    print " clicked click="+_clickedCount+" oldcursor="+_cursorOld+" cursor="+_cursor
		
		if _cursorOld = _cursor Then
		'      print " cursor clicked click="+_clickedCount

			p.x = 0
			local cursor:int = PointToIndex( p )
		
			Local text := _doc.Text.Slice( cursor, cursor + length )
			local alpha := "abcdefghijklmnopqrstuvwxyz.#'0123456789"
			local alpha1 := "abcdefghijklmnopqrstuvwxyz#'0123456789"
			local chr:String
			local k:Int = _cursor - cursor

			      'print ">"+text+"< "+k

			chr = text.Mid(k, 1)
			chr = chr.ToLower()
			if alpha.Find( chr ) = -1 Then
			'        print " eat space"
        
				if _clickedCount > 0 Then
			'          print "eat Line"
					_anchor = cursor
					_cursor = cursor + length
					return
				end if

				'get previous space
				local pos:int = -1
				repeat
					k -= 1
					chr = text.Mid(k, 1)
					chr = chr.ToLower()
					pos += 1
				until k < 0 or alpha.Find( chr ) > -1
				_anchor -= pos
            
				'get next space
				k = _cursor - cursor
				pos = 0
				repeat
					k += 1
					chr = text.Mid(k, 1)
					chr = chr.ToLower()
					pos += 1
				until k >= length or alpha.Find( chr ) > -1
				_cursor += pos

			Else
				'print " eat alpha"
        
				local search:string = alpha1
				local startPos:int = k
				local endPos:int = k
				local munch:int = False
        
				if _clickedCount > 0 then
					search = alpha
					if _clickedCount > 1 Then munch = true
					'print "eat Line"
				end If
        
				'get previous space
				local pos:int = -1
				repeat
					startPos -= 1
					chr = text.Mid(startPos, 1)
					chr = chr.ToLower()
					pos += 1
				until startPos < 0 or search.Find( chr ) = -1
				_anchor -= pos
            
				'get next space
				pos = 0
				repeat
					endPos += 1
					chr = text.Mid(endPos, 1)
					chr = chr.ToLower()
					pos += 1
				until endPos >= length or search.Find( chr ) = -1
				_cursor += pos
            
				if munch or (_anchor = _clickedStart and _cursor = _clickedEnd) Then
					'print "munch line"
					_anchor = cursor
					_cursor = cursor + length
					return
				end if
            
				_clickedStart = _anchor
				_clickedEnd = _cursor

			end if
			_clickedCount += 1
		Else
			_clickedCount = 0
			_clickedStart = _cursor
		end if
		
		_cursorOld = storedCursor
	  end Method
  
  

	Method GotoLine( line:int, txt:string = "")
		'    print "gotoline "+line
    
		local showLine:int = line + 20
		if showLine > _doc.LineCount then showLine = _doc.LineCount

		local row:int = 0
		if txt <> "" then
			local text:string = _doc.GetLine( line )
			row = text.Find( txt )
			if row < 0 then row = 0
		end if

    
		_cursor = _doc.StartOfLine( showLine )
		_anchor = _cursor
		UpdateCursor()
		
		_cursor = _doc.StartOfLine( line ) + row
		_anchor = _cursor
		UpdateCursor()
	  end Method
  
  
  
	method NextWord( line:int )
		if line <= 0 or line > _doc.LineCount Return
    
		local length1:int = _doc.LineLength( line - 1)
		local length2:int = _doc.LineLength( line )
      
		local length:int = length2 - length1 - 1
		if length < 0 then length = 0
      
		if length < 1 then Return

		local text:string = _doc.GetLine( line )
		local alpha := "abcdefghijklmnopqrstuvwxyz.#'0123456789()[]"
		local alpha1 := "abcdefghijklmnopqrstuvwxyz#'0123456789()[]"
		local chr:string

		local pos:int = 0
		local k:Int = Column( _cursor )
		chr = text.Mid(k, 1)
		chr = chr.ToLower()
      
		if alpha.Find( chr ) = -1 then 'next non alpha
			repeat
				k += 1
				chr = text.Mid(k, 1)
				chr = chr.ToLower()
				pos += 1
			until k >= length or alpha.Find( chr ) > -1
			'print "nonalpha pos="+pos+" length="+length
			_cursor += pos
		else ' next alpha
			repeat
				k += 1
				chr = text.Mid(k, 1)
				chr = chr.ToLower()
				pos += 1
			until k >= length or alpha1.Find( chr ) = -1
			'print "alpha pos="+pos+" length="+length
			_cursor += pos
		endif
	end method



	method PrevWord( line:int )
		If line <= 0 or line > _doc.LineCount Return
    
		local length1:int = _doc.LineLength( line - 1)
		local length2:int = _doc.LineLength( line )
      
		local length:int = length2 - length1 - 1
		if length < 0 then length = 0
      
		if length < 1 then Return

		local text:string = _doc.GetLine( line )
		local alpha := "abcdefghijklmnopqrstuvwxyz.#'0123456789()[]"
		local alpha1 := "abcdefghijklmnopqrstuvwxyz#'0123456789()[]"
		local chr:string

		local pos:int = 0
		local k:Int = Column( _cursor )
		chr = text.Mid(k, 1)
		chr = chr.ToLower()
      
		if alpha.Find( chr ) = -1 then 'next non alpha
			repeat
				k -= 1
				chr = text.Mid(k, 1)
				chr = chr.ToLower()
				pos += 1
			until k < 0 or alpha.Find( chr ) > -1
			'print "nonalpha pos="+pos+" length="+length
			_cursor -= pos
		else ' next alpha
			repeat
				k -= 1
				chr = text.Mid(k, 1)
				chr = chr.ToLower()
				pos += 1
			until k < 0 or alpha1.Find( chr ) = -1
			'print "alpha pos="+pos+" length="+length
			_cursor -= pos
		endif
	  end method



	Method DebugLine( p:Vec2i )
		if p.y < 0 Return
		
		Local line := p.y / _charh
		Local lastVisLine := Min( (ClipRect.Bottom-1)/_charh+1,_doc.LineCount )

		If line >= _doc.LineCount-1 or line >= lastVisLine-1 Return
		
		'local min := _cursorMin( _anchor, _cursor )
		'local max := Max( _cursor, 11 )
		Local text := _doc.Text.Slice( _cursor, _cursor+11 )

'		print "CURRENT LINE = "+line+"  "+text
		if text.ToLower() = "debugstop()" Then
			_cursor += 12
			UpdateCursor()
			ReplaceText( "" )
		Else
			Insert( "DebugStop()~n" )
		end if
    

		_doc.DebugToggle( line )

		UpdateCursor()

		'    _lines[line].debug = not _lines[line].debug
	  end method



	Method Insert( txt:string )
		If _readOnly or txt = "" then Return

		_anchor = _cursor'Clamp( _anchor,0,_doc.TextLength )
		'_cursor = Clamp( _cursor,0,_doc.TextLength )
		UpdateCursor()
		
'		If App.ClipboardTextEmpty Return
		
'		Local text:String=App.ClipboardText
'		text=text.Replace( "~r~n","~n" )
'		text=text.Replace( "~r","~n" )
		
'		If text ReplaceText( text )

		 ReplaceText( txt )
	end Method
	
	
	
	Method Paste()
		If _readOnly Return
		
		If App.ClipboardTextEmpty Return
		
		Local text:String=App.ClipboardText
		text=text.Replace( "~r~n","~n" )
		text=text.Replace( "~r","~n" )
		
		If text ReplaceText( text )
	End



Private


	
	Class UndoOp
		Field text:String
		Field anchor:Int
		Field cursor:Int
	End


	
	Field _doc:TextDocument
	Field _tabStop:Int = 4
	Field _tabSpaces:String = "    "
	Field _cursorColor:Color = New Color( 0.1,0.3,0.6, 1 )
	Field _selColor:Color = New Color( 1,1,1,.25 )
	Field _blockCursor:Bool = True
	Field _showInvisibles:Bool = True
	
	Field _textColors:Color[]

	Field _anchor:Int
	Field _cursor:Int
	
	Field _cursorOld:int
	field _clickedCount:int
	field _clickedStart:Int
	field _clickedEnd:int
	
	Field _tabw:Int
	Field _charw:Int
	Field _charh:Int
	Field _gutterw:Int
	Field _columnX:Int
	Field _cursorRect:Recti
	
	Field _contentMargin:Recti
	
	Field _undos:=New Stack<UndoOp>
	Field _redos:=New Stack<UndoOp>
	
	Field _dragging:Bool
	
	Field _scroller:ScrollView
	
	Field _readOnly:Bool


	
	Method Row:Int( index:Int )
		Return _doc.FindLine( index )
	End


	
	Method Column:Int( index:Int )
		Return index-_doc.StartOfLine( _doc.FindLine( index ) )
	End


	
	Method UpdateCursor()
		Local rect := MakeCursorRect( _cursor )
		If rect = _cursorRect Return
		
		_cursorRect = rect
		_columnX = rect.X

		CursorMoved()
	End


	
	Method MakeCursorRect:Recti( cursor:Int )
		ValidateStyle()
		
		Local line := _doc.FindLine( cursor )
		Local text := _doc.GetLine( line )
		
		Local x := 0.0
		local i0 := 0
		local e := cursor - _doc.StartOfLine( line )
		
		While i0 < e
		
			Local i1 := text.Find( "~t",i0 )
			If i1 = -1 then i1 = e
			
			If i1 > i0 then
				If i1 > e then i1=e
				x += Style.DefaultFont.TextWidth( text.Slice( i0, i1 ) )
				If i1 = e then Exit
			Endif
			
			x = Int( (x+_tabw)/_tabw ) * _tabw
			i0 = i1 + 1
			
		Wend
		
		Local w := _charw
		
		If e < text.Length then
			If text[e] = 9 then
'				w=Int( (x+_tabw)/_tabw ) * _tabw-x
			Else
				w = Style.DefaultFont.TextWidth( text.Slice( e, e + 1 ) )
			Endif
		Endif
		
		x += _gutterw
		Local y := line * _charh
		
		Return New Recti( x,y, x+w,y+_charh )
	End


	
	Method PointXToIndex:Int( px:Int,line:Int )
		ValidateStyle()

		px=Max( px-_gutterw, 0 )
		
		Local text := _doc.GetLine( line )
		Local sol := _doc.StartOfLine( line )
		
		Local x:=0.0,i0:=0,e:=text.Length
		
		While i0<e
		
			Local i1:=text.Find( "~t",i0 )
			If i1=-1 i1=e
			
			If i1>i0
				For Local i:=i0 Until i1
					x+=Style.DefaultFont.TextWidth( text.Slice( i,i+1 ) )
					If px<x Return sol+i
				Next
				If i1=e Exit
			Endif
			
			x=Int( (x+_tabw)/_tabw ) * _tabw
			If px<x Return sol+i0
			
			i0=i1+1
		Wend
		
		Return sol+e
	End


	
	Method PointToIndex:Int( p:Vec2i )
		If p.y < 0 Return 0
		
		Local line := p.y / _charh
		If line > _doc.LineCount Return _doc.TextLength
		
		Return PointXToIndex( p.x, line )
	End



'  Method GotoLine( line:int )
'    print "gotoline "+line
'  end Method
  
  
	
	Method MoveLine( delta:Int )

		Local line := Clamp( Row( _cursor )+delta, 0, _doc.LineCount-1 )
		
		_cursor = PointXToIndex( _columnX, line )
		
		Local x := _columnX
		
		UpdateCursor()
		
		_columnX = x
	End


  
'  Method DebugLine( p:Vec2i )
' 		If p.y < 0 Return
		
'		Local line := p.y / _charh
'		If line > _doc.LineCount Return

'    _doc.DebugToggle( line )
'    _lines[line].debug = not _lines[line].debug
'  end method

	
Protected


	
	Property GutterWidth:Int()
		Return _gutterw
	Setter( gutterWidth:Int )
		_gutterw=gutterWidth
	End


	
	Property ContentMargin:Recti()
		Return _contentMargin
	Setter( contentMargin:Recti )
		_contentMargin=contentMargin
	End


	
	Method OnValidateStyle() Override
		_icons = Style.GetImage( "node:icons" )

 		_charw=Style.DefaultFont.TextWidth( "X" )
		_charh=Style.DefaultFont.Height
		_tabw=_charw*_tabStop
		
		UpdateCursor()
	End



	Method OnMeasure:Vec2i() Override
		Return New Vec2i( 320*_charw+_gutterw,_doc.LineCount*_charh )+_contentMargin.Size
	End




	Method OnRender( canvas:Canvas ) Override
		Local firstVisLine := ClipRect.Top/_charh
		Local lastVisLine := Min( (ClipRect.Bottom-1)/_charh+1,_doc.LineCount )
		local currentLine := _doc.FindLine( _cursor )
		
		local colorDark := new Color( 0,0,0, 0.2 )
		local colorLight := new Color( 1,1,1, 0.1 )
		
		
		If _cursor <> _anchor then
		
			Local min := MakeCursorRect( Min( _anchor,_cursor ) )
			Local max := MakeCursorRect( Max( _anchor,_cursor ) )
			
			canvas.Color = _selColor
			
			If min.Y = max.Y
				canvas.DrawRect( min.Left ,min.Top, max.Left-min.Left, min.Height )
			Else
				canvas.DrawRect( min.Left,min.Top,(ClipRect.Right-min.Left),min.Height )
				canvas.DrawRect( _gutterw,min.Bottom,ClipRect.Right-_gutterw,max.Top-min.Bottom )
				canvas.DrawRect( _gutterw,max.Top,max.Left-_gutterw,max.Height )
			Endif
			
		Else If Not _readOnly And App.KeyView = Self
		
			canvas.Color = _cursorColor
			
			If _blockCursor
				canvas.DrawRect( _cursorRect.X-1,_cursorRect.Y-1,_cursorRect.Width+2,_cursorRect.Height+2 )
			Else
				canvas.DrawRect( _cursorRect.X-1,_cursorRect.Y-2,2,_cursorRect.Height+4 )
'				canvas.DrawRect( _cursorRect.X-2,_cursorRect.Y,6,2 )
'				canvas.DrawRect( _cursorRect.X-2,_cursorRect.Y+_cursorRect.Height-2,6,2 )
			Endif
			
		Endif

		_textColors[0] = Style.DefaultColor
		local tabsize:int = _gutterw
		
		local halfchar:int = _charh * 0.5
		
		For Local line := firstVisLine Until lastVisLine
		
			_doc.HighlightLine( line )
			'print g_CodeKind +" "+ g_CodeText +"  "+ g_CodeLine
			'print line+" "+currentLine
			
			if _doc._showHighlightLine and line = currentLine Then
				canvas.Color = colorDark
				canvas.DrawRect( 0,_cursorRect.Y+1, Width,_cursorRect.Height )
				canvas.Color = colorLight
				canvas.DrawLine( 0, _cursorRect.Y, Width,_cursorRect.Y )
				canvas.DrawLine( 0, _cursorRect.Y+_cursorRect.Height, Width, _cursorRect.Y+_cursorRect.Height )
			end if
		
			Local sol := _doc.StartOfLine( line )
			Local eol := _doc.EndOfLine( line )

			Local text := _doc.Text.Slice( sol, eol )
			Local colors := _doc.Colors
			
			Local x := 0
			Local y := line * _charh
			Local i0 := 0
			
			While i0 < text.Length
			
				Local i1 := text.Find( "~t", i0 )
				If i1 = -1 then i1 = text.Length
				
				if i1 <= i0 Then
        
					if text.Left(1) = "~t" and _showInvisibles then
'						if _doc._showHidden then
							canvas.Color = Color.LightGrey
							canvas.DrawImageIcon( _icons, x + tabsize, y,  NODEKIND_TAB, 80 )
'						end if
					endif
					
				else
				
					Local color := colors[sol+i0]
					Local start := i0
					
					Repeat
						
						While i0 < i1 And colors[sol + i0] = color
							i0 += 1
						Wend
						
						If i0 > start then
							If color < 0 Or color >= _textColors.Length then color = 0
							
							Local t := text.Slice( start, i0 )
							
							canvas.Color = _textColors[color]
							if t.Left(2) = "#-" then
								canvas.Alpha = 0.3
								canvas.DrawLine( 0,y+halfchar, Width,y+halfchar )
								canvas.Alpha = 1
							end if

							canvas.DrawText( t, x + _gutterw, y )
							
							
							x += Style.DefaultFont.TextWidth( t )
						Endif
						
						If i0 = i1 then Exit
						
						color = colors[sol+i0]
						start = i0
						i0 += 1
						
					Forever
				
					If i1 = text.Length then Exit
					
				Endif
				
				x = Int( (x+_tabw) / _tabw ) * _tabw
				
				i0 = i1 + 1
			
			Wend

			if _showInvisibles then'_doc._showHidden then
				canvas.Color = Color.LightGrey
				canvas.DrawImageIcon( _icons, x + tabsize, y,  NODEKIND_RETURN, 80 )
			endif
			
		Next
		
#rem		
		If _flags & TextViewFlags.ShowLineNumbers
		
			Local GutterColor:=New Color( .9,.9,.9,1 )
			
			canvas.SetColor( GutterColor.r,GutterColor.g,GutterColor.b,GutterColor.a )
			canvas.DrawRect( ClipRect.X,ClipRect.Y,_gutterw-_charw,ClipRect.Height )
		
			canvas.SetColor( Style.DefaultColor.r,Style.DefaultColor.g,Style.DefaultColor.b,Style.DefaultColor.a*.5 )

			For Local i:=firstVisLine Until lastVisLine
				canvas.DrawText( (i+1),ClipRect.X+_gutterw-_charh,i*_charh,1,0 )
			Next
		End
#end
	End



	
	Method OnKeyEvent( event:KeyEvent ) Override
		If _readOnly Return

		local _modifier := Modifier.Control
    
#If __HOSTOS__="macos"
		_modifier = Modifier.Command
#Endif

	
		Select event.Type
			Case EventType.KeyDown, EventType.KeyRepeat
				Local control := event.Modifiers & _modifier'Modifier.Control
		
				local _control := event.Modifiers & Modifier.Control
				local _alt := event.Modifiers & Modifier.Alt
				local _command := event.Modifiers & Modifier.Command
				local _shift := event.Modifiers & Modifier.Shift

				Select event.Key
			
					Case Key.A
						If control SelectAll()
						Return
            
					Case Key.X
						If control Cut()
						Return
            
					Case Key.C
						If control Copy()
						Return
          
					Case Key.V
						If control Paste()
						Return
            
					Case Key.Z
						If control Undo()
						Return
          
					Case Key.Backspace
						If _anchor = _cursor And _cursor > 0 SelectText( _cursor-1, _cursor )
						ReplaceText( "" )
            
					Case Key.KeyDelete
						If _anchor = _cursor And _cursor < _doc.Text.Length SelectText( _cursor, _cursor+1 )
						ReplaceText( "" )
            
					Case Key.Tab
						
						Local min := Min( _anchor, _cursor )
						Local max := Max( _anchor, _cursor )
						Local line := _doc.FindLine( min )
						Local eLine := _doc.FindLine( max )

'						print line+" "+eLine
						
						if eLine - line > 0 Then
							eLine -= 1
							'print "lines"
							local startLine:int = _doc.StartOfLine( line )
							local difference:int = max - min
'							local nextLine:int = _doc.StartOfLine( line+1 )
							local endLine:int = _doc.StartOfLine( eLine )
							
							local watchtab:bool = (line = eLine)

							
							'print "indenting start="+line+" endline="+eLine
			
							while startLine <= endLine
								startLine = _doc.StartOfLine( line )
								
								if not(watchtab) or (watchtab and line < eLine+1) then
								'if startLine <= endLine then
									'print "indenting line="+line+" start="+startLine+" endline="+endLine
									_cursor = startLine
									_anchor = startLine
									if _shift Then
										if line < (eLine+1) Then
											if _doc._text.Mid(startLine, 1) = "~t" or _doc._text.Mid(startLine, 1) = " " Then
												'print "endent"
												_anchor = startLine
												_cursor = startLine + 1
												
	'											local text:string = _doc.GetLine( line )
	'											print ">"+text+"<"
												
												ReplaceText( "" )
												difference -= 1
											end if
										end if	
									else
										'_cursor = startLine + 1
										ReplaceText( "~t" )
										difference += 1
									end if
								end if
'								_cursor = startLine
'								_anchor = startLine
'								if _shift Then
'									if _doc._text.Mid(startLine, 1) = "~t" or _doc._text.Mid(startLine, 1) = " " Then
'										print "endent"
'										_anchor = startLine
'										_cursor = startLine + 1
'										ReplaceText( "" )
'										difference -= 1
'									end if
'								else
'									ReplaceText( "~t" )
'									difference += 1
'								end if
								line += 1
							wend

							_anchor = min
							_cursor = min + difference
							UpdateCursor()
							return

						Else
							print "line"
								if not _shift then
									ReplaceText( "~t" )
								end if
						end if
						
'						print "anchor="+min+" cursor="+max
'						print " line="+min
'						print "fromline="+startLine+" endline="+endLine
#rem						
						if min < nextLine and max >= nextLine Then
							local startLine:int = _doc.StartOfLine( line )
							local difference:int = max - min
							while startLine < endLine
								startLine = _doc.StartOfLine( line )
								_cursor = startLine
								_anchor = startLine
								if _shift Then
									if _doc._text.Mid(startLine, 1) = "~t" or _doc._text.Mid(startLine, 1) = " " Then
'										print "endent"
										_anchor = startLine
										_cursor = startLine + 1
										ReplaceText( "" )
										difference -= 1
									end if
								else
									ReplaceText( "~t" )
									difference += 1
								end if
								'print "indenting line="+line
								line += 1
							wend
							
'							print "indent min="+min+" difference="+difference
							_anchor = min
							_cursor = min + difference
							UpdateCursor()
'							print _anchor+" "+_cursor
							return
							
						Else
'							print "normal"
						end if
'						ReplaceText( "~t" )
#end            
					Case Key.Enter
						ReplaceText( "~n" )
            
					            'auto indent!
						Local line := CursorRow
						If line > 0 then
            
							Local ptext := _doc.GetLine( line-1 )
              
							Local indent := ptext
							For Local i := 0 Until ptext.Length
								If ptext[i] <= 32 then Continue
								indent = ptext.Slice( 0, i )
								Exit
							Next
              
							If indent then ReplaceText( indent )
            
						Endif
            
#If __HOSTOS__="macos"          
					Case Key.Left
						'ctrl = prev space
						'alt = start of line
						if _alt or control Then
							_cursor = _doc.StartOfLine( Row( _cursor ) )
							UpdateCursor()
						Else
							if _control Then
								PrevWord( Row( _cursor ) )
								UpdateCursor()
							Else
								If _cursor 
									_cursor -= 1
									UpdateCursor()
								Endif
							end if
						end if
            
					Case Key.Right
						'ctrl = next space
						'alt = end of line
          
						if _alt or control Then
							_cursor = _doc.EndOfLine( Row( _cursor ) )
							UpdateCursor()
						else
							if _control Then
								NextWord( Row( _cursor ) )
								UpdateCursor()
							Else
								If _cursor < _doc.Text.Length
									_cursor += 1
									UpdateCursor()
								Endif
							endif
						endif
#Else
					Case Key.Left
						'ctrl = prev space
						'alt = start of line
						if _control or control Then
							_cursor = _doc.StartOfLine( Row( _cursor ) )
							UpdateCursor()
						Else
							if _alt Then
								PrevWord( Row( _cursor ) )
								UpdateCursor()
							Else
								If _cursor 
									_cursor -= 1
									UpdateCursor()
								Endif
							end if
						end if
            
					Case Key.Right
						'ctrl = next space
						'alt = end of line
          
						if _control or control Then
							_cursor = _doc.EndOfLine( Row( _cursor ) )
							UpdateCursor()
						else
							if _alt Then
								NextWord( Row( _cursor ) )
								UpdateCursor()
							Else
								If _cursor < _doc.Text.Length
									_cursor += 1
									UpdateCursor()
								Endif
							endif
						endif
#end            
					Case Key.Up
						If control Then
							_cursor = 0
							UpdateCursor()
						Else
							MoveLine( -1 )
						End If
          
					Case Key.Down
						If control Then
							_cursor = _doc.TextLength
							UpdateCursor()
						Else
							MoveLine( 1 )
						End if
						
					Case Key.Home
						'print "home"
						If control
							_cursor = 0
						Else
							_cursor = _doc.StartOfLine( Row( _cursor ) )
						Endif
            
						UpdateCursor()
            
					Case Key.KeyEnd
						'print "end"
						If control
							_cursor = _doc.TextLength
						Else
							_cursor = _doc.EndOfLine( Row( _cursor ) )
						Endif
            
						UpdateCursor()

					Case Key.PageUp
						if _control Then
							_cursor = 0
							UpdateCursor()
						else
							Local n := ClipRect.Height / _charh - 1 'shouldn't really use cliprect here...
            
							MoveLine( -n )
						end if
            
					Case Key.PageDown
						if _control then
							_cursor = _doc.TextLength
							UpdateCursor()
						else
							Local n := ClipRect.Height / _charh - 1
            
							MoveLine( n )
						end If
            
					Default
          
						Return
				End
			
				If Not (event.Modifiers & Modifier.Shift) _anchor = _cursor
			
			Case EventType.KeyChar
				If _undos.Length
					Local undo := _undos.Top
					If Not undo.text And _cursor = undo.cursor then
						ReplaceText( _anchor,_cursor, event.Text )
						undo.cursor = _cursor
						Return
					Endif
				Endif
      
				ReplaceText( event.Text )
			
		End
		
		_doc.CursorPos = _cursor
		
	End



	Method OnMouseEvent( event:MouseEvent ) Override
		Select event.Type
			Case EventType.MouseDown
				App.KeyView = Self
				_cursor = PointToIndex( event.Location )
				_anchor = _cursor
				_dragging = True
				UpdateCursor()
          
				if event.Location.X < 16 Then
					DebugLine( event.Location )
          
				elseif event.Location.X < 64 Then
					ExpandGutterSelect( event.Location )
					UpdateCursor()
					'print "here"
				Else
					ExpandSelect( event.Location )
					UpdateCursor()
				end If
				
				_doc.CursorPos = _cursor
        
			Case EventType.MouseUp
				_dragging = False
        
			Case EventType.MouseMove
				If _dragging
					_cursor = PointToIndex( event.Location )
					UpdateCursor()
				Endif
        
			Case EventType.MouseWheel
				Super.OnMouseEvent( event )
				Return
        
		End Select
		
	End


	
	Method OnMakeKeyView() Override
		Super.OnMakeKeyView()
		UpdateCursor()
	End
	
End
