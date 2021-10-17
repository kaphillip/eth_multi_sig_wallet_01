pragma solidity 0.7.5;
pragma abicoder v2;

import "./MultiSigOwners.sol";
    //second contract OwnerList with whitelisted addresses
        //functions to verify and control signatory addresses


contract MultiSigWallet is OwnerList {
    
    mapping(address => uint) balance;

    //event to keep track of deposits & transfers; indexed
    event depositDone(uint amount, address indexed depositedFrom);
    event transferDone(uint amount, address indexed transferTo);
    event confirmationDone(address requester, uint amount, address indexed confirmSignature);
    
    //could have declared a better name, meant to track transfer requests
    //Potential Upgrade - add function to auto-remove requests with successful transfers
    struct pendingRequest{
        address transferRequester;
        uint transferAmount;
        address transferTo;
        bool transferConfirmed;
    }
    
    pendingRequest[] requests;
    
    //function getUserBalance
    function getUserBalance() public view returns (uint){
        return balance[msg.sender];
    }
    
    //function getWalletBalance
    function getWalletBalance() public view returns (uint){
        return balance[address(this)];
    }
    
    //deposit funds into wallet from user
    function depositWallet() public payable returns (uint){
        //check balance of msg.sender
        require(balance[msg.sender] >= msg.value, "Balance not sufficient");
         _transfer(msg.sender, address(this), msg.value);
        
        //log deposit
        emit depositDone(msg.value, msg.sender);
        return balance[msg.sender]; 
    }
    
    //deposit funds into user's wallet for testing
    function depositUser() public payable returns (uint){
        balance[msg.sender] += msg.value;
        emit depositDone(msg.value, msg.sender);
        return balance[msg.sender]; 
    }
    
    //create a transfer Request by verified user to be confirmed by 2nd verified signer
    function transferRequest(address recipient, uint amount) public {
        require(address(this) != recipient, "Do not send funds to yourself");
        
        //verify signatory address 
        require(verifySignPerson(msg.sender) == true, "Failed signatory verification");
        
        bool _transferConfirmed = false;
        requests.push(pendingRequest(msg.sender, amount, recipient, _transferConfirmed));
    }
    
    //function getRequest
    function getRequest(uint _index) public view returns(pendingRequest memory){
        return requests[_index];
    }
    
    
    //confirm a selected Request by 2nd verified signer
    function confirmRequest(uint _index) public returns(uint){
        require(verifySignPerson(msg.sender) == true, "Failed signatory verification");
        require(msg.sender != requests[_index].transferRequester, "Requires two unique authorized signers");
        require(requests[_index].transferConfirmed == false, "Cannot reconfirm a request");
        require(signers.length == 3, "Must have 3 verified addresses");
        require(_index < requests.length, "Specified request does not exist");
        
        uint previousSenderBalance = balance[address(this)];
        require(previousSenderBalance - requests[_index].transferAmount >= 0,"Cannot transfer more than available amount");
        
        //commits the transfer based on data in requests
        requests[_index].transferConfirmed = true;
        _transfer(address(this), requests[_index].transferTo, requests[_index].transferAmount);
        
        assert(balance[address(this)] == previousSenderBalance - requests[_index].transferAmount);
        emit transferDone(requests[_index].transferAmount, requests[_index].transferTo);
        emit confirmationDone(requests[_index].transferRequester, requests[_index].transferAmount, msg.sender);
        return balance[address(this)];
    }
    
    
    //function _transfer
    function _transfer(address from, address to, uint amount) private {
        balance[from] -= amount;
        balance[to] += amount;
    }
    
}