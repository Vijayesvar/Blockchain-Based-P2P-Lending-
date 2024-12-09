// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './Credit.sol';
import './common/Destructible.sol';

/** @title Peer to Peer Lending contract.
 * Inherits the Destructible contract.
 */
contract PeerToPeerLending is Destructible {
    using SafeMath for uint;

    /** @dev User structure */
    struct User {
        bool credited;
        address activeCredit;
        bool fraudStatus;
        address[] allCredits;
    }

    mapping(address => User) public users;
    address[] public credits;

    /** @dev Events */
    event LogCreditCreated(address indexed creditAddress, address indexed borrower, uint indexed timestamp);
    event LogCreditStateChanged(address indexed creditAddress, Credit.State indexed state, uint indexed timestamp);
    event LogCreditActiveChanged(address indexed creditAddress, bool indexed active, uint indexed timestamp);
    event LogUserSetFraud(address indexed borrower, bool fraudStatus, uint timestamp);

    /** @dev Constructor */
    constructor() Destructible() { }

    /**
     * @dev Credit application function.
     * @param requestedAmount Requested funding amount in wei.
     * @param repaymentsCount Requested repayments count.
     * @param interest The interest rate for the credit.
     * @param creditDescription The description of the funding.
     * @return _credit The address of the newly created credit contract.
     */
    function applyForCredit(
        uint requestedAmount, 
        uint repaymentsCount, 
        uint interest, 
        bytes32 creditDescription
    ) 
        public 
        returns(address _credit) 
    {
        require(!users[msg.sender].credited, "User already credited");
        require(!users[msg.sender].fraudStatus, "User is marked as fraud");
        require(users[msg.sender].activeCredit == address(0), "User already has an active credit");

        // Create a new Credit contract instance
        Credit credit = new Credit(requestedAmount, repaymentsCount, interest, creditDescription);
        users[msg.sender].credited = true;
        users[msg.sender].activeCredit = address(credit);
        credits.push(address(credit));
        users[msg.sender].allCredits.push(address(credit));

        emit LogCreditCreated(address(credit), msg.sender, block.timestamp);

        return address(credit);
    }

    /** @dev Get the list of all credits.
     * @return List of credit addresses.
     */
    function getCredits() public view returns (address[] memory) {
        return credits;
    }

    /** @dev Get all credits associated with the caller.
     * @return Array of the caller's credit addresses.
     */
    function getUserCredits() public view returns (address[] memory) {
        return users[msg.sender].allCredits;
    }

    /** @dev Sets a user's fraud status to true.
     * @param _borrower The user's address.
     * @return Updated fraud status.
     */
    function setFraudStatus(address _borrower) external onlyOwner returns (bool) {
        users[_borrower].fraudStatus = true;
        emit LogUserSetFraud(_borrower, true, block.timestamp);
        return true;
    }

    /** @dev Change the state of a credit.
     * @param _credit The credit's address.
     * @param state New state to set.
     */
    function changeCreditState(Credit _credit, Credit.State state) public onlyOwner {
        _credit.changeState(state);
        emit LogCreditStateChanged(address(_credit), state, block.timestamp);
    }

    /** @dev Toggle the active state of a credit.
     * @param _credit The credit's address.
     */
    function toggleCreditActiveState(Credit _credit) public onlyOwner {
        bool active = _credit.toggleActive();
        emit LogCreditActiveChanged(address(_credit), active, block.timestamp);
    }
}

