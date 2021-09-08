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
			Dim shopDataMap As Map = CreateMap("shop_full_name":queryResultSet.GetString("full_name"),"shop_phone_number":queryResultSet.GetString("phone_number"),"shop_contact_address":queryResultSet.GetString("contact_address"),"shop_logo_path":queryResultSet.GetString("path"),"shop_email_address":queryResultSet.GetString("email_address"),"shop_status":queryResultSet.GetString("status"))
			connection.Close
			Utility.MapToResponse(200,Utility.ResponseWithData(200,True,"Retrived Shop Details","Shop can update this data",shopDataMap),resp)
			Return
		Catch
			Log(LastException)
			connection.Close
			Utility.MapToResponse(500,Utility.GenerateErrorMap(500,"Something went wrong. Try again","Could not complete Operation"),resp)
			Return
		End Try
	End If
	
End Sub