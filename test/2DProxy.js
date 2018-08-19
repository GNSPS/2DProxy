const NoConstructor = artifacts.require("NoConstructor");
const NoConstructor_ctor = artifacts.require("NoConstructor_ctor");
const NoConstructor_runtime = artifacts.require("NoConstructor_runtime");
const ConstructorNoParam = artifacts.require("ConstructorNoParam");
const ConstructorNoParam_ctor = artifacts.require("ConstructorNoParam_ctor");
const ConstructorNoParam_runtime = artifacts.require("ConstructorNoParam_runtime");
const ConstructorWithParam = artifacts.require("ConstructorWithParam");
const ConstructorWithParam_ctor = artifacts.require("ConstructorWithParam_ctor");
const ConstructorWithParam_runtime = artifacts.require("ConstructorWithParam_runtime");
const TwoDeeProxyFactory = artifacts.require("TwoDeeProxyFactory");

const utils = require('./helpers/Utils');


contract('2DProxy', function(accounts) {

  it("Verifies 2DProxy works with NoConstructor", async () => {

    let factory = await TwoDeeProxyFactory.new(accounts[0])

    let ctor = await NoConstructor_ctor.new(accounts[0])
    let runtime = await NoConstructor_runtime.new(accounts[0])

    let createProxyTx = await factory.createProxy(ctor.address, runtime.address)

    let proxyAddress
    for (let log of createProxyTx.logs) {
      if (log.event == "ProxyDeployed") {
        proxyAddress = log.args.proxyAddress
      }
    }

    let proxy = await NoConstructor.at(proxyAddress)

    let myNum = await proxy.getNum.call()

    assert(myNum.toNumber() == 12)

  });

  it("Verifies 2DProxy works with ConstructorNoParam", async () => {

    let factory = await TwoDeeProxyFactory.new(accounts[0])

    let ctor = await ConstructorNoParam_ctor.new(accounts[0])
    let runtime = await ConstructorNoParam_runtime.new(accounts[0])

    let createProxyTx = await factory.createProxy(ctor.address, runtime.address)

    let proxyAddress
    for (let log of createProxyTx.logs) {
      if (log.event == "ProxyDeployed") {
        proxyAddress = log.args.proxyAddress
      }
    }

    let proxy = await ConstructorNoParam.at(proxyAddress)

    let myNum = await proxy.getNum.call()

    assert(myNum.toNumber() == 73)

  });

  it("Verifies 2DProxy does *not* work with ConstructorWithParam", async () => {

    let factory = await TwoDeeProxyFactory.new(accounts[0])

    let ctor = await ConstructorWithParam_ctor.new(accounts[0])
    let runtime = await ConstructorWithParam_runtime.new(accounts[0])

    let createProxyTx = await factory.createProxy(ctor.address, runtime.address)

    let proxyAddress
    for (let log of createProxyTx.logs) {
      if (log.event == "ProxyDeployed") {
        proxyAddress = log.args.proxyAddress
      }
    }

    let proxy = await ConstructorWithParam.at(proxyAddress)

    let myNum = await proxy.getNum.call()

    assert(myNum.toNumber() == 0)

  });

});
