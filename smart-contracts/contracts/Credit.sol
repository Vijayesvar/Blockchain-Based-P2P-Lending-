// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './common/SafeMath.sol';
import './common/Destructible.sol';

/** @title Credit contract.
  * Inherits the Destructible contract.
  */
contract Credit is Destructible {

    using SafeMath for uint;

    address public borrower;
    uint public requestedAmount;
    uint public returnAmount;
    uint public repaidAmount;
    uint public interest;
    uint public requestedRepayments;
    uint public remainingRepayments;
    uint public repaymentInstallment;
    uint public requestedDate;
    uint public lastRepaymentDate;
    bytes32 public description;
    bool public active = true;

    enum State { Investment, Repayment, InterestReturns, Expired, Revoked, Fraud }
    State public state;

    mapping(address => bool) public lenders;
    mapping(address => uint) public lendersInvestedAmount;
    uint public lendersCount = 0;
    uint public revokeVotes = 0;
    mapping(address => bool) public revokeVoters;
    uint public revokeTimeNeeded = block.timestamp + 1 days;  // Changed to 1 day for practical purposes
    uint public fraudVotes = 0;
    mapping(address => bool) public fraudVoters;

    event LogCreditInitialized(address indexed _address, uint indexed timestamp);
    event LogCreditStateChanged(State indexed state, uint indexed timestamp);
    event LogCreditStateActiveChanged(bool indexed active, uint indexed timestamp);
    event LogBorrowerWithdrawal(address indexed _address, uint indexed _amount, uint indexed timestamp);
    event LogBorrowerRepaymentInstallment(address indexed _address, uint indexed _amount, uint indexed timestamp);
    event LogBorrowerRepaymentFinished(address indexed _address, uint indexed timestamp);
    event LogBorrowerChangeReturned(address indexed _address, uint indexed _amount, uint indexed timestamp);
    event LogBorrowerIsFraud(address indexed _address, bool indexed fraudStatus, uint indexed timestamp);
    event LogLenderInvestment(address indexed _address, uint indexed _amount, uint indexed timestamp);
    event LogLenderWithdrawal(address indexed _address, uint indexed _amount, uint indexed timestamp);
    event LogLenderChangeReturned(address indexed _address, uint indexed _amount, uint indexed timestamp);
    event LogLenderVoteForRevoking(address indexed _address, uint indexed timestamp);
    event LogLenderVoteForFraud(address indexed _address, uint indexed timestamp);
    event LogLenderRefunded(address indexed _address, uint indexed _amount, uint indexed timestamp);

    modifier isActive() {
        require(active, "Contract is not active.");
        _;
    }

    modifier onlyBorrower() {
        require(msg.sender == borrower, "Caller is not the borrower.");
        _;
    }

    modifier onlyLender() {
        require(lenders[msg.sender], "Caller is not a lender.");
        _;
    }

    modifier canAskForInterest() {
        require(state == State.InterestReturns, "Interest cannot be requested.");
        require(lendersInvestedAmount[msg.sender] > 0, "No investment to request interest from.");
        _;
    }

    modifier canInvest() {
        require(state == State.Investment, "Investing is not allowed.");
        _;
    }

    modifier canRepay() {
        require(state == State.Repayment, "Repayment is not allowed.");
        _;
    }

    modifier canWithdraw() {
        require(address(this).balance >= requestedAmount, "Insufficient balance to withdraw.");
        _;
    }

    modifier isNotFraud() {
        require(state != State.Fraud, "Contract marked as fraud.");
        _;
    }

    modifier isRevokable() {
        require(block.timestamp >= revokeTimeNeeded, "Revoke time not reached.");
        require(state == State.Investment, "Cannot revoke in current state.");
        _;
    }

    modifier isRevoked() {
        require(state == State.Revoked, "Contract is not revoked.");
        _;
    }

    constructor(uint _requestedAmount, uint _requestedRepayments, uint _interest, bytes32 _description) {
        borrower = tx.origin;
        interest = _interest;
        requestedAmount = _requestedAmount;
        requestedRepayments = _requestedRepayments;
        remainingRepayments = _requestedRepayments;
        returnAmount = requestedAmount.add(interest);
        repaymentInstallment = returnAmount.div(requestedRepayments);
        description = _description;
        requestedDate = block.timestamp;
        emit LogCreditInitialized(borrower, block.timestamp);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function invest() public canInvest payable {
        uint extraMoney = 0;

        if (address(this).balance >= requestedAmount) {
            extraMoney = address(this).balance.sub(requestedAmount);
            if (extraMoney > 0) {
                payable(msg.sender).transfer(extraMoney);
                emit LogLenderChangeReturned(msg.sender, extraMoney, block.timestamp);
            }
            state = State.Repayment;
            emit LogCreditStateChanged(state, block.timestamp);
        }

        lenders[msg.sender] = true;
        lendersCount++;
        lendersInvestedAmount[msg.sender] = lendersInvestedAmount[msg.sender].add(msg.value.sub(extraMoney));
        emit LogLenderInvestment(msg.sender, msg.value.sub(extraMoney), block.timestamp);
    }

    function repay() public onlyBorrower canRepay payable {
        require(remainingRepayments > 0, "No repayments remaining.");
        require(msg.value >= repaymentInstallment, "Insufficient repayment amount.");

        uint extraMoney = 0;
        if (msg.value > repaymentInstallment) {
            extraMoney = msg.value.sub(repaymentInstallment);
            payable(msg.sender).transfer(extraMoney);
            emit LogBorrowerChangeReturned(msg.sender, extraMoney, block.timestamp);
        }

        emit LogBorrowerRepaymentInstallment(msg.sender, msg.value.sub(extraMoney), block.timestamp);
        repaidAmount = repaidAmount.add(msg.value.sub(extraMoney));
        remainingRepayments--;

        if (repaidAmount == returnAmount) {
            emit LogBorrowerRepaymentFinished(msg.sender, block.timestamp);
            state = State.InterestReturns;
            emit LogCreditStateChanged(state, block.timestamp);
        }
    }

    function withdraw() public isActive onlyBorrower canWithdraw isNotFraud {
        state = State.Repayment;
        emit LogCreditStateChanged(state, block.timestamp);
        emit LogBorrowerWithdrawal(msg.sender, address(this).balance, block.timestamp);
        payable(borrower).transfer(address(this).balance);
    }

    function requestInterest() public isActive onlyLender canAskForInterest {
        uint lenderReturnAmount = returnAmount / lendersCount;
        require(address(this).balance >= lenderReturnAmount, "Insufficient balance for interest payment.");
        payable(msg.sender).transfer(lenderReturnAmount);
        emit LogLenderWithdrawal(msg.sender, lenderReturnAmount, block.timestamp);

        if (address(this).balance == 0) {
            active = false;
            emit LogCreditStateActiveChanged(active, block.timestamp);
            state = State.Expired;
            emit LogCreditStateChanged(state, block.timestamp);
        }
    }

    function getCreditInfo() public view returns (
        address borrowerAddress, 
        bytes32 creditDescription, 
        uint reqAmount, 
        uint reqRepayments, 
        uint repaymentInstal, 
        uint remainingRepay, 
        uint intRate, 
        uint returnAmt, 
        State creditState, 
        bool activeStatus, // Renamed from 'isActive'
        uint balance
    ) {
        return (
            borrower,
            description,
            requestedAmount,
            requestedRepayments,
            repaymentInstallment,
            remainingRepayments,
            interest,
            returnAmount,
            state,
            active,
            address(this).balance
        );
    }

    function revokeVote() public isActive isRevokable onlyLender {
        require(!revokeVoters[msg.sender], "Lender already voted for revocation.");
        revokeVotes++;
        revokeVoters[msg.sender] = true;
        emit LogLenderVoteForRevoking(msg.sender, block.timestamp);

        if (lendersCount == revokeVotes) {
            revoke();
        }
    }

    function revoke() internal {
        state = State.Revoked;
        emit LogCreditStateChanged(state, block.timestamp);
    }

    function refund() public isActive onlyLender isRevoked {
        require(address(this).balance >= lendersInvestedAmount[msg.sender], "Insufficient balance for refund.");
        payable(msg.sender).transfer(lendersInvestedAmount[msg.sender]);
        emit LogLenderRefunded(msg.sender, lendersInvestedAmount[msg.sender], block.timestamp);

        if (address(this).balance == 0) {
            active = false;
            emit LogCreditStateActiveChanged(active, block.timestamp);
            state = State.Expired;
            emit LogCreditStateChanged(state, block.timestamp);
        }
    }

    function fraudVote() public isActive onlyLender returns (bool) {
        require(!fraudVoters[msg.sender], "Lender already voted for fraud.");
        fraudVotes++;
        fraudVoters[msg.sender] = true;
        emit LogLenderVoteForFraud(msg.sender, block.timestamp);

        if (lendersCount == fraudVotes) {
            return fraud();
        }
        return true;
    }
    
    function fraud() internal returns (bool) {
        ( , bytes memory data) = owner.call(abi.encodeWithSignature("setFraudStatus(address)", borrower));
        bool fraudStatusResult = abi.decode(data, (bool));
        emit LogBorrowerIsFraud(borrower, fraudStatusResult, block.timestamp);
        return fraudStatusResult;
    }

    function changeState(State _state) external onlyOwner {
        state = _state;
        emit LogCreditStateChanged(state, block.timestamp);
    }

    function toggleActive() external onlyOwner returns (bool) {
        active = !active;
        emit LogCreditStateActiveChanged(active, block.timestamp);
        return active;
    }
}

