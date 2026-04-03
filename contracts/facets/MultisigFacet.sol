// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// import {AppStorage} from "../libraries/AppStorage.sol";
import {AppStorage, MultisigProposal} from "../libraries/AppStorage.sol";
import {IDiamondCut} from "../interfaces/IDiamondCut.sol";

contract MultisigFacet {
    AppStorage internal s;

    event ProposalCreated(uint256 indexed proposalId, address indexed proposer);
    event ProposalApproved(uint256 indexed proposalId, address indexed signer);
    event ProposalExecuted(uint256 indexed proposalId);

    modifier onlySigner() {
        bool isSigner = false;
        for (uint256 i = 0; i < s.signers.length; i++) {
            if (s.signers[i] == msg.sender) {
                isSigner = true;
                break;
            }
        }
        require(isSigner, "Not a signer");
        _;
    }

    function addSigner(address signer) external {
        require(msg.sender == s.owner, "Not owner");
        s.signers.push(signer);
    }

    function setRequiredSignatures(uint256 required) external {
        require(msg.sender == s.owner, "Not owner");
        require(required <= s.signers.length, "Exceeds signer count");
        s.requiredSignatures = required;
    }

    function proposeDiamondCut(
        IDiamondCut.FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external onlySigner returns (uint256) {
        uint256 proposalId = s.proposalCount++;
        MultisigProposal storage proposal = s.proposals[proposalId];
        proposal.target = address(this);
        proposal.callData = abi.encodeWithSelector(
            IDiamondCut.diamondCut.selector,
            _diamondCut,
            _init,
            _calldata
        );
        proposal.executed = false;
        proposal.approvals = 0;
        emit ProposalCreated(proposalId, msg.sender);
        return proposalId;
    }

    function approveProposal(uint256 proposalId) external onlySigner {
        MultisigProposal storage proposal = s.proposals[proposalId];
        require(!proposal.executed, "Already executed");
        require(!proposal.approved[msg.sender], "Already approved");
        proposal.approved[msg.sender] = true;
        proposal.approvals += 1;
        emit ProposalApproved(proposalId, msg.sender);
    }

    function executeProposal(uint256 proposalId) external onlySigner {
        MultisigProposal storage proposal = s.proposals[proposalId];
        require(!proposal.executed, "Already executed");
        require(proposal.approvals >= s.requiredSignatures, "Not enough approvals");
        proposal.executed = true;
        (bool success, ) = proposal.target.call(proposal.callData);
        require(success, "Execution failed");
        emit ProposalExecuted(proposalId);
    }

    function getSigners() external view returns (address[] memory) {
        return s.signers;
    }

    function getProposalApprovals(uint256 proposalId) external view returns (uint256) {
        return s.proposals[proposalId].approvals;
    }
}