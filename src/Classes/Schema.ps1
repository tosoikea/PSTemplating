#Requires -Version 5.0

class Schema {
    # Operations included in the group.
    hidden [SchemaNode[]] $Nodes

    [SchemaNode[]] GetNodes() {
        return $this.Nodes
    }

    [boolean] Equals($obj) {
        #Check for null and compare run-time types.
        if (($null -eq $obj) -or -not $this.GetType().Equals($obj.GetType())) {
            return $false
        }
        else {
            $other = $obj -as [Schema]

            $isEqual = ($this.Nodes.Length -eq $other.Nodes.Length)
            
            for ([int] $i = 0; $i -lt $this.Nodes.Length -and $isEqual; $i++) {
                $isEqual = $this.Nodes[$i] -eq $other.Nodes[$i]
            }

            return $isEqual
        }
    }

    [string] ToString() {
        return "{0}" -f [system.String]::Join(",", $this.Nodes)
    }

    Schema([SchemaNode[]] $nodes) {
        $this.Nodes = $nodes
    }
}