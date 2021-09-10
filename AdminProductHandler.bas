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
End Sub