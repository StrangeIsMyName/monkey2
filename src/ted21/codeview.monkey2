
Namespace ted2





Class CodeView Extends DockingView

	Field _docker := New DockingView



	Method New()
    _actionFind = New Action( "find" )
    _actionFind.Triggered = Lambda()
'      caller.CloseButtonChanged()
        print "close"
    End
   _findButton = New Buttonx( _actionFind, "", 40, 40)

		Local findBar := New DockingView
		findBar.AddView( New Label( "  Show:" ), "left" )
		findBar.AddView( _findButton, "right" )
'		findBar.ContentView = _findField


		_docker = New DockingView
		AddView( findBar, "top", 40, false )
		
		ContentView = _docker
		_docker.ContentView = null
	End
	
	
Private


	
  Field _findButton:Buttonx
  Field _actionFind:Action
	
	
	
end 