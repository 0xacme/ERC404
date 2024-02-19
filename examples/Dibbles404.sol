//SPDX-License-Identifier: UNLICENSED

/**
 * Enabling a new era of Meme utility with the ERC404A, the most gas-optimized solution of ERC404.
 */

pragma solidity ^0.8.0;

import "../ERC404/ERC404A.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Dibbles404 is ERC404A {
    string public baseTokenURI;

    constructor(
        address _owner
    ) ERC404A("Dibbles 404", "ERRDB", 18, 10000, _owner) {
        balanceOf[_owner] = 10000 * 10 ** 18;
    }

    function setTokenURI(string memory _tokenURI) public onlyOwner {
        baseTokenURI = _tokenURI;
    }

    function setNameSymbol(
        string memory _name,
        string memory _symbol
    ) public onlyOwner {
        _setNameSymbol(_name, _symbol);
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        if (bytes(baseTokenURI).length > 0) {
            return string.concat(baseTokenURI, Strings.toString(id), ".json");
        }
        
        return "https://bafybeih4yfcubczmulmjdbsunc32n34ep5rs37ejewhcvvd2d2gsfzlpii.ipfs.nftstorage.link/errdb_soon.json";
    }
}
