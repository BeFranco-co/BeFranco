// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title BeFranco — Registro de fundaciones verificadas y enrutador de donaciones
/// @notice Prototipo para la convocatoria AIT Colombia 5. No auditado; solo para red de prueba.
/// @dev Flujo de verificación en tres pasos:
///      1. Un verificador de BeFranco revisa los documentos legales (Cámara de Comercio, RUT,
///         régimen tributario especial DIAN) y registra la fundación con el hash de esos documentos.
///      2. La fundación demuestra que controla su billetera llamando a `confirmWallet` DESDE esa
///         misma dirección (prueba de control: solo quien tiene la llave privada puede hacerlo).
///      3. Solo entonces la fundación queda "Verified" y puede recibir donaciones por este contrato.

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract BeFranco {
    enum Status { None, Pending, Verified, Revoked }

    struct Foundation {
        string name;          // nombre legal
        string nit;           // NIT ante la DIAN
        bytes32 docsHash;     // hash de los documentos legales revisados
        address wallet;       // dirección que recibirá las donaciones
        Status status;
        uint256 totalReceived; // suma de donaciones (en unidades de cada token, solo informativo)
    }

    address public owner;
    mapping(address => bool) public isVerifier;
    mapping(uint256 => Foundation) public foundations;
    mapping(address => uint256) public foundationIdByWallet;
    uint256 public foundationCount;

    event VerifierSet(address indexed verifier, bool allowed);
    event FoundationRegistered(uint256 indexed id, string name, address wallet, bytes32 docsHash);
    event WalletConfirmed(uint256 indexed id, address wallet);
    event FoundationRevoked(uint256 indexed id, string reason);
    event Donation(uint256 indexed foundationId, address indexed donor, address indexed token, uint256 amount, bool fromYield);

    error NotOwner();
    error NotVerifier();
    error WalletAlreadyUsed();
    error NotFoundationWallet();
    error NotPending();
    error NotVerified();
    error ZeroAmount();
    error TransferFailed();

    modifier onlyOwner() { if (msg.sender != owner) revert NotOwner(); _; }
    modifier onlyVerifier() { if (!isVerifier[msg.sender]) revert NotVerifier(); _; }

    constructor() {
        owner = msg.sender;
        isVerifier[msg.sender] = true;
        emit VerifierSet(msg.sender, true);
    }

    function setVerifier(address verifier, bool allowed) external onlyOwner {
        isVerifier[verifier] = allowed;
        emit VerifierSet(verifier, allowed);
    }

    /// @notice Paso 1: un verificador registra la fundación tras revisar sus documentos legales.
    function registerFoundation(string calldata name, string calldata nit, bytes32 docsHash, address wallet)
        external onlyVerifier returns (uint256 id)
    {
        if (foundationIdByWallet[wallet] != 0) revert WalletAlreadyUsed();
        id = ++foundationCount;
        foundations[id] = Foundation(name, nit, docsHash, wallet, Status.Pending, 0);
        foundationIdByWallet[wallet] = id;
        emit FoundationRegistered(id, name, wallet, docsHash);
    }

    /// @notice Paso 2: la fundación confirma, desde su propia billetera, que la controla.
    function confirmWallet(uint256 id) external {
        Foundation storage f = foundations[id];
        if (f.status != Status.Pending) revert NotPending();
        if (msg.sender != f.wallet) revert NotFoundationWallet();
        f.status = Status.Verified;
        emit WalletConfirmed(id, msg.sender);
    }

    /// @notice Retira el sello si se detecta fraude o la fundación deja de cumplir.
    function revoke(uint256 id, string calldata reason) external onlyVerifier {
        foundations[id].status = Status.Revoked;
        emit FoundationRevoked(id, reason);
    }

    /// @notice Consulta para la app y para cualquier billetera: ¿esta dirección es de una fundación verificada?
    function isVerifiedWallet(address wallet) external view returns (bool verified, uint256 id) {
        id = foundationIdByWallet[wallet];
        verified = id != 0 && foundations[id].status == Status.Verified;
    }

    /// @notice Dona un token (USDC, stablecoin en CHF, etc.) a una fundación verificada.
    /// @dev El donante debe aprobar antes este contrato en el token. Los fondos van directo a la
    ///      billetera de la fundación: BeFranco nunca custodia las donaciones.
    function donate(uint256 foundationId, address token, uint256 amount, bool fromYield) external {
        if (amount == 0) revert ZeroAmount();
        Foundation storage f = foundations[foundationId];
        if (f.status != Status.Verified) revert NotVerified();
        if (!IERC20(token).transferFrom(msg.sender, f.wallet, amount)) revert TransferFailed();
        f.totalReceived += amount;
        emit Donation(foundationId, msg.sender, token, amount, fromYield);
    }
}
