
Namespace nogox



Class ToolButton Extends Button

	Method New( action:Action )
		Super.New( action )
		Style=Style.GetStyle( "mojo.ToolButton" )
	End


	Method OnRender( canvas:Canvas ) Override
		If Icon
			canvas.DrawImage( Icon, 4,4,0, 1.5,1.5 )
		Endif

'    If _hover
'      canvas.Color = New Color( 1,1,1, 0.5 )
'      canvas.DrawLine ( 0,1, 0, 26)
'      canvas.DrawLine ( 0,3, 29, 3)
'      canvas.DrawLine ( 0,26, 29, 26)
'      canvas.DrawLine ( 29,3, 29, 27)
'    End if
  End



	Method OnMeasure:Vec2i() Override
		Local size := New Vec2i
		
		size.x = 30
		size.y = 30
		
		Return size
	End
	
End



Class ToolBar Extends DockingView

	Method New()
		Layout = "fill"
		Style = Style.GetStyle( "mojo.ToolBar" )
	End



	Method AddAction( action:Action )
		Local button := New ToolButton( action )
		AddView( button, "left", 0 )
	End

	
	
	Method AddAction:Action( label:String="", icon:Image=Null )
		Local action := New Action( label, icon )
		AddAction( action )
		Return action
	End

End
