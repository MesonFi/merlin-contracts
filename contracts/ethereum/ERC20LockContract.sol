// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract ERC20LockContract is UUPSUpgradeable {
    address public admin;
    address public operator;

    mapping(address => bool) public recipientWhitelist;

    // Store the locked token balance
    mapping(address => uint256) public tokenBalanceOf;

    function initialize(address _admin, address _operator) public initializer {
        admin = _admin;
        operator = _operator;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyAdmin {}

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can execute");
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operator, "Only the operator can execute");
        _;
    }

    event AdminTransferred(address indexed prevAdmin, address indexed newAdmin);
    event OperatorTransferred(address indexed prevOperator, address indexed newOperator);

    function transferAdmin(address newAdmin) public onlyAdmin {
        address prevAdmin = admin;
        admin = newAdmin;
        emit AdminTransferred(prevAdmin, newAdmin);
    }

    function transferOperator(address newOperator) public onlyOperator {
        address prevOperator = operator;
        operator = newOperator;
        emit OperatorTransferred(prevOperator, newOperator);
    }

    event WhitelistRecipientAdded(address indexed recipient);
    event WhitelistRecipientRemoved(address indexed recipient);

    function addWhitelistRecipient(address recipient) public onlyAdmin {
        recipientWhitelist[recipient] = true;
        emit WhitelistRecipientAdded(recipient);
    }

    function removeWhitelistRecipient(address recipient) public onlyAdmin {
        recipientWhitelist[recipient] = false;
        emit WhitelistRecipientRemoved(recipient);
    }

    event TokenLocked(address indexed account, address token, uint256 amount);
    event TokenWithdrawn(address indexed account, address token, uint256 amount);

    // Function to receive ERC20 tokens
    function lockERC20(address token, uint256 amount) public {
        require(amount > 0, "Deposit amount must be greater than zero");

        tokenBalanceOf[token] += amount;
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        emit TokenLocked(msg.sender, token, amount);
    }

    // Function to withdraw ERC20 tokens
    function withdrawERC20(address token, uint256 amount, address recipient) public onlyOperator {
        require(recipientWhitelist[recipient], "Recipient not in whitelist");

        IERC20 tokenContract = IERC20(token);
        uint256 balance = tokenContract.balanceOf(address(this));
        require(balance >= amount, "Insufficient token balance");

        tokenBalanceOf[token] -= amount;
        tokenContract.transfer(recipient, amount);
        emit TokenWithdrawn(recipient, token, amount);
    }
}
