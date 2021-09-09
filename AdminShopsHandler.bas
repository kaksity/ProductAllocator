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
	If req.Method = "GET" Then
		
		Dim typeRequestParameter As String  = req.GetParameter("type")
		Dim idRequestParameter As String = req.GetParameter("shop-id")
		
		'Check if the type is given and is either list or details
		If typeRequestParameter = "" Or (typeRequestParameter <> "details" And typeRequestParameter <> "list") Then
			Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Specify the type of request which must be details or list","type has to be added to the request url, and the corresponding value must be list or details"),resp)
			Return
		End If
		
		If typeRequestParameter = "list" Then
			Dim connection As SQL = Main.poolOfConnection.GetConnection
			Dim sqlQuery As String
			Dim listOfData As List
			
			Dim queryResultSet As ResultSet
		
		
			listOfData.Initialize
			
			sqlQuery = "SELECT shp.id,shp.full_name, shp.phone_number, shp.contact_address,shpl.path,shpa.email_address, shpa.status  FROM shops shp INNER JOIN shop_logos shpl ON shp.id = shpl.shop_id INNER JOIN shop_authentications shpa ON shp.id = shpa.shop_id WHERE shp.is_deleted=false ORDER BY shp.created_at ASC"
			Try
				queryResultSet = connection.ExecQuery(sqlQuery)
			
				Do While queryResultSet.NextRow
					listOfData.Add(CreateMap("shop_id":queryResultSet.GetString("id"),"shop_name":queryResultSet.GetString("full_name"),"shop_phone_number":queryResultSet.GetString("phone_number"),"shop_contact_address":queryResultSet.GetString("contact_address"),"shop_logo_path":queryResultSet.GetString("path"),"shop_email_address":queryResultSet.GetString("email_address"),"shop_status":queryResultSet.GetString("status")))
				Loop

				connection.Close
				Utility.MapToResponse(200,Utility.ResponseWithList(200,True,"Retrived list of shop records","Admin can now update this record",listOfData),resp)
				Return
			Catch
				Utility.MapToResponse(500,Utility.GenerateErrorMap(500,"Something went wrong. Try again","Could not complete Operation"),resp)
				Return
			End Try
		End If
		
		If typeRequestParameter = "details" Then
			If idRequestParameter.Trim = "" Then
				Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Shop Id is required","Since we are request for a shop details, shop-id has to be added to the request url"),resp)
				Return
			End If
			If Utility.IsUUID(idRequestParameter) = False Then
				Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Shop Id is invalid","Shop Id must be a valid UUID"),resp)
				Return
			End If
			
			Try
				Dim shopObj As JavaObject = Utility.ParseUUIDFromString(idRequestParameter)
				Dim connection As SQL = Main.poolOfConnection.GetConnection
				Dim sqlQuery As String
		
				Dim queryResultSet As ResultSet
		
				sqlQuery = "SELECT shp.full_name, shp.phone_number, shp.contact_address,shpl.path,shpa.email_address, shpa.status  FROM shops shp INNER JOIN shop_logos shpl ON shp.id = shpl.shop_id INNER JOIN shop_authentications shpa ON shp.id = shpa.shop_id WHERE shp.is_deleted=false AND shp.id = ?"
		
				queryResultSet = connection.ExecQuery2(sqlQuery,Array(shopObj))
				queryResultSet.NextRow
				Dim shopDataMap As Map = CreateMap("shop_name":queryResultSet.GetString("full_name"),"shop_phone_number":queryResultSet.GetString("phone_number"),"shop_contact_address":queryResultSet.GetString("contact_address"),"shop_logo_path":queryResultSet.GetString("path"),"shop_email_address":queryResultSet.GetString("email_address"),"shop_status":queryResultSet.GetString("status"))
				connection.Close
				Utility.MapToResponse(200,Utility.ResponseWithData(200,True,"Retrived Shop Details","Admin can now update this record",shopDataMap),resp)
				Return
			Catch
				Utility.MapToResponse(500,Utility.GenerateErrorMap(500,"Something went wrong. Try again","Could not complete Operation"),resp)
				Return
			End Try
			
		End If
	End If
End Sub