const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules"); 

module.exports = buildModule("BaseTestModule", (m) => { 
const baseTest = m.contract("BaseTest", []); 

m.call(baseTest, "Status", []);
return { baseTest }; 
}); 