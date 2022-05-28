# PSTemplating

The PSTemplating module provides a simple way of generating values based on a schema (template) and variable bindings.
Details about the usage can be found inside the **Wiki**.

## Installation

```powershell
Install-Module PSTemplating
```

## Basic Usage

```powershell
ConvertFrom-Schema -Schema "{firstName(lower?countUp[1,3])}.{lastName(lower)}" -InputObject @{
    "FirstName" = "Max"
    "LastName" = "Mustermann"
}
```

```powershell
max.mustermann
Max1.mustermann
Max2.mustermann
Max3.mustermann
```

```powershell
ConvertFrom-Schema -Schema "{firstName(lower)(?countUp[1,3])}.{lastName(lower)}" -InputObject @{
    "FirstName" = "Max"
    "LastName" = "Mustermann"
}

```powershell
max.mustermann
max1.mustermann
max2.mustermann
max3.mustermann
```

## Authors

- **Torben Soennecken**
