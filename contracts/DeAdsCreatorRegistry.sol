//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

interface DeAdsMainContract {
    function getTags() external view returns (string[] memory);

    function getRatingFromUser() external view returns (uint256);
}

contract DeAdsCreator {
    address public admin;
    address payable public DeAdsMainContractAdress;
    constructor(address payable _DeAdsMainContractAdress){
        admin = msg.sender;
        DeAdsMainContractAdress = _DeAdsMainContractAdress;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "ONLY_ADMIN");
        _;
    }

    struct Creator{
        address creator;
        string adHash;
        string tag;
        uint amount;
    }

    mapping(address => Creator[]) public creatorMapping;
    mapping(string => Creator[]) public tagMapping;
    mapping(address => bool) public registeredCreator;

    function registerCreator(address _creatorAddress) onlyAdmin public {
        registeredCreator[_creatorAddress] = true;
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

    function careateAd(string memory _tag, string memory _adHash) payable public {
        require(registeredCreator[msg.sender] == true, "Invalid creator");
        bool isValid = _checkForValidTag(_tag);
        require(isValid, "Invalid tag");
        Creator memory c;
        c.creator = msg.sender;
        c.adHash = _adHash;
        c.tag = _tag;
        c.amount = msg.value;

        creatorMapping[msg.sender].push(c);
        tagMapping[_tag].push(c);
        (DeAdsMainContractAdress).send(msg.value);

    }

    function getAdsByTag(string memory _tag) external view returns(Creator[] memory) {
        return tagMapping[_tag];
    }


}