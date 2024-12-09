// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './Ownable.sol';

/** @title Destructible contract.
 * Allows the contract to be destroyed by its owner.
 */
contract Destructible is Ownable {

    constructor() payable Ownable() { }

    /** @dev Destroys the contract and sends remaining funds to the owner. */
    function destroy() public onlyOwner {
        selfdestruct(payable(owner));
    }
    
    /** @dev Destroys the contract and sends remaining funds to a specified address.
     * @param _recipient The address to receive the remaining funds.
     */
    function destroyAndSend(address payable _recipient) public onlyOwner {
        selfdestruct(_recipient);
    }
}

