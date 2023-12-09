// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Gallery is Ownable, ERC1155 {
    struct Artwork {
        string metadataURL;
        uint256 supply;
    }

    address public protocolFeeDestination;
    uint256 public protocolFeePercent;
    uint256 public artistFeePercent;
    uint256 public feePrecision = 1000;
    uint256 private tokenIdCounter = 0;
    uint256 public constant MAX_CHARACTERS = 888;

    mapping(uint256 => Artwork) public artworks;
    mapping(uint256 => address) public artworkOwners;
    mapping(uint256 => string) public artworkPrompts;
    mapping(address => uint256[]) public ownerData;

    uint256 public protocolEarnedFees;
    mapping(uint256 => uint256) public artistEarnedFees;
    mapping(address => uint256) public totalEarndFee;

    event Trade(
        address trader,
        uint256 tokenId,
        bool isBuy,
        uint256 ethAmount,
        uint256 protocolEthAmount,
        uint256 artistEthAmount,
        uint256 supply
    );
    event ArtworkMinted(uint256 tokenId, string metadataURL);

    constructor(
        address _feeDestination,
        uint256 _protocolFeePercent,
        uint256 _artistFeePercent,
        string memory _uri
    ) ERC1155(_uri) Ownable(msg.sender) {
        protocolFeeDestination = _feeDestination;
        protocolFeePercent = _protocolFeePercent;
        artistFeePercent = _artistFeePercent;
    }

    function setFeeDestination(address _feeDestination) public onlyOwner {
        protocolFeeDestination = _feeDestination;
    }

    function setProtocolFeePercent(uint256 _feePercent) public onlyOwner {
        protocolFeePercent = _feePercent;
    }

    function setArtistFeePercent(uint256 _feePercent) public onlyOwner {
        artistFeePercent = _feePercent;
    }

    function getTokenIdCounter() external view returns (uint256) {
        return tokenIdCounter;
    }

    function getPrice(uint256 supply, uint256 amount) public pure returns (uint256) {
        uint256 sum1 = supply == 0 ? 0 : (supply - 1) * (supply) * (2 * (supply - 1) + 1) / 6;
        uint256 sum2 = supply == 0 && amount == 1
            ? 0
            : (supply - 1 + amount) * (supply + amount) * (2 * (supply - 1 + amount) + 1) / 6;
        uint256 summation = sum2 - sum1;
        return summation * 1 ether / 1600;
    }

    function getBuyPrice(uint256 tokenId, uint256 amount) public view returns (uint256) {
        return getPrice(artworks[tokenId].supply, amount);
    }
    function getSellPrice(uint256 tokenId, uint256 amount) public view returns (uint256) {
        return getPrice(artworks[tokenId].supply, amount);
    }

    function getBuyPriceAfterFee(uint256 tokenId, uint256 amount) public view returns (uint256) {
        uint256 price = getBuyPrice(tokenId, amount);
        uint256 protocolFee = price * protocolFeePercent / feePrecision;
        uint256 artistFee = price * artistFeePercent / feePrecision;
        return price + protocolFee + artistFee;
    }

    function getSellPriceAfterFee(uint256 tokenId, uint256 amount) public view returns (uint256) {
        uint256 price = getSellPrice(tokenId, amount);
        uint256 protocolFee = price * protocolFeePercent / feePrecision;
        uint256 artistFee = price * artistFeePercent / feePrecision;
        return price - protocolFee - artistFee;
    }

    // Helper function to convert uint to string
    function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    /**
     * @dev Mints a new artwork.
     * @param text The text for the artwork.
     */
    function mintArtwork(string memory text) public payable returns (uint256) {
        require(bytes(text).length > 0, "Text cannot be empty");
        require(bytes(text).length <= MAX_CHARACTERS, "Text exceeds the maximum character limit");
        require(msg.value == 0.001 ether, "Minting fee is 0.001 ETH"); // Adjusted minting fee

        tokenIdCounter++;

        // Construct the metadataURL using "metadata" directory and token ID
        string memory metadataURL = string(abi.encodePacked("metadata/", uint2str(tokenIdCounter), ".json"));

        _mint(_msgSender(), tokenIdCounter, 1, "");
        artworks[tokenIdCounter] = Artwork(metadataURL, 1); // Set initial supply to 1
        artworkOwners[tokenIdCounter] = _msgSender();
        
        emit ArtworkMinted(tokenIdCounter, metadataURL);
        
        payable(owner()).transfer(msg.value); // Send the ETH to the contract owner
        artworkPrompts[tokenIdCounter] = text;
        ownerData[msg.sender].push(tokenIdCounter);

        return tokenIdCounter;
    }

    /**
     * @dev Buys a token from the marketplace.
     * @param tokenId The ID of the token.
     * @param amount The amount of tokens to buy.
     */
    function buyToken(uint256 tokenId, uint256 amount) public payable {
        require(artworks[tokenId].supply > 0, "Token supply should be greater than 0");

        uint256 price = getBuyPriceAfterFee(tokenId, amount);
        require(msg.value >= price, "Payment amount is less than the required price");

        uint256 protocolFee = price * protocolFeePercent / feePrecision;
        uint256 artistFee = price * artistFeePercent / feePrecision;

        _mint(_msgSender(), tokenId, amount, "");
        artworks[tokenId].supply += amount;
        totalEarndFee[artworkOwners[tokenId]] += artistFee;

        emit Trade(
            _msgSender(),
            tokenId,
            true,
            price,
            protocolFee,
            artistFee,
            artworks[tokenId].supply
        );

        payable(protocolFeeDestination).transfer(protocolFee);
        protocolEarnedFees += protocolFee;

        payable(artworkOwners[tokenId]).transfer(artistFee);
        artistEarnedFees[tokenId] += artistFee;
    }

    /**
     * @dev Sells a token on the marketplace.
     * @param tokenId The ID of the token.
     * @param amount The amount of tokens to sell.
     */
    function sellToken(uint256 tokenId, uint256 amount) public {
        require(artworks[tokenId].supply > 1, "Cannot sell the last token");
        require(balanceOf(_msgSender(), tokenId) > 0, "You don't have this token");

        uint256 price = getSellPriceAfterFee(tokenId, amount);
        uint256 protocolFee = price * protocolFeePercent / feePrecision;
        uint256 artistFee = price * artistFeePercent / feePrecision;

        _burn(_msgSender(), tokenId, amount);
        artworks[tokenId].supply -= amount;
        totalEarndFee[artworkOwners[tokenId]] += artistFee;
        emit Trade(
            _msgSender(),
            tokenId,
            false,
            price,
            protocolFee,
            artistFee,
            artworks[tokenId].supply
        );

        payable(protocolFeeDestination).transfer(protocolFee);
        protocolEarnedFees += protocolFee;

        payable(artworkOwners[tokenId]).transfer(artistFee);
        artistEarnedFees[tokenId] += artistFee;
        payable(_msgSender()).transfer(price);
    }

    /**
     * @dev Returns the total earned fees by the protocol.
     */
    function getProtocolEarnedFees() public view returns (uint256) {
        return protocolEarnedFees;
    }

    /**
     * @dev Returns the earned fees by the artist for a specific token.
     * @param tokenId The ID of the token.
     */
    function getArtistEarnedFees(uint256 tokenId) public view returns (uint256) {
        return artistEarnedFees[tokenId];
    }

    /**
     * @dev Returns the earned fees by the art creator.
     * @param creator The address of the art creator.
     */
    function getTotalEarndFees(address creator) public view returns (uint256) {
        return totalEarndFee[creator];
    }

    /**
     * @dev Returns the number of tokens owned by a user.
     * @param user The address of the user.
     */
    function getUserOwnCounts(address user) public view returns (uint256) {
        return ownerData[user].length;
    }
}
