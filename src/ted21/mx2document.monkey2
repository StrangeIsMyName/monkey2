
Namespace ted2

Global Mx2Keywords := New StringMap<String>
const Mx2Fields:string = "const;field;global;void;bool;byte;ubyte;short;ushort;int;uint;long;ulong;float;double;string;"
const Mx2Function:string = "function;"
const Mx2Method:string = "method;"
const Mx2Class:string = "class;"
const Mx2ClassPrivate:string = "private"
const Mx2ClassPublic:string = "public"
const Mx2ClassProtected:string = "protected"
const Mx2ClassFriend:string = "friend"
const Mx2Property:string = "property;setter;"
const Mx2Struct:string = "struct;"
const Mx2Lambda:string = "lambda;"

Private




Function InitKeywords()
	Local kws:=""

	kws += "Namespace;Using;Import;Extern;"
	kws += "Public;Private;Protected;Friend;"
	kws += "Void;Bool;Byte;UByte;Short;UShort;Int;UInt;Long;ULong;Float;Double;String;"
	kws += "Object;Continue;Exit;"
	kws += "New;Self;Super;Eachin;True;False;Null;Where;"
	kws += "Alias;Const;Local;Global;Field;Method;Function;Property;Getter;Setter;Operator;Lambda;"
	kws += "Enum;Class;Interface;Struct;Extends;Implements;Virtual;Override;Abstract;Final;Inline;"
	kws += "Var;Varptr;Ptr;"
	kws += "Not;Mod;And;Or;Shl;Shr;End;"
	kws += "If;Then;Else;Elseif;Endif;"
	kws += "While;Wend;"
	kws += "Repeat;Until;Forever;"
	kws += "For;To;Step;Next;"
	kws += "Select;Case;Default;"
	kws += "Try;Catch;Throw;Throwable;"
	kws += "DebugStop;"
	kws += "Return;Print;Static;Cast"
	
	For Local kw := Eachin kws.Split( ";" )
		Mx2Keywords[kw.ToLower()] = kw
	Next
End



Public



Class Mx2Error

	Field path:String
	Field line:Int
	Field msg:String
	Field removed:Bool


	
	Method New( path:String,line:Int,msg:String )
		Self.path=path
		Self.line=line
		Self.msg=msg
	End



	Operator<=>:Int( err:Mx2Error )
		If line<err.line Return -1
		If line>err.line Return 1
		Return 0
	End
	
End



Class Mx2TextView Extends TextView

	field _editorColors := New Color[15]

	Method New( mx2Doc:Mx2Document )
		_mx2Doc = mx2Doc
		
		Document = _mx2Doc.TextDocument
		Document.ShowHidden = true
		Document.ShowHighlightLine = true
		Document.CodeClicked = Lambda( line:int, txt:string )
'			print "Line clicked="+line+" "+txt
			GotoLine( line, txt )
		end

		Style = Style.GetStyle( "mojo.mx2Document" )
		
		GutterWidth = 80
		
		
		Select Theme.Name
			Case "light"
				_editorColors[COLOR_IDENT]=New Color( .1,.1,.1 )
				_editorColors[COLOR_KEYWORD]=New Color( 0,0,1 )
				_editorColors[COLOR_STRING]=New Color( 0,.5,0 )
				_editorColors[COLOR_NUMBER]=New Color( 0,0,.5 )
				_editorColors[COLOR_COMMENT]=New Color( 0,.5,.5 )
				_editorColors[COLOR_PREPROC]=New Color( .8,.65,0 )
				_editorColors[COLOR_OTHER]=New Color( .1,.1,.1 )
				_editorColors[COLOR_FIELD]=New Color( 0,0,1 )
				_editorColors[COLOR_METHOD]=New Color( 0,0,1 )
				_editorColors[COLOR_FUNCTION]=New Color( 0,0,1 )
				_editorColors[COLOR_CLASS]=New Color( 0,0,1 )
				_editorColors[COLOR_PROPERTY]=New Color( 0,0,1 )
				_editorColors[COLOR_STRUCT]=New Color( 0,0,1 )
				_editorColors[COLOR_LAMBDA]=New Color( 0,0,1 )
			Default
				_editorColors[COLOR_IDENT]=New Color( .7,.7,.7 )
				_editorColors[COLOR_KEYWORD]=New Color( .35,.5,.73 )
				_editorColors[COLOR_STRING]=New Color( .7, .5, .5 )
				_editorColors[COLOR_NUMBER]=New Color( 0,.8,.6 )
				_editorColors[COLOR_COMMENT]=New Color( .4,.5,.4 )
				_editorColors[COLOR_PREPROC]=New Color( 1,.75,0 )
				_editorColors[COLOR_OTHER]=New Color( 0,1,.5 )
				_editorColors[COLOR_FIELD]=New Color( .32,.8,.31 )
				_editorColors[COLOR_METHOD]=New Color( .25,.6,.82 )
				_editorColors[COLOR_FUNCTION]=New Color( .61,.36,.72 )
				_editorColors[COLOR_CLASS]=New Color( .61,.36,.72 )
				_editorColors[COLOR_PROPERTY]=New Color( .89,.64,.17 )
				_editorColors[COLOR_STRUCT]=New Color( .25,.6,.82 )
				_editorColors[COLOR_LAMBDA]=New Color( .89,.64,.17 )
		End
		
		TextColors=_editorColors
		CursorColor=New Color( 0,.5,1 )
		SelectionColor=New Color( 0.1,0.3,0.6, 1 )
	End

	
