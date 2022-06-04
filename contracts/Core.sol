// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

contract Core {
    struct Item {
        address collector; // List of addresses that contain item's information, treat as metadata
        bytes32 signature; // List of signatures that return information on specific contracts
    }

    mapping(bytes32 => Item[]) internal items;

    event ItemIdentity(bytes32 indexed itemHash);

    modifier onlyExistingItems(bytes32 itemHash) {
        require(items[itemHash].length > 0, "Core: item does not exist");
        _;
    }

    function addIdentity(
        bytes32 saleId,
        uint256 itemIndex,
        address baseCollector,
        bytes32 baseSignature
    ) external returns (bytes32 itemHash) {
        // Build an item id hash based on sale ID and index that will be used for further lookups
        itemHash = keccak256(abi.encodePacked(saleId, itemIndex));

        _checkCollectorsAndSignatures(itemHash, baseCollector, baseSignature);

        Item memory itemInfo = Item(baseCollector, baseSignature);

        items[itemHash].push(itemInfo);

        emit ItemIdentity(itemHash);
    }

    function appendIdentity(
        bytes32 itemHash,
        address collector,
        bytes32 signature
    ) external onlyExistingItems(itemHash) {}

    function getIdentity(bytes32 itemHash)
        external
        view
        returns (address[] memory collectors, bytes32[] memory signatures)
    {
        Item[] memory itemInfo = items[itemHash];
        uint256 itemsLength = itemInfo.length;

        collectors = new address[](itemsLength);
        signatures = new bytes32[](itemsLength);

        for (uint256 i = 0; i < itemsLength; i++) {
            collectors[i] = itemInfo[i].collector;
            signatures[i] = itemInfo[i].signature;
        }
    }

    function _checkCollectorsAndSignatures(
        bytes32 itemHash,
        address newCollector,
        bytes32 newSignature
    ) private view {
        Item[] memory itemInfo = items[itemHash];
        uint256 itemsLength = itemInfo.length;

        // Check all `Item` structs for this item and check that no collector or signature
        // is the same as the new ones
        for (uint256 i = 0; i < itemsLength; i++) {
            require(itemInfo[i].collector != newCollector, "Core: collector exists for item");
            require(itemInfo[i].signature != newSignature, "Core: signature exists for item");
        }
    }
}
