// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TimeLockedWallet {
    address public owner;
    uint256 public unlockTime;
    uint256 public balance;

    event FundsDeposited(address indexed sender, uint256 amount);
    event FundsWithdrawn(address indexed owner, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner!");
        _;
    }

    modifier hasTimePassed() {
        require(block.timestamp >= unlockTime, "Funds are still locked!");
        _;
    }

    modifier hasBalance() {
        require(balance > 0, "No funds to withdraw!");
        _;
    }

    // Constructor to set the owner and unlock time
    constructor(uint256 _unlockTime) {
        owner = msg.sender;
        unlockTime = _unlockTime;
    }

    // Deposit funds into the contract
    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero.");
        balance += msg.value;
        emit FundsDeposited(msg.sender, msg.value);
    }

    // Withdraw funds after the time lock has expired
    function withdraw() external onlyOwner hasTimePassed hasBalance {
        uint256 amount = balance;
        balance = 0;
        payable(owner).transfer(amount);
        emit FundsWithdrawn(owner, amount);
    }

    // View function to check current balance of the wallet
    function getBalance() external view returns (uint256) {
        return balance;
    }

    // View function to check if the funds are unlocked yet
    function isUnlocked() external view returns (bool) {
        return block.timestamp >= unlockTime;
    }

    // Function to extend the lock time (only owner)
    function extendLockTime(uint256 newUnlockTime) external onlyOwner {
        require(newUnlockTime > unlockTime, "New unlock time must be greater.");
        unlockTime = newUnlockTime;
    }
}
