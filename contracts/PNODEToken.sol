// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// ============================================================
// PNODE Token — PocketNode Utility Token
// Network: BSC (BEP-20)
// Compiler: Solidity 0.8.24, Optimization: 200 runs, EVM: paris
// ============================================================
//
// PNODE is the native utility token of the PocketNode app.
// Providers earn it by sharing their mobile device's computing
// power with the decentralized network. PNODE is a BEP-20 token
// on the Binance Smart Chain. Servers, computing resources, and
// all other services within PocketNode can only be purchased
// with $PNODE — it's the sole currency of the ecosystem.
// ============================================================

// Custom Errors (gas efficient — cheaper than require strings)
error TransferToZeroAddress();
error InsufficientBalance(uint256 available, uint256 required);
error ExceedsAllowance(uint256 available, uint256 required);
error DecreasedAllowanceBelowZero(uint256 current, uint256 decrease);

/**
 * @title PNODEToken
 * @notice BEP-20 (ERC-20 compatible) token on BSC
 * @dev Simple fixed-supply token without owner, mint, burn, pause
 *      Total supply: 7,000,000,000 PNODE (decimals: 18)
 *      Fully decentralized — no admin functions
 */
contract PNODEToken {

    // ==================== Constants ====================

    string private constant _NAME = "POKEDNODE";
    string private constant _SYMBOL = "PNODE";
    uint8  private constant _DECIMALS = 18;
    uint256 private constant _TOTAL_SUPPLY = 7_000_000_000 * 10**18; // 7B tokens

    // ==================== State Variables ====================

    /// @notice Total supply of tokens
    uint256 public totalSupply;

    /// @notice Balance of each address
    mapping(address => uint256) public balanceOf;

    /// @notice Allowances: owner => spender => amount
    mapping(address => mapping(address => uint256)) public allowance;

    // ==================== Events ====================

    /// @notice Emitted on token transfer
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @notice Emitted on allowance change
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // ==================== Constructor ====================

    /**
     * @notice Deploys the token and mints entire supply to deployer
     * @dev All tokens go to msg.sender at deployment
     */
    constructor() {
        totalSupply = _TOTAL_SUPPLY;
        balanceOf[msg.sender] = _TOTAL_SUPPLY;
        emit Transfer(address(0), msg.sender, _TOTAL_SUPPLY);
    }

    // ==================== View Functions ====================

    /**
     * @notice Returns the token name
     * @return Token name "POKEDNODE"
     */
    function name() public pure returns (string memory) {
        return _NAME;
    }

    /**
     * @notice Returns the token symbol
     * @return Token symbol "PNODE"
     */
    function symbol() public pure returns (string memory) {
        return _SYMBOL;
    }

    /**
     * @notice Returns the number of decimals
     * @return Decimals (18)
     */
    function decimals() public pure returns (uint8) {
        return _DECIMALS;
    }

    // ==================== Transfer Functions ====================

    /**
     * @notice Transfer tokens to a recipient
     * @param to Recipient address
     * @param value Amount to transfer
     * @return success Always true on success
     */
    function transfer(address to, uint256 value) external returns (bool) {
        if (to == address(0)) revert TransferToZeroAddress();
        if (balanceOf[msg.sender] < value)
            revert InsufficientBalance(balanceOf[msg.sender], value);

        unchecked {
            balanceOf[msg.sender] -= value;
            balanceOf[to] += value;
        }

        emit Transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @notice Transfer tokens on behalf of owner (requires allowance)
     * @param from Token owner address
     * @param to Recipient address
     * @param value Amount to transfer
     * @return success Always true on success
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        if (to == address(0)) revert TransferToZeroAddress();

        uint256 currentAllowance = allowance[from][msg.sender];
        if (currentAllowance < value)
            revert ExceedsAllowance(currentAllowance, value);

        if (balanceOf[from] < value)
            revert InsufficientBalance(balanceOf[from], value);

        unchecked {
            allowance[from][msg.sender] = currentAllowance - value;
            balanceOf[from] -= value;
            balanceOf[to] += value;
        }

        emit Approval(from, msg.sender, allowance[from][msg.sender]);
        emit Transfer(from, to, value);
        return true;
    }

    // ==================== Approval Functions ====================

    /**
     * @notice Approve spender to spend tokens
     * @param spender Address allowed to spend
     * @param value Amount allowed
     * @return success Always true
     */
    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @notice Increase the allowance for a spender (safe pattern)
     * @param spender Address allowed to spend
     * @param addedValue Additional amount to allow
     * @return success Always true
     */
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        allowance[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    /**
     * @notice Decrease the allowance for a spender (safe pattern)
     * @param spender Address allowed to spend
     * @param subtractedValue Amount to decrease
     * @return success Always true
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        uint256 currentAllowance = allowance[msg.sender][spender];
        if (currentAllowance < subtractedValue)
            revert DecreasedAllowanceBelowZero(currentAllowance, subtractedValue);

        unchecked {
            allowance[msg.sender][spender] = currentAllowance - subtractedValue;
        }

        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }
}
