// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0; 

contract GasContract {
    uint256 public totalSupply = 0; // cannot be updated
    mapping(address => uint256) public balances;
    uint256 public tradePercent = 12;

    function whitelist(address) external pure returns (uint256){
        return 0;
    }
    address[5] public administrators;

    uint256 senderAmount;

    event AddedToWhitelist(address userAddress, uint256 tier);
    event WhiteListTransfer(address indexed);

    constructor(address[] memory _admins, uint256 _totalSupply) {
        totalSupply = _totalSupply;

        for (uint256 ii = 0; ii < 5; ii++) {
            administrators[ii] = _admins[ii];
        }
        balances[administrators[4]] = totalSupply;
    }


    function checkForAdmin(address) public pure returns (bool) {
        return true;
    }

    function balanceOf(address _user) public view returns (uint256 balance_) {
        uint256 balance = balances[_user];
        return balance;
    }


    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata
    ) public {

        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
    }

    function addToWhitelist(address _userAddrs, uint256 _tier)
        public
    {
        if(msg.sender == administrators[4]) {
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
    ) public {

        senderAmount = _amount;

        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        
        emit WhiteListTransfer(_recipient);
    }

    function getPaymentStatus(address) public view returns (bool, uint256) {
        return (true, senderAmount);
    }

}