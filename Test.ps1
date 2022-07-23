Clear-Host

[string] $script = @'
WITH cte_sales_amounts (staff, sales, year) AS (
    SELECT    
        first_name + ' ' + last_name, 
        SUM(quantity * list_price * (1 - discount)),
        YEAR(order_date)
    FROM    
        sales.orders o
    INNER JOIN sales.order_items i ON i.order_id = o.order_id
    INNER JOIN sales.staffs s ON s.staff_id = o.staff_id
    GROUP BY 
        first_name + ' ' + last_name,
        year(order_date)
)

SELECT
    staff, 
    sales
FROM 
    cte_sales_amounts
WHERE
    year = 2018;
'@


try {
    . $PSScriptRoot\Get-TSqlAbstractSyntaxTree.ps1
    [xml]$result = Get-TSqlAbstractSyntaxTree -SqlServerVersion 2017 -ScriptDomLocation 'C:\Temp\' -Script $script -PositionalProperties $false
}
catch {
    throw $_
    break
}

$StringWriter = New-Object System.IO.StringWriter 
$XmlWriter = New-Object -TypeName System.XMl.XmlTextWriter -ArgumentList $StringWriter 
            
$XmlWriter.Formatting = 'indented' 
$XmlWriter.Indentation = 2
            
$result.WriteContentTo($XmlWriter) 
$XmlWriter.Flush()
$StringWriter.Flush() 
            
Write-Host $stringWriter.ToString()