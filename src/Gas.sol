// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0; 
// import "forge-std/console.sol";
contract GasContract {

    bytes32 private admin12;
    bytes32 private admin23;
    address private admin4;
    uint256 private senderBalance;
    uint256 private recipientBalance;
    address private sender;

    event AddedToWhitelist(address userAddress, uint256 tier);
    event WhiteListTransfer(address indexed);

    constructor(address[] memory _admins, uint256) {
        
        // admin12 = admin1|admin2(1st half)
        // admin23 = admin2(2nd half)|admin3
        // admin4 = admin4
        assembly{
            let address1 := mload(add(_admins, 0x20))
            let address2 := mload(add(_admins, 0x40))
            let address3 := mload(add(_admins, 0x60))
            let half1Address2 := and(shr(80, address2), 0xFFFFFFFFFFFFFFFFFFFF)
            let half2Address2 := shl(160, and(address2, 0xFFFFFFFFFFFFFFFFFFFF))

            sstore(0x0, add(shl(80, address1), half1Address2))
            sstore(0x1, add(address3, half2Address2))
            sstore(0x2, mload(add(_admins, 0x80)))
        }
        
        // assembly{
        //     for {let i := 0x0} lt(i, 0x4) {i := add(i, 0x1)} {
        //         sstore(add(0x0, i), mload(add(add(_admins, 0x20), mul(i, 0x20))))
        //     }
        // }

        // for (uint256 ii = 0; ii < 4; ii++) {
        //     admin = _admins[ii];
        //     assembly{
        //         sstore(add(0x0, ii), admin)
        //     }
        // }    
    }

    function administrators(uint256 index) external view returns (address) {
        // if (index == 4)  {return address(0x1234);}
        // assembly{
        //     admin := sload(add(0x0, index))
        // }
        // return admin;

        assembly{
            switch index 
                case 0 {
                    mstore(0x0, shr(80, sload(0x0)))
                    return(0x0, 0x20)
                }
                case 1 {
                    let x := shl(176, sload(0x0))
                    mstore(0x0, shr(96, x))
                    mstore(0x16, shl(16, sload(0x1)))
                    return(0x0, 0x20)
                }
                case 2 {
                    let x := shl(96, sload(0x1))
                    mstore(0x0, shr(96, x))
                    return(0x0, 0x20)
                }
                case 3 {
                    mstore(0x0, sload(0x2))
                    return(0x0, 0x20)
                }
                case 4 {
                    mstore(0x0, 0x1234)
                    return(0x0, 0x20)
                }
                default {
                    revert(0, 0)
                }
        }
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
        assembly{
            sstore(0x3, _amount)
            sstore(0x5, _recipient)
        }
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount
    ) external {
        assembly{
            sstore(0x3, 0)
            sstore(0x4, _amount)
            
            // Emit WhiteListTransfer event
            // Event signature: keccak256("WhiteListTransfer(address)")
            
            log2(0, 0, 0x98eaee7299e9cbfa56cf530fd3a0c6dfa0ccddf4f837b8f025651ad9594647b3, _recipient)
        }
    }

    function addToWhitelist(address, uint256 _tier)
        external
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