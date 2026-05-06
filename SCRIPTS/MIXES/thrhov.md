# THRHOV Mixer pentru RadioMaster Pocket + BETAFPV Air75

`THRHOV.lua` este un EdgeTX Mixes Script care creeaza un throttle modelat pentru hover. Scriptul ia throttle-ul pilotului, aplica Expo din `GV1`, apoi remapeaza curba astfel incat stick jos sa fie 0%, stick centru sa fie hover-point-ul `X`, iar stick sus sa fie 100%.

Hover-point-ul `X` este controlat din `S1`, intre 20% si 80%, dar numai cat timp modelul este armat. Cand modelul este dezarmat, scriptul pastreaza ultimul `X` valid in `xLocked`.

## Fisiere

`SCRIPTS/MIXES/THRHOV.lua` este mixerul.

`SCRIPTS/TELEMETRY/THREXP.lua` este pagina dedicata pentru reglarea Expo.

## Activare mixer

1. Copiaza `SCRIPTS/MIXES/THRHOV.lua` pe SD card in `/SCRIPTS/MIXES/`.
2. In modelul Air75, mergi la pagina de Mixes Scripts si adauga scriptul `THRHOV`.
3. Seteaza inputurile scriptului:
   - `Thr`: throttle stick.
   - `S1`: sliderul/potentiometrul folosit pentru hover-point.
   - `Arm`: sursa de armare, de obicei switch-ul sau canalul folosit pentru arm.
4. Foloseste outputul `ThrOut` ca sursa pentru canalul de throttle catre flight controller.

## Pagina THREXP

1. Copiaza `SCRIPTS/TELEMETRY/THREXP.lua` pe SD card in `/SCRIPTS/TELEMETRY/`.
2. In model, mergi la `Display/Screens`.
3. Alege un ecran liber.
4. Seteaza tipul ecranului la `Script`.
5. Selecteaza scriptul `THREXP`.
6. Revino pe ecranele principale si foloseste Page Up/Page Down pana ajungi la pagina `THRHOV EXPO`.

Pe pagina `THRHOV EXPO`, tastele `+` si `-` ajusteaza Expo in pasi de `0.01`, intre `0.00` si `0.80`. Valoarea este salvata in `GV1` pentru flight mode-ul curent.

## Comportament armare

Scriptul are un soft pre-arm check: cand `Arm` este cerut, pozitia `S1` trebuie sa fie aproape de pozitia care corespunde ultimului hover-point salvat (`xLocked`). Toleranta este aproximativ 8% din cursa completa a lui `S1`.

Daca verificarea esueaza, mixerul returneaza `-1024`, adica throttle cut, si emite o alarma rate-limited aproximativ o data pe secunda.

## Expo si Betaflight

Expo pentru acest mixer se regleaza din pagina `THREXP` si se salveaza in `GV1`. Nu este citit din `S1`.

Evita dublarea Expo in Betaflight. Recomandat: seteaza `Throttle Expo` in Betaflight la `0`, sau la o valoare foarte mica daca ai un motiv clar sa pastrezi putina modelare si in flight controller.
