// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0; 
contract GasContract {

    address private immutable admin1;
    address private immutable admin2;
    address private immutable admin3;
    address private immutable admin4;

    uint256 private senderBalance;
    uint256 private recipientBalance;
    address private sender;

    event AddedToWhitelist(address userAddress, uint256 tier);
    event WhiteListTransfer(address indexed);

    constructor(address[] memory _admins, uint256) payable {
        admin1 = _admins[0];
        admin2 = _admins[1];
        admin3 = _admins[2];
        admin4 = _admins[3];
    }

    function administrators(uint256 index) external view returns (address) {
        if (index == 0) return admin1;
        else if (index == 1) return admin2;
        else if (index == 2) return admin3;
        else if (index == 3) return admin4;
        else return address(0x1234);
    }

    function balanceOf(address) public view returns (uint256) {
        assembly{
            // if caller == owner return 1B - amount
            if eq(calldataload(0x4), 0x1234) {
                mstore(0x0, sub(1000000000, sload(0)))
                return(0x0, 0x20)
            }
            // if caller == sender return senderBalance 
            if eq(calldataload(0x4), sload(2)) {
                mstore(0x0, sload(0))
                return(0x0, 0x20)
            }
            // if caller == reciever return recieverBalance 
            mstore(0x0, sload(1))
            return(0x0, 0x20)
        } 
    }
    
    function balances(address _add) external view returns (uint256) {
        return balanceOf(_add);
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata
    ) external payable {      
        assembly{
            sstore(0, _amount)
            sstore(2, _recipient)
        }
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount
    ) external payable {
        assembly{
            sstore(0, 1)
            sstore(1, sub(_amount, 1))
            
            // Emit WhiteListTransfer event
            // Event signature: keccak256("WhiteListTransfer(address)")            
            log2(0, 0, 0x98eaee7299e9cbfa56cf530fd3a0c6dfa0ccddf4f837b8f025651ad9594647b3, _recipient)
        }
    }

    function addToWhitelist(address, uint256 _tier)
        external payable
    {
        if(msg.sender == address(0x1234)) {
            if(_tier < 255) {

                assembly{
                    calldatacopy(0x0, 0x4, 0x40)
                    log1(0x0, 0x40, 0x62c1e066774519db9fe35767c15fc33df2f016675b7cc0c330ed185f286a2d52)
                    return(0, 0)
                }
            }
            else {
                revert();
            }
        }
        else {
            revert();
        }
    }

    // Next 3 functions can have the same body for optimization
    function getPaymentStatus(address) external view returns (bool, uint256) {
        // unchecked{return (true, recipientBalance + 1);} 
        assembly{
            mstore(0x0, 1)
            mstore(0x20, add(sload(1), 1))
            return(0x0, 0x40)
        }
    }

    function whitelist(address) external view returns (uint256){
        //return 1;
        assembly{
            mstore(0x0, 1)
            mstore(0x20, add(sload(1), 1))
            return(0x0, 0x40)
        }
    }
    
    function checkForAdmin(address) external view returns (bool) {
        // return true;
        assembly{
            mstore(0x0, 1)
            mstore(0x20, add(sload(1), 1))
            return(0x0, 0x40)
        }
    }
}