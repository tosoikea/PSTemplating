# PSTemplating

The PSTemplating module provides a simple way of generating values based on a schema (template) and variable bindings.
Details about the usage can be found inside the **Wiki**.

## Installation

```powershell
Install-Module PSTemplating
```

## Basic Usage

While this module can be used for basic substitution of variables with concise values, it's real worth lies within the generation of values based on operations and failovers.

### Basic Substitution

```powershell
ConvertFrom-Schema -Schema "{firstName}.{lastName}" -InputObject @{
    "FirstName" = "Max-Test"
    "LastName" = "Mustermann"
}
```

```powershell
Max-Test.Mustermann
```

### Basic Operations

```powershell
ConvertFrom-Schema -Schema "{firstName(lower)(split)}.{lastName(lower)}" -InputObject @{
    "FirstName" = "Max-Test"
    "LastName" = "Mustermann"
}
```

```powershell
max.mustermann
test.mustermann
```

### Basic Failover

```powershell
ConvertFrom-Schema -Schema "{firstName(lower)(split)(?countUp[1,3])}.{lastName(lower)}" -InputObject @{
    "FirstName" = "Max-Test"
    "LastName" = "Mustermann"
}
```

```powershell
max.mustermann
test.mustermann
max1.mustermann
max2.mustermann
max3.mustermann
test1.mustermann
test2.mustermann
test3.mustermann
```

### Disjunctive Operation Group

```powershell
ConvertFrom-Schema -Schema "ext-{firstName(lower)(split)(sel[0]|sel[0,1]|sel[0,2])}.{lastName(lower)}" -InputObject @{
    "FirstName" = "Max-Test"
    "LastName" = "Mustermann"
}
```

```powershell
ext-m.mustermann
ext-t.mustermann
ext-ma.mustermann
ext-te.mustermann
ext-mx.mustermann
ext-ts.mustermann
```

### Conjunctive Operation Group

```powershell
ConvertFrom-Schema -Schema "{lastName(?replace[$, ]&countUp[1,3])}, {firstName}" -InputObject @{
    "FirstName" = "Max-Test"
    "LastName" = "Mustermann"
}
```

```powershell
Mustermann, Max-Test
Mustermann 1, Max-Test
Mustermann 2, Max-Test
Mustermann 3, Max-Test
```

## Authors

- **Torben Soennecken**
