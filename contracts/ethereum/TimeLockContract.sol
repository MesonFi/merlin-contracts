// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TimeLockContract is Ownable {
    using SafeERC20 for IERC20;

    uint256 public releaseTime;

    // Store the locked token balance for an account in `lockedBalanceOf[account][token]`
    // `token = 0x1` means ETH
    mapping(address => mapping(address => uint256)) public lockedBalanceOf;

    // Constructor sets the owner address and release time (in Unix timestamp)
    constructor(uint256 _releaseTime) Ownable(msg.sender) {
        if (_releaseTime > 0) {
            require(_releaseTime > block.timestamp, "Release time must be in the future");
            require(_releaseTime < block.timestamp + 90 days, "Release time must be within 3 months");
            releaseTime = _releaseTime;
        }
    }

    // Function to receive ETH deposits
    receive() external payable {
        uint256 amount = msg.value;
        require(amount > 0, "Deposit amount must be greater than zero");

        lockedBalanceOf[msg.sender][address(0x1)] += amount;
        emit TokenLocked(msg.sender, address(0x1), amount);
    }

    // Function to receive ERC20 tokens
    function lockERC20(address token, uint256 amount) public {
        require(amount > 0, "Deposit amount must be greater than zero");

        lockedBalanceOf[msg.sender][token] += amount;
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        emit TokenLocked(msg.sender, token, amount);
    }

    // Function to withdraw ETH, only available after release time and only to the beneficiary
    function withdrawETH(uint256 amount) public onlyOwner {
        require(releaseTime == 0 || block.timestamp >= releaseTime, "Current time is before release time");

        uint256 balance = address(this).balance;
        require(balance >= amount, "Insufficient ETH balance");

        payable(owner()).transfer(amount);
        emit TokenWithdrawn(address(0x1), amount);
    }

    // Function to withdraw ERC20 tokens, only available after release time and only to the beneficiary
    function withdrawERC20(address token, uint256 amount) public onlyOwner {
        require(releaseTime == 0 || block.timestamp >= releaseTime, "Current time is before release time");

        IERC20 tokenContract = IERC20(token);
        uint256 balance = tokenContract.balanceOf(address(this));
        require(balance >= amount, "Insufficient token balance");

        tokenContract.safeTransfer(owner(), amount);
        emit TokenWithdrawn(token, amount);
    }

    event TokenLocked(address indexed account, address token, uint256 amount);
    event TokenWithdrawn(address token, uint256 amount);
}
