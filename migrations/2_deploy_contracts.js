var NoConstructor = artifacts.require("NoConstructor");
var NoConstructor_ctor = artifacts.require("NoConstructor_ctor");
var NoConstructor_runtime = artifacts.require("NoConstructor_runtime");
var ConstructorNoParam = artifacts.require("ConstructorNoParam");
var ConstructorNoParam_ctor = artifacts.require("ConstructorNoParam_ctor");
var ConstructorNoParam_runtime = artifacts.require("ConstructorNoParam_runtime");
var ConstructorWithParam = artifacts.require("ConstructorWithParam");
var ConstructorWithParam_ctor = artifacts.require("ConstructorWithParam_ctor");
var ConstructorWithParam_runtime = artifacts.require("ConstructorWithParam_runtime");
var TwoDeeProxyFactory = artifacts.require("TwoDeeProxyFactory");

module.exports = function(deployer) {
  deployer.deploy(NoConstructor);
  deployer.deploy(NoConstructor_ctor);
  deployer.deploy(NoConstructor_runtime);
  deployer.deploy(ConstructorNoParam);
  deployer.deploy(ConstructorNoParam_ctor);
  deployer.deploy(ConstructorNoParam_runtime);
  deployer.deploy(ConstructorWithParam, 48);
  deployer.deploy(ConstructorWithParam_ctor);
  deployer.deploy(ConstructorWithParam_runtime);
  deployer.deploy(TwoDeeProxyFactory);
};