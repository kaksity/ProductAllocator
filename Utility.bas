B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=8.5
@EndOfDesignText@

Sub Process_Globals
	
End Sub
Sub LoadConfigurationSetting() As Map
	Return File.ReadMap(File.DirAssets,"config.properties")
End Sub