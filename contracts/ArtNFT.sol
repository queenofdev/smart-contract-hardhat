// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ArtNFT is ERC721 {
    uint256 public currentArtId = 1;  // Initialized to 1

    event ArtNFTCreated(
        address owner,
        uint256 artId
    );

    event TradeStatusChange(
        uint256 ad,
        string status
    );

    enum State { Open, Cancelled }

    struct Art {
        uint256 artId;
        address ownerAddress;
        string artName;
        uint256 artPrice;
        string ipfsHashOfArt;
        State status;
        uint256 reputation;
    }

    Art[] public arts;
    
    constructor() 
        ERC721("Ichiro-art-mint", "ArtNFT") 
    {
        // Additional setup can be done if needed
    }

    function mint(string memory tokenURI, uint256 artPrice, string memory artName) public returns (bool) {
        uint256 newArtId = currentArtId;

        _mint(msg.sender, newArtId);
        // Construct new Art struct and push it into the array
        Art memory newArt = Art({
            artId: newArtId,
            ownerAddress: msg.sender,
            artPrice: artPrice,
            artName: artName,
            ipfsHashOfArt: tokenURI,
            status: State.Cancelled,  // Initial status set to Cancelled
            reputation: 0
        });
        arts.push(newArt);

        emit ArtNFTCreated(msg.sender, newArtId);

        currentArtId++;

        return true;
    }

    function getArt(uint256 index) public view returns (Art memory) {
        require(index < arts.length, "Art does not exist");
        return arts[index];
    }

    function getAllArts() public view returns (Art[] memory) {
        return arts;
    }

    function openTrade(uint256 artId) public {
        Art storage art = arts[artId - 1];
        require(art.ownerAddress == msg.sender, "You do not own this art");
        require(ownerOf(artId) == msg.sender, "NFT must be owned by user");
        require(art.status == State.Cancelled, "Trade is not cancelable");

        art.status = State.Open;
        emit TradeStatusChange(artId, "Open");

        _transfer(msg.sender, address(this), artId);
    }

    function cancelTrade(uint256 artId) public {
        Art storage art = arts[artId - 1];
        require(art.ownerAddress == msg.sender, "You do not own this art");
        require(ownerOf(artId) == address(this), "Trade is not open");

        art.status = State.Cancelled;
        emit TradeStatusChange(artId, "Cancelled");

        _transfer(address(this), msg.sender, artId);
    }

    function buyNFT(uint256 artId) public payable returns (bool) {
        Art storage art = arts[artId - 1];
        address seller = art.ownerAddress;

        require(msg.value == art.artPrice, "Incorrect value");
        require(art.status == State.Open, "Art not for sale");

        art.ownerAddress = msg.sender;
        art.status = State.Cancelled;
        
        // Transfer NFT ownership to buyer
        _transfer(address(this), msg.sender, artId);
        
        // Transfer funds to seller
        payable(seller).transfer(msg.value);

        emit TradeStatusChange(artId, "Cancelled");

        return true;
    }
}
