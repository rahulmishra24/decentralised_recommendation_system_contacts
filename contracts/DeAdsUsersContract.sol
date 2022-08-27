//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

interface DeAdsMainContract {
    function getTags() external view returns (string[] memory);

    function getRatingFromUser() external view returns (uint256);
}

contract DeAdsUsersContract {
    address DeAdsMainContractAdress;
    mapping(address => string[]) public userTagMap;
    uint256 constant USER_FEES = 0.3 ether;
    address admin;
    constructor(address _DeAdsMainContract) {
        admin = msg.sender;
        DeAdsMainContractAdress = _DeAdsMainContract;
    }

        modifier onlyAdmin() {
        require(msg.sender == admin, "ONLY_ADMIN");
        _;
    }

    function _addTags(string[] memory _userTags) internal {
        for (uint8 i = 0; i < _userTags.length; i++) {
            bool _isValid = _checkForValidTag(_userTags[i]);
            if (_isValid)
                userTagMap[msg.sender].push(_userTags[i]);
        }
    }

    function registerUser(string[] memory _tags) external payable {
        require(msg.value > USER_FEES, "Amount less than minimum fees");
         require(userTagMap[msg.sender].length == 0, "User already registered");
        _addTags(_tags);
    }

    function _checkForValidTag(string memory _ad) public view returns (bool) {
        string[] memory _validTags = DeAdsMainContract(DeAdsMainContractAdress)
            .getTags();
        for (uint8 i = 0; i < _validTags.length; i++) {
            if (keccak256(abi.encodePacked(_ad)) == keccak256(abi.encodePacked(_validTags[i])))
                return true;
        }
        return false;
    }

    function getUserTags(address _userAddress)
        external
        view
        returns (string[] memory)
    {
        return userTagMap[_userAddress];
    }

    function updateUser(string[] memory _newTags) external {
        require(userTagMap[msg.sender].length != 0, "User not registered");
        _addTags(_newTags);
    }

    function getRating(string memory _ad) external view {
        require(userTagMap[msg.sender].length != 0, "User not registered");
        require(_checkForValidTag(_ad), "Invalid ad id");
        // place holder to call getRatingFromUser
    }
}
