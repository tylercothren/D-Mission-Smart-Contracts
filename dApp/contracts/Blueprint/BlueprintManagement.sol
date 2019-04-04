pragma solidity ^0.4.20;

import "./BlueprintBase.sol";

/// @title The facet of the Matchboxes! core contract that manages ownership, ERC-721 (draft) compliant.
/// @dev Ref: https://github.com/ethereum/EIPs/issues/721
contract BlueprintManagement is BlueprintBase {

    /// @notice Name and symbol of the non fungible token, as defined in ERC721.
    string public name = "D-Mission! [Blueprints]";
    string public symbol = "DMB";

    // bool public implementsERC721 = true;
    function implementsERC721() public pure returns (bool)
    {
        return true;
    }
    
    /**
    * @notice Guarantees msg.sender is owner of the given Blueprint
    * @param _tokenId uint256 ID of the Blueprint to validate its ownership belongs to msg.sender
    */
    modifier onlyOwnerOfBlueprint(uint256 _tokenId) {
        require(_ownsBlueprint(msg.sender, _tokenId));
        _;
    }

    function _ownsBlueprint(address _claimant, uint256 _tokenId) internal view returns (bool)
    {
        return blueprintIndexToOwner[_tokenId] == _claimant;
    }

    function _approvedForBlueprint(address _claimant, uint256 _tokenId) internal view returns (bool) 
    {
        return blueprintIndexToApproved[_tokenId] == _claimant;
    }

    function _approveBlueprint(uint256 _tokenId, address _approved) internal 
    {
        blueprintIndexToApproved[_tokenId] = _approved;
    }

    function transferBlueprint( address _to, uint256 _tokenId ) public whenNotPaused onlyOwnerOfBlueprint(_tokenId)
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));

        // Reassign ownership, clear pending approvals, emit Transfer event.
        _transferBlueprint(msg.sender, _to, _tokenId);
    }

    function approveBlueprint( address _to, uint256 _tokenId ) public whenNotPaused
    {
        // Register the approval (replacing any previous approval).
        _approveBlueprint(_tokenId, _to);

        // Emit approval event.
        Approval(msg.sender, _to, _tokenId);
    }

    /// @notice Transfer a Blueprint owned by another address, for which the calling address
    ///  has previously been granted transfer approval by the owner.
    /// @param _from The address that owns the Blueprint to be transfered.
    /// @param _to The address that should take ownership of the Blueprint. Can be any address,
    ///  including the caller.
    /// @param _tokenId The ID of the Blueprint to be transferred.
    /// @dev Required for ERC-721 compliance.
    function transferFromBlueprint( address _from, address _to, uint256 _tokenId ) public whenNotPaused onlyOwnerOfBlueprint(_tokenId)
    {
        // Reassign ownership (also clears pending approvals and emits Transfer event).
        Transfer(_from, _to, _tokenId);
    }

    /// @notice Returns the total number of Blueprints currently in existence.
    /// @dev Required for ERC-721 compliance.
    function totalSupply() public view returns (uint) {
        return blueprints.length - 1;
    }

    /// @notice Returns the address currently assigned ownership of a given Blueprint.
    /// @dev Required for ERC-721 compliance.
    function ownerOf(uint256 _tokenId) external view returns (address owner)
    {
        owner = blueprintIndexToOwner[_tokenId];

        require(owner != address(0));
    }

    function blueprintOfOwnerByIndex(address _owner, uint256 _index) external onlyCEO view returns (uint256 tokenId)
    {
        uint256 count = 0;
        for (uint256 i = 1; i <= totalSupply(); i++) {
            if (blueprintIndexToOwner[i] == _owner) {
                if (count == _index) {
                    return i;
                } else {
                    count++;
                }
            }
        }
        revert();
    }
}