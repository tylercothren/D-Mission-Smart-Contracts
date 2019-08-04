pragma solidity ^0.5.1;
import "./DMissionAccessControl.sol";

contract BlueprintBase is DMissionAccessControl {

    /*** EVENTS ***/

    event ManufacturedBlueprint(uint256 blueprintId, uint256 seriesId, string partName);

    event ManufacturedAttribute(uint256 attributetId, uint256 blueprintId, uint256 targetId, int128 affect);

    /*** DATA TYPES ***/

    struct Blueprint {
        uint256 seriesId;

        string partName;
    }

    struct Attribute {
        uint256 blueprintId;

        uint256 targetId;

        int128 affect;
    }

    /*** STORAGE ***/

    Blueprint[] blueprints;

    Attribute[] attributes;

    ///  Creates a new Blueprint and stores it.
    function _createBlueprint(
        uint256 _seriesId,
        string memory _partName
    )
        internal
        returns (uint)
    {
        Blueprint memory _blueprint = Blueprint({
            seriesId: uint32(_seriesId),
            partName: _partName
        });
        uint256 newBlueprintId = blueprints.push(_blueprint) - 1;

        // 4 billion limit case
        require(newBlueprintId == uint256(uint32(newBlueprintId)));

        // emit the manufacture event
        emit ManufacturedBlueprint(
            newBlueprintId,
            uint256(_blueprint.seriesId),
            _partName
        );

        return newBlueprintId;
    }

    ///  Creates a new Attribute and stores it.
    function _createAttribute(
        uint256 _blueprintId,
        uint256 _targetId,
        int128 _affect
    )
        internal
        returns (uint)
    {
        Attribute memory _attribute = Attribute({
            blueprintId: uint256(_blueprintId),
            targetId: uint256(_targetId),
            affect: int128(_affect)
        });
        uint256 newAttributeId = attributes.push(_attribute) - 1;

        // 4 billion limit case
        require(newAttributeId == uint256(uint32(newAttributeId)));

        // emit the manufacture event
        emit ManufacturedAttribute(
            newAttributeId,
            uint256(_attribute.blueprintId),
            uint256(_attribute.targetId),
            int128(_attribute.affect)
        );

        return newAttributeId;
    }

    ///  Creates new Blueprints in batch to save gas and stores it.
    function _batchCreateBlueprint(
        uint256[] memory _seriesIds,
        string[] memory _partNames
    )
        internal
        returns (uint[] memory)
    {
        Blueprint memory _blueprint;
        uint256[] memory newBlueprintIds;

        if (_seriesIds.length != _partNames.length){
            return newBlueprintIds;
        }

        for(uint256 i = 0; i < _seriesIds.length - 1; i++){

            _blueprint = Blueprint({
                seriesId: uint32(_seriesIds[i]),
                partName: _partNames[i]
            });

            newBlueprintIds[i] = blueprints.push(_blueprint) - 1;

            // 4 billion limit case
            require(newBlueprintIds[i] == uint256(uint32(newBlueprintIds[i])));

            // emit the manufacture event
            emit ManufacturedBlueprint(
                newBlueprintIds[i],
                uint256(_blueprint.seriesId),
                _blueprint.partName
            );
        }
        return newBlueprintIds;
    }

    ///  Creates new Attributes in batch to save gas and stores it.
    function _batchCreateAttribute(
        uint256[] memory _blueprintIds,
        uint256[] memory _targetIds,
        int128[] memory _affects
    )
        internal
        returns (uint[] memory)
    {
        Attribute memory _attribute;
        uint256[] memory newAttributeIds;

        if (_blueprintIds.length != _targetIds.length && _blueprintIds.length != _affects.length){
            return newAttributeIds;
        }

        for(uint256 i = 0; i < _blueprintIds.length - 1; i++){

            _attribute = Attribute({
                blueprintId: uint256(_blueprintIds[i]),
                targetId: uint256(_targetIds[i]),
                affect: int128(_affects[i])
            });

            newAttributeIds[i] = attributes.push(_attribute) - 1;

            // 4 billion limit case
            require(newAttributeIds[i] == uint256(uint32(newAttributeIds[i])));

            // emit the manufacture event
            emit ManufacturedAttribute(
                newAttributeIds[i],
                uint256(_attribute.blueprintId),
                uint256(_attribute.targetId),
                int128(_attribute.affect)
            );
        }
        return newAttributeIds;
    }
}