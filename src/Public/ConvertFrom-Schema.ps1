<#
.SYNOPSIS
Convert a schema string to values based on variable bindings provided by the input object.

.DESCRIPTION
The ConvertFrom-Schema function tries to parse the schema string.
If done successfully, the obtained schema is evaluated and variables bound by the input object.

.PARAMETER Schema
The schema string used for generating values.

.PARAMETER InputObject
Binds variables used within the schema string to concise values.

.EXAMPLE
ConvertFrom-Schema -Schema "{?x}.{y}" -InputObject @{"x"="A";"y"="B"}
#>
function ConvertFrom-Schema {
    param(
        [Parameter(Mandatory)]
        [String]
        $Schema,
        [Parameter(Mandatory)]
        [object]
        $InputObject
    )

    # A) Parse Schema
    $parsed = ConvertFrom-SchemaText -Schema $Schema

    # B) Convert Input Object into bindings
    if ([System.Collections.IDictionary].IsAssignableFrom($InputObject.GetType())) {
        $bindings = ConvertFrom-Dictionary -Values $InputObject
    }
    elseif ($InputObject -is [psobject]) {
        $bindings = ConvertFrom-PSObject -Values $InputObject
    }
    else {
        throw [System.NotImplementedException]::new($InputObject.GetType())
    }

    # C) Generate values
    [Value[]] $generated = Use-Schema -Schema $parsed -Bindings $bindings

    # D) Only return text value
    $res = [string[]]::new($generated.Length)

    for ([int] $i = 0; $i -lt $res.Length; $i++) {
        $res[$i] = $generated[$i].GetValue()
    }

    return $res
}