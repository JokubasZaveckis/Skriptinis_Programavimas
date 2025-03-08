Šiame laboratoriniame darba sukurtas .bat skriptas, kuriam pateikus nuorodą į aplankalą, ir nurodžius file extensioną, jis randa visus tokius failus nurodytoje direktyvoje.
Default parametrai, nenurodžius nieko: User home aplankalas ir .bat failai.
Paleidus skriptą, jis randa failus, surašo juos į log failą, atidaro per notepad, ten parašyta data, laikas, rasto failo pavadinimas ir išspausdintas to failo path.
Norint užbaigti skriptą, reikia per cmd paspausti bet kokį mygtuką, ir log failas bus uždarytas ir ištrintas.
Komandų pavyzdžiai:
.\Laboratorinis1
.\Laboratorinis1 "<Path>" PVZ: "C:\Users\jokub\Desktop\Tests"
.\Laboratorinis1 "<Path>" "<fileExtension>"  PVZ: "C:\Users\jokub\Desktop\Tests" ".txt"