Protected


	
	Method OnValidateStyle() Override
		Super.OnValidateStyle()

'		_icons = Style.GetImage( "node:icons" )
'		GutterWidth=RenderStyle.DefaultFont.TextWidth( "999999 " )
	End


	
	Method OnRender( canvas:Canvas ) Override
		Local color := canvas.Color
	
		Local clip:Recti
		clip.min.x = -Frame.min.x
		clip.min.y = -Frame.min.y
		clip.max.x = clip.min.x+GutterWidth
		clip.max.y = clip.min.y+ClipRect.Height

		
		local lineCount:int = Document.LineCount
		
		If _mx2Doc._errors.Length
			canvas.Color = New Color( .5,0,0 )
			
			For Local err := Eachin _mx2Doc._errors
				canvas.DrawRect( 0,err.line*LineHeight, Width, LineHeight )
			Next
		Endif
		
		If _mx2Doc._debugLine <> -1
			Local line := _mx2Doc._debugLine
			If line < 0 Or line >= lineCount Return
			
			canvas.Color = New Color( .7,.3,0 )
			canvas.DrawRect( 0, line*LineHeight, Width, LineHeight )
			
		Endif
		
		canvas.Color = color
		Super.OnRender( canvas )
		
		
		'OK, VERY ugly! Draw gutter stuff...
		'draw right code view
		canvas.Color = New Color( 0,0,0, .15 )
		local lft:int = ClipRect.Width - 50 + ClipRect.X
		local rght:int = lft + 50
		canvas.DrawRect( lft, ClipRect.Y, 50, ClipRect.Height )
		local lineDifference:float = float(Document.LineCount) / ClipRect.Height
		local pos:Int
		local line:int = 0
		local ll:int
		local lineLength:int
		local prevline:int = 0
		
		local prevDebug:int = 0
		local currDebug:int = 0
		local nextDebug:int = GetDebugState( 0 )
		
