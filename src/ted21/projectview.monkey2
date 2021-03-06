
Namespace ted21





Class ProjectView Extends ScrollView
	
	field _currentProjectDir:string = ""

	Method New()
		_docker = New DockingView
		
		ContentView = _docker
		
		_docker.ContentView = New TreeView
	End



	Method RefreshProject()
		if _currentProjectDir = "" then return

		CloseProject( _currentProjectDir )
		OpenProject( _currentProjectDir )
	end Method
	
	
	
	Method OpenProject:Bool( dir:String )
		dir = StripSlashes( dir )
		
		If _projects[dir] then Return False
		
		If GetFileType( dir ) <> FileType.Directory Then Return False
		
		_currentProjectDir = dir
	
		Local browser := New FileBrowser( dir )
		
		browser.FileClicked = Lambda( path:String, event:MouseEvent )
		
			Select event.Button
				Case MouseButton.Left
				
					If GetFileType( path ) = FileType.File
					
						New Fiber( Lambda()
						
							MainWindow.OpenDocument( path, True )
							MainWindow.SaveState()
							
						End )
						
					Endif
				
				Case MouseButton.Right
				
					#rem Laters...!
					Select GetFileType( path )
					Case FileType.Directory
					
						Local menu:=New Menu( path )
						menu.AddAction( "New file" ).Triggered=Lambda()
							Local file:=MainWindow.RequestFile( "New file","",True,path )
							Print "File="+file
						End
						
						menu.Open( event.Location,browser,Null )
					
					End
					#end
					
			End
		End
		
		browser.RootNode.Label = StripDir( dir )+" ("+dir+")"
		browser.RootNode.Expanded = true
		
		_docker.AddView( browser, "top" )
		
		_projects[dir] = browser
		
		Return True
	End



	
	Method CloseProject( dir:String )
		dir = StripSlashes( dir )
		
		Local view := _projects[dir]
		If Not view Then Return
		
		_docker.RemoveView( view )
		
		_projects.Remove( dir )
	End


	
Private
	
	Field _docker := New DockingView
	Field _projects := New StringMap<FileBrowser>

End


