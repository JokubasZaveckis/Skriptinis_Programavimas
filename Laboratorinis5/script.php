#!/usr/bin/env php
<?php

// Funkcija gauna procesu sarasa is Windows per "tasklist" komanda
function getProcesses($username = null) {
    $cmd = 'tasklist /v /fo csv'; 
    $output = [];
    exec($cmd, $output);

    $filtered = [];

    foreach ($output as $line) {
        // Skaldome eilute i stulpelius, naudojant CSV formata
        $fields = str_getcsv(trim($line, "\xEF\xBB\xBF"));
        // Pirma eilute
        if (str_contains($fields[0], 'Image Name')) {
            $filtered[] = $line;
            continue;
        }

        // Jei nurodytas vartotojas - filtruojame pagal vartotojo varda (neiskiriant didziosios/mazosios)
        if ($username === null || stripos($fields[6], $username) !== false) {
            $filtered[] = $line;
        }
    }

    return $filtered; 
}

// Funkcija issaugo rezultatus i nurodyto formato faila
function saveToFile($data, $format, $filename) {
    switch ($format) {
        case 'csv':
            // CSV formatas - tiesiog iraso eilutes
            file_put_contents($filename, implode(PHP_EOL, $data));
            break;

        case 'html':
            // HTML formatas - formuoja lentele
            $html = "<table border='1'>";
            foreach ($data as $line) {
                $cols = str_getcsv($line);
                $html .= "<tr><td>" . implode("</td><td>", $cols) . "</td></tr>";
            }
            $html .= "</table>";
            file_put_contents($filename, $html);
            break;

        case 'txt':
        default:
            // TXT formatas - paprastas tekstas
            file_put_contents($filename, implode(PHP_EOL, $data));
            break;
    }
}

// Nuskaito argumentus is komandu eilutes
$format = $argv[1] ?? 'txt';        // Pirmas argumentas - formatas
$username = $argv[2] ?? null;       // Antras argumentas - vartotojo vardas (nebutinas)

// Tikrina ar formatas yra teisingas
if (!in_array($format, ['txt', 'csv', 'html'])) {
    echo "Neteisingas formatas. Naudokite: txt, csv arba html.\n";
    exit(1);
}

// Gauname procesu sarasa pagal vartotoja (jei nurodytas)
$data = getProcesses($username);

$filename = "log.$format";

// Issaugo duomenis i faila
saveToFile($data, $format, $filename);

// Parodo informacija ir laukia enter
echo "Logas sukurtas: $filename\n";
echo "Paspauskite Enter kad istrintumete loga ir baigtumete...";
fgets(STDIN);

// Istriname faila
unlink($filename);
echo "Logas istrintas. Baigiame.\n";
