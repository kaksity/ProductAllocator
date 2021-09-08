B4J=true
Group=Handler\Admin
ModulesStructureVersion=1
Type=Class
Version=8.5
@EndOfDesignText@
'Handler class
Sub Class_Globals
	
End Sub

Public Sub Initialize
	
End Sub

Sub Handle(req As ServletRequest, resp As ServletResponse)
	If req.Method <> "POST" Then
		Utility.MapToResponse(404,Utility.GenerateErrorMap(404,"Invalid routes","Only POST request is allowed here"),resp)
		Return
	End If
	
	Try
		Dim shopDataMap As Map = Utility.RequestToMap(req.InputStream)
	
		Dim adminEmailAddress As String = shopDataMap.Get("admin_email_address")
		Dim adminPassword As String = shopDataMap.Get("admin_password")
	
		'Check for required Data
		If adminEmailAddress.Trim = "" Then
			Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Admin Email Address is required","Add admin_email_address to the JSON body that is to be sent"),resp)
			Return
		Else If adminPassword.Trim = "" Then
			Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Admin Password is required","Add admin_password to the JSON body that is to be sent"),resp)
			Return
		End If
	
		'Check for Invalid Data Format
		If adminPassword.Length < 8 Then
			Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Invalid Admin Login Credentials","The login credentials that was sent is not valid, get the correct credentails and try again"),resp)
			Return
		End If
	
		'Check if the Email Address Already Exist
		Dim sqlQuery As String
		Dim connection As SQL = Main.poolOfConnection.GetConnection
	
		sqlQuery = "SELECT admin_id,email_address, password FROM admin_authentications WHERE email_address = ? AND is_deleted = false"

		Dim queryResultSet As ResultSet = connection.ExecQuery2(sqlQuery,Array(adminEmailAddress))
	
		If queryResultSet.NextRow == False Then
			Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Invalid Admin Login Credentials","The login credentials that was sent is not valid, get the correct credentails and try again"),resp)
			connection.Close
			Return
		End If
	
		Dim hashedPassword As String = queryResultSet.GetString("password")
		Dim shopLoginId As String = queryResultSet.getstring("admin_id")
		
		connection.Close
		
		Dim bcrypt As BCrypt
		bcrypt.Initialize("")

		If bcrypt.checkpw(adminPassword,hashedPassword) = False  Then
			Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Invalid Admin Login Credentials","The login credentials that was sent is not valid, get the correct credentails and try again"),resp)
			Return
		End If
		
		Utility.MapToResponse(200,Utility.ResponseWithData(200,True,"Login was successful","You have logged in successful. Fill free to explore the api",CreateMap("token":Utility.GenerateJWTToken(shopLoginId,Main.PrivateKey))),resp)
		Return
			
	Catch
		Log(LastException)
		Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Check sent request body","The sent request body must have the representation {admin_email_address:string,admin_password:string}"),resp)
		Return
	End Try
End Sub