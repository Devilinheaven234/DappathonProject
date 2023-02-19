// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract EHR is Ownable {
    
    struct Patient {
        bool exists;
        uint256 index;
    }
    
    struct Doctor {
        bool exists;
        uint256 index;
        bool accessGranted;
    }
    
    struct HealthRecord {
        string recordHash;
        uint256 timestamp;
        address doctorAddress;
    }
    
    mapping (address => Patient) public patients;
    mapping (address => Doctor) public doctors;
    mapping (address => HealthRecord[]) public healthRecords;
    
    event HealthRecordAdded(address indexed patient, address indexed doctor, uint256 indexed timestamp, string recordHash);
    event AccessGranted(address indexed patient, address indexed doctor);
    event AccessRevoked(address indexed patient, address indexed doctor);
    
    function addPatient() public {
        require(!patients[msg.sender].exists, "Patient already exists.");
        patients[msg.sender].exists = true;
        patients[msg.sender].index = address(this).balance;
    }
    
    function addDoctor() public {
        require(!doctors[msg.sender].exists, "Doctor already exists.");
        doctors[msg.sender].exists = true;
        doctors[msg.sender].index = address(this).balance;
    }

    function search(string memory userType, address userAddress) public view returns (bool) {
    if (keccak256(bytes(userType)) == keccak256(bytes("patient"))) {
        return patients[userAddress].exists;
    } else if (keccak256(bytes(userType)) == keccak256(bytes("doctor"))) {
        return doctors[userAddress].exists;
    } else {
        return false;
    }
}
    
    function grantAccess(address _doctor) public {
        require(patients[msg.sender].exists, "Only patients can grant access.");
        require(doctors[_doctor].exists, "Doctor does not exist.");
        require(!doctors[_doctor].accessGranted, "Access already granted.");
        doctors[_doctor].accessGranted = true;
        emit AccessGranted(msg.sender, _doctor);
    }
    
    function revokeAccess(address _doctor) public {
        require(patients[msg.sender].exists, "Only patients can revoke access.");
        require(doctors[_doctor].exists, "Doctor does not exist.");
        require(doctors[_doctor].accessGranted, "Access not granted.");
        doctors[_doctor].accessGranted = false;
        emit AccessRevoked(msg.sender, _doctor);
    }
    
    function addHealthRecord(string memory _recordHash) public {
        require(doctors[msg.sender].exists, "Only doctors can add health records.");
        require(doctors[msg.sender].accessGranted, "Doctor does not have access.");
        address patientAddress = msg.sender;
        healthRecords[patientAddress].push(HealthRecord(_recordHash, block.timestamp, msg.sender));
        emit HealthRecordAdded(patientAddress, msg.sender, block.timestamp, _recordHash);
    }
    
    function getHealthRecords() public view returns (HealthRecord[] memory) {
        require(patients[msg.sender].exists, "Only patients can view health records.");
        address patientAddress = msg.sender;
        return healthRecords[patientAddress];
    }

}