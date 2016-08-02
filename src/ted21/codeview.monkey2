
Namespace ted2




Class CodeView Extends DockingView

	Field MethodClicked:Void( )
	Field FunctionClicked:Void( )
	Field FieldClicked:Void( )
	Field PropertyClicked:Void( )
	Field LambdaClicked:Void( )

	Field _docker := New CodeTreeView


	Property MethodState:Bool()
		Return _methodButton.Selected
	Setter( methodButton:bool )
		_methodButton.Selected = methodButton
	End



	Property LambdaState:Bool()
		Return _lambdaButton.Selected
	Setter( lambdaButton:bool )
		_lambdaButton.Selected = lambdaButton
	End


	Property FunctionState:Bool()
		Return _functionButton.Selected
	Setter( functionButton:bool )
		_functionButton.Selected = functionButton
	End


	Property FieldState:Bool()
		Return _fieldButton.Selected
	Setter( fieldButton:bool )
		_fieldButton.Selected = fieldButton
	End


	Property PropertyState:Bool()
		Return _propertyButton.Selected
	Setter( propertyButton:bool )
		_propertyButton.Selected = propertyButton
	End


	Method New()
    _actionMethod = New Action( "method" )
    _actionMethod.Triggered = Lambda()
'			if _docker then
				_methodButton.Selected = not _methodButton.Selected
				MethodClicked()
'			end if
    End
   _methodButton = New Buttonx( _actionMethod, "", 40, 40)
   _methodButton.Selected = true
   _methodButton.ImageButton = 12'NODEKIND_METHOD
   

    _actionFunction = New Action( "function" )
    _actionFunction.Triggered = Lambda()
'			if _docker then
				_functionButton.Selected = not _functionButton.Selected
				FunctionClicked()
'        print "function"
'			end if
    End
   _functionButton = New Buttonx( _actionFunction, "", 40, 40)
   _functionButton.Selected = true
   _functionButton.ImageButton = 13'NODEKIND_FUNCTION

    _actionField = New Action( "field" )
    _actionField.Triggered = Lambda()
'			if _docker then
				_fieldButton.Selected = not _fieldButton.Selected
				FieldClicked()
'        print "field"
'			end if
    End
   _fieldButton = New Buttonx( _actionField, "", 40, 40)
   _fieldButton.Selected = true
   _fieldButton.ImageButton = 14'NODEKIND_FIELD

    _actionProperty = New Action( "property" )
    _actionProperty.Triggered = Lambda()
'			if _docker then
				_propertyButton.Selected = not _propertyButton.Selected
				PropertyClicked()
'        print "property"
'			end if
    End
   _propertyButton = New Buttonx( _actionProperty, "", 40, 40)
   _propertyButton.Selected = true
   _propertyButton.ImageButton = 15'NODEKIND_PROPERTY

    _actionLambda = New Action( "lambda" )
    _actionLambda.Triggered = Lambda()
				_lambdaButton.Selected = not _lambdaButton.Selected
				LambdaClicked()
    End
   _lambdaButton = New Buttonx( _actionLambda, "", 40, 40)
   _lambdaButton.Selected = true
   _lambdaButton.ImageButton = 11'NODEKIND_LAMBDA


		Local findBar := New DockingView
'		findBar.AddView( New Label( "  Show:" ), "left" )
		findBar.AddView( _lambdaButton, "right" )
		findBar.AddView( _propertyButton, "right" )
		findBar.AddView( _fieldButton, "right" )
		findBar.AddView( _functionButton, "right" )
		findBar.AddView( _methodButton, "right" )
'		findBar.ContentView = _findField


		_docker = null
		AddView( findBar, "top", 40, false )
		
		ContentView = _docker
		'_docker.ContentView = null
	End
	
	
Private

  Field _fieldButton:Buttonx
  Field _actionField:Action

  Field _lambdaButton:Buttonx
  Field _actionLambda:Action

  Field _propertyButton:Buttonx
  Field _actionProperty:Action
	
  Field _methodButton:Buttonx
  Field _actionMethod:Action

  Field _functionButton:Buttonx
  Field _actionFunction:Action
end


