//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// import "hardhat/console.sol";

interface DeAdsUsersContract {
    function getUserTags(address _userAddress)
        external
        view
        returns (string[] memory);
}

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

contract DeAdsMainContract {
    uint256 public totalCount = 1;
    address public admin;
    string[] public tags;
    address public DeAdsUserContractAddress;

    struct SupplierClicksStruct {
        string ad;
        uint256 score;
    }

    struct SupplierStruct {
        string tag;
        string ad;
        uint256 score;
    }

    struct UserAds {
        string ad;
        uint256 score;
    }

    struct Recommendation {
        string ad;
        uint256 score;
    }

    struct SupplierRecommendation {
        address supplier;
        Recommendation[] recommendations;
    }
    //sports => [{ad, score}, {ad, score}]
    mapping(string => SupplierRecommendation) recommendationMap;
    mapping(address => bool) public registerSupplierMap;
    mapping(address => uint256) public supplierClicksMap;
    mapping(uint256 => SupplierClicksStruct[]) public tagMap;
    // ad -> address -> supplier
    mapping(string => mapping(address => SupplierStruct)) public recommendMap;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "ONLY_ADMIN");
        _;
    }

    function setDeAdsUserContract(address _contractAddress) onlyAdmin external {
        DeAdsUserContractAddress = _contractAddress;
    }

    function strConcat(
        string memory _a,
        string memory _b,
        string memory _c,
        string memory _d,
        string memory _e
    ) internal pure returns (string memory) {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(
            _ba.length + _bb.length + _bc.length + _bd.length + _be.length
        );
        bytes memory babcde = bytes(abcde);
        uint256 k = 0;
        uint256 i;
        for (i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }

    // function setUserRecommendation(
    //     string memory _tag,
    //     string memory _ad,
    //     uint256 _correlationScore
    // ) external {
    //     SupplierRecommendation storage _sr = recommendationMap[_tag];
    //     require(registerSupplierMap[msg.sender] == true , "Invalid supplier");
    //     Recommendation memory _rm;
    //     _rm.ad = _ad;
    //     uint256 _supplierScore = getSupplierClickRate(msg.sender);
    //     if(_supplierScore == 0)
    //         _supplierScore = 1;
    //     _rm.score =
    //         ((_correlationScore * _supplierScore) * 100)/ totalCount;
    //     _sr.recommendations.push(_rm);
    // }

    function setUserRecommendation(string memory _tag, string memory _ad, uint256 _correlationScore) external {
        SupplierRecommendation storage _sr = recommendationMap[_tag];
        require(registerSupplierMap[msg.sender] == true , "Invalid supplier");
        Recommendation memory _rm;
        _rm.ad = _ad;
        uint _supplierScore = getSupplierClickRate(msg.sender);
        // Case if supplier is starting out
         if(_supplierScore == 0 &&  _sr.supplier == address(0))
           { _supplierScore = 1;
            _sr.supplier = msg.sender;
           }
        _rm.score = ((_correlationScore * _supplierScore) * 100)/ totalCount;
        _sr.recommendations.push(_rm);
         SupplierStruct memory s;
         s.tag = _tag;
         s.ad = _ad;
         s.score = _rm.score;
         recommendMap[_ad][msg.sender] = s;

    }

    function addNewTag(string memory _tag) external onlyAdmin {
        tags.push(_tag);
    }

    function getSupplierClickRate(address _supplier) public view returns (uint256) {
        return supplierClicksMap[_supplier];
    }

    function getTags() external view returns(string[] memory){
        return tags;
    }

    function setRatingForUser(
        string memory _tag,
        string memory _ad,
        address _supplier
    ) external {
        ++totalCount;
        string[] memory userTags = DeAdsUsersContract(DeAdsUserContractAddress)
            .getUserTags(msg.sender);
        for (uint8 i = 0; i < userTags.length; i++) {
            SupplierStruct memory s = recommendMap[_ad][_supplier];
            if (
                keccak256(abi.encodePacked(_ad)) ==
                keccak256(abi.encodePacked(s.ad)) &&
                keccak256(abi.encodePacked(_tag)) ==
                keccak256(abi.encodePacked(s.tag))
            ) {
                supplierClicksMap[_supplier]= ++supplierClicksMap[_supplier];
            }
        }
    }

    function registerSupplier(address _supplier) external onlyAdmin {
        registerSupplierMap[_supplier] = true;
    }

    function checkSupplierRegistration(address _supplier)
        external
        view
        returns (bool)
    {
        return (registerSupplierMap[_supplier]);
    }

    function getRecommendationFromSupplier(string memory _tag)
        public
        view
        returns (SupplierRecommendation memory)
    {
        return recommendationMap[_tag];
    }

    function getAdsForUser() external view returns (string[] memory) {
        string[] memory _tags = DeAdsUsersContract(DeAdsUserContractAddress)
            .getUserTags(msg.sender);
        string[] memory results = new string[](100);
        uint256 tempLength = 0;
        for (uint256 i = 0; i < _tags.length; i++) {
            SupplierRecommendation memory sr = getRecommendationFromSupplier(
                _tags[i]
            );
            for (uint256 j = 0; j < sr.recommendations.length; j++) {
                string memory tempAd = strConcat(
                    sr.recommendations[j].ad,
                    "+",
                    Strings.toString(sr.recommendations[j].score),
                    "",
                    ""
                );
                results[tempLength++] = (tempAd);
            }
        }
        return results;
    }
}