'		print ClipRect.Height+" "+Document.LineCount+" "+lineDifference
		local screenY:int = ClipRect.Y
		
		Local viewport := clip
		Local line0 := clip.Top/LineHeight
		Local line1 := Min( (clip.Bottom-1)/LineHeight+1, Document.LineCount )
		
		canvas.Color = New Color( 1,1,1, 0.2 )
		for pos = 0 to ClipRect.Height-1
			line = pos * lineDifference
			
			if line >= line0 and line <= line1 Then
				canvas.Color = New Color( 1,1,1, 0.1 )
				canvas.DrawLine( lft, screenY, rght, screenY )
				canvas.Color = New Color( 1,1,1, 0.2 )
			end if
			
			ll = Document.LineLength( line )
			lineLength = (ll-prevline) / 5
			prevline = ll

			prevDebug = currDebug
			currDebug = nextDebug
			nextDebug = GetDebugState( line + 1 )
			if line < Document.LineCount-2 and (prevDebug or currDebug or nextDebug) Then
				canvas.Color = Color.Red
				canvas.DrawLine( lft, screenY, rght, screenY )
				canvas.Color = New Color( 1,1,1, 0.2 )
			end if
			
			if lineLength > 0 Then
				select Document.GetCodeJumpIcon( line )
					case NODEKIND_CLASS
						canvas.Color = _editorColors[COLOR_CLASS]
						canvas.DrawLine( lft, screenY, lft + lineLength, screenY )
						canvas.Color = New Color( 1,1,1, 0.2 )
					case NODEKIND_METHOD
						canvas.Color = _editorColors[COLOR_METHOD]
						canvas.DrawLine( lft, screenY, lft + lineLength, screenY )
						canvas.Color = New Color( 1,1,1, 0.2 )
					case NODEKIND_FUNCTION
						canvas.Color = _editorColors[COLOR_FUNCTION]
						canvas.DrawLine( lft, screenY, lft + lineLength, screenY )
						canvas.Color = New Color( 1,1,1, 0.2 )
					case NODEKIND_FIELD
						canvas.Color = _editorColors[COLOR_FIELD]
						canvas.DrawLine( lft, screenY, lft + lineLength, screenY )
						canvas.Color = New Color( 1,1,1, 0.2 )
					case NODEKIND_LAMBDA
						canvas.Color = _editorColors[COLOR_LAMBDA]
						canvas.DrawLine( lft, screenY, lft + lineLength, screenY )
						canvas.Color = New Color( 1,1,1, 0.2 )
					case NODEKIND_PROPERTY
						canvas.Color = _editorColors[COLOR_PROPERTY]
						canvas.DrawLine( lft, screenY, lft + lineLength, screenY )
						canvas.Color = New Color( 1,1,1, 0.2 )
					default
						if Document.LineState( line ) <> -1 Then
							canvas.Color = _editorColors[COLOR_COMMENT]
							canvas.DrawLine( lft, screenY, lft + lineLength, screenY )
							canvas.Color = New Color( 1,1,1, 0.2 )
						else
							canvas.DrawLine( lft, screenY, lft + lineLength, screenY ) 
						end if
				end select
						

			end if
			screenY += 1

		next
		
		

		'draw left gutter and code and stuff

		viewport.min += RenderStyle.Bounds.min
		canvas.Viewport = viewport

		
		canvas.Color = New Color( .2, .2, .2 )
		canvas.DrawRect( 0, 0, viewport.Width-4, viewport.Height )

		canvas.Color = New Color( .05, .05, .05 )
		canvas.DrawLine( viewport.Width-4, 0, viewport.Width-4, viewport.Height )
		
		canvas.Viewport = Rect
		

		
'		canvas.Color = New Color( .35, .35, .35 )
'    If CursorRow = 0 Then
'      print "ok"
'    End if

		canvas.Color = Color.Grey
		Local ln:int
		local ypos:int
		local icn:int

		For Local i := line0 Until line1
			ln = i + 1
			If ln = CursorRow+1 Then
				canvas.Color = New Color( 0.1,0.3,0.6, 1 )
				canvas.DrawRect( 0, i*LineHeight, viewport.Width-8, LineHeight )
				canvas.Color = Color.White
				canvas.DrawText( String( ln ), clip.X+GutterWidth-8, i*LineHeight, 1, 0 )
				canvas.Color = Color.Grey
			else
				canvas.DrawText( String( ln ), clip.X+GutterWidth-8, i*LineHeight, 1, 0 )
			End If
			
			
			icn = GetCodeIcon( i )
			if icn > 0 then
				canvas.Color = Color.White
				canvas.DrawImageIcon( _icons, clip.X+16, i*LineHeight,  icn, 80 )
			end if  
			
			if ln >= lineCount Then
			else  
				if GetDebugState( i ) then
					canvas.Color = Color.White
					canvas.DrawImageIcon( _icons, clip.X, i*LineHeight,  NODEKIND_DEBUGON, 80 )
				else
					canvas.Color = Color.Grey
					canvas.DrawImageIcon( _icons, clip.X, i*LineHeight,  NODEKIND_DEBUGOFF, 80 )
				end if
		end if	
		'canvas.DrawImageIcon( _icons, clip.X, i*LineHeight,  10, 48 )
      
		Next
	End


	
Private
	
	Field _mx2Doc:Mx2Document

'	Field _icons:Image

	
	Method AddSpace( insert:string = "" )
		Local cursor := Cursor
		local line:int = Document.FindLine( cursor )
