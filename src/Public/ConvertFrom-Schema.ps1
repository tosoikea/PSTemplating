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
}