// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {ERC721} from "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {IProduceNFT} from "./IProduceNFT.sol";
import {ReentrancyGuardTransient} from "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuardTransient.sol";

/**
 * @title ProduceNFT
 * @notice ERC721-based NFT representing produced goods. Stores minimal product metadata
 *         on-chain and emits lifecycle events for off-chain indexing.
 */
contract ProduceNFT is ERC721URIStorage, IProduceNFT, ReentrancyGuardTransient {
    uint256 private _tokenIdCounter;

    // keep only primitive storage to avoid copying dynamic arrays from memory
    mapping(uint256 => string) private productExternalId;
    mapping(uint256 => address) private productProducer;
    mapping(uint256 => Status) private statuses;

    /**
     * @notice Construct a new `ProduceNFT` collection.
     * @param name_ ERC721 name.
     * @param symbol_ ERC721 symbol.
     */
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    /**
     * @inheritdoc IProduceNFT
     * @dev Mints an ERC721 token and emits `Minted` with the supplied product info.
     */
    function mint(ProductInfo calldata productInfo, string calldata tokenURI)
        external
        override
        nonReentrant
        returns (uint256 tokenId)
    {
        // Effects (CEI): assign tokenId and metadata before any external calls
        _tokenIdCounter += 1;
        tokenId = _tokenIdCounter;

        productExternalId[tokenId] = productInfo.externalId;
        productProducer[tokenId] = productInfo.producer;
        statuses[tokenId] = Status.CREATED;
        _setTokenURI(tokenId, tokenURI);

        // Interaction: _safeMint may call onERC721Received on the recipient
        _safeMint(msg.sender, tokenId);

        ProductInfo memory emitted = ProductInfo({
            externalId: productInfo.externalId, producer: productInfo.producer, attributes: new Attribute[](0)
        });
        emit Minted(msg.sender, tokenId, emitted);
    }

    /**
     * @inheritdoc IProduceNFT
     */
    function produced(uint256 tokenId) external override nonReentrant {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        statuses[tokenId] = Status.PRODUCED;
        emit Produced(tokenId);
    }

    /**
     * @inheritdoc IProduceNFT
     */
    function markSpoiled(uint256 tokenId, bytes calldata reason) external override nonReentrant {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        statuses[tokenId] = Status.LOST_DAMAGED;
        emit Spoiled(msg.sender, tokenId, reason);
    }

    /**
     * @inheritdoc IProduceNFT
     */
    function close(uint256 tokenId) external override nonReentrant {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        statuses[tokenId] = Status.CLOSED;
        emit Closed(tokenId);
    }

    /**
     * @inheritdoc IProduceNFT
     */
    function close(uint256 tokenId, ProductRating calldata rating) external override nonReentrant {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        statuses[tokenId] = Status.CLOSED;
        emit Closed(tokenId, rating);
    }

    /**
     * @inheritdoc IProduceNFT
     */
    function lostOrDamaged(uint256 tokenId) external override nonReentrant {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        statuses[tokenId] = Status.LOST_DAMAGED;
        emit LostOrDamaged(tokenId);
    }

    /**
     * @inheritdoc IProduceNFT
     */
    function getStatus(uint256 tokenId) external view override returns (Status) {
        return statuses[tokenId];
    }

    /**
     * @inheritdoc IProduceNFT
     */
    function getProductInfo(uint256 tokenId) external view override returns (ProductInfo memory) {
        ProductInfo memory info = ProductInfo({
            externalId: productExternalId[tokenId], producer: productProducer[tokenId], attributes: new Attribute[](0)
        });
        return info;
    }
}

