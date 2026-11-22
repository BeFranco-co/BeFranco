# BeFranco

Billetera de ahorro en pesos, dólares y francos suizos digitales (stablecoins), con donaciones directas a fundaciones colombianas verificadas.

Proyecto de Jorge Andrés Santana Pico, con el respaldo del semillero del grupo de investigación Finance & Management (F&M) de la Universidad Industrial de Santander.

**Página del proyecto y lista de espera:** el enlace de GitHub Pages de este repositorio (`index.html`). **Verificador público de fundaciones:** `verificador.html` (lee el contrato directamente en la blockchain). **Prototipo navegable de la billetera:** `prototipo.html`.

## Estado del MVP (noviembre de 2026)

Los contratos inteligentes están desplegados en la red de prueba Ethereum Sepolia, con el código verificado públicamente en Blockscout y Sourcify. El flujo de donación en tokens se probó el 17 de noviembre de 2026; el bloqueo de fundaciones no verificadas, el 21 de noviembre; y ese mismo día, la ruta de donaciones en pesos con la segunda versión del contrato (V2).

| Paso | Qué se probó | Transacción |
|---|---|---|
| Contrato | BeFranco desplegado en Sepolia | [0x3509…a862](https://eth-sepolia.blockscout.com/address/0x3509a1c1EA4fD27f95E1397a92fDA0872FFCa862) |
| 1 | BeFranco registra una fundación de prueba (`registerFoundation`) | [ver en el explorador](https://sepolia.etherscan.io/tx/0x848a5e1ef72961aa8068cc870a9332b28e5ff3189a7a342916581ef422227158) |
| 2 | La fundación confirma, desde su propia billetera, que la controla (`confirmWallet`) | [ver en el explorador](https://eth-sepolia.blockscout.com/tx/0x213205ed32ae4cbd0eee48460ec42680a6d5b0c2ac5b7a5b3c3802502de16213) |
| 3 | Donación de 10 tCHF directo del donante a la fundación (`donate`) | [ver en el explorador](https://eth-sepolia.blockscout.com/tx/0xf175270769358bf393ae3b5e63698e6f256edb19a0ea2a27667fbcb88772610b) |

### Prueba de bloqueo (21 de noviembre de 2026)

Registramos una segunda fundación de prueba con la billetera `0x…dEaD`, que nadie controla, así que nunca puede confirmarse. Luego intentamos registrarla otra vez e intentamos donarle. El contrato rechazó las dos operaciones.

| Paso | Qué se probó | Resultado | Transacción |
|---|---|---|---|
| 4 | Registrar la fundación de prueba n.º 2 | Registrada, pero no verificada | [ver en el explorador](https://eth-sepolia.blockscout.com/tx/0xf5c79b1b2f5a51ef4905e490be74f807efaac9341d9ee142393a4f585a50b433) |
| 5 | Registrar otra fundación con la misma billetera | Rechazada: `WalletAlreadyUsed()` | [ver en el explorador](https://eth-sepolia.blockscout.com/tx/0x2016208b0571e2de31b6115eea5cb9ade2a82e63d0d214e9401b7dabcc02bb6e) |
| 6 | Donar a la fundación no verificada | Rechazada: `NotVerified()`, sin mover ningún token | [ver en el explorador](https://eth-sepolia.blockscout.com/tx/0xec1bb34a93d2d6750d16e6352d691a5d2ea789ae113964ea7606d01f842e870e) |

Historial completo del contrato V1: [Blockscout](https://eth-sepolia.blockscout.com/address/0x3509a1c1EA4fD27f95E1397a92fDA0872FFCa862?tab=txs)

### Prueba de la ruta en pesos (21 de noviembre de 2026, contrato V2)

En una donación en pesos el dinero viaja por el banco, no por la blockchain. El contrato V2 guarda la huella (hash SHA-256) del comprobante y dos firmas independientes: la de BeFranco, que registra la donación, y la de la fundación, que confirma desde su propia billetera que el dinero llegó. Ningún dato personal queda en la red.

Para la prueba usamos una transferencia simulada de 50.000 COP con un comprobante marcado como documento de prueba. Cualquiera puede descargarlo y comprobar que su huella coincide con la registrada, en el [verificador](verificador.html) o con `Get-FileHash` en Windows.

| Paso | Qué se probó | Firma | Transacción |
|---|---|---|---|
| Contrato | BeFrancoV2 desplegado en Sepolia, código verificado | BeFranco | [0xCcef…2629](https://eth-sepolia.blockscout.com/address/0xCcef9b76E5E1E7c929b730f24ae3866935232629) |
| 7 | Registro de la fundación demo con la huella de sus documentos de prueba (`registerFoundation`) | BeFranco | [ver en el explorador](https://eth-sepolia.blockscout.com/tx/0x77e94f4bcbdcf5137069f4c6edab59e2fd9ca4291bdce2ab1bbf9861bddb4140) |
| 8 | La fundación confirma su billetera (`confirmWallet`) | Fundación | [ver en el explorador](https://eth-sepolia.blockscout.com/tx/0x24b16bc02630cc693d503ca52475380a12be0a09d6be474a9e67d59d680cc483) |
| 9 | BeFranco registra la donación de 50.000 COP con la huella del comprobante (`recordFiatDonation`) | BeFranco | [ver en el explorador](https://eth-sepolia.blockscout.com/tx/0x740a20f3fc9150e643b5e890f40de797661df8a16f2e7a82b9f2d0b8d25a760d) |
| 10 | La fundación confirma que recibió el dinero (`confirmFiatDonation`) | Fundación | [ver en el explorador](https://eth-sepolia.blockscout.com/tx/0x660c3385244be66435f4309e20bae639ec8d7a5a2dc1bcdea5a5caad5c59f33a) |

Resultado en el contrato: `fiatReceivedCop(1) = 50000` y la donación n.º 1 en estado 2 (confirmada).

| Archivo de prueba | Huella SHA-256 registrada en la red |
|---|---|
| [`docs/Comprobante_prueba_BeFranco.pdf`](docs/Comprobante_prueba_BeFranco.pdf) | `0x21030e804ad601640a4c12c93e61c7e64fcbcfbea23652e254fcc328d191cc43` |
| [`docs/Documentos_prueba_Fundacion_Demo.pdf`](docs/Documentos_prueba_Fundacion_Demo.pdf) | `0x431f819cf39fe5cce951ecb0c637c54b998847c93df14d17dd0f433d9e586a50` |

Historial completo del contrato V2: [Blockscout](https://eth-sepolia.blockscout.com/address/0xCcef9b76E5E1E7c929b730f24ae3866935232629?tab=txs)

Token de prueba tCHF: [0xB920…689E](https://eth-sepolia.blockscout.com/address/0xB9209C97FD04Ad67763d82584c72C6d6C9f0689E)

Las capturas de cada paso están en [`docs/Evidencias_MVP_BeFranco.pdf`](docs/Evidencias_MVP_BeFranco.pdf).

## Cómo funciona la verificación

1. **Revisión legal.** Un verificador de BeFranco revisa los documentos de la fundación (Cámara de Comercio, RUT y régimen tributario especial de la DIAN) y la registra con el hash de esos documentos.
2. **Prueba de control.** La fundación firma desde su propia billetera para demostrar que la controla. Solo quien tiene la llave privada puede hacerlo.
3. **Sello de verificada.** Solo entonces la fundación puede recibir donaciones por el contrato. El dinero va directo de la billetera del donante a la de la fundación: BeFranco nunca lo custodia.
4. **Consulta abierta.** Cualquier billetera o aplicación puede preguntar al contrato si una dirección pertenece a una fundación verificada (`isVerifiedWallet`). Si se detecta un fraude, el sello se retira (`revoke`).
5. **Donaciones en pesos.** BeFranco registra la huella del comprobante bancario (`recordFiatDonation`) y la fundación confirma desde su billetera que recibió el dinero (`confirmFiatDonation`). Quedan dos firmas independientes y ningún dato personal en la red.

## Contenido

| Archivo | Descripción |
|---|---|
| `contracts/BeFranco.sol` | Contrato V1, desplegado en Sepolia el 17 de noviembre de 2026 |
| `contracts/TestCHF.sol` | Token de prueba "Test Swiss Franc" (tCHF), sin valor |
| `contracts/BeFrancoV2.sol` | Contrato V2, con la ruta de donaciones en pesos; desplegado en Sepolia el 21 de noviembre de 2026 |
| `index.html` | Página del proyecto con la lista de espera |
| `prototipo.html` | Prototipo navegable de la billetera |
| `verificador.html` | Verificador público: consulta si una dirección es de una fundación verificada, sin pasar por servidores de BeFranco |
| `docs/Evidencias_MVP_BeFranco.pdf` | Capturas y enlaces de cada transacción |
| `docs/Comprobante_prueba_BeFranco.pdf` | Comprobante de prueba de la ruta en pesos; su huella SHA-256 es la que se registra en la red |
| `docs/Documentos_prueba_Fundacion_Demo.pdf` | Documentos de prueba de la fundación demo; su huella es el `docsHash` registrado en V2 |

## Aviso

Prototipo no auditado, solo para red de prueba. El ETH de Sepolia y el token tCHF no tienen valor real. El contrato no guarda datos personales de donantes.

## Licencia

MIT
