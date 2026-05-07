# BetaFPV Air75 EdgeTX Scripts

Proiect EdgeTX pentru RadioMaster Pocket + BETAFPV Air75. Include un mixer de throttle hover cu hover-point reglabil din `S1` si o pagina dedicata pentru reglarea setarilor de curba in `GV1`..`GV4`.

## Fisiere principale

`SCRIPTS/MIXES/THRHOV.lua` este Mixes Script-ul principal. Primeste `Thr`, `S1` si `Arm`, aplica `Expo Down`, `Expo Up`, `Up Scale` si `Max throttle` din Global Variables, remapeaza throttle-ul in jurul hover-point-ului si returneaza `ThrOut`.

`SCRIPTS/TELEMETRY/THREXP.lua` este pagina de telemetrie pentru reglarea curbei. `ENTER` schimba randul selectat, iar tastele `+` si `-` ajusteaza valorile in pasi de `0.01` si le salveaza in `GV1`..`GV4` pentru flight mode-ul curent.

`SCRIPTS/MIXES/thrhov.md` explica instalarea, configurarea inputurilor si avertizarea despre evitarea dublarii Expo in Betaflight.

## Instalare rapida

1. Copiaza folderul `SCRIPTS` pe SD card-ul radio-ului EdgeTX.
2. In modelul Air75, adauga Mixes Script-ul `THRHOV`.
3. Configureaza inputurile: `Thr` = throttle stick, `S1` = hover-point, `Arm` = switch/canal armare.
4. Foloseste outputul `ThrOut` ca sursa pentru canalul de throttle.
5. In `Display/Screens`, adauga un ecran de tip `Script` si selecteaza `THREXP`.
6. Pe pagina `THRHOV EXPO`, regleaza Expo cu `+` si `-`.

Recomandare: lasa `Throttle Expo` in Betaflight la `0`, sau foarte mic, ca sa nu dublezi curba de throttle.

## THRHOV Expo Simulator

Pagina live este aici: [https://malikster.github.io/BetaFPV-Air75/](https://malikster.github.io/BetaFPV-Air75/).

