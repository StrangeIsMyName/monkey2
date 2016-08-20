
Namespace ted21

Class TxtTextView Extends TextView

	Method New( doc:TxtDocument )

		_doc=doc
		
		Document=_doc.TextDocument
		
		GutterWidth = 64
		CursorColor = New Color( 0,.5,1 )
		SelectionColor = New Color( 0.1,0.3,0.6, 1 )
	End
	
	Protected
	
	
'#rem	
	Method OnRender( canvas:Canvas ) Override
    
		Super.OnRender( canvas )

		'OK, VERY ugly! Draw gutter...

'		Local viewport := clip
'		viewport.min += RenderStyle.Bounds.min
'		canvas.Viewport = viewport
		Local clip:Recti
		clip.min.x=-Frame.min.x
		clip.min.y=-Frame.min.y
		clip.max.x=clip.min.x+GutterWidth
		clip.max.y=clip.min.y+ClipRect.Height
		
		Local viewport:=clip
		viewport.min+=RenderStyle.Bounds.min
		
		canvas.Viewport=viewport
				
		canvas.Color = New Color( .2, .2, .2 )
		canvas.DrawRect( 0, 0, viewport.Width-4, viewport.Height )

		canvas.Color = New Color( .05, .05, .05 )
		canvas.DrawLine( viewport.Width-4, 0, viewport.Width-4, viewport.Height )
		
		canvas.Viewport = Rect
		
		Local line0 := clip.Top/LineHeight
		Local line1 := (clip.Bottom-1)/LineHeight+1
		
'		canvas.Color = New Color( .35, .35, .35 )
'    If CursorRow = 0 Then
'      print "ok"
'    End if

		canvas.Color = Color.Grey
		Local ln:int

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
      
		Next
#rem		
		Local clip:Recti
		clip.min.x=-Frame.min.x
		clip.min.y=-Frame.min.y
		clip.max.x=clip.min.x+GutterWidth
		clip.max.y=clip.min.y+ClipRect.Height
		
		Local viewport:=clip
		viewport.min+=RenderStyle.Bounds.min
		
		canvas.Viewport=viewport
		
		canvas.Color = RenderStyle.BackgroundColor
		canvas.DrawRect( 0,0,viewport.Width,viewport.Height )
		
		canvas.Viewport=Rect
		
		Local line0:=clip.Top/LineHeight
		Local line1:=(clip.Bottom-1)/LineHeight+1
		
		canvas.Color=Color.Grey

		For Local i:=line0 Until line1
			canvas.DrawText( String( i+1 ),clip.X+GutterWidth-8,i*LineHeight,1,0 )
		Next
#end
	End
'#end
	
	Private
	
	Field _doc:TxtDocument
	
End

Class TxtDocument Extends Ted2Document

	Method New( path:String )
		Super.New( path )

		_textDoc = New TextDocument()
		
		_textDoc.TextChanged = Lambda()
			Dirty = True
		End
		
		_textView = New TxtTextView( Self )
	End
	
	Property TextDocument:TextDocument()
	
		Return _textDoc
	End
	
	Protected
	
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
	
	Private
	
	Field _textDoc:TextDocument
	Field _textView:TxtTextView
	
End

