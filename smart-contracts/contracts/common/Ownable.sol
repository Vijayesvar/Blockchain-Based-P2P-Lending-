// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/** @title Ownable contract.
  * Provides basic authorization control functions, simplifying the implementation of user permissions.
  */
contract Ownable {
    address public owner;

    event LogOwnershipTransferred(address indexed _currentOwner, address indexed _newOwner);

    /** @dev Constructor sets the initial owner of the contract. */
    constructor() {
        owner = msg.sender;
    }

    /** @dev Modifier to restrict functions to the contract owner. */
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    /** @dev Transfers ownership to a new address.
      * This functionality is commented out to prevent unintended changes.
      * Uncomment to allow ownership transfer.
      * @param _newOwner The address of the new owner.
      */
    /* function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "New owner is the zero address");
        emit LogOwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    } */
}

