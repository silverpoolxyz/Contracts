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
    uint MintOneCost = 0.0088 ether;

    bytes32 public root =
        "此处填入梅克尔树根";

    bool IsMinting = true;

    constructor() ERC721("SilverAlpha", "SA") {
        owner = msg.sender;
        _tokenIds.increment();
    }

    function mint(address player) private returns (uint256) {
        require(IsMinting, "Stop Mint!");
        uint256 newItemId = _tokenIds.current();
        string memory tokenURI = getTokenURI(newItemId);
        require(MintMaxTotal >= newItemId, "Max overflow!");
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);
        _tokenIds.increment();
        return newItemId;
    }

    function mintGuest(address player, uint times) external payable {
        require(msg.value >= MintOneCost * times, "ether not enough!");
        require(times <= MintMaxCount && times >= MintMinCount);
        for (uint key = 0; key < times; key++) {
            mint(player);
        }
    }

    function mintWhiteLists(address player, bytes32[] memory proof) external {
        require(isWhiteLists(proof, keccak256(abi.encodePacked(player))));
        for (uint key = 0; key < MintMaxCount; key++) {
            mint(player);
        }
    }

    function setMintTotal(uint count) external onlyOwner {
        MintMaxTotal = count;
    }

    function checkoutMintState(bool state) external onlyOwner {
        IsMinting = state;
    }

    function setMerkleTreeRoot(bytes32 _root) external onlyOwner {
        root = _root;
    }

    function isWhiteLists(bytes32[] memory proof, bytes32 leaf)
        private
        view
        returns (bool)
    {
        return MerkleProof.verify(proof, root, leaf);
    }

    function contractURI() public pure returns (string memory) {
        return
            "https://raw.githubusercontent.com/silverpoolxyz/Contracts/main/SilverAlpha/contractURI.json";
    }

    function getTokenURI(uint256 index) private pure returns (string memory) {
        uint256 randomIndex = index;
        string memory randomIndexString = Strings.toString(randomIndex);
        string
            memory headerString = "这里是metadata";
        string memory footerString = ".json";
        string memory tokenURI = string.concat(
            headerString,
            randomIndexString,
            footerString
        );
        return tokenURI;
    }

    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Must be owner!");
        _;
    }
}