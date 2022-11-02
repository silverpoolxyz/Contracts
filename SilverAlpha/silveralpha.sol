// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract SilverAlpha is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address owner;

    uint MintMaxTotal = 100;
    uint MintMaxCount = 1;
    uint MintMinCount = 1;
    uint MintOneCost = 0.0066 ether;

    bool IsMinting = true;
    mapping(address => bool) public whiteLists;


    constructor() ERC721("Silver Alpha Test", "SAT") {
        owner = msg.sender;
        _tokenIds.increment();
    }

    function setWhiteLists(address _userAddress, bool _whiteState) public byOwner {
        whiteLists[_userAddress] = _whiteState;
    }


    function mint(address player) public returns (uint256) {
        require(IsMinting, "Stop Mint!");
        require(whiteLists[player], "No whiteList!");
        uint256 newItemId = _tokenIds.current();
        string memory tokenURI = getTokenURI(newItemId);
        require(MintMaxTotal >= newItemId, "Max overflow!");
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);
        _tokenIds.increment();
        return newItemId;
    }


    function setMintTotal(uint count) external byOwner {
        MintMaxTotal = count;
    }

    function checkoutMintState(bool state) external byOwner {
        IsMinting = state;
    }


    function contractURI() public pure returns (string memory) {
        return
            "https://raw.githubusercontent.com/silverpoolxyz/Contracts/main/SilverAlpha/contractURI.json";
    }

    function getTokenURI(uint256 index) private pure returns (string memory) {
        uint256 randomIndex = index;
        string memory randomIndexString = Strings.toString(randomIndex);
        string
            memory headerString = "https://raw.githubusercontent.com/silverpoolxyz/Contracts/main/SilverAlpha/json/";
        string memory footerString = ".json";
        string memory tokenURI = string.concat(
            headerString,
            randomIndexString,
            footerString
        );
        return tokenURI;
    }

    function withdraw() public payable byOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }

    modifier byOwner() {
        require(msg.sender == owner, "Must be owner!");
        _;
    }

}