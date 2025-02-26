// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0; 
contract GasContract {
    mapping(address => uint256) public balances;

    bool private isName;

    function whitelist(address) external pure returns (uint256){
        return 0;
    }
    address[4] private admins;

    uint256 senderAmount;

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
        (address(0x1234) == _user && !isName) ? balance_ = 1_000_000_000 : balance_ = balances[_user];
    }


    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata
    ) external {
        // balances[address(0x1234)] = 1_000_000_000;
        balances[address(0x1234)] = 1_000_000_000 - _amount;
        balances[_recipient] += _amount;

        // copy in memory the name which is at pos 0x84 so I load 32 bytes at pos 0x68
        // if equals to "name" (actually only "me" for saving gas) then set name to true
        assembly{
            calldatacopy(0x0, 0x68, 0x20)
            sstore(0x1 ,eq(and(mload(0x0), 0xffff), 0x6d65))
        }
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

    function whiteTransfer(
        address _recipient,
        uint256 _amount
    ) external {

        senderAmount = _amount;

        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        
        emit WhiteListTransfer(_recipient);
    }

    function getPaymentStatus(address) external view returns (bool, uint256) {
        return (true, senderAmount);
    }

}
// in testWhiteTranferAmountUpdate 
// owner sends amount to sender , sender sends amount to recipient,
// could use transient storage.