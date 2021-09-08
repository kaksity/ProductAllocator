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
	
	If req.Method = "GET" Then
		
		Try
			
			Dim shop As String = Utility.ParseJWTToken(Utility.GetTokenStringFromHeader(req.GetHeader("authorization")),Main.publicKey)
			Dim shopObj As JavaObject = Utility.ParseUUIDFromString(shop)
			Dim connection As SQL = Main.poolOfConnection.GetConnection
			Dim sqlQuery As String
		
			Dim queryResultSet As ResultSet
		
			sqlQuery = "SELECT shp.full_name, shp.phone_number, shp.contact_address,shpl.path,shpa.email_address, shpa.status  FROM shops shp INNER JOIN shop_logos shpl ON shp.id = shpl.shop_id INNER JOIN shop_authentications shpa ON shp.id = shpa.shop_id WHERE shp.is_deleted=false AND shp.id = ?"
		
			queryResultSet = connection.ExecQuery2(sqlQuery,Array(shopObj))
			queryResultSet.NextRow
			Dim shopDataMap As Map = CreateMap("shop_name":queryResultSet.GetString("full_name"),"shop_phone_number":queryResultSet.GetString("phone_number"),"shop_contact_address":queryResultSet.GetString("contact_address"),"shop_logo_path":queryResultSet.GetString("path"),"shop_email_address":queryResultSet.GetString("email_address"),"shop_status":queryResultSet.GetString("status"))
			connection.Close
			Utility.MapToResponse(200,Utility.ResponseWithData(200,True,"Retrived Shop Details","Shop can update this data",shopDataMap),resp)
			Return
		Catch
			Log(LastException)
			connection.Close
			Utility.MapToResponse(500,Utility.GenerateErrorMap(500,"Something went wrong. Try again","Could not complete Operation"),resp)
			Return
		End Try
	Else if req.Method = "PUT" Then
		Try
			Dim shop As String = Utility.ParseJWTToken(Utility.GetTokenStringFromHeader(req.GetHeader("authorization")),Main.publicKey)
			Dim shopObj As JavaObject = Utility.ParseUUIDFromString(shop)
			Dim shopDataMap As Map = Utility.RequestToMap(req.InputStream)
			Dim shopName As String = shopDataMap.Get("shop_name")
			Dim shopContactAddress As String = shopDataMap.Get("shop_contact_address")
			Dim shopPhoneNumber As String = shopDataMap.Get("shop_phone_number")
	
			'Check for required Data
			If shopName.Trim = "" Then
				Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Shop Name is required","Add shop_name to the JSON body that is to be sent"),resp)
				Return
			Else if shopContactAddress.Trim = "" Then
				Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Shop Contact Address is required","Add shop_contact_address to the JSON body that is to be sent"),resp)
				Return
			Else If shopPhoneNumber.Trim = "" Then
				Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Shop Phone Number is required","Add shop_phone_number to the JSON body that is to be sent"),resp)
				Return
			End If
			
			If IsNumber(shopPhoneNumber) = False Or shopPhoneNumber.Length <> 11 Then
				Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Shop Phone Number must be numeric and 11 digits","Phone Number must be numeric and 11 digits"),resp)
				Return
			End If
			
			Dim connection As SQL = Main.poolOfConnection.GetConnection
			Dim sqlQuery As String 
			Try
				sqlQuery = "UPDATE shops SET full_name = ?, phone_number = ?, contact_address = ? WHERE is_deleted=false and id = ?"
				connection.ExecNonQuery2(sqlQuery,Array(shopName.ToUpperCase,shopPhoneNumber,shopContactAddress.ToUpperCase,shopObj))	
				connection.Close
				Utility.MapToResponse(200,Utility.ResponseWithOutData(200,True,"Shop record was updated successfully","you can get updated records"),resp)
				Return
			Catch
				Log(LastException)
				connection.Close
				Utility.MapToResponse(500,Utility.GenerateErrorMap(500,"Something went wrong. Try again","Could not complete Operation"),resp)
				Return
			End Try
		Catch
			Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Check sent request body","The sent request body must have the representation {shop_name:string,shop_phone_number:string,shop_contact_address:string}"),resp)
			Return
		End Try
	End If
	
End Sub