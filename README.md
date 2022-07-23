# Get-TSqlAbstractSyntaxTree
PowerShell function to generate an abstract syntax tree in XML of a T-SQL script using the Microsoft ScriptDom library

## Dependency

This function is dependent on the `Microsoft.SqlServer.TransactSql.ScriptDom` library.  This is installed as part of a SQL Server installation or can be downloaded from Microsoft here:

[Download and install SqlPackage](https://docs.microsoft.com/en-us/sql/tools/sqlpackage-download)

## Usage

### Sample PowerShell Script

```powershell
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
```

### Sample Output

```xml
<TSqlScript BaseType="TSqlFragment">
  <Batches Type="IList`1" Count="1">
    <TSqlBatch BaseType="TSqlFragment">
      <Statements Type="IList`1" Count="1">
        <SelectStatement BaseType="StatementWithCtesAndXmlNamespaces">
          <QueryExpression Type="QuerySpecification" BaseType="QueryExpression" UniqueRowFilter="NotSpecified">
            <SelectElements Type="IList`1" Count="2">
              <SelectScalarExpression BaseType="SelectElement">
                <Expression Type="ColumnReferenceExpression" BaseType="PrimaryExpression" ColumnType="Regular">
                  <MultiPartIdentifier Type="MultiPartIdentifier" BaseType="TSqlFragment" Count="1">
                    <Identifiers Type="IList`1" Count="1">
                      <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">staff</Identifier>
                    </Identifiers>
                  </MultiPartIdentifier>
                </Expression>
              </SelectScalarExpression>
              <SelectScalarExpression BaseType="SelectElement">
                <Expression Type="ColumnReferenceExpression" BaseType="PrimaryExpression" ColumnType="Regular">
                  <MultiPartIdentifier Type="MultiPartIdentifier" BaseType="TSqlFragment" Count="1">
                    <Identifiers Type="IList`1" Count="1">
                      <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">sales</Identifier>
                    </Identifiers>
                  </MultiPartIdentifier>
                </Expression>
              </SelectScalarExpression>
            </SelectElements>
            <FromClause Type="FromClause" BaseType="TSqlFragment">
              <TableReferences Type="IList`1" Count="1">
                <NamedTableReference BaseType="TableReferenceWithAlias" ForPath="False">
                  <SchemaObject Type="SchemaObjectName" BaseType="MultiPartIdentifier" Count="1">
                    <BaseIdentifier Type="Identifier" BaseType="TSqlFragment" QuoteType="NotQuoted">cte_sales_amounts</BaseIdentifier>
                    <Identifiers Type="IList`1" Count="1">
                      <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">cte_sales_amounts</Identifier>
                    </Identifiers>
                  </SchemaObject>
                </NamedTableReference>
              </TableReferences>
            </FromClause>
            <WhereClause Type="WhereClause" BaseType="TSqlFragment">
              <SearchCondition Type="BooleanComparisonExpression" BaseType="BooleanExpression" BooleanComparisonType="Equals">
                <FirstExpression Type="ColumnReferenceExpression" BaseType="PrimaryExpression" ColumnType="Regular">
                  <MultiPartIdentifier Type="MultiPartIdentifier" BaseType="TSqlFragment" Count="1">
                    <Identifiers Type="IList`1" Count="1">
                      <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">year</Identifier>
                    </Identifiers>
                  </MultiPartIdentifier>
                </FirstExpression>
                <SecondExpression Type="IntegerLiteral" BaseType="Literal" LiteralType="Integer">2018</SecondExpression>
              </SearchCondition>
            </WhereClause>
          </QueryExpression>
          <WithCtesAndXmlNamespaces Type="WithCtesAndXmlNamespaces" BaseType="TSqlFragment">
            <CommonTableExpressions Type="IList`1" Count="1">
              <CommonTableExpression BaseType="TSqlFragment">
                <ExpressionName Type="Identifier" BaseType="TSqlFragment" QuoteType="NotQuoted">cte_sales_amounts</ExpressionName>
                <Columns Type="IList`1" Count="3">
                  <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">staff</Identifier>
                  <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">sales</Identifier>
                  <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">year</Identifier>
                </Columns>
                <QueryExpression Type="QuerySpecification" BaseType="QueryExpression" UniqueRowFilter="NotSpecified">
                  <SelectElements Type="IList`1" Count="3">
                    <SelectScalarExpression BaseType="SelectElement">
                      <Expression Type="BinaryExpression" BaseType="ScalarExpression" BinaryExpressionType="Add">
                        <FirstExpression Type="BinaryExpression" BaseType="ScalarExpression" BinaryExpressionType="Add">
                          <FirstExpression Type="ColumnReferenceExpression" BaseType="PrimaryExpression" ColumnType="Regular">
                            <MultiPartIdentifier Type="MultiPartIdentifier" BaseType="TSqlFragment" Count="1">
                              <Identifiers Type="IList`1" Count="1">
                                <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">first_name</Identifier>
                              </Identifiers>
                            </MultiPartIdentifier>
                          </FirstExpression>
                          <SecondExpression Type="StringLiteral" BaseType="Literal" LiteralType="String" IsNational="False" IsLargeObject="False"> </SecondExpression>
                        </FirstExpression>
                        <SecondExpression Type="ColumnReferenceExpression" BaseType="PrimaryExpression" ColumnType="Regular">
                          <MultiPartIdentifier Type="MultiPartIdentifier" BaseType="TSqlFragment" Count="1">
                            <Identifiers Type="IList`1" Count="1">
                              <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">last_name</Identifier>
                            </Identifiers>
                          </MultiPartIdentifier>
                        </SecondExpression>
                      </Expression>
                    </SelectScalarExpression>
                    <SelectScalarExpression BaseType="SelectElement">
                      <Expression Type="FunctionCall" BaseType="PrimaryExpression" UniqueRowFilter="NotSpecified">
                        <FunctionName Type="Identifier" BaseType="TSqlFragment" QuoteType="NotQuoted">SUM</FunctionName>
                        <Parameters Type="IList`1" Count="1">
                          <BinaryExpression BaseType="ScalarExpression" BinaryExpressionType="Multiply">
                            <FirstExpression Type="BinaryExpression" BaseType="ScalarExpression" BinaryExpressionType="Multiply">
                              <FirstExpression Type="ColumnReferenceExpression" BaseType="PrimaryExpression" ColumnType="Regular">
                                <MultiPartIdentifier Type="MultiPartIdentifier" BaseType="TSqlFragment" Count="1">
                                  <Identifiers Type="IList`1" Count="1">
                                    <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">quantity</Identifier>
                                  </Identifiers>
                                </MultiPartIdentifier>
                              </FirstExpression>
                              <SecondExpression Type="ColumnReferenceExpression" BaseType="PrimaryExpression" ColumnType="Regular">
                                <MultiPartIdentifier Type="MultiPartIdentifier" BaseType="TSqlFragment" Count="1">
                                  <Identifiers Type="IList`1" Count="1">
                                    <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">list_price</Identifier>
                                  </Identifiers>
                                </MultiPartIdentifier>
                              </SecondExpression>
                            </FirstExpression>
                            <SecondExpression Type="ParenthesisExpression" BaseType="PrimaryExpression">
                              <Expression Type="BinaryExpression" BaseType="ScalarExpression" BinaryExpressionType="Subtract">
                                <FirstExpression Type="IntegerLiteral" BaseType="Literal" LiteralType="Integer">1</FirstExpression>
                                <SecondExpression Type="ColumnReferenceExpression" BaseType="PrimaryExpression" ColumnType="Regular">
                                  <MultiPartIdentifier Type="MultiPartIdentifier" BaseType="TSqlFragment" Count="1">
                                    <Identifiers Type="IList`1" Count="1">
                                      <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">discount</Identifier>
                                    </Identifiers>
                                  </MultiPartIdentifier>
                                </SecondExpression>
                              </Expression>
                            </SecondExpression>
                          </BinaryExpression>
                        </Parameters>
                      </Expression>
                    </SelectScalarExpression>
                    <SelectScalarExpression BaseType="SelectElement">
                      <Expression Type="FunctionCall" BaseType="PrimaryExpression" UniqueRowFilter="NotSpecified">
                        <FunctionName Type="Identifier" BaseType="TSqlFragment" QuoteType="NotQuoted">YEAR</FunctionName>
                        <Parameters Type="IList`1" Count="1">
                          <ColumnReferenceExpression BaseType="PrimaryExpression" ColumnType="Regular">
                            <MultiPartIdentifier Type="MultiPartIdentifier" BaseType="TSqlFragment" Count="1">
                              <Identifiers Type="IList`1" Count="1">
                                <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">order_date</Identifier>
                              </Identifiers>
                            </MultiPartIdentifier>
                          </ColumnReferenceExpression>
                        </Parameters>
                      </Expression>
                    </SelectScalarExpression>
                  </SelectElements>
                  <FromClause Type="FromClause" BaseType="TSqlFragment">
                    <TableReferences Type="IList`1" Count="1">
                      <QualifiedJoin BaseType="JoinTableReference" QualifiedJoinType="Inner" JoinHint="None">
                        <SearchCondition Type="BooleanComparisonExpression" BaseType="BooleanExpression" BooleanComparisonType="Equals">
                          <FirstExpression Type="ColumnReferenceExpression" BaseType="PrimaryExpression" ColumnType="Regular">
                            <MultiPartIdentifier Type="MultiPartIdentifier" BaseType="TSqlFragment" Count="2">
                              <Identifiers Type="IList`1" Count="2">
                                <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">s</Identifier>
                                <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">staff_id</Identifier>
                              </Identifiers>
                            </MultiPartIdentifier>
                          </FirstExpression>
                          <SecondExpression Type="ColumnReferenceExpression" BaseType="PrimaryExpression" ColumnType="Regular">
                            <MultiPartIdentifier Type="MultiPartIdentifier" BaseType="TSqlFragment" Count="2">
                              <Identifiers Type="IList`1" Count="2">
                                <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">o</Identifier>
                                <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">staff_id</Identifier>
                              </Identifiers>
                            </MultiPartIdentifier>
                          </SecondExpression>
                        </SearchCondition>
                        <FirstTableReference Type="QualifiedJoin" BaseType="JoinTableReference" QualifiedJoinType="Inner" JoinHint="None">
                          <SearchCondition Type="BooleanComparisonExpression" BaseType="BooleanExpression" BooleanComparisonType="Equals">
                            <FirstExpression Type="ColumnReferenceExpression" BaseType="PrimaryExpression" ColumnType="Regular">
                              <MultiPartIdentifier Type="MultiPartIdentifier" BaseType="TSqlFragment" Count="2">
                                <Identifiers Type="IList`1" Count="2">
                                  <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">i</Identifier>
                                  <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">order_id</Identifier>
                                </Identifiers>
                              </MultiPartIdentifier>
                            </FirstExpression>
                            <SecondExpression Type="ColumnReferenceExpression" BaseType="PrimaryExpression" ColumnType="Regular">
                              <MultiPartIdentifier Type="MultiPartIdentifier" BaseType="TSqlFragment" Count="2">
                                <Identifiers Type="IList`1" Count="2">
                                  <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">o</Identifier>
                                  <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">order_id</Identifier>
                                </Identifiers>
                              </MultiPartIdentifier>
                            </SecondExpression>
                          </SearchCondition>
                          <FirstTableReference Type="NamedTableReference" BaseType="TableReferenceWithAlias" ForPath="False">
                            <SchemaObject Type="SchemaObjectName" BaseType="MultiPartIdentifier" Count="2">
                              <SchemaIdentifier Type="Identifier" BaseType="TSqlFragment" QuoteType="NotQuoted">sales</SchemaIdentifier>
                              <BaseIdentifier Type="Identifier" BaseType="TSqlFragment" QuoteType="NotQuoted">orders</BaseIdentifier>
                              <Identifiers Type="IList`1" Count="2">
                                <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">sales</Identifier>
                                <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">orders</Identifier>
                              </Identifiers>
                            </SchemaObject>
                            <Alias Type="Identifier" BaseType="TSqlFragment" QuoteType="NotQuoted">o</Alias>
                          </FirstTableReference>
                          <SecondTableReference Type="NamedTableReference" BaseType="TableReferenceWithAlias" ForPath="False">
                            <SchemaObject Type="SchemaObjectName" BaseType="MultiPartIdentifier" Count="2">
                              <SchemaIdentifier Type="Identifier" BaseType="TSqlFragment" QuoteType="NotQuoted">sales</SchemaIdentifier>
                              <BaseIdentifier Type="Identifier" BaseType="TSqlFragment" QuoteType="NotQuoted">order_items</BaseIdentifier>
                              <Identifiers Type="IList`1" Count="2">
                                <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">sales</Identifier>
                                <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">order_items</Identifier>
                              </Identifiers>
                            </SchemaObject>
                            <Alias Type="Identifier" BaseType="TSqlFragment" QuoteType="NotQuoted">i</Alias>
                          </SecondTableReference>
                        </FirstTableReference>
                        <SecondTableReference Type="NamedTableReference" BaseType="TableReferenceWithAlias" ForPath="False">
                          <SchemaObject Type="SchemaObjectName" BaseType="MultiPartIdentifier" Count="2">
                            <SchemaIdentifier Type="Identifier" BaseType="TSqlFragment" QuoteType="NotQuoted">sales</SchemaIdentifier>
                            <BaseIdentifier Type="Identifier" BaseType="TSqlFragment" QuoteType="NotQuoted">staffs</BaseIdentifier>
                            <Identifiers Type="IList`1" Count="2">
                              <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">sales</Identifier>
                              <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">staffs</Identifier>
                            </Identifiers>
                          </SchemaObject>
                          <Alias Type="Identifier" BaseType="TSqlFragment" QuoteType="NotQuoted">s</Alias>
                        </SecondTableReference>
                      </QualifiedJoin>
                    </TableReferences>
                  </FromClause>
                  <GroupByClause Type="GroupByClause" BaseType="TSqlFragment" GroupByOption="None" All="False">
                    <GroupingSpecifications Type="IList`1" Count="2">
                      <ExpressionGroupingSpecification BaseType="GroupingSpecification" DistributedAggregation="False">
                        <Expression Type="BinaryExpression" BaseType="ScalarExpression" BinaryExpressionType="Add">
                          <FirstExpression Type="BinaryExpression" BaseType="ScalarExpression" BinaryExpressionType="Add">
                            <FirstExpression Type="ColumnReferenceExpression" BaseType="PrimaryExpression" ColumnType="Regular">
                              <MultiPartIdentifier Type="MultiPartIdentifier" BaseType="TSqlFragment" Count="1">
                                <Identifiers Type="IList`1" Count="1">
                                  <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">first_name</Identifier>
                                </Identifiers>
                              </MultiPartIdentifier>
                            </FirstExpression>
                            <SecondExpression Type="StringLiteral" BaseType="Literal" LiteralType="String" IsNational="False" IsLargeObject="False"> </SecondExpression>
                          </FirstExpression>
                          <SecondExpression Type="ColumnReferenceExpression" BaseType="PrimaryExpression" ColumnType="Regular">
                            <MultiPartIdentifier Type="MultiPartIdentifier" BaseType="TSqlFragment" Count="1">
                              <Identifiers Type="IList`1" Count="1">
                                <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">last_name</Identifier>
                              </Identifiers>
                            </MultiPartIdentifier>
                          </SecondExpression>
                        </Expression>
                      </ExpressionGroupingSpecification>
                      <ExpressionGroupingSpecification BaseType="GroupingSpecification" DistributedAggregation="False">
                        <Expression Type="FunctionCall" BaseType="PrimaryExpression" UniqueRowFilter="NotSpecified">
                          <FunctionName Type="Identifier" BaseType="TSqlFragment" QuoteType="NotQuoted">year</FunctionName>
                          <Parameters Type="IList`1" Count="1">
                            <ColumnReferenceExpression BaseType="PrimaryExpression" ColumnType="Regular">
                              <MultiPartIdentifier Type="MultiPartIdentifier" BaseType="TSqlFragment" Count="1">
                                <Identifiers Type="IList`1" Count="1">
                                  <Identifier BaseType="TSqlFragment" QuoteType="NotQuoted">order_date</Identifier>
                                </Identifiers>
                              </MultiPartIdentifier>
                            </ColumnReferenceExpression>
                          </Parameters>
                        </Expression>
                      </ExpressionGroupingSpecification>
                    </GroupingSpecifications>
                  </GroupByClause>
                </QueryExpression>
              </CommonTableExpression>
            </CommonTableExpressions>
          </WithCtesAndXmlNamespaces>
        </SelectStatement>
      </Statements>
    </TSqlBatch>
  </Batches>
</TSqlScript>
```
