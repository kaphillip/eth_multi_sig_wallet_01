pragma solidity 0.7.5;
pragma abicoder v2;


contract OwnerList{
    
    //structure with whitelisted signatory addresses
    struct SignPerson {
        string name;
        address signAddress;
    }
    
    SignPerson[] signers;
    
    //function to add signatory address for a max of 3 signers
    function addSignPerson(string memory _name) external{
        //verify less than 3 signers exist
        require(signers.length <= 2, "Only 3 signing addresses allowed");
        
        //verify new address is unique to existing rows
        if(signers.length > 0){
            for (uint i = 0; i <= signers.length-1; i++){
                require(signers[i].signAddress != msg.sender, "Cannot be the same as existing address");
            }
        }
        
        signers.push( SignPerson(_name, msg.sender) );
        
        //verify less than 4 signers exist
        assert(signers.length <= 3);
    }
    
    //function to delete signatory address
    //Potential Upgrade - have delete require 2 verified signatures for security purposes
    function deleteSignPerson(uint _index) external returns (uint) {
        //verify 3 signers currently exist
        require(signers.length == 3, "Cannot remove signer unless 3 total signers exist");
        require(_index < signers.length, "Selection must be in structure range");
        
        //verify signatory address
        require(verifySignPerson(msg.sender) == true, "Current address does not qualify");
        
        //remove address from structure
        for (uint i = _index; i < signers.length-1; i++){
            signers[i] = signers[i+1];
        }

        signers.pop();
        return signers.length;
    }
    
    //function to get signatory address structure
    function getSigner(uint _index) external view returns (SignPerson memory, uint){
        return (signers[_index], signers.length);
    }
    
    //function to verify current user is a valid signer
    function verifySignPerson(address _userAddress) internal view returns (bool){
        bool verifiedOne = false;
        
        if(signers.length > 0){
            for (uint i = 0; i <= signers.length-1; i++){
            if(signers[i].signAddress == _userAddress){
                verifiedOne = true;
                }
            }
        }
        return verifiedOne;
    }
    
    
    //Potential Upgrade - Have a whitelist of transfer/withdrawal addresses
    
}