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
	If req.Method <> "GET" And req.Method <> "POST" And req.Method <> "DELETE" Then 
		Utility.MapToResponse(404,Utility.GenerateErrorMap(404,"Only GET POST AND DELETE methods are allowed on this endpoint",""),resp)
		Return
	End If
	
	If req.Method = "DELETE" Then
		Dim idRequestParameter As String = req.GetParameter("product-id")
		
		If idRequestParameter.Trim = "" Then
			Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Product Id is required","Since we are requesting to delete a product, product-id has to be added to the request url"),resp)
			Return
		End If
		If Utility.IsUUID(idRequestParameter) = False Then
			Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Product Id is invalid","Product Id must be a valid UUID"),resp)
			Return
		End If
		
		Try
			'Check if the product exists
			Dim connection As SQL = Main.poolOfConnection.GetConnection
			Dim sqlQuery As String
			Dim queryResultSet As ResultSet
			Dim productIdObj As JavaObject = Utility.ParseUUIDFromString(idRequestParameter)
			
			sqlQuery = "SELECT id FROM products WHERE id = ? AND is_deleted=false"
			
			queryResultSet = connection.ExecQuery2(sqlQuery,Array(productIdObj))
			
			If queryResultSet.NextRow = False Then
				connection.Close
				Utility.MapToResponse(404,Utility.GenerateErrorMap(404,"Product record was not found","Check the product id as this product id does not exist"),resp)
				Return
			End If
			
			sqlQuery = "UPDATE products SET is_deleted=true WHERE id = ? AND is_deleted = false"
			connection.ExecNonQuery2(sqlQuery, Array(productIdObj))
			
			connection.Close
			Utility.MapToResponse(200,Utility.GenerateErrorMap(200,"Product record was deleted successfully","Product with this id no longer exist in the database"),resp)
			Return
			
		Catch
			connection.Close
			Utility.MapToResponse(500,Utility.GenerateErrorMap(500,"Something went wrong. Try again","Could not complete Operation"),resp)
			Return
		End Try

	End If
	If req.Method = "POST" Then
		Try
			Dim requestBodyMap As Map = Utility.RequestToMap(req.InputStream)
			
			Dim productName As String = requestBodyMap.Get("product_name")
			Dim productPrice As Float = requestBodyMap.Get("product_price")
			
			
			If productName.Trim = "" Then
				Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Product Name is required","Add product_name to the JSON body that is to be sent"),resp)
				Return
			End If
			
			If productPrice <= 0 Then
				Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Product Price must be greater than 0","Product Price is required and must be a number that is greater than 0"),resp)
				Return
			End If
			
			Dim connection As SQL = Main.poolOfConnection.GetConnection
			Dim sqlQuery As String
			
			Dim productId As JavaObject = Utility.GenerateUUID
			Dim adminId As String = Utility.ParseJWTToken(Utility.GetTokenStringFromHeader(req.GetHeader("authorization")),Main.publicKey)
			Dim adminIdObj As JavaObject = Utility.ParseUUIDFromString(adminId)
			
			Try
				sqlQuery = "INSERT INTO public.products(id, admin_id, name, price, is_deleted, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?)"
				connection.ExecNonQuery2(sqlQuery,Array(productId,adminIdObj,productName.ToUpperCase,productPrice,False,Utility.GenerateDateTime,Utility.GenerateDateTime))
				connection.Close()
				
				Utility.MapToResponse(200,Utility.ResponseWithOutData(200,True,"Product record was created successfully","you can get created products records"),resp)
				Return
			Catch
				connection.Close
				Utility.MapToResponse(500,Utility.GenerateErrorMap(500,"Something went wrong. Try again","Could not complete Operation"),resp)
				Return
			End Try
			
		Catch
			Log(LastException)
			Utility.MapToResponse(400,Utility.GenerateErrorMap(400,"Check sent request body","The sent request body must have the representation {product_name:string,product_price:number}"),resp)
			Return
		End Try
	End If
	If req.Method = "GET" Then
		Dim typeRequestParameter As String  = req.GetParameter("type")
		
		
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
			
			sqlQuery = "SELECT pdt.id,adm.full_name, pdt.name,pdt.price FROM products pdt INNER JOIN admins adm ON pdt.admin_id = adm.id WHERE pdt.is_deleted=false ORDER BY pdt.created_at ASC"
			
			Try
				queryResultSet = connection.ExecQuery(sqlQuery)
			
				Do While queryResultSet.NextRow
					listOfData.Add(CreateMap("product_id":queryResultSet.GetString("id"),"product_name":queryResultSet.GetString("name"),"product_price":queryResultSet.GetLong("price"),"added_by":queryResultSet.GetString("full_name")))
				Loop

				connection.Close
				Utility.MapToResponse(200,Utility.ResponseWithList(200,True,"Retrived list of products","Admin can now update this record",listOfData),resp)
				Return
			Catch
				Utility.MapToResponse(500,Utility.GenerateErrorMap(500,"Something went wrong. Try again","Could not complete Operation"),resp)
				Return
			End Try
		End If
	End If
End Sub