// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0; 
contract GasContract {

    uint256 private senderBalance;
    uint256 private recipientBalance;

    address private sender;

    address[4] private admins;



    event AddedToWhitelist(address userAddress, uint256 tier);
    event WhiteListTransfer(address indexed);

    constructor(address[] memory _admins, uint256) {

        for (uint256 ii = 0; ii < 4; ii++) {
            admins[ii] = _admins[ii];
        }    
    }

    function administrators(uint256 index) external view returns (address) {
        return index == 4?  address(0x1234) : admins[index];
    }

    function checkForAdmin(address) external pure returns (bool) {
        return true;
    }

    function balanceOf(address _user) external view returns (uint256 balance_) {
        address(0x1234) == _user?
          (balance_ = 1_000_000_000 - senderBalance) 
           : _user == sender ? balance_ = senderBalance : balance_ = recipientBalance;
    }
    
    function balances(address _user) external view returns (uint256 balance_) {
        address(0x1234) == _user?
          (balance_ = 1_000_000_000 - senderBalance) 
           : _user == sender ? balance_ = senderBalance : balance_ = recipientBalance;
    }


    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata
    ) external {
        
        senderBalance = _amount;
        sender = _recipient;
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount
    ) external {

        senderBalance = 0;
        recipientBalance = _amount;
        emit WhiteListTransfer(_recipient);
    }

    function addToWhitelist(address _userAddrs, uint256 _tier)
        external
    {
        if(msg.sender == address(0x1234)) {
            if(_tier < 255) {

                emit AddedToWhitelist(_userAddrs, _tier);
            }
            else {
                revert();
            }
        }
        else {
            revert();
        }
    }

    function getPaymentStatus(address) external view returns (bool, uint256) {
        return (true, recipientBalance);
    }

    function whitelist(address) external pure returns (uint256){
        return 0;
    }
}
// in testWhiteTranferAmountUpdate 
// owner sends amount to sender , sender sends amount to recipient,
// could use transient storage.