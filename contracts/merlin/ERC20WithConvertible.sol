// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

import "./ConvertibleERC20.sol";

contract ERC20WithConvertible is UUPSUpgradeable, ERC20Upgradeable {
    address public admin;

    uint8 private _decimals;
    address public minter;
    ConvertibleERC20 public convertible;

    function initialize(
        address _admin,
        string memory name,
        string memory symbol,
        uint8 __decimals,
        address _minter
    ) public initializer {
        admin = _admin;

        __ERC20_init(name, symbol);
        _decimals = __decimals;
        minter = _minter;
        convertible = new ConvertibleERC20(
            _admin,
            string(abi.encodePacked("Convertible ", name)),
            string(abi.encodePacked("m", symbol)),
            __decimals,
            _minter,
            this
        );
    }

    function _authorizeUpgrade(address) internal view override {
        require(_msgSender() == admin, "Unauthorized");
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    event AdminTransferred(address indexed prevAdmin, address indexed newAdmin);

    function transferAdmin(address newAdmin) public {
        require(_msgSender() == admin, "Only the admin can execute");
        address prevAdmin = admin;
        admin = newAdmin;
        emit AdminTransferred(prevAdmin, newAdmin);
    }

    modifier onlyMinter() {
        require(_msgSender() == minter, "Only the minter can execute");
        _;
    }

    event MinterTransferred(address indexed prevMinter, address indexed newMinter);

    function transferMinter(address newMinter) public onlyMinter {
        address prevMinter = minter;
        minter = newMinter;
        emit MinterTransferred(prevMinter, newMinter);
    }

    event TokenMinted(address indexed account, uint256 amount);
    event TokenBurnt(address indexed account, uint256 amount);

    function mint(address account, uint256 amount) public onlyMinter {
        require(amount > 0, "Amount must be greater than zero");
        _mint(account, amount);

        emit TokenMinted(account, amount);
    }

    function burn(uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");
        _burn(_msgSender(), amount);

        emit TokenBurnt(_msgSender(), amount);
    }

    function mintThroughConvertible(address account, uint256 amount) public {
        require(_msgSender() == address(convertible), "Only callable through the convertible token");
        require(amount > 0, "Amount must be greater than zero");
        _mint(account, amount);
    }
}
