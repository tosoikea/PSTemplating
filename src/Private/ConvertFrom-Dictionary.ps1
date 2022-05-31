function ConvertFrom-Dictionary {
    [OutputType([System.Collections.Generic.Dictionary[String, String]])]
    param(
        [Parameter(Mandatory)]
        [System.Collections.IDictionary]
        $Values
    )

    $res = [System.Collections.Generic.Dictionary[String, String]]::new([System.StringComparer]::OrdinalIgnoreCase)

    for ($entryEnum = $Values.GetEnumerator(); $entryEnum.MoveNext(); ) {
        $res[$entryEnum.Entry.Key] = $entryEnum.Entry.Value
    }
    
    return $res
}