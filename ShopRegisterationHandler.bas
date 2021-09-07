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
	
		Dim shopName As String = shopDataMap.Get("shop_name")
		Dim shopEmailAddress As String = shopDataMap.Get("shop_email_address")
		Dim shopPassword As String = shopDataMap.Get("shop_password")
		Dim shopConfirmPassword As String = shopDataMap.Get("shop_confirm_password")
	
		'Check for required Data
		If shopName.Trim = "" Then
			Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Shop Name is required","Add shop_name to the JSON body that is to be sent"),resp)
			Return
		Else if shopEmailAddress.Trim = "" Then
			Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Shop Email Address is required","Add shop_email_address to the JSON body that is to be sent"),resp)
			Return
		Else If shopPassword.Trim = "" Then
			Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Shop Password is required","Add shop_password to the JSON body that is to be sent"),resp)
			Return
		Else If shopConfirmPassword.Trim = "" Then
			Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Shop Confirm Password is required","Add shop_confirm_password to the JSON body that is to be sent"),resp)
			Return
		End If
	
		'Check for Invalid Data Format
		If shopPassword.Length < 8 Then
			Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Shop Password must be 8 or more characters","For security purposes, password are required to be long minimun of 8 characters"),resp)
			Return
		Else if shopPassword <> shopConfirmPassword Then
			Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Shop Password must match Shop Confirm Password is required","Shop password must the exactly the same as Shop confirm password"),resp)
			Return
		End If
	
		'Check if the Email Address Already Exist
		Dim sqlQuery As String
		Dim connection As SQL = Main.poolOfConnection.GetConnection
	
		sqlQuery = "SELECT id, email_address, password, status, is_deleted, created_at, updated_at, shop_id FROM shop_authentications WHERE email_address = ?"

		Dim queryResultSet As ResultSet = connection.ExecQuery2(sqlQuery,Array(shopEmailAddress))
	
		If queryResultSet.NextRow Then
			Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Shop Email Address already exist","A shop has been registered with this email address, change the email address and register again"),resp)
			connection.Close
			Return
		End If
	
		connection.BeginTransaction
		Try
			Dim shopId As JavaObject = Utility.GenerateUUID
			Dim shopLogoId As JavaObject = Utility.GenerateUUID
			Dim shopAuthenticationId As JavaObject = Utility.GenerateUUID
		
			sqlQuery = "INSERT INTO public.shops(id, full_name, phone_number, contact_address, is_deleted, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?);"
			connection.ExecNonQuery2(sqlQuery,Array(shopId,shopName.ToUpperCase,"","",False,Utility.GenerateDateTime,Utility.GenerateDateTime))
		
			sqlQuery = "INSERT INTO public.shop_authentications(id,shop_id,email_address, password, status, is_deleted, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?);"
			connection.ExecNonQuery2(sqlQuery,Array(shopAuthenticationId,shopId,shopEmailAddress,shopPassword,"pending",False,Utility.GenerateDateTime,Utility.GenerateDateTime))
		
			sqlQuery = "INSERT INTO public.shop_logos(id, shop_id, path, is_deleted, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?);"
			connection.ExecNonQuery2(sqlQuery,Array(shopLogoId,shopId,"",False,Utility.GenerateDateTime,Utility.GenerateDateTime))
			connection.TransactionSuccessful
			Utility.MapToResponse(201,Utility.ResponseWithOutData(201,True,"Shop was registered successfully","Now proceed to log into the shop account that was created"),resp)
			Return
		Catch
			connection.Rollback
			Utility.MapToResponse(500,Utility.GenerateErrorMap(500,"Something went wrong. Try again","Could not complete Operation"),resp)
			Return
		End Try
	Catch
		Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Check sent request body","The sent request body must have the representation {shop_name:string,shop_email_address:string,shop_password:string,shop_confirm_password:string}"),resp)
		Return
	End Try
End Sub