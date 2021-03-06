B4J=true
Group=Utility
ModulesStructureVersion=1
Type=StaticCode
Version=8.5
@EndOfDesignText@

Sub Process_Globals
	
End Sub
Sub LoadConfigurationSetting() As Map
	Return File.ReadMap(File.DirAssets,"config.properties")
End Sub

Sub GenerateErrorMap(statusCode As Int,message As String, description As String) As Map
	Return CreateMap("success":"false","status_code":statusCode,"message":message,"description":description)
End Sub

Sub MapToResponse(statusCode As Int, data As Map, resp As ServletResponse)
	Dim jGenerator As JSONGenerator
	
	jGenerator.Initialize(data)	
	
	resp.ContentType = "application/json"
	resp.Status = statusCode
	resp.Write(jGenerator.ToPrettyString(2))
End Sub

Sub ParseUUIDFromString(UUID As String) As JavaObject
	Dim UUIDJO As JavaObject
	UUIDJO.InitializeStatic("java.util.UUID")
	Return UUIDJO.RunMethodJO("fromString",Array(UUID))
End Sub

Sub GenerateDateTime As JavaObject
	Dim DateTimeJO As JavaObject
	
	DateTimeJO.InitializeStatic("java.time.LocalDateTime")
	
	Return DateTimeJO.RunMethodJO("now",Null)
End Sub

Sub IsUUID(UUID As String) As Boolean
	Try
		Dim UUIDJO As JavaObject
		UUIDJO.InitializeStatic("java.util.UUID")
		UUIDJO = UUIDJO.RunMethodJO("fromString",Array(UUID))
		Return True
	Catch
		Return False
	End Try
	
End Sub
Sub GenerateUUID As JavaObject
	Dim UUIDJO As JavaObject
	UUIDJO.InitializeStatic("java.util.UUID")
	Return UUIDJO.RunMethodJO("randomUUID",Null)
End Sub
Sub RequestToMap(reqStream As InputStream) As Map
	

	Dim jParser As JSONParser
	Dim txtReader As TextReader
	
	txtReader.Initialize(reqStream)
	
	jParser.Initialize(txtReader.ReadAll)
	
	Return jParser.NextObject
End Sub

Sub ResponseWithOutData(StatusCode As Int, Success As Boolean,Message As String, Description As String) As Map
	Return CreateMap("status_code":StatusCode,"success":Success,"message":Message,"description": Description)
End Sub
Sub ResponseWithData(StatusCode As Int, Success As Boolean,Message As String, Description As String,Data As Map) As Map
	Return CreateMap("status_code":StatusCode,"success":Success,"message":Message,"description": Description,"data":Data)
End Sub
Sub ResponseWithList(StatusCode As Int, Success As Boolean,Message As String, Description As String,Data As List) As Map
	Return CreateMap("status_code":StatusCode,"success":Success,"message":Message,"description": Description,"data":Data)
End Sub

Sub GenerateJWTToken(AgentID As String,PrivateKey As JavaObject) As String

	Dim IOJwtsJO As JavaObject
	
	IOJwtsJO.InitializeStatic("io.jsonwebtoken.Jwts")
	Return	$"Bearer ${IOJwtsJO.RunMethodJO("builder",Null).RunMethodJO("setSubject",Array(AgentID)).RunMethodJO("signWith",Array(PrivateKey)).RunMethod("compact",Null)}"$
End Sub

Sub ParseJWTToken(JWTToken As String , PublicKey As JavaObject) As string

	Dim IOJwtsJO As JavaObject
	IOJwtsJO.InitializeStatic("io.jsonwebtoken.Jwts")
	Return IOJwtsJO.RunMethodJO("parserBuilder",Null).RunMethodJO("setSigningKey",Array(PublicKey)).RunMethodJO("build",Null).RunMethodJO("parseClaimsJws",Array(JWTToken)).RunMethodJO("getBody",Null).RunMethod("getSubject",Null)
	
End Sub

Sub GetTokenStringFromHeader(token As String) As String
	Return token.SubString(7)
End Sub