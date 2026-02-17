// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAIProject {
    function createProject(string calldata _name, string calldata _description, uint256 _target) external payable;
    function vote(uint256 _projectId) external;
    function getProject(uint256 _projectId) external view returns (string memory, string memory, uint256);
}

contract AICommunityPlatform {
    mapping(uint256 => Project) private projects;
    mapping(address => uint256[]) private userTokens;

    struct Project {
        string name;
        string description;
        uint256 target;
        uint256 raised;
        uint256 deadline;
        address[] contributors;
    }

    event ProjectCreated(uint256 indexed projectId, string name, string description, uint256 target);
    event Contribution(address indexed contributor, uint256 indexed projectId, uint256 amount);

    function createProject(string calldata _name, string calldata _description, uint256 _target) external {
        require(msg.value > 0, "Must send funds");
        
        Project storage newProject = projects[projects.length];
        newProject.name = _name;
        newProject.description = _description;
        newProject.target = _target;
        newProject.raised += msg.value;
        newProject.deadline = block.timestamp + 30 days; // 30-day deadline
        newProject.contributors.push(msg.sender);

        emit ProjectCreated(projects.length, _name, _description, _target);
    }

    function contribute(uint256 _projectId) external payable {
        require(_projectId < projects.length, "Invalid project ID");
        Project storage p = projects[_projectId];
        require(block.timestamp < p.deadline, "Project deadline passed");
        
        p.raised += msg.value;
        p.contributors.push(msg.sender);
        
        emit Contribution(msg.sender, _projectId, msg.value);
    }

    function withdraw(uint256 _projectId) external {
        require(_projectId < projects.length, "Invalid project ID");
        Project storage p = projects[_projectId];
        require(block.timestamp >= p.deadline && msg.sender == p.contributors[0], "Not eligible to withdraw");
        
        (bool sent, ) = payable(p.contributors[0]).call{value: p.raised}("");
        require(sent, "Failed to send funds");
    }

    function getProject(uint256 _projectId) external view returns (string memory name, string memory description, uint256 target) {
        Project storage p = projects[_projectId];
        return (p.name, p.description, p.target);
    }
}