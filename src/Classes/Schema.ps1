#Requires -Version 5.0

# A schema is composed of an ordered list of nodes.
class SchemaNode {
    # This function is used to determine the concise value of the node from the bindings.
    [String] Bind([System.Collections.Generic.Dictionary[String, String]] $bindings) {
        throw [System.NotImplementedException]::new()
    }

    [boolean] IsFailover() {
        throw [System.NotImplementedException]::new()
    }
}

class Schema {
    # Operations included in the group.
    hidden [SchemaNode[]] $Nodes

    [SchemaNode[]] GetNodes() {
        return $this.Nodes
    }

    Schema([SchemaNode[]] $nodes) {
        $this.Nodes = $nodes
    }
}