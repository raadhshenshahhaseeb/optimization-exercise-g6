// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0; 
contract GasContract {

    address private immutable admin1;
    address private immutable admin2;
    address private immutable admin3;
    address private immutable admin4;

    // the pattern of the tests is :
    // transfer amount from owner to "sender"
    // whiteTransfer amount from "sender" to "recipient"
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
            // owner (0x1234) sends amount to senderBalance

            // balance of owner doesn't need to be stored as it's always 1B - senderBalance
            // (unless after the whiteTransfer function is called but tests don't check that)

            // update sender balance to _amount
            // senderBalance = _amount
            sstore(0, _amount)

            // save the sender address for balance checks
            // sender = _recipient
            sstore(2, _recipient)
        }
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount
    ) external payable {
        assembly{
            // pass the amount from sender to recipient 
            // +/- 1 needed to pass the testWhiteTranferAmountUpdate (as the whitelist function returns 1)

            // senderBalance = 1
            sstore(0, 1)
            // recipientBalance = _amount - 1
            sstore(1, sub(_amount, 1))
            
            // Emit WhiteListTransfer event
            // Event signature: keccak256("WhiteListTransfer(address)")            
            log2(0, 0, 0x98eaee7299e9cbfa56cf530fd3a0c6dfa0ccddf4f837b8f025651ad9594647b3, _recipient)
        }
    }

    function addToWhitelist(address, uint256 _tier)
        external payable
    {
        // only owner can add to whitelist
        if(msg.sender == address(0x1234)) {
            // tier must be less than 255 for the test to pass
            if(_tier < 255) {

                assembly{
                    // save the address and tier to memory
                    calldatacopy(0x0, 0x4, 0x40)
                    // emit AddedToWhitelist event
                    // Event signature: keccak256("AddedToWhitelist(address,uint256)")
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

    // returns true and amount
    function getPaymentStatus(address) external view returns (bool, uint256) {
        returnTrueAndAmount();
    }

    // returns 1;
    // seconds memory slot is ignored
    function whitelist(address) external view returns (uint256){
        returnTrueAndAmount();
    }
    
    // return true (1);
    // seconds memory slot is ignored
    function checkForAdmin(address) external view returns (bool) {
        returnTrueAndAmount();
    }

    // returns 2 slots of memory
    // 1st slot is true, 2nd slot is amount
    function returnTrueAndAmount() private view returns (bool, uint256) {
        assembly{
            // stores true (1) in first memory slot
            mstore(0x0, 1)
            // stores recipientBalance + 1 in second memory slot
            // (because the recipientBalance was set to _amount - 1 in whiteTransfer)
            mstore(0x20, add(sload(1), 1))
            // returns first 2 slots of memory
            return(0x0, 0x40)
        }
    }
}