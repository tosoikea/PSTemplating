<#
.SYNOPSIS
Convert any Unicode data (string) to its ASCII equivalent.

.DESCRIPTION
ConvertFrom-Unicode checks the input char by char and tries
the conversion to an ASCII equivalent char if possible.
The length of the input and output can differ, as chars can be discarded
if they fall e.g. under the unicode private range.

.PARAMETER InputObject
Data to be converted to ASCII

.PARAMETER DACH
Specifies if a conversion by the standard of Germany/Switzerland/Austria is desired.
This changes the behavior from e.g. ä->a to ä->ae.

.PARAMETER RemoveNonAlphabeticChars
Removes any character from the converted output not being an alphabetic char.

.EXAMPLE
ConvertFrom-Unicode -InputObject "Testä__"
Testa__

.EXAMPLE
ConvertFrom-Unicode -InputObject "Testä__" -RemoveNonAlphabeticChars
Testa

.EXAMPLE
ConvertFrom-Unicode -InputObject "Testä__" -DACH -RemoveNonAlphabeticChars
Testae

.NOTES
Use with care. No guarantees of functionality are made.
If you want to specify custom behavior, just alter the files underneath /lib.
#>
function ConvertFrom-Unicode {
    [CmdletBinding()]
    [OutputType([String])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [Char[]]
        $InputObject,
        [Switch]
        $DACH,
        [Switch]
        $RemoveNonAlphabeticChars
    )

    Begin {
        #Lib Directory.
        [String] $rootDirectory = ( $MyInvocation.MyCommand.Module.Path -replace $MyInvocation.MyCommand.Module.RootModule )
        [String] $dataDirectory = Join-Path -Path $rootDirectory -ChildPath "lib"

        #Used for caching sections.
        $sectionCache = @{ }

        ##Basic ASCII
        $asciiEnd = 127
        #Ignore values over 0xeffff
        $extremeValues = 983039
        
        #Ignore https://en.wikipedia.org/wiki/Private_Use_Areas
        <#
        0x0E000 - 0x0F8FF
        57344 - 63743
        #>
        $privateRange = @(57344, 63743)

        #Ignore https://docs.microsoft.com/en-us/windows/desktop/intl/surrogates-and-supplementary-characters
        $supplementaryRange = @(55296, 57343)

        #DACH conversions
        [hashtable] $lowerConversion = @{
            [char] 'ä' = "ae"
            [char] 'ü' = "ue"
            [char] 'ö' = "oe"
            [char] 'ß' = "ss"
        }        
        [hashtable] $upperConversion = @{
            [char] 'Ä' = "Ae"
            [char] 'Ü' = "Ue"
            [char] 'Ö' = "Oe"
        }
    }

    Process {
        #End Result.
        [String] $returnValue = [String]::Empty

        #Loop through all chars inside string.
        foreach ( $char in $InputObject ) {
            $ordinalValue = [Int][Char]$char


            if ( $ordinalValue -gt $extremeValues ) {
                Write-Error -Message ("{0} - ordinalValue is out of Range" -f $ordinalValue)
                continue
            }

            if ( $ordinalValue -ge $privateRange[0] -and $ordinalValue -le $privateRange[1] ) {
                Write-Error -Message ("{0} - ordinalValue is in private use Range" -f $ordinalValue)
                continue
            }

            if ( $ordinalValue -ge $supplementaryRange[0] -and $ordinalValue -le $supplementaryRange[1] ) {
                Write-Error -Message ("{0} - ordinalValue is supplementary character and will be skipped" -f $ordinalValue)
                continue
            }

            #ASCII can stay ASCII. 
            if ( $ordinalValue -le $asciiEnd ) {
                $returnValue += $char
                continue
            }

            #-- DACH
            if ($DACH.IsPresent) {

                if ($lowerConversion.ContainsKey($char)) {
                    $returnValue += $lowerConversion.Item($char)
                    continue
                }
                
                if ($upperConversion.ContainsKey($char)) {
                    $returnValue += $lowerConversion.Item($char)
                    continue
                }
            }
            #--

            #Pad If needed
            $hexValue = ([Convert]::ToString($ordinalValue, 16)).PadLeft(5, "0")

            $decodeSection = $hexValue.Substring(0, 3)
            $decodeCharKey = [Convert]::ToInt32($hexValue.Substring(3, 2), 16)

            if ( -not $sectionCache.ContainsKey($decodeSection) ) {
                [hashtable] $keyTable = Import-PowerShellDataFile -Path ("{0}\x{1}.ignore" -f $dataDirectory, $decodeSection)
                $sectionCache.Add($decodeSection, $keyTable.data)
            }

            $conversionList = $sectionCache.Item($decodeSection)
            $returnValue += $conversionList[$decodeCharKey]
        }

        if ( $RemoveNonAlphabeticChars.IsPresent ) {
            $alphString = [String]::Empty

            foreach ( $char in $returnValue[0..($returnValue.Length - 1)] ) {
                $charValue = [byte][char]$char

                ##space
                if ( 
                    ( $charValue -ge 65 -and $charValue -le 90 ) -or 
                    ( $charValue -ge 97 -and $charValue -le 122 ) 
                ) {
                    #ascii char all fine
                }
                else {
                    $char = ""    
                }
                ##valid 

                $alphString += $char
            }

            $returnValue = $alphString
        }

        return $returnValue
    }
}