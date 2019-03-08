B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=6.51
@EndOfDesignText@
'Static code module
Sub Process_Globals

End Sub

Sub getText(path As String) As String
    Dim sb As StringBuilder
	sb.Initialize
	Dim files As List
	Dim xmlstring As String
	xmlstring=XMLUtils.escapedText(File.ReadString(path,""),"source","xliff")

	files=getFilesList(xmlstring)
	
	For Each fileMap As Map In files
		Try
			Dim body As Map
			body=fileMap.Get("body")
		Catch
			Continue
		End Try
		
		For Each tu As List In getTransUnits(fileMap)
			sb.Append(tu.Get(0))
			sb.Append(CRLF)
		Next
	Next
	Dim result As String
	result=sb.ToString
	result=Regex.Replace("<.*?>",result,"")
	Return result
End Sub


Sub getTransUnits(fileMap As Map) As List
	Dim body As Map
	body=fileMap.Get("body")
	Dim tidyTransUnits As List
	tidyTransUnits.Initialize
	Dim groups As List
	groups.Initialize
	Dim transUnits As List
	If body.ContainsKey("group") Then
		groups=XMLUtils.GetElements(body,"group")
		Dim groupIndex As Int=0
		For Each group As Map In groups
			addFromGroups(group,transUnits,tidyTransUnits,groupIndex)
		Next
	Else
		transUnits=XMLUtils.GetElements(body,"trans-unit")
		addTransUnit(transUnits,tidyTransUnits,-1)
	End If
	
	Return tidyTransUnits
End Sub

Sub addFromGroups(group As Map,transUnits As List,tidyTransUnits As List,groupIndex As Int)
	If group.ContainsKey("trans-unit") Then
		transUnits=XMLUtils.GetElements(group,"trans-unit")
		addTransUnit(transUnits,tidyTransUnits,groupIndex)
		groupIndex=groupIndex+1
	Else If group.ContainsKey("group") Then
		Dim groups As List
		groups=XMLUtils.GetElements(group,"group")
		Dim groupIndex As Int=0
		For Each innergroup As Map In groups
			addFromGroups(innergroup,transUnits,tidyTransUnits,groupIndex)
			groupIndex=groupIndex+1
		Next
	End If
End Sub

Sub addTransUnit(transUnits As List,tidyTransUnits As List,groupIndex As Int)
	For Each transUnit As Map In transUnits
		'Log(transUnit)
		Dim attributes As Map
		attributes=transUnit.Get("Attributes")
		Dim id As String
		id=attributes.Get("id")
		Try
			Dim source As Map
			source=transUnit.Get("source")
			Dim text As String
			text=source.Get("Text")
		Catch
			'Log(LastException)
			Dim text As String
			text=transUnit.Get("source")
		End Try
		Dim segSource As Map
		segSource.Initialize
		Dim mrkList As List
		mrkList.Initialize
		If transUnit.ContainsKey("seg-source") Then
			segSource=transUnit.Get("seg-source")
			mrkList=XMLUtils.GetElements(segSource,"mrk")
		End If
		
		Dim oneTransUnit As List
		oneTransUnit.Initialize
		oneTransUnit.Add(text)
		oneTransUnit.Add(id)
		oneTransUnit.Add(mrkList)
		oneTransUnit.Add(groupIndex)
		tidyTransUnits.Add(oneTransUnit)
	Next
End Sub

Sub getFilesList(xmlstring As String) As List
	'Log("read")
	Dim xmlMap As Map
	xmlMap=XMLUtils.getXmlMap(xmlstring)
	'Log(xmlMap)
	Dim xliffMap As Map
	xliffMap=xmlMap.Get("xliff")
	Return XMLUtils.GetElements(xliffMap,"file")
End Sub