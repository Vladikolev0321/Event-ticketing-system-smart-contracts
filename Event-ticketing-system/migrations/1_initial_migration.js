const EventManager = artifacts.require("EventManager");
const DEX = artifacts.require("DEX");

module.exports = function (deployer) {
  deployer.deploy(EventManager);
  deployer.deploy(DEX);
};
