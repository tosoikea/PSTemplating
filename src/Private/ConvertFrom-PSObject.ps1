function ConvertFrom-PSObject {
    [OutputType([System.Collections.Generic.Dictionary[String, String]])]
    param(
        [Parameter(Mandatory)]
        [PSObject]
        $Values
    )

    $res = [System.Collections.Generic.Dictionary[String, String]]::new([System.StringComparer]::OrdinalIgnoreCase)

    foreach ($member in (
            $Values | Get-Member -MemberType Property, Properties, NoteProperty
        )) {
        $res[$member.Name] = $Values.($member.Name)
    }
    
    return $res
}