'		print (line + 1) + " " + cursor + "  "+ Document.EndOfLine( line )
		
		Local state := Document.LineState( Document.FindLine( cursor ) )
		If state <> -1 Return
		
		Insert( insert + " " )
	 end Method
  
  
  
	Method Capitalize( typing:Bool )
		Local cursor := Cursor
		
		Local state := Document.LineState( Document.FindLine( cursor ) )
		If state <> -1 Return
		
		Local text := Text
		Local start := cursor
		While start And IsIdent( text[start-1] )
			start -= 1
		Wend
		While start < text.Length And IsDigit( text[start] )
			start += 1
		Wend
		
		If start < text.Length 
			Local color := Document.Colors[start]
			If color <> COLOR_KEYWORD Return'color<>COLOR_IDENT Return
		Endif

		Local ident := text.Slice( start, cursor )
		If Not ident Return
		
		Local kw := Mx2Keywords[ident.ToLower()]
		If kw And kw <> ident Document.ReplaceText( Cursor-ident.Length, Cursor, kw )
	End


	
	Method OnKeyEvent( event:KeyEvent ) Override
		Select event.Type
			Case EventType.KeyDown
				Select event.Key
				'          Case Key.Equals, Key.Comma
				'           	 AddSpace()
			
					Case Key.Tab, Key.Enter
						Capitalize( True )
			
					Case Key.Up, Key.Down
						Capitalize( False )
			
				End
			
			Case EventType.KeyChar
				local _shift := event.Modifiers & Modifier.Shift
				if not _shift then
					Select event.Key
						Case Key.Equals
							AddSpace( "=" )
							return
						case Key.Comma
							AddSpace( "," )
							return
					end 
				end if
			
				If Not IsIdent( event.Text[0] )
					Capitalize( True )
				Endif
		End

		Super.OnKeyEvent( event )
	End



	Method OnMouseEvent( event:MouseEvent ) Override
		Select event.Type
			Case EventType.MouseDown
				local lft:int = ClipRect.Width - 50 + ClipRect.X
'				local rght:int = lft + 50
'				print event.Location.X+" "+lft+" "+rght
				
				if event.Location.X > lft Then
					'canvas.DrawRect( lft, ClipRect.Y, 50, ClipRect.Height )
					local lineDifference:float = float(Document.LineCount) / ClipRect.Height
					local line:float = ( (event.Location.Y - ClipRect.Y) * lineDifference )
					GotoLine( line )
'					local clipPos:int = ( (Height / Document.LineCount) * line )
'					ClipRect.Top = clipPos
					return
				end if
        
		End Select

		Super.OnMouseEvent( event )
		
	End



End




Class Mx2Document Extends Ted2Document


	Method New( path:String )
		Super.New( path )
	
		InitKeywords()
		
		_textDoc = New TextDocument
		_textDoc.TextChanged = Lambda()
			Dirty = True
		End
'		_textDoc.CursorMoved = Lambda()
'			print "line="+_textDoc.CursorLine+" column="+_textDoc.CursorColumn
'		end
		
'		_textDoc.CodeClicked = Lambda( line:int )
'			print "Line clicked="+line
'			_textDoc.Document.GotoLine( line )
'		end
		
		
		_textDoc.TextHighlighter = Mx2TextHighlighter
		
		_textDoc.LinesModified=Lambda( first:Int, removed:Int, inserted:Int )
			Local put := 0
			For Local get := 0 Until _errors.Length
				Local err := _errors[get]
				If err.line >= first
					If err.line < first + removed 
						err.removed = True
						Continue
					Endif
					err.line += (inserted - removed)
				Endif
				_errors[put] = err
				put += 1
			Next
			_errors.Resize( put )
		End

	
		_textView = New Mx2TextView( Self )
	End


	
	Property TextDocument:TextDocument()
		Return _textDoc
	End


	
	Property DebugLine:Int()
		Return _debugLine
	Setter( debugLine:Int )
		If debugLine=_debugLine Return
		
		_debugLine=debugLine
		If _debugLine=-1 Return

		Local scroller:=Cast<ScrollView>( _textView.Container )
		If Not scroller Return
		
		Local h:=_textView.LineHeight
		Local y:=_debugLine*h
		
		scroller.EnsureVisible( New Recti( 0,y,1,y+scroller.ContentClipRect.Height/3 ) )
	End


	
	Property Errors:Stack<Mx2Error>()
		Return _errors
	End


	
Private

	Field _textDoc:TextDocument
	Field _errors := New Stack<Mx2Error>
	Field _debugLine:Int=-1

	Field _textView:TextView



	
	Method OnLoad:Bool() Override
		Local text:=stringio.LoadString( Path )
		
		_textDoc.Text=text
		
		Return True
	End


	
	Method OnSave:Bool() Override
		Local text:=_textDoc.Text
		
		Return stringio.SaveString( text,Path )
	End


	
	Method OnCreateView:View() Override
		Return _textView
	End


	
End

