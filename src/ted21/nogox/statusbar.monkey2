
Namespace nogox


Const STATUSBAR_NORMAL:Int = 0
Const STATUSBAR_DEBUG:Int = 1
Const STATUSBAR_RUNNING:Int = 2
Const STATUSBAR_BUILDING:Int = 3
Const STATUSBAR_ERROR:Int = 4

Const STATUSBARKIND_NONE:int = 0
Const STATUSBARKIND_TEXT:int = 1
Const STATUSBARKIND_IMAGE:int = 2



Class StatusBar Extends Button

	Field LeftTextClicked:Void()
	Field RightTextClicked:Void()

'	Property Display:Int()
'		Return _display
'	Setter( display:Int )
'    _display = display
'  End 

	Property DocumentKind:int()
		return _displayKind
	Setter( documentKind:int )
		_displayKind = documentKind
	end
	
	
	Method SetImage( width:int, height:int, zoom:float )
		_displayKind = STATUSBARKIND_IMAGE

		_width = width
		_height = height
		_zoom = zoom
	end
	
	
	Method SetCursor( line:int, column:int, chr:int )
		_displayKind = STATUSBARKIND_TEXT
		
		If not _errorOn Then _display = STATUSBAR_NORMAL
		
		_line = line
		_column = column
		_chr = chr
	end 
	
	
	
	Method SetText(txt:String = "")
		'print "SetText"
		If _display = STATUSBAR_DEBUG Then Return
		'print " ok"
		
		'_display = STATUSBAR_NORMAL
		If txt = "" Then
		  If not _errorOn Then _text = "Ready"
		else
		  _text = txt
		End if
	End 
		
		
	Method SetDebug(txt:String = "")
		_display = STATUSBAR_DEBUG
		_text = txt
	End 
		
		
	Method EndDebug()
		If _display <> STATUSBAR_DEBUG Then return
		'print "EndDebug"
		If not _errorOn Then _display = STATUSBAR_NORMAL
		_text = "Ready"
	End 
		
		
	Method SetNormal()
		'print "Debug"
		If _display = STATUSBAR_DEBUG Then Return
		'print " ok"
		
		If not _errorOn Then _display = STATUSBAR_NORMAL
	End 
		
	
	method ErrorOff()
		If not _errorOn Then Return
		
		_errorOn =  False
		_display = STATUSBAR_NORMAL
		_text = "Ready"
	End method
	
	
	Method SetError(line:int, txt:String = "")
		'print "Error"
		If _display = STATUSBAR_DEBUG Then Return
		'print " ok"
		
		_errorOn = true
		_display = STATUSBAR_ERROR
		_text = txt
		_errorLine = line
	End 
		
		
		
	Method SetRunning()
		'print "Running"
		If _display = STATUSBAR_DEBUG Then Return
		'print " ok"
		
		_display = STATUSBAR_RUNNING
	End 
		
		
	Method SetBuilding(ps:float, txt:string)
		'print "Building"
		If _display = STATUSBAR_DEBUG Then Return
		'print " ok"
		
		_text = txt
		_display = STATUSBAR_BUILDING
		_buildpos = ps / 11.0
	End


	Method New()
		Layout="fill"
		Style=Style.GetStyle( "mojo.StatusBar" )
	End


	Method OnRender( canvas:Canvas ) Override
'		If Icon
'			canvas.DrawImage( Icon, 4,4,0, 1.5,1.5 )
'		Endif

'    Local width := _current.View.Container.Frame.Width
		Local tx:Int = 10
		Local ty:Int = 6

		Select _display
			Case STATUSBAR_NORMAL
				canvas.Color = New Color( 0.1,0.3,0.6, 1 )
				canvas.DrawRect( 0,0, Width, Height )
				canvas.Color = Color.White
				canvas.DrawText( _text, tx, ty )
		
				select _displayKind
					case STATUSBARKIND_NONE
					case STATUSBARKIND_TEXT
						canvas.DrawText( "Line  "+_line, Width-250, ty)
						canvas.DrawText( "Column  "+_column, Width-170, ty)
						canvas.DrawText( "Chr  "+_chr, Width-70, ty)
						
					case STATUSBARKIND_IMAGE
						canvas.DrawText( "Width  "+_width, Width-290, ty)
						canvas.DrawText( "Height  "+_height, Width-190, ty)
						canvas.DrawText( "Zoom  "+_zoom+"%", Width-90, ty)
				end select
					
			Case STATUSBAR_DEBUG
				canvas.Color = New Color( .7,.3,0, 1 )
				canvas.DrawRect( 0,0, Width, Height )
				
				canvas.Color = Color.White
				canvas.DrawText( "Debug   " + _text, tx, ty )
				
			Case STATUSBAR_RUNNING
				canvas.Color = New Color( .1,.5, 0.1, 1 )
				canvas.DrawRect( 0,0, Width, Height )
				canvas.Color = Color.White
				canvas.DrawText( "Running   ", tx, ty )
				
			Case STATUSBAR_BUILDING
				canvas.Color = New Color( 0.1,0.1,0.6, 1 )
				canvas.DrawRect( 0,0, Width, Height )
				
				canvas.Color = New Color( 0.1,0.5,0.1, 1 )
				canvas.DrawRect( 0,0, Width * _buildpos, Height )
				
				canvas.Color = Color.White
				canvas.DrawText( "Building   "+int(_buildpos * 100)+"%     "+_text, tx, ty )
				
			Case STATUSBAR_ERROR
				canvas.Color = New Color( .4,.0,0, 1 )
				canvas.DrawRect( 0,0, Width, Height )
				
				canvas.Color = Color.White
				canvas.DrawText( _text, tx, ty )
		End Select
				
				
				
				'    If _hover
				'      canvas.Color = New Color( 1,1,1, 0.5 )
				'      canvas.DrawLine ( 0,1, 0, 26 )
				'      canvas.DrawLine ( 0,3, 29, 3 )
				'      canvas.DrawLine ( 0,26, 29, 26 )
				'      canvas.DrawLine ( 29,3, 29, 27 )
				'    End if
	End

	Method OnMouseEvent( event:MouseEvent ) Override
		Select event.Type
		Case EventType.MouseDown
			If event.Location.X > Width-250 Then
				RightTextClicked()
			Else	
				LeftTextClicked()
			End if
'			_drag=True
'			_org=event.Location
		Case EventType.MouseUp
'			_drag=False
		Case EventType.MouseEnter
'			_hover=True
		Case EventType.MouseLeave
'			_hover=False
		Case EventType.MouseMove
'			If _drag Dragged( event.Location-_org )
		End
	End method

'	Method AddAction( action:Action )
'		Local button:=New ToolButton( action )
'		AddView( button,"left",0 )
'	End

	
	
'	Method AddAction:Action( label:String="",icon:Image=Null )
'		Local action:=New Action( label,icon )
'		AddAction( action )
'		Return action
'	End


  Field _display:Int = STATUSBAR_NORMAL
  Field _text:String = "Ready"
  Field _buildpos:float
  
  field _line:Int = 0
  field _column:int = 0
  field _chr:int = 0
  
  field _errorLine:int = 0
  field _errorOn:bool = false
  
  field _width:int = 0
  field _height:int = 0
  field _zoom:float = 1
  
  field _displayKind:int = STATUSBARKIND_NONE
  
End
