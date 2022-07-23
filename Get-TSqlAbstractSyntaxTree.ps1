<#
.SYNOPSIS
Get-TSqlAbstractSyntaxTree is a function that generates an XML representation of the abstract syntax tree for a T-SQL script.

.DESCRIPTION
The function uses the Microsoft T-SQL ScriptDOM library to parse T-SQL scripts and generate an XML representation of the abstract syntax tree
that can be used for further code analysis and checking.

.PARAMETER SqlServerVersion
Specifies which SQL Server version to use the parser from.  If you select 2012 and you script contains function only available in a later
version of SQL Server a parse error will be generated.

.PARAMETER ScriptDomLocation
The path to the location of the Microsoft.SqlServer.TransactSql.ScriptDom.dll file.

.PARAMETER Script
The T-SQL script to generate the XML abstract syntax tree for.

.PARAMETER PositionalProperties
Boolean flag to indicate if the position properties are included in the XML output, i.e. line and column numbers.  If not needed and to reduce
the size of the XML set to false, otherwise set to true to include.  Default is false.

.EXAMPLE

    . $PSScriptRoot\Get-TSqlAbstractSyntaxTree.ps1
    [xml]$result = Get-TSqlAbstractSyntaxTree -SqlServerVersion 2017 -ScriptDomLocation 'C:\Temp\' -Script $script -PositionalProperties $false

add -Debug at the end to see additional debug information when running.

.NOTES
General notes
#>
function Get-TSqlAbstractSyntaxTree {
    [cmdletbinding()]
    param (
        [Parameter()]
        [ValidateSet(2012,2014,2016,2017,2019)]
        [int]$SqlServerVersion=2019,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ScriptDomLocation=$(throw 'ScriptDomLocation is mandatory, please provide a value.'),

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]]$Script=$(throw 'Script is mandatory, please provide a value.'),

        [Parameter()]
        [bool]$PositionalProperties = $false
    )

    function Get-TSqlFragmentNode{
        [OutputType([System.Xml.XmlNode])]
        param (
            [System.Xml.XmlDocument]$Doc,
            [object]$Fragment,
            [string]$PropertyName,
            [bool]$PositionalProperties = $true,
            [string]$ParserName
        )
        try {
            [System.Xml.XmlNode]$node = $null
            $positionalPropertyNames = 'StartOffset','FragmentLength','StartLine','StartColumn','FirstTokenIndex','LastTokenIndex'

            $typeName = $Fragment.GetType().Name
            $baseTypeName = $Fragment.GetType().BaseType.Name

            if ( $baseTypeName -ne 'Enum' ) {
                if ( $PropertyName.Length -gt 0 ) {
                    $node = $Doc.CreateNode("element",$PropertyName,$null)
                    $node.SetAttribute("Type",$typeName) | Out-Null
                }
                else {
                    $node = $Doc.CreateNode("element",$typeName,$null)
                }

                $node.SetAttribute("BaseType",$baseTypeName) | Out-Null
            }
            else {
                return
            }

            foreach ( $prop in $Fragment.GetType().GetProperties() ) {
                if ( $prop.GetIndexParameters().Length -ne 0 ) { 
                    continue 
                }

                $propTypeName = $prop.PropertyType.Name
                $propBaseTypeName = $prop.PropertyType.BaseType.Name

                if ( $propBaseTypeName -eq 'ValueType') {
                    if($PositionalProperties -eq $true -Or $positionalPropertyNames -notcontains $prop.name ) {
                        $node.SetAttribute($prop.Name,$prop.GetValue($Fragment,$null).ToString()) | Out-Null
                    }
                    continue
                }

                if ( $propTypeName -like 'IList*' ) {
                    if ( $prop.Name -ne 'ScriptTokenStream' ) {
                        $list = $prop.GetValue($Fragment,$null)

                        if ( $list.Count -gt 0 ) {
                            $listNode = $Doc.CreateNode("element",$prop.Name,$null)
                            $listNode.SetAttribute('Type',$propTypeName) | Out-Null
                            $listNode.SetAttribute("Count",$list.Count.ToString()) | Out-Null

                            foreach ( $listItem in $list) {
                                $listItemNode = Get-TSqlFragmentNode -Doc $Doc -Fragment $listItem -PositionalProperties $PositionalProperties
                                $listNode.AppendChild($listItemNode) | Out-Null
                            }

                            $node.AppendChild($listNode) | Out-Null
                        }
                    }
                }
                else {
                    $obj = $prop.GetValue($Fragment, $null)

                    if ( $null -ne $obj ) {
                        $objTypeName = $obj.GetType().Name
                        $objBaseTypeName =$obj.GetType().BaseType.Name

                        if ( $obj.GetType() -eq [string] ) {
                            $node.InnerText = $prop.GetValue($Fragment, $null)
                        }
                        else {
                            if ( $objBaseTypeName -eq 'Enum' ) {
                                $node.SetAttribute($objTypeName,$obj.ToString()) | Out-Null
                            }
                            else {
                                $objNode = Get-TSqlFragmentNode -Doc $Doc -Fragment $obj -PropertyName $prop.Name -PositionalProperties $PositionalProperties
                                $node.AppendChild($objNode) | Out-Null
                            }
                        }

                    }
                }

            }

            return $node
        }
        catch {
            throw $_
            break
        }
    }

    $DebugPreference = 'Continue'

    $debugMsg = @"
`r`nSQL Server Version........: $($SqlServerVersion)
ScriptDOM Library Location: $($ScriptDomLocation)
Show Positional Properties: $($PositionalProperties)
PS Version................: $($PSVersionTable.PSVersion.ToString())
"@
        
    Write-Debug -Message $debugMsg

    $libraryPath = "$($ScriptDomLocation)Microsoft.SqlServer.TransactSql.ScriptDom.dll"

    try {
        Add-Type -Path $libraryPath -ErrorAction SilentlyContinue
        Write-Debug "Added type from $($libraryPath)"
    }
    catch {
        throw "Couldn't add type $($libraryPath)"
        break
    }

    switch ($SqlServerVersion){
        2012 { $parserObjectName = 'TSql110Parser'}
        2014 { $parserObjectName = 'TSql120Parser'}
        2016 { $parserObjectName = 'TSql130Parser'}
        2017 { $parserObjectName = 'TSql140Parser'}
        2019 { $parserObjectName = 'TSql150Parser'}
    }

    $parserType = "Microsoft.SqlServer.TransactSql.ScriptDom.$($parserObjectName)"

    try {
        $parser = New-Object -TypeName $parserType -ArgumentList ($true)
        Write-Debug "Created object $($parserType)"
    }
    catch {
        throw "Couldn't create object $($parserType)"
        break
    }

    try {
        $parseError = New-Object -TypeName 'System.Collections.Generic.List[Microsoft.SqlServer.TransactSql.ScriptDom.ParseError]'
        $reader = New-Object -TypeName 'System.IO.StringReader' -ArgumentList @($Script)
        $fragment = $parser.Parse( $reader, [ref]$parseError )
        
    }
    catch {
        throw $_
        break
    }

    if ($parseError.Count -eq 0) {
        [xml]$doc = New-Object System.Xml.XmlDocument
    
        $node = Get-TSqlFragmentNode -Doc $doc -Fragment $fragment -PositionalProperties $PositionalProperties #-ParserName $parserObjectName
    
        $doc.AppendChild($node) | Out-Null
    
        return $doc
    }
    else {
        return $parseError | ConvertTo-Xml
    }
}