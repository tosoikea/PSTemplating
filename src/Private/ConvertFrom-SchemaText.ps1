function ConvertFrom-SchemaText {
    param(
        [Parameter(Mandatory)]
        [String]
        $Schema
    )

    # Schema Nodes
    $nodes = @()

    <#
        0 : plain
        1 : substitution
        2 : operation name
        3 : operation parameters
    #>
    $mode = 0

    # for mode 0 : plain text
    $plain = ""

    # for mode 1 : substitution variable name
    $variable = ""
    $failoverVariable = $false
    $operationGroups = [System.Collections.Generic.List[OperationGroup]]::new()

    # for mode 2 : operation group
    $operations = @()

    $operation = ""
    $failoverGroup = $false
    # 0 unspecified, 1 conjunctive, 2 disjunctive
    $groupType = 0
    $parameters = @()

    # for mode 3 : parameter
    $parameter = ""

    foreach ($char in $Schema.ToCharArray()) {
        switch ($mode) {
            0 {
                switch ($char) {
                    # A) We switch from plain text matching to substitution variable matching upon encountering {
                    '{' {
                        if ($plain -ne "") {
                            # Save
                            $nodes += [Plain]::new($plain)
                        
                            # Reset
                            $plain = ""
                        }

                        # Switch
                        $mode = 1
                    }
                    # B) We construct plain text in this mode
                    default {
                        $plain += $char
                    }
                }
            }
            1 {
                switch ($char) {
                    # A) We discard whitespaces with a warning in substitution variable matching
                    ' ' {
                        Write-Warning -Message "Skipping whitespace in variable matching."
                        continue
                    }
                    # B) We mark the substitution variable as failover, given that the question mark is the first character
                    '?' {
                        # Variable marked as failover
                        if ($variable -eq "") {
                            $failoverVariable = $true
                        }
                        else {
                            Write-Error -Message "Unexpected question mark in schema string."
                        }
                    }
                    # C) We switch to operation groups matching upon encountering (
                    '(' {
                        $mode = 2
                    }
                    # D) We switch back to plain text matching upon closing the substition variable with a }
                    '}' {
                        # Save
                        $nodes += [Variable]::new(
                            $failoverVariable,
                            $variable,
                            $operationGroups.ToArray()
                        )

                        # Reset
                        $failoverVariable = $false
                        $variable = ""
                        $operationGroups = [System.Collections.Generic.List[OperationGroup]]::new()

                        # Switch
                        $mode = 0
                    }
                    # E) We construct the variable name
                    default {
                        $variable += $char
                    }
                }
            }
            2 {
                switch ($char) {
                    # A) We mark the first operation in the group as failover or delimit multiple operations when encountering a ?
                    '?' {
                        # Starting operation marked as failover
                        if ($operation -eq "") {
                            $failoverGroup = $true
                        }
                        else {
                            Write-Error -Message "Unexpected question mark in schema string."
                        }
                    }
                    '|' {
                        if ($groupType -eq 0 -or $groupType -eq 2) {
                            # Save
                            $groupType = 2
                            $operations += [OperationFactory]::GetOperation(
                                $operation,
                                $parameters
                            )

                            # Reset
                            $operation = ""
                            $parameters = @()
                        }
                        else {
                            Write-Error -Message "Mixed disjunctive group with conjunctive group."
                        }
                    }
                    '&' {
                        if ($groupType -eq 0 -or $groupType -eq 1) {
                            # Save
                            $groupType = 1
                            $operations += [OperationFactory]::GetOperation(
                                $operation,
                                $parameters
                            )

                            # Reset
                            $operation = ""
                            $parameters = @()
                        }
                        else {
                            Write-Error -Message "Mixed conjunctive group with disjunctive group."
                        }
                    }
                    # B) We switch to parameter matching upon encountering a [
                    '[' {
                        $mode = 3
                    }
                    # C) We switch back to variable matching upon closing the operation group variable with a )
                    ')' {
                        # Save
                        if ($operation -ne "") {
                            $operations += [OperationFactory]::GetOperation(
                                $operation,
                                $parameters
                            )
                        }

                        switch ($groupType) {
                            1 {
                                $operationGroups.Add(
                                    [OperationGroup]::new($operations, $failoverGroup, [OperationGroupType]::Conjunctive)
                                ) 
                            }
                            2 {
                                $operationGroups.Add(
                                    [OperationGroup]::new($operations, $failoverGroup, [OperationGroupType]::Disjunctive)
                                )
                            }
                            Default {
                                $operationGroups.Add(
                                    [OperationGroup]::new($operations, $failoverGroup)
                                )
                            }
                        }

                        # Reset
                        $operation = ""
                        $failoverGroup = $false
                        $groupType = 0
                        $parameters = @()
                        $operations = @()

                        # Switch
                        $mode = 1
                    }
                    # D) We construct the operation name
                    default {
                        $operation += $char
                    }
                }
            }
            3 {
                switch ($char) {
                    # A) We match another parameter when encountering a ,
                    ',' {
                        # Save
                        $parameters += $parameter
                        # Reset
                        $parameter = ""
                    }
                    # B) We switch back to operation group matching upon closing the parameters with a ]
                    ']' {
                        # Save
                        $parameters += $parameter
                        # Reset
                        $parameter = ""
                        # Switch
                        $mode = 2
                    }
                    # C) We construct the parameter value
                    default {
                        $parameter += $char
                    }
                }
            }
            default {
                throw [System.NotImplementedException]::new()
            }
        }
    }

    if ($mode -ne 0) {
        Write-Error "Unexpected EOL"
    }
    elseif ($plain -ne "") {
        $nodes += [Plain]::new($plain)
    }

    return [Schema]::new($nodes)
}