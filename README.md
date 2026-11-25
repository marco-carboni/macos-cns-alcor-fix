# CNS + Alcor AU9540 on macOS

A documented, reproducible workaround for a smart-card reader that could read a CNS certificate but could not complete authentication. On one Apple Silicon Mac, installing a newer CCID driver resolved an Agenzia delle Entrate login that hung after certificate selection. Safari and Firefox both reached the authenticated area afterwards.

**Status: one successful hardware case, not a universal fix.** This repository packages an existing upstream correction; it does not claim to have discovered or authored the CCID fix. The original [Alcor AU9540 issue](https://github.com/LudovicRousseau/CCID/issues/84) and the [CCID project by Ludovic Rousseau](https://github.com/LudovicRousseau/CCID) deserve credit. The user's card and the cards in the original issue are different, so the exact mechanism in this case has not been proven.

## In breve (italiano)

Se un lettore Alcor AU9540 vede la CNS ma l’accesso resta bloccato dopo la scelta del certificato, questo progetto permette di compilare e provare un driver CCID aggiornato. Il caso è stato risolto su **un Mac Apple Silicon con macOS 26.6.2**, con Firefox e Safari; le altre combinazioni sono ancora da verificare. La correzione del driver è del progetto originale CCID: qui documentiamo l’indagine e rendiamo ripetibile la configurazione.

L’installazione richiede Terminale, strumenti di sviluppo, Homebrew e una password amministratore. Cambia una preferenza valida per tutti i lettori di smart card del Mac; lo script di rimozione ripristina il valore precedente. Il driver è compilato localmente e non è notarizzato da Apple. Leggi le istruzioni e prova prima su un Mac non di produzione.

## Tested and intended support

| Environment | Status |
|---|---|
| Apple Silicon, macOS 26.6.2, AU9540 (058f:9540), InfoCamere CNS | **Hardware tested:** Firefox and Safari login succeeded on one Mac. |
| Apple Silicon, macOS 14 / 15 / 27 | Build/install targets; **hardware and authentication not yet verified**. |
| Intel Macs | Not supported by this build script. |
| Other reader IDs or card models | Not tested; the generated driver is restricted to 058f:9540. |

Apple's commercial releases include macOS 14, 15, 26 and 27. Darwin 24 and 25 are kernel version numbers, not macOS 24 and 25. A successful build in CI does not test a reader or establish authentication compatibility.

## What this changes

- Builds upstream CCID **1.8.4** at commit `c37cf6cb42279ce9648ff7314180c866d68f9e0d`, containing upstream fixes for AU9540 readers.
- Restricts the generated driver's reader list to USB ID `058f:9540` and installs it alongside system drivers.
- Sets the **system-wide** `useIFDCCID` preference. Other smart-card readers can be affected. Previous preference is saved for rollback.
- Does **not** install the card middleware or import certificates. A working vendor middleware and active CNS certificate may still be required.
- The driver is compiled locally and is **not notarized by Apple**. Use only on machines you administer, review the scripts, and test outside production first.

## Install

On Apple Silicon macOS 14, 15, 26 or 27, install Apple's command-line developer tools and Homebrew, then install build dependencies:

```sh
brew install git meson ninja pkg-config libusb
```

Clone this repository, review the scripts, then:

```sh
./scripts/build.sh
./scripts/install.sh
```

The build fetches upstream source pinned to the commit above and includes its license with the local build. The installer displays the system-wide effect, requests confirmation and administrator authentication, and refuses to overwrite an existing installation or rollback state. Disconnect and reconnect the reader after installation. Confirm the reader and test authentication in a browser. If the card is not recognized, check the vendor middleware and card orientation. Do not post PINs, tax codes, certificate serials, or private data in issues.

## Roll back

```sh
./scripts/uninstall.sh
```

This removes this repository's driver and restores the saved `useIFDCCID` preference. Reconnect the reader. If the preference has been changed by another administrator since installation, coordinate before rolling back because the saved value will be restored.

## Verification and contributing

The GitHub Actions workflow builds on macOS 15 and 26 Apple Silicon hosted runners and checks the driver manifest; it does not access a card reader. Hardware reports for supported macOS releases, card models and reader firmware are welcome. Please redact personal data from logs and screenshots. For use with a government portal, do not upload your certificate or PIN to an issue.

## Credits and licensing

Investigation and packaging: Marco Carboni with AI-assisted diagnosis. CCID is by Ludovic Rousseau and contributors, available under LGPL-2.1-or-later; its source is fetched from the original project and its license copied to `dist/` with the binary. The scripts and documentation in this repository are MIT licensed; see `LICENSE`. No endorsement or affiliation with Apple, InfoCamere, or Agenzia delle Entrate is implied.
