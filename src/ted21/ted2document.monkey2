
Namespace ted2



Class Ted2Document



	Field DirtyChanged:Void()



	Method New( path:String )
	_path = path
	End


	
	Property Path:String()
		Return _path
	End


	
	Property Time:Long()
		Return _time
	End



	Property View:View()
		If Not _view then _view = OnCreateView()
		
		Return _view
	End


	
	Property Dirty:Bool()
		Return _dirty
	Setter( dirty:Bool)
		If dirty = _dirty then Return
		
		_dirty = dirty
		
		DirtyChanged()
	End
	


	Method Load:Bool()
		If Not OnLoad() Return False

		Dirty = False
		
		_time =  GetFileTime( _path )
		Print _time +" "+ _path
		
		Return True
	End


	
	Method Save:Bool()
		If Not _dirty Return True
		
		If Not OnSave() Return False
		
		Dirty = False

		Return True
	End


	
	Method Rename( path:String )
		_path = path
		
		Dirty = True
	End



	
	Method Close()
		OnClose()
	End


	
Protected



	Method OnLoad:Bool() Virtual
		Return False
	End


	
	Method OnSave:Bool() Virtual
		Return False
	End


	
	Method OnClose() Virtual
	End


	
	Method OnCreateView:View() Virtual
		Return Null
	End


	
Private

	Field _dirty:Bool
	Field _path:String
	Field _view:View
	Field _time:Long
	
End
