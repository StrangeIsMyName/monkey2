
Namespace ted2

Class HelpWindowView Extends DockingView

	Field PageClicked:Void( url:String )
	
	field _searchView:HelpView

	Method New()
		Style = Style.GetStyle( "mojo.HelpSystem" )

		_actionModule = New Action( "module" )
		_actionModule.Triggered = Lambda()
			ContentView = _moduleView
		End
		_moduleButton = New Buttonx( _actionModule, "", 40, 40)
		_moduleButton.ImageButton = 22

		_actionIndex = New Action( "index" )
		_actionIndex.Triggered = Lambda()
			ContentView = _indexView
		End
		_indexButton = New Buttonx( _actionIndex, "", 40, 40)
		_indexButton.ImageButton = 23

		_actionSearch = New Action( "search" )
		_actionSearch.Triggered = Lambda()
			ContentView = _searchView
		End
		_searchButton = New Buttonx( _actionSearch, "", 40, 40)
		_searchButton.ImageButton = 3

		Local findBar := New DockingView
		findBar.AddView( _moduleButton, "top" )
		findBar.AddView( _indexButton, "top" )
		findBar.AddView( _searchButton, "top" )

		_indexView = New HelpIndexView
		_indexView.PageClicked = Lambda( url:String )
			PageClicked( url )
		End

		_moduleView = New HelpModuleView
		_moduleView.PageClicked = Lambda( url:String )
			PageClicked( url )
		End

		_searchView = New HelpView
		_searchView.PageClicked = Lambda( url:String )
			PageClicked( url )
		End

		AddView( findBar, "left", 40, false )
		ContentView = _searchView

	End method


	method OnRender( canvas:Canvas ) Override
		canvas.Color = Style.DefaultColor
		canvas.DrawRect( 0, 0, 40, Height )
		canvas.Color = Style.BackgroundColor
		canvas.DrawRect( 40, 0, Width-40, Height )
	End method


		
Private
	Field _moduleButton:Buttonx
	Field _actionModule:Action
	
	Field _indexButton:Buttonx
	Field _actionIndex:Action

	Field _searchButton:Buttonx
	Field _actionSearch:Action

	field _indexView:HelpIndexView
	field _moduleView:HelpModuleView
End