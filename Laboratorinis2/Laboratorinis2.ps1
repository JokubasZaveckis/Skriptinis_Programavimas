# =======================================================================================
# Parametrai:
#   -Username: neprivalomas parametras, nurodantis konkretu vartotoja
#     Jei nebus nurodytas, bus naudojamas esamas prisijunges vartotojas
# =======================================================================================

Param(
    [string]$Username = $env:USERNAME
)

# ---------------------------------------------------------------------------------------
# Funkcija: Gauti visu procesu sarasa su vartotojo vardu
# Naudojame Win32_Process ir GetOwner() metoda, kad suzinotume, kuriam vartotojui
# priklauso procesas. Jei vartotojas nenustatytas arba GetOwner() meta klaida,
# priskiriame "NoUser"
# ---------------------------------------------------------------------------------------
Write-Host "Gaunamas procesu sarasas is Win32_Process..."

$processData = Get-WmiObject Win32_Process | ForEach-Object {
    try {
        $owner = $_.GetOwner()
        $user = $owner.User
    }
    catch {
        $user = "NoUser"
    }
    if (-not $user) {
        $user = "NoUser"
    }
    [PSCustomObject]@{
        User         = $user
        Name         = $_.Name
        PID          = $_.ProcessId
        ThreadCount  = $_.ThreadCount
        WorkingSet   = $_.WorkingSetSize
        Priority     = $_.Priority
    }
}

# ---------------------------------------------------------------------------------------
# Jei parametre nurodytas vartotojo vardas, atrenkame tik ji atitinkancius procesus
# ---------------------------------------------------------------------------------------
if ($PSBoundParameters.ContainsKey('Username')) {
    Write-Host "Filtruojami procesai pagal vartotoja: $Username"
    $processData = $processData | Where-Object { $_.User -eq $Username }
}

# ---------------------------------------------------------------------------------------
# Grupavimas pagal vartotojo varda
# ---------------------------------------------------------------------------------------
Write-Host "Grupuojame procesus pagal vartotojus..."
$groupedData = $processData | Group-Object -Property User

# ---------------------------------------------------------------------------------------
# Formuojame log failus. Kiekvienas vartotojas gauna atskira faila.
# Failo pavadinimas: "$username-process-log-$date-$time.txt"
# ---------------------------------------------------------------------------------------
$dateString = (Get-Date).ToString("yyyy-MM-dd")
$timeString = (Get-Date).ToString("HH-mm-ss")

Write-Host "Kuriame log failus ir atidarome Notepad..."

$logFiles = @()

foreach ($group in $groupedData) {

    $userName   = $group.Name
    $outputFile = "$($userName)-process-log-$dateString-$timeString.txt"

    # Parasome pradine informacija: data ir laikas
    @(
        "Data:  $dateString"
        "Laikas: $timeString"
    ) | Out-File -FilePath $outputFile -Encoding UTF8

    # Kiekvienam proceso irasui, isvedame reikiama informacija:
    # Pavyzdziui: ThreadCount ir WorkingSet, kurie paprastai yra trumpi skaiciai.
    foreach ($item in $group.Group) {
        @(
            "----------------------------------------"
            "Procesas:       $($item.Name)"
            "Proceso PID:    $($item.PID)"
            "ThreadCount:    $($item.ThreadCount)"
            "WorkingSet:     $($item.WorkingSet)"
            "Priority:       $($item.Priority)"
        ) | Out-File -FilePath $outputFile -Append -Encoding UTF8
    }

    # Issaugome failo varda, kad veliau galetume ji uzdaryti
    $logFiles += $outputFile

    # Atidarome log faila Notepad'e
    Start-Process "notepad.exe" $outputFile
}

# ---------------------------------------------------------------------------------------
# Paliekame skripta laukti vartotojo, kad jis galetu perziureti Notepad langus
# ---------------------------------------------------------------------------------------
Write-Host "Paspauskite Enter, norint testi ir uzdaryti Notepad..."
[void][System.Console]::ReadLine()

# ---------------------------------------------------------------------------------------
# Uzdarome visas atidarytas Notepad sesijas
# ---------------------------------------------------------------------------------------
Write-Host "Uzdaromi visi Notepad langai..."
Get-Process notepad -ErrorAction SilentlyContinue | Stop-Process -Force

Write-Host "Skriptas baigtas."
