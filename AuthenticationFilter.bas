B4J=true
Group=Filters
ModulesStructureVersion=1
Type=Class
Version=8.5
@EndOfDesignText@
'Filter class
Sub Class_Globals
	
End Sub

Public Sub Initialize
	
End Sub

'Return True to allow the request to proceed.
Public Sub Filter(req As ServletRequest, resp As ServletResponse) As Boolean
	
	Try
		'Check if the Authentication has been added to the request
		If req.GetHeader("authorization") = "" Then
			Utility.MapToResponse(401, Utility.GenerateErrorMap(401,"Access Denied","Authentication token has to be added to the authorization header. Sample Bearer xxxxxxxxxx"),resp)
			Return False
		End If
		
		Dim authenticationToken As String = req.GetHeader("authorization")
		
		If authenticationToken.Contains("Bearer ") = False Then 
			Utility.MapToResponse(401, Utility.GenerateErrorMap(401,"Authentication token has been tampered with","Authentication given is a Bearer authentication token. Added Bearer to the token, Login to get a new token. Sample Bearer xxxxxxxxxx"),resp)
			Return False
		End If
		Utility.ParseJWTToken(authenticationToken.SubString(7),Main.publicKey)
		Return True
	Catch
		Log(LastException)
		Utility.MapToResponse(401, Utility.GenerateErrorMap(401,"Authentication token has been tampered with","Authentication token has been tampered with, Login to get a new token. Sample Bearer xxxxxxxxxx"),resp)
		Return False
	End Try
	
End Sub