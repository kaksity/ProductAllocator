B4J=true
Group=Handler\Shop
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
	
		Dim shopEmailAddress As String = shopDataMap.Get("shop_email_address")
		Dim shopPassword As String = shopDataMap.Get("shop_password")
	
		'Check for required Data
		If shopEmailAddress.Trim = "" Then
			Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Shop Email Address is required","Add shop_email_address to the JSON body that is to be sent"),resp)
			Return
		Else If shopPassword.Trim = "" Then
			Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Shop Password is required","Add shop_password to the JSON body that is to be sent"),resp)
			Return
		End If
	
		'Check for Invalid Data Format
		If shopPassword.Length < 8 Then
			Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Invalid Shop Login Credentials","The login credentials that was sent is not valid, get the correct credentails and try again"),resp)
			Return
		End If
	
		'Check if the Email Address Already Exist
		Dim sqlQuery As String
		Dim connection As SQL = Main.poolOfConnection.GetConnection
	
		sqlQuery = "SELECT shop_id,email_address, password FROM shop_authentications WHERE email_address = ? AND is_deleted = false"

		Dim queryResultSet As ResultSet = connection.ExecQuery2(sqlQuery,Array(shopEmailAddress))
	
		If queryResultSet.NextRow == False Then
			Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Invalid Shop Login Credentials","The login credentials that was sent is not valid, get the correct credentails and try again"),resp)
			connection.Close
			Return
		End If
	
		Dim hashedPassword As String = queryResultSet.GetString("password")
		Dim shopLoginId As String = queryResultSet.getstring("shop_id")
		connection.Close
		
		Dim bcrypt As BCrypt
		bcrypt.Initialize("")

		If bcrypt.checkpw(shopPassword,hashedPassword) = False  Then
			Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Invalid Shop Login Credentials","The login credentials that was sent is not valid, get the correct credentails and try again"),resp)
			Return
		End If
		
		Utility.MapToResponse(200,Utility.ResponseWithData(200,True,"Login was successful","You have logged in successful. Fill free to explore the api",CreateMap("token":Utility.GenerateJWTToken(shopLoginId,Main.PrivateKey))),resp)
		Return
			
	Catch
		Log(LastException)
		Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Check sent request body","The sent request body must have the representation {shop_email_address:string,shop_password:string}"),resp)
		Return
	End Try
End Sub