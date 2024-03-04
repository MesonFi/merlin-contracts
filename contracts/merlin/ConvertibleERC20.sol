// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./ERC20WithConvertible.sol";

contract ConvertibleERC20 is ERC20 {
    address public admin;

    uint8 private _decimals;
    address public minter;
    ERC20WithConvertible public underlyingToken;

    bool public conversionEnabled = false;
    bool public mintDisabled = false;

    constructor(
        address _admin,
        string memory name,
        string memory symbol,
        uint8 __decimals,
        address _minter,
        ERC20WithConvertible _underlyingToken
    ) ERC20(name, symbol) {
        _decimals = __decimals;
        minter = _minter;
        admin = _admin;
        underlyingToken = _underlyingToken;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    modifier onlyMinter() {
        require(msg.sender == minter, "Only the minter can mint");
        _;
    }

    function mint(address account, uint256 amount) public onlyMinter {
        require(!mintDisabled, "Mint disabled");
        require(amount > 0, "Amount must be greater than zero");
        _mint(account, amount);
    }

    function batchMint(address[] memory accounts, uint256[] memory amounts) public onlyMinter {
        require(!mintDisabled, "Mint disabled");
        require(accounts.length == amounts.length, "The number of accounts must equal to the number of amounts");
        require(accounts.length < 65536, "Can mint to at most 65536 accounts at the same time");
        for (uint32 i = 0; i < accounts.length; i++) {
            uint256 amount = amounts[i];
            require(amount > 0, "Amount must be greater than zero");
            _mint(accounts[i], amount);
        }
    }

    function enableConversion() public {
        require(msg.sender == admin, "Only admin can enable conversion");
        conversionEnabled = true;
    }

    function disableMint() public {
        require(msg.sender == admin, "Only admin can disable mint");
        mintDisabled = true;
    }

    function convert(uint256 amount) public {
        require(conversionEnabled, "Conversion not enabled");
        require(amount > 0, "Amount must be greater than zero");
        _burn(msg.sender, amount);
        underlyingToken.mintThroughConvertible(msg.sender, amount);
    }
